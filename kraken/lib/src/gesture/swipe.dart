/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:flutter/gestures.dart';

enum _DragState {
  ready,
  possible,
  accepted,
}

enum _OffsetDirection {
  up,
  left,
  down,
  right,
}

class SwipeGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  ///
  /// [dragStartBehavior] must not be null.
  ///
  /// {@macro flutter.gestures.gestureRecognizer.kind}
  SwipeGestureRecognizer({
    Object debugOwner,
    PointerDeviceKind kind,
    this.dragStartBehavior = DragStartBehavior.start,
    this.velocityTrackerBuilder = _defaultBuilder,
    this.onSwipe,
  }) : assert(dragStartBehavior != null),
        super(debugOwner: debugOwner, kind: kind);

  static VelocityTracker _defaultBuilder(PointerEvent event) => VelocityTracker.withKind(event.kind);
  /// Configure the behavior of offsets sent to [onStart].
  ///
  /// If set to [DragStartBehavior.start], the [onStart] callback will be called
  /// at the time and position when this gesture recognizer wins the arena. If
  /// [DragStartBehavior.down], [onStart] will be called at the time and
  /// position when a down event was first detected.
  ///
  /// For more information about the gesture arena:
  /// https://flutter.dev/docs/development/ui/advanced/gestures#gesture-disambiguation
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// ## Example:
  ///
  /// A finger presses down on the screen with offset (500.0, 500.0), and then
  /// moves to position (510.0, 500.0) before winning the arena. With
  /// [dragStartBehavior] set to [DragStartBehavior.down], the [onStart]
  /// callback will be called at the time corresponding to the touch's position
  /// at (500.0, 500.0). If it is instead set to [DragStartBehavior.start],
  /// [onStart] will be called at the time corresponding to the touch's position
  /// at (510.0, 500.0).
  DragStartBehavior dragStartBehavior;

  GestureCallback onSwipe;

  /// The pointer that previously triggered [onDown] did not complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  GestureDragCancelCallback onCancel;

  /// The minimum distance an input pointer drag must have moved to
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double minFlingDistance;

  /// The minimum velocity for an input pointer drag to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double maxFlingVelocity;

  /// Determines the type of velocity estimation method to use for a potential
  /// drag gesture, when a new pointer is added.
  ///
  /// To estimate the velocity of a gesture, [DragGestureRecognizer] calls
  /// [velocityTrackerBuilder] when it starts to track a new pointer in
  /// [addAllowedPointer], and add subsequent updates on the pointer to the
  /// resulting velocity tracker, until the gesture recognizer stops tracking
  /// the pointer. This allows you to specify a different velocity estimation
  /// strategy for each allowed pointer added, by changing the type of velocity
  /// tracker this [GestureVelocityTrackerBuilder] returns.
  ///
  /// If left unspecified the default [velocityTrackerBuilder] creates a new
  /// [VelocityTracker] for every pointer added.
  ///
  /// See also:
  ///
  ///  * [VelocityTracker], a velocity tracker that uses least squares estimation
  ///    on the 20 most recent pointer data samples. It's a well-rounded velocity
  ///    tracker and is used by default.
  ///  * [IOSScrollViewFlingVelocityTracker], a specialized velocity tracker for
  ///    determining the initial fling velocity for a [Scrollable] on iOS, to
  ///    match the native behavior on that platform.
  GestureVelocityTrackerBuilder velocityTrackerBuilder;

  _DragState _state = _DragState.ready;
  OffsetPair _initialPosition;
  OffsetPair _pendingDragOffset;
  // The buttons sent by `PointerDownEvent`. If a `PointerMoveEvent` comes with a
  // different set of buttons, the gesture is canceled.
  int _initialButtons;
  _OffsetDirection _direction = _OffsetDirection.left;

  /// Distance moved in the global coordinate space of the screen in drag direction.
  ///
  /// If drag is only allowed along a defined axis, this value may be negative to
  /// differentiate the direction of the drag.
  double _globalVerticalDistanceMoved;
  double _globalHorizontalDistanceMoved;

  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? computeHitSlop(kind);
    if (_direction == _OffsetDirection.left || _direction == _OffsetDirection.right) {
      return estimate.pixelsPerSecond.dx.abs() > minVelocity && estimate.offset.dx.abs() > minDistance;
    } else {
      return estimate.pixelsPerSecond.dy.abs() > minVelocity && estimate.offset.dy.abs() > minDistance;
    }
  }

  bool _hasSufficientGlobalDistanceAndVelocityToAccept(PointerEvent event) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? computeHitSlop(event.kind);
    final VelocityEstimate estimate = _velocityTrackers[event.pointer].getVelocityEstimate();
    bool isFling = estimate.pixelsPerSecond.dy.abs() > minVelocity && estimate.offset.dy.abs() > minDistance;
    return isFling && (_globalVerticalDistanceMoved.abs() > kTouchSlop  || _globalHorizontalDistanceMoved.abs() > kTouchSlop);
  }

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (_initialButtons == null) {
      switch (event.buttons) {
        case kPrimaryButton:
          if (onCancel == null && onSwipe == null)
            return false;
          break;
        default:
          return false;
      }
    } else {
      // There can be multiple drags simultaneously. Their effects are combined.
      if (event.buttons != _initialButtons) {
        return false;
      }
    }
    return super.isPointerAllowed(event as PointerDownEvent);
  }

  @override
  void addAllowedPointer(PointerEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _velocityTrackers[event.pointer] = velocityTrackerBuilder(event);
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      _initialPosition = OffsetPair(global: event.position, local: event.localPosition);
      _initialButtons = event.buttons;
      _pendingDragOffset = OffsetPair.zero;
      _globalVerticalDistanceMoved = 0.0;
      _globalHorizontalDistanceMoved = 0.0;
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized
        && (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer];
      assert(tracker != null);
      tracker.addPosition(event.timeStamp, event.localPosition);
    }
    if (event is PointerMoveEvent) {
      if (event.buttons != _initialButtons) {
        _giveUpPointer(event.pointer);
        return;
      }
      if (_state != _DragState.accepted) {
        _pendingDragOffset += OffsetPair(local: event.localDelta, global: event.delta);

        final Matrix4 localToGlobalTransform = event.transform == null ? null : Matrix4.tryInvert(event.transform);

        final Offset movedVerticalLocally = Offset(0.0, event.localDelta.dy);
        _globalVerticalDistanceMoved += PointerEvent.transformDeltaViaPositions(
          transform: localToGlobalTransform,
          untransformedDelta: movedVerticalLocally,
          untransformedEndPosition: event.localPosition,
        ).distance * (movedVerticalLocally.dy ?? 1).sign;

        final Offset movedHorizontalLocally = Offset(event.localDelta.dx, 0.0);
        _globalHorizontalDistanceMoved += PointerEvent.transformDeltaViaPositions(
          transform: localToGlobalTransform,
          untransformedDelta: movedHorizontalLocally,
          untransformedEndPosition: event.localPosition,
        ).distance * (movedHorizontalLocally.dx ?? 1).sign;

        if (_hasSufficientGlobalDistanceAndVelocityToAccept(event)) {
          if (_globalVerticalDistanceMoved.abs() > kTouchSlop) {
            _direction = (_globalVerticalDistanceMoved > 0) ? _OffsetDirection.up : _OffsetDirection.down;
          } else {
            _direction = (_globalHorizontalDistanceMoved > 0) ? _OffsetDirection.left : _OffsetDirection.right;
          }
          resolve(GestureDisposition.accepted);
        }
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _giveUpPointer(
        event.pointer,
        reject: event is PointerCancelEvent || _state ==_DragState.possible,
      );
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (_state != _DragState.accepted) {
      _state = _DragState.accepted;
      final OffsetPair delta = _pendingDragOffset;
      switch (dragStartBehavior) {
        case DragStartBehavior.start:
          _initialPosition = _initialPosition + delta;
          break;
        case DragStartBehavior.down:
          break;
      }
      _pendingDragOffset = OffsetPair.zero;
    }
  }

  @override
  void rejectGesture(int pointer) {
    _giveUpPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(_state != _DragState.ready);
    switch(_state) {
      case _DragState.ready:
        break;

      case _DragState.possible:
        resolve(GestureDisposition.rejected);
        _checkCancel();
        break;

      case _DragState.accepted:
        _checkEnd(pointer);
        break;
    }
    _velocityTrackers.clear();
    _initialButtons = null;
    _state = _DragState.ready;
  }

  void _giveUpPointer(int pointer, {bool reject = true}) {
    stopTrackingPointer(pointer);
    if (reject) {
      if (_velocityTrackers.containsKey(pointer)) {
        _velocityTrackers.remove(pointer);
        resolvePointer(pointer, GestureDisposition.rejected);
      }
    }
  }

  void _checkEnd(int pointer) {
    assert(_initialButtons == kPrimaryButton);
    if (onSwipe == null)
      return;

    final VelocityTracker tracker = _velocityTrackers[pointer];
    assert(tracker != null);

    String Function() debugReport;

    final VelocityEstimate estimate = tracker.getVelocityEstimate();
    final Velocity velocity = Velocity(pixelsPerSecond: estimate.pixelsPerSecond).clampMagnitude(minFlingVelocity ?? kMinFlingVelocity, maxFlingVelocity ?? kMaxFlingVelocity);

    GestureEventInit e = GestureEventInit(deltaX: velocity.pixelsPerSecond.dx, deltaY: velocity.pixelsPerSecond.dy, direction: 0 );
    invokeCallback<void>('onSwipe', () => onSwipe(GestureEvent(EVENT_SWIPE, e)), debugReport: debugReport);
  }

  void _checkCancel() {
    assert(_initialButtons == kPrimaryButton);
    if (onCancel != null)
      invokeCallback<void>('onCancel', onCancel);
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DragStartBehavior>('start behavior', dragStartBehavior));
  }

  String get debugDescription => 'swipe gesture';
}
