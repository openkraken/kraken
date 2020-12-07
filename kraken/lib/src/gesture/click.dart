/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';


import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

import 'package:flutter/gestures.dart';

/// A tap with a primary button has occurred.
typedef GestureClickCallback = void Function(Event);

class ClickGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initializes the [deadline] field during construction of subclasses.
  ///
  /// {@macro flutter.gestures.gestureRecognizer.kind}
  ClickGestureRecognizer({
    this.deadline,
    this.acceptSlopTolerance = kTouchSlop,
    Object debugOwner,
    PointerDeviceKind kind,
  }) : assert(
  acceptSlopTolerance == null || acceptSlopTolerance >= 0,
  'The acceptSlopTolerance must be positive or null',
  ),
        super(debugOwner: debugOwner, kind: kind);

  /// If non-null, the recognizer will call [didExceedDeadline] after this
  /// amount of time has elapsed since starting to track the primary pointer.
  ///
  /// The [didExceedDeadline] will not be called if the primary pointer is
  /// accepted, rejected, or all pointers are up or canceled before [deadline].
  final Duration deadline;

  /// The maximum distance in logical pixels the gesture is allowed to drift
  /// from the initial touch down position before the gesture is accepted.
  ///
  /// Drifting past the allowed slop amount causes the gesture to be rejected.
  ///
  /// Can be null to indicate that the gesture can drift for any distance.
  /// Defaults to 18 logical pixels.
  final double acceptSlopTolerance;

  /// The current state of the recognizer.
  ///
  /// See [GestureRecognizerState] for a description of the states.
  GestureRecognizerState state = GestureRecognizerState.ready;

  /// The ID of the primary pointer this recognizer is tracking.
  int primaryPointer;

  /// The location at which the primary pointer contacted the screen.
  OffsetPair initialPosition;
  Timer _timer;

  PointerDownEvent _down;

  GestureClickCallback onClick;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (state == GestureRecognizerState.ready) {
      _down = event;
      startTrackingPointer(event.pointer, event.transform);
      state = GestureRecognizerState.possible;
      primaryPointer = event.pointer;
      initialPosition = OffsetPair(local: event.localPosition, global: event.position);
      if (deadline != null)
        _timer = Timer(deadline, () => didExceedDeadlineWithEvent(event));
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(state != GestureRecognizerState.ready);
    if (state == GestureRecognizerState.possible && event.pointer == primaryPointer) {
      final bool isAcceptSlopPastTolerance = acceptSlopTolerance != null &&
          _getGlobalDistance(event) > acceptSlopTolerance;

      if (event is PointerMoveEvent && isAcceptSlopPastTolerance) {
        stopTrackingPointer(primaryPointer);
      } else {
        if (event is PointerUpEvent) {
          if (onClick != null)
            onClick(Event(EVENT_CLICK, EventInit()));
          _reset();
        } else if (event is PointerCancelEvent) {
          _reset();
        } else if (event.buttons != _down.buttons) {
          stopTrackingPointer(primaryPointer);
        }
      }
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  void _reset() {
    _down = null;
  }

  void didExceedDeadlineWithEvent(PointerEvent event) {
    assert(state != GestureRecognizerState.ready);
    state = GestureRecognizerState.ready;
    _reset();
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(state != GestureRecognizerState.ready);
    _stopTimer();
    state = GestureRecognizerState.ready;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  double _getGlobalDistance(PointerEvent event) {
    final Offset offset = event.position - initialPosition.global;
    return offset.distance;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<GestureRecognizerState>('state', state));
  }

  String get debugDescription => 'click gesture';
}
