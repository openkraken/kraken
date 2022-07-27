/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

const String DIRECTION_UP = 'up';
const String DIRECTION_DOWN = 'down';
const String DIRECTION_LEFT = 'left';
const String DIRECTION_RIGHT = 'right';

/// Like [kSwipeSlop], but for more precise pointers like mice and trackpads.
const double kPrecisePointerSwipeSlop = kPrecisePointerHitSlop * 2.0; // Logical pixels

/// The distance a touch has to travel for the framework to be confident that
/// the gesture is a swipe gesture.
const double kSwipeSlop = kTouchSlop * 2.0; // Logical pixels

enum _SwipeState {
  ready,
  possible,
  accepted,
}

typedef GestureSwipeCallback = void Function(SwipeDetails details);

class SwipeDetails {
  /// Creates the details for a [GestureSwipeCallback].
  const SwipeDetails({
    this.direction = '',
    this.velocity = Velocity.zero,
  });

  final String direction;

  final Velocity velocity;
}

/// Determine the approriate pan slop pixels based on the [kind] of pointer.
double computeSwipeSlop(PointerDeviceKind kind) {
  switch (kind) {
    case PointerDeviceKind.mouse:
    case PointerDeviceKind.trackpad:
      return kPrecisePointerSwipeSlop;
    case PointerDeviceKind.stylus:
    case PointerDeviceKind.invertedStylus:
    case PointerDeviceKind.unknown:
    case PointerDeviceKind.touch:
      return kSwipeSlop;
  }
}

typedef GestureSwipeCancelCallback = void Function();

class SwipeGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  ///
  /// [dragStartBehavior] must not be null.
  ///
  /// {@macro flutter.gestures.gestureRecognizer.kind}
  SwipeGestureRecognizer({
    Object? debugOwner,
    Set<PointerDeviceKind>? supportedDevices,
    this.dragStartBehavior = DragStartBehavior.start,
    this.velocityTrackerBuilder = _defaultBuilder,
    this.onSwipe,
  }) : super(debugOwner: debugOwner, supportedDevices: supportedDevices);

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

  /// The pointer that previously triggered [onDown] did not complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  GestureSwipeCancelCallback? onCancel;

  GestureSwipeCallback? onSwipe;

  /// The minimum distance an input pointer drag must have moved to
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double? minFlingDistance;

  /// The minimum velocity for an input pointer swipe to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double? minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double? maxFlingVelocity;

  /// Determines the type of velocity estimation method to use for a potential
  /// swipe gesture, when a new pointer is added.
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

  _SwipeState _state = _SwipeState.ready;
  late OffsetPair _initialPosition;
  OffsetPair? _pendingDragOffset;
  // The buttons sent by `PointerDownEvent`. If a `PointerMoveEvent` comes with a
  // different set of buttons, the gesture is canceled.
  int? _initialButtons;

  String? _direction;

  /// Distance moved in the global coordinate space of the screen in swipe direction.
  ///
  /// If swipe is only allowed along a defined axis, this value may be negative to
  /// differentiate the direction of the swipe.
  late double _globalHorizontalDistanceMoved;

  late double _globalVerticalDistanceMoved;

  /// Determines if a gesture is a fling or not based on velocity.
  ///
  /// A fling calls its gesture end callback with a velocity, allowing the
  /// provider of the callback to respond by carrying the gesture forward with
  /// inertia, for example.
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? computeHitSlop(kind, gestureSettings);

    return ((_direction == DIRECTION_LEFT || _direction == DIRECTION_RIGHT) &&
            (estimate.pixelsPerSecond.dx.abs() > minVelocity && estimate.offset.dx.abs() > minDistance) ||
        (_direction == DIRECTION_UP || _direction == DIRECTION_DOWN) &&
            (estimate.pixelsPerSecond.dy.abs() > minVelocity && estimate.offset.dy.abs() > minDistance));
  }

  bool _hasSufficientGlobalDistanceToAccept(PointerDeviceKind pointerDeviceKind) {
    return (_globalHorizontalDistanceMoved.abs() > computeSwipeSlop(pointerDeviceKind) ||
        _globalVerticalDistanceMoved.abs() > computeSwipeSlop(pointerDeviceKind));
  }

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (_initialButtons == null) {
      switch (event.buttons) {
        case kPrimaryButton:
          if (onSwipe == null && onCancel == null) return false;
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
    if (_state == _SwipeState.ready) {
      _state = _SwipeState.possible;
      _initialPosition = OffsetPair(global: event.position, local: event.localPosition);
      _initialButtons = event.buttons;
      _pendingDragOffset = OffsetPair.zero;
      _globalHorizontalDistanceMoved = 0.0;
      _globalVerticalDistanceMoved = 0.0;
    } else if (_state == _SwipeState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _SwipeState.ready);
    if (!event.synthesized && (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
      tracker.addPosition(event.timeStamp, event.localPosition);
    }

    if (event is PointerMoveEvent) {
      if (event.buttons != _initialButtons) {
        _giveUpPointer(event.pointer);
        return;
      }

      _pendingDragOffset = _pendingDragOffset! + OffsetPair(local: event.localDelta, global: event.delta);

      final Matrix4? localToGlobalTransform = event.transform == null ? null : Matrix4.tryInvert(event.transform!);

      final Offset movedHorizontalLocally = Offset(event.localDelta.dx, 0.0);
      _globalHorizontalDistanceMoved += PointerEvent.transformDeltaViaPositions(
            transform: localToGlobalTransform,
            untransformedDelta: movedHorizontalLocally,
            untransformedEndPosition: event.localPosition,
          ).distance *
          (movedHorizontalLocally.dx).sign;

      final Offset movedVerticalLocally = Offset(0.0, event.localDelta.dy);
      _globalVerticalDistanceMoved += PointerEvent.transformDeltaViaPositions(
            transform: localToGlobalTransform,
            untransformedDelta: movedVerticalLocally,
            untransformedEndPosition: event.localPosition,
          ).distance *
          (movedVerticalLocally.dy).sign;

      if (_globalHorizontalDistanceMoved.abs() > _globalVerticalDistanceMoved.abs()) {
        _direction = _globalHorizontalDistanceMoved > 0 ? DIRECTION_RIGHT : DIRECTION_LEFT;
      } else {
        _direction = _globalVerticalDistanceMoved > 0 ? DIRECTION_DOWN : DIRECTION_UP;
      }

      if (_state != _SwipeState.accepted && _hasSufficientGlobalDistanceToAccept(event.kind)) {
        resolve(GestureDisposition.accepted);
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _giveUpPointer(
        event.pointer,
        reject: event is PointerCancelEvent || _state == _SwipeState.possible,
      );
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (_state != _SwipeState.accepted) {
      _state = _SwipeState.accepted;
      final OffsetPair? delta = _pendingDragOffset;
      if (dragStartBehavior == DragStartBehavior.start) {
        _initialPosition = _initialPosition + delta!;
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
    assert(_state != _SwipeState.ready);
    switch (_state) {
      case _SwipeState.ready:
        break;

      case _SwipeState.possible:
        resolve(GestureDisposition.rejected);
        _checkCancel();
        break;

      case _SwipeState.accepted:
        _checkEnd(pointer);
        break;
    }
    _velocityTrackers.clear();
    _initialButtons = null;
    _state = _SwipeState.ready;
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
    if (onSwipe == null) return;

    final VelocityTracker tracker = _velocityTrackers[pointer]!;

    String Function() debugReport;

    final VelocityEstimate? estimate = tracker.getVelocityEstimate();
    if (estimate != null && isFlingGesture(estimate, tracker.kind)) {
      final Velocity velocity = Velocity(pixelsPerSecond: estimate.pixelsPerSecond)
          .clampMagnitude(minFlingVelocity ?? kMinFlingVelocity, maxFlingVelocity ?? kMaxFlingVelocity);
      debugReport = () {
        return '$estimate; fling at $velocity.';
      };

      SwipeDetails details = SwipeDetails(
        direction: _direction ?? '',
        velocity: velocity,
      );
      invokeCallback<void>('onSwipe', () => onSwipe!(details), debugReport: debugReport);
    }
  }

  void _checkCancel() {
    assert(_initialButtons == kPrimaryButton);
    if (onCancel != null) invokeCallback<void>('onCancel', onCancel!);
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

  @override
  String get debugDescription => 'swipe';
}
