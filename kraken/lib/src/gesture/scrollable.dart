/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'gesture_detector.dart';
import 'monodrag.dart';
import 'scroll_activity.dart';
import 'scroll_context.dart';
import 'scroll_physics.dart';
import 'scroll_position.dart';
import 'scroll_position_with_single_context.dart';

typedef ScrollListener = void Function(double scrollOffset, AxisDirection axisDirection);

mixin _CustomTickerProviderStateMixin implements TickerProvider {
  Set<Ticker>? _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= <_CustomTicker>{};
    final _CustomTicker result = _CustomTicker(onTick, this, debugLabel: 'created by $this');
    _tickers!.add(result);
    return result;
  }

  void _removeTicker(_CustomTicker ticker) {
    assert(_tickers != null);
    assert(_tickers!.contains(ticker));
    _tickers!.remove(ticker);
  }
}

// This class should really be called _DisposingTicker or some such, but this
// class name leaks into stack traces and error messages and that name would be
// confusing. Instead we use the less precise but more anodyne "_WidgetTicker",
// which attracts less attention.
class _CustomTicker extends Ticker {
  _CustomTicker(TickerCallback onTick, this._creator, {String? debugLabel}) : super(onTick, debugLabel: debugLabel);

  final _CustomTickerProviderStateMixin _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}

class KrakenScrollable with _CustomTickerProviderStateMixin implements ScrollContext {
  late AxisDirection _axisDirection;
  ScrollPosition? position;
  final ScrollPhysics _physics = ScrollPhysics.createScrollPhysics();
  DragStartBehavior dragStartBehavior;
  ScrollListener? scrollListener;

  KrakenScrollable({
    AxisDirection axisDirection = AxisDirection.down,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollListener,
  }) {
    _axisDirection = axisDirection;
    position = ScrollPositionWithSingleContext(physics: _physics, context: this, oldPosition: null);
  }

  /// The axis along which the scroll view scrolls.
  ///
  /// Determined by the [axisDirection].
  Axis get axis => axisDirectionToAxis(_axisDirection);

  void handlePointerDown(PointerDownEvent event) {
    for (GestureRecognizer? recognizer in _recognizers.values) {
      recognizer!.addPointer(event);
    }
  }

  @override
  AxisDirection get axisDirection => _axisDirection;

  // This field is set during layout, and then reused until the next time it is set.
  Map<Type, GestureRecognizerFactory> _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
  Map<Type, GestureRecognizer?> _recognizers = const <Type, GestureRecognizer?>{};
  bool? _lastCanDrag;
  Axis? _lastAxisDirection;

