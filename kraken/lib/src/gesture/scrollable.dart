/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'gesture_detector.dart';
import 'monodrag.dart';
import 'scroll_activity.dart';
import 'scroll_context.dart';
import 'scroll_physics.dart';
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
  ScrollPositionWithSingleContext? position;
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
          // Vertical drag gesture recognizer to trigger vertical scroll.
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
          // Horizontal drag gesture recognizer to horizontal vertical scroll.
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

  // Used in the Arena to judge whether the vertical drag gesture can trigger the current container to scroll.
  bool _isAcceptedVerticalDrag(AxisDirection direction) {
    ScrollDragController drag = _drag!;
    double pixels = drag.pixels!;
    double maxScrollExtent = drag.maxScrollExtent!;
    double minScrollExtent = drag.minScrollExtent!;

    return !((direction == AxisDirection.down && (pixels <= minScrollExtent || nearEqual(pixels, minScrollExtent, Tolerance.defaultTolerance.distance)))
        || direction == AxisDirection.up && (pixels >= maxScrollExtent || nearEqual(pixels, maxScrollExtent, Tolerance.defaultTolerance.distance)));
  }

  // Used in the Arena to judge whether the horizontal drag gesture can trigger the current container to scroll.
  bool _isAcceptedHorizontalDrag(AxisDirection direction) {
    ScrollDragController drag = _drag!;
    double pixels = drag.pixels!;
    double maxScrollExtent = drag.maxScrollExtent!;
    double minScrollExtent = drag.minScrollExtent!;
    return !((direction == AxisDirection.right && (pixels <= minScrollExtent || nearEqual(pixels, minScrollExtent, Tolerance.defaultTolerance.distance)))
        || direction == AxisDirection.left && (pixels >= maxScrollExtent || nearEqual(pixels, maxScrollExtent, Tolerance.defaultTolerance.distance)));
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
  ScrollDragController? _drag;
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
