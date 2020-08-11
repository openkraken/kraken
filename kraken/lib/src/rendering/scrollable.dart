/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';
import 'ticker_provider.dart';

typedef ScrollListener = void Function(double scrollOffset, AxisDirection axisDirection);

class RenderSingleViewPortParentData extends ContainerBoxParentData<RenderBox> {}

class KrakenScrollable with CustomTickerProviderStateMixin implements ScrollContext {
  AxisDirection _axisDirection;
  ScrollPosition position;
  ScrollPhysics _physics = BouncingScrollPhysics();
  DragStartBehavior dragStartBehavior;
  ScrollListener scrollListener;

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
    assert(_recognizers != null);
    for (GestureRecognizer recognizer in _recognizers.values) {
      recognizer.addPointer(event);
    }
  }

  @override
  AxisDirection get axisDirection => _axisDirection;

  // This field is set during layout, and then reused until the next time it is set.
  Map<Type, GestureRecognizerFactory> _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
  Map<Type, GestureRecognizer> _recognizers = const <Type, GestureRecognizer>{};
  bool _lastCanDrag;
  Axis _lastAxisDirection;

  @override
  void setCanDrag(bool canDrag) {
    if (canDrag == _lastCanDrag && (!canDrag || axis == _lastAxisDirection)) return;
    if (!canDrag) {
      _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
    } else {
      switch (axis) {
        case Axis.vertical:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
              (VerticalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..dragStartBehavior = dragStartBehavior;
              },
            ),
          };
          break;
        case Axis.horizontal:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
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

  void _syncAll(Map<Type, GestureRecognizerFactory> gestures) {
    assert(_recognizers != null);
    final Map<Type, GestureRecognizer> oldRecognizers = _recognizers;
    _recognizers = <Type, GestureRecognizer>{};
    for (Type type in gestures.keys) {
      assert(gestures[type] != null);
      assert(!_recognizers.containsKey(type));
      _recognizers[type] = oldRecognizers[type] ?? gestures[type].constructor();
      assert(_recognizers[type].runtimeType == type,
          'GestureRecognizerFactory of type $type created a GestureRecognizer of type ${_recognizers[type].runtimeType}. The GestureRecognizerFactory must be specialized with the type of the class that it returns from its constructor method.');
      gestures[type].initializer(_recognizers[type]);
    }
    for (Type type in oldRecognizers.keys) {
      if (!_recognizers.containsKey(type)) oldRecognizers[type].dispose();
    }
  }

  // TOUCH HANDLERS

  Drag _drag;
  ScrollHoldController _hold;

  void _handleDragDown(DragDownDetails details) {
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position.drag(details, _disposeDrag);
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
  void setSemanticsActions(Set<SemanticsAction> actions) {}

  @override
  TickerProvider get vsync => this;
}

mixin RenderOverflowMixin on RenderBox {
  AxisDirection XAxis;
  AxisDirection YAxis;
  ScrollListener scrollListener;

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

  Size _scrollableSize;

  ViewportOffset get scrollOffsetX => _scrollOffsetX;
  ViewportOffset _scrollOffsetX;
  set scrollOffsetX(ViewportOffset value) {
    assert(value != null);
    if (value == _scrollOffsetX) return;
    _scrollOffsetX = value;
    _scrollOffsetX.removeListener(_scrollXListener);
    _scrollOffsetX.addListener(_scrollXListener);
    markNeedsLayout();
  }

  ViewportOffset get scrollOffsetY => _scrollOffsetY;
  ViewportOffset _scrollOffsetY;
  set scrollOffsetY(ViewportOffset value) {
    assert(value != null);
    if (value == _scrollOffsetY) return;
    _scrollOffsetY = value;
    _scrollOffsetY.removeListener(_scrollYListener);
    _scrollOffsetY.addListener(_scrollYListener);
    markNeedsLayout();
  }

  void _scrollXListener() {
    assert(scrollListener != null);
    scrollListener(scrollOffsetX.pixels, AxisDirection.right);
    markNeedsPaint();
  }

  void _scrollYListener() {
    assert(scrollListener != null);
    scrollListener(scrollOffsetY.pixels, AxisDirection.down);
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
    _scrollOffsetX.applyViewportDimension(size.width);
    _scrollOffsetX.applyContentDimensions(0.0, _scrollableSize.width - size.width);
  }

  void _setUpScrollY() {
    _scrollOffsetY.applyViewportDimension(size.height);
    _scrollOffsetY.applyContentDimensions(0.0, _scrollableSize.height - size.height);
  }

  void setUpOverflowScroller(Size scrollableSize) {
    _scrollableSize = scrollableSize;
    if (_clipX && _scrollOffsetX != null) {
      _setUpScrollX();
    }

    if (_clipY && _scrollOffsetY != null) {
      _setUpScrollY();
    }
  }

  double get _paintOffsetX {
    if (_scrollOffsetX == null) return 0.0;
    return -_scrollOffsetX.pixels;
  }
  double get _paintOffsetY {
    if (_scrollOffsetY == null) return 0.0;
    return -_scrollOffsetY.pixels;
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset, Size childSize) {
    return paintOffset < Offset.zero || !(Offset.zero & size).contains((paintOffset & childSize).bottomRight);
  }

  // @TODO implement RenderSilver protocol to achieve high performance scroll list.
  void paintOverflow(PaintingContext context, Offset offset, EdgeInsets borderEdge, PaintingContextCallback callback) {
    if (clipX == false && clipY == false) return callback(context, offset);
    final double paintOffsetX = _paintOffsetX;
    final double paintOffsetY = _paintOffsetY;
    final Offset paintOffset = Offset(paintOffsetX, paintOffsetY);
    // Overflow should not cover border
    Rect clipRect = Offset.zero & Size(
      size.width - borderEdge.right,
      size.height - borderEdge.bottom,
    );
    if (_shouldClipAtPaintOffset(paintOffset, size)) {
      context.pushClipRect(needsCompositing, offset, clipRect, (PaintingContext context, Offset offset) {
        callback(context, offset + paintOffset);
      });
    } else {
      callback(context, offset);
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double result;
    final RenderSingleViewPortParentData childParentData = parentData;
    double candidate = getDistanceToActualBaseline(baseline);
    if (candidate != null) {
      candidate += childParentData.offset.dy;
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
  Rect describeApproximatePaintClip(RenderObject child) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    if (child != null && _shouldClipAtPaintOffset(paintOffset, size)) return Offset.zero & size;
    return null;
  }
}