  @override
  void setCanDrag(bool canDrag) {
    if (canDrag == _lastCanDrag && (!canDrag || axis == _lastAxisDirection)) return;
    if (!canDrag) {
      _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
    } else {
      switch (axis) {
        case Axis.vertical:
        // Vertical trag gesture recongnizer to trigger vertical scroll.
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            ScrollVerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScrollVerticalDragGestureRecognizer>(
              () => ScrollVerticalDragGestureRecognizer(),
              (ScrollVerticalDragGestureRecognizer instance) {
                instance
                  ..isAcceptedDrag = _isAcceptedVerticalDrag
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics.minFlingDistance
                  ..minFlingVelocity = _physics.minFlingVelocity
                  ..maxFlingVelocity = _physics.maxFlingVelocity
                  ..dragStartBehavior = dragStartBehavior;
              },
            ),
          };
          break;
        case Axis.horizontal:
          // Horizontal trag gesture recongnizer to horizontal vertical scroll.
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            ScrollHorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScrollHorizontalDragGestureRecognizer>(
              () => ScrollHorizontalDragGestureRecognizer(),
              (ScrollHorizontalDragGestureRecognizer instance) {
                instance
                  ..isAcceptedDrag = _isAcceptedHorizontalDrag
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics.minFlingDistance
                  ..minFlingVelocity = _physics.minFlingVelocity
                  ..maxFlingVelocity = _physics.maxFlingVelocity
                  ..dragStartBehavior = dragStartBehavior;
              },
            ),
          };
          break;
      }
    }
    _lastCanDrag = canDrag;
    _lastAxisDirection = axis;
    _syncAll(_gestureRecognizers);
  }

  // Used in the Arena to judge whether the vertical trag gesture can trigger the current container to scroll.
  bool _isAcceptedVerticalDrag (AxisDirection direction) {
    double? pixels = (_drag as ScrollDragController).pixels;
    double? maxScrollExtent = (_drag as ScrollDragController).maxScrollExtent;
    double? minScrollExtent = (_drag as ScrollDragController).minScrollExtent;
    return !((direction == AxisDirection.down && pixels! <= minScrollExtent!) || direction == AxisDirection.up && pixels! >= maxScrollExtent!);
  }

  // Used in the Arena to judge whether the horizontal trag gesture can trigger the current container to scroll.
  bool _isAcceptedHorizontalDrag (AxisDirection direction) {
    double? pixels = (_drag as ScrollDragController).pixels;
    double? maxScrollExtent = (_drag as ScrollDragController).maxScrollExtent;
    double? minScrollExtent = (_drag as ScrollDragController).minScrollExtent;
    return !((direction == AxisDirection.right && pixels! <= minScrollExtent!) || direction == AxisDirection.left && pixels! >= maxScrollExtent!);
  }

  void _syncAll(Map<Type, GestureRecognizerFactory> gestures) {
    final Map<Type, GestureRecognizer?> oldRecognizers = _recognizers;
    _recognizers = <Type, GestureRecognizer?>{};
    for (Type type in gestures.keys) {
      assert(gestures[type] != null);
      assert(!_recognizers.containsKey(type));
      _recognizers[type] = oldRecognizers[type] ?? gestures[type]!.constructor();
      assert(_recognizers[type].runtimeType == type,
          'GestureRecognizerFactory of type $type created a GestureRecognizer of type ${_recognizers[type].runtimeType}. The GestureRecognizerFactory must be specialized with the type of the class that it returns from its constructor method.');
      gestures[type]!.initializer(_recognizers[type]);
    }
    for (Type type in oldRecognizers.keys) {
      if (!_recognizers.containsKey(type)) oldRecognizers[type]!.dispose();
    }
  }

  // TOUCH HANDLERS

  Drag? _drag;
  ScrollHoldController? _hold;

  void _handleDragDown(DragDownDetails details) {
    assert(_drag == null);
    assert(_hold == null);
    _hold = position!.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position!.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.end(details);
    assert(_drag == null);
  }

  void _handleDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  @override
  void setSemanticsActions(Set<SemanticsAction?>? actions) {}

  @override
  TickerProvider get vsync => this;
}

mixin RenderOverflowMixin on RenderBox {
  ScrollListener? scrollListener;
  void Function(PointerEvent)? scrollablePointerListener;

  void disposeScrollable() {
    scrollListener = null;
    scrollablePointerListener = null;
    _scrollOffsetX = null;
    _scrollOffsetY = null;
    // Dispose clip layer.
    _clipRRectLayer.layer = null;
    _clipRectLayer.layer = null;
  }

  bool _clipX = false;
  bool get clipX => _clipX;
  set clipX(bool value) {
    if (_clipX == value) return;
    _clipX = value;
    markNeedsLayout();
  }

  bool _clipY = false;
  bool get clipY => _clipY;
  set clipY(bool value) {
    if (_clipY == value) return;
    _clipY = value;
    markNeedsLayout();
  }

  bool _enableScrollX = false;
  bool get enableScrollX => _enableScrollX;
  set enableScrollX(bool value) {
    if (_enableScrollX == value) return;
    _enableScrollX = value;
  }

  bool _enableScrollY = false;
  bool get enableScrollY => _enableScrollY;
  set enableScrollY(bool value) {
    if (_enableScrollY == value) return;
    _enableScrollY = value;
  }

  Size? _scrollableSize;
  Size? _viewportSize;

  ViewportOffset? get scrollOffsetX => _scrollOffsetX;
  ViewportOffset? _scrollOffsetX;
  set scrollOffsetX(ViewportOffset? value) {
    if (value == _scrollOffsetX) return;
    _scrollOffsetX?.removeListener(_scrollXListener);
    _scrollOffsetX = value;
    _scrollOffsetX?.addListener(_scrollXListener);
    markNeedsLayout();
  }

  ViewportOffset? get scrollOffsetY => _scrollOffsetY;
  ViewportOffset? _scrollOffsetY;
  set scrollOffsetY(ViewportOffset? value) {
    if (value == _scrollOffsetY) return;
    _scrollOffsetY?.removeListener(_scrollYListener);
    _scrollOffsetY = value;
    _scrollOffsetY?.addListener(_scrollYListener);
    markNeedsLayout();
  }

  void _scrollXListener() {
    assert(scrollListener != null);
    scrollListener!(scrollOffsetX!.pixels, AxisDirection.right);
    markNeedsPaint();
  }

  void _scrollYListener() {
    assert(scrollListener != null);
    scrollListener!(scrollOffsetY!.pixels, AxisDirection.down);
    markNeedsPaint();
  }

  BoxConstraints deflateOverflowConstraints(BoxConstraints constraints) {
    BoxConstraints result = constraints;
    if (_clipX && _clipY) {
      result = BoxConstraints();
    } else if (_clipX) {
      result = BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    } else if (_clipY) {
      result = BoxConstraints(minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
    }
    return result;
  }

  void _setUpScrollX() {
    _scrollOffsetX!.applyViewportDimension(_viewportSize!.width);
    _scrollOffsetX!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.width - _viewportSize!.width));
  }

  void _setUpScrollY() {
    _scrollOffsetY!.applyViewportDimension(_viewportSize!.height);
    _scrollOffsetY!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.height - _viewportSize!.height));
  }

  void setUpOverflowScroller(Size scrollableSize, Size viewportSize) {
    _scrollableSize = scrollableSize;
    _viewportSize = viewportSize;
    if (_clipX && _scrollOffsetX != null) {
      _setUpScrollX();
    }

    if (_clipY && _scrollOffsetY != null) {
      _setUpScrollY();
    }
  }

  double get _paintOffsetX {
    if (_scrollOffsetX == null) return 0.0;
    return -_scrollOffsetX!.pixels;
  }
  double get _paintOffsetY {
    if (_scrollOffsetY == null) return 0.0;
    return -_scrollOffsetY!.pixels;
  }

  double get scrollTop {
    if (_scrollOffsetY == null) return 0.0;
    return _scrollOffsetY!.pixels;
  }

  double get scrollLeft {
    if (_scrollOffsetX == null) return 0.0;
    return _scrollOffsetX!.pixels;
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset, Size childSize) {
    return paintOffset < Offset.zero || !(Offset.zero & size).contains((paintOffset & childSize).bottomRight);
  }

  final LayerHandle<ClipRRectLayer> _clipRRectLayer = LayerHandle<ClipRRectLayer>();
  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  void paintOverflow(PaintingContext context, Offset offset, EdgeInsets borderEdge, BoxDecoration? decoration, PaintingContextCallback callback) {
    if (clipX == false && clipY == false) return callback(context, offset);
    final double paintOffsetX = _paintOffsetX;
    final double paintOffsetY = _paintOffsetY;
    final Offset paintOffset = Offset(paintOffsetX, paintOffsetY);
    // Overflow should not cover border
    Rect clipRect = Offset(borderEdge.left, borderEdge.top) & Size(
      size.width - borderEdge.right - borderEdge.left,
      size.height - borderEdge.bottom - borderEdge.top,
    );
    if (_shouldClipAtPaintOffset(paintOffset, size)) {
      // ignore: prefer_function_declarations_over_variables
      PaintingContextCallback painter = (PaintingContext context, Offset offset) {
        callback(context, offset + paintOffset);
      };

      // It needs to create new layer to clip children in case children has its own layer
      // for all overflow value which is not visible (auto/scroll/hidden/clip).
      bool _needsCompositing = true;

      if (decoration != null && decoration.borderRadius != null) {
        BorderRadius radius = decoration.borderRadius as BorderRadius;
        RRect clipRRect = RRect.fromRectAndCorners(clipRect,
            topLeft: radius.topLeft,
            topRight: radius.topRight,
            bottomLeft: radius.bottomLeft,
            bottomRight: radius.bottomRight
        );
        _clipRRectLayer.layer = context.pushClipRRect(_needsCompositing, offset, clipRect, clipRRect, painter, oldLayer: _clipRRectLayer.layer);
      } else {
        _clipRectLayer.layer = context.pushClipRect(_needsCompositing, offset, clipRect, painter, oldLayer: _clipRectLayer.layer);
      }
    } else {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = null;
      callback(context, offset);
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    double? result;
    final BoxParentData? childParentData = parentData as BoxParentData?;
    double? candidate = getDistanceToActualBaseline(baseline);
    if (candidate != null) {
      candidate += childParentData!.offset.dy;
      if (result != null)
        result = math.min(result, candidate);
      else
        result = candidate;
    }
    return result;
  }

  void applyOverflowPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    if (_shouldClipAtPaintOffset(paintOffset, size)) return Offset.zero & size;
    return null;
  }

  void debugOverflowProperties(DiagnosticPropertiesBuilder properties) {
    if (_scrollableSize != null) properties.add(DiagnosticsProperty('scrollableSize', _scrollableSize));
    if (_viewportSize != null) properties.add(DiagnosticsProperty('viewportSize', _viewportSize));
    properties.add(DiagnosticsProperty('clipX', clipX));
    properties.add(DiagnosticsProperty('clipY', clipY));
  }
}
