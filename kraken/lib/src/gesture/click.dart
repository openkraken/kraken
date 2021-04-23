/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

import 'package:flutter/gestures.dart';

/// A tap with a primary button has occurred.
typedef GestureCallback = void Function(Event);

class ClickGestureRecognizer extends PrimaryPointerGestureRecognizer {
  /// Creates a tap gesture recognizer.
  ClickGestureRecognizer({ Object debugOwner })
      : super(deadline: kPressTimeout , debugOwner: debugOwner);

  bool _sentTapDown = false;
  bool _wonArenaForPrimaryPointer = false;

  PointerDownEvent _down;
  PointerUpEvent _up;

  /// A pointer has contacted the screen, which might be the start of a tap.
  ///
  /// This triggers after the down event, once a short timeout ([deadline]) has
  /// elapsed, or once the gesture has won the arena, whichever comes first.
  ///
  /// The parameter `down` is the down event of the primary pointer that started
  /// the tap sequence.
  ///
  /// If this recognizer doesn't win the arena, [handleTapCancel] is called next.
  /// Otherwise, [handleTapUp] is called next.
  void handleTapDown(PointerDownEvent down) {}

  /// A pointer has stopped contacting the screen, which is recognized as a tap.
  ///
  /// This triggers on the up event if the recognizer wins the arena with it
  /// or has previously won.
  ///
  /// The parameter `down` is the down event of the primary pointer that started
  /// the tap sequence, and `up` is the up event that ended the tap sequence.
  ///
  /// If this recognizer doesn't win the arena, [handleTapCancel] is called
  /// instead.
  void handleTapUp( PointerDownEvent down, PointerUpEvent up ) {
    if (onClick != null)
      onClick(
          MouseEvent(EVENT_CLICK,
              MouseEventInit(
                  bubbles: true,
                  cancelable: true,
                  clientX: down.localPosition.dx,
                  clientY: down.localPosition.dy,
                  offsetX: down.position.dx,
                  offsetY: down.position.dy,
              )
          )
      );
  }

  GestureCallback onClick;

  /// A pointer that previously triggered [handleTapDown] will not end up
  /// causing a tap.
  ///
  /// This triggers once the gesture loses the arena if [handleTapDown] has
  /// been previously triggered.
  ///
  /// The parameter `down` is the down event of the primary pointer that started
  /// the tap sequence; `cancel` is the cancel event, which might be null;
  /// `reason` is a short description of the cause if `cancel` is null, which
  /// can be "forced" if other gestures won the arena, or "spontaneous"
  /// otherwise.
  ///
  /// If this recognizer wins the arena, [handleTapUp] is called instead.
  void handleTapCancel( PointerDownEvent down, PointerCancelEvent cancel, String reason ) {
    if (onClick != null)
      onClick(Event(EVENT_CANCEL, EventInit(bubbles: true, cancelable: true)));
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    assert(event != null);
    if (state == GestureRecognizerState.ready) {
      // `_down` must be assigned in this method instead of `handlePrimaryPointer`,
      // because `acceptGesture` might be called before `handlePrimaryPointer`,
      // which relies on `_down` to call `handleTapDown`.
      _down = event;
    }
    if (_down != null) {
      // This happens when this tap gesture has been rejected while the pointer
      // is down (i.e. due to movement), when another allowed pointer is added,
      // in which case all pointers are simply ignored. The `_down` being null
      // means that _reset() has been called, since it is always set at the
      // first allowed down event and will not be cleared except for reset(),
      super.addAllowedPointer(event);
    }
  }

  @override
  void startTrackingPointer(int pointer, [Matrix4 transform]) {
    // The recognizer should never track any pointers when `_down` is null,
    // because calling `_checkDown` in this state will throw exception.
    assert(_down != null);
    super.startTrackingPointer(pointer, transform);
  }

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerUpEvent) {
      _up = event;
      _checkUp();
    } else if (event is PointerCancelEvent) {
      resolve(GestureDisposition.rejected);
      if (_sentTapDown) {
        _checkCancel(event, '');
      }
      _reset();
    } else if (event.buttons != _down.buttons) {
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(primaryPointer);
    }
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (_wonArenaForPrimaryPointer && disposition == GestureDisposition.rejected) {
      // This can happen if the gesture has been canceled. For example, when
      // the pointer has exceeded the touch slop, the buttons have been changed,
      // or if the recognizer is disposed.
      assert(_sentTapDown);
      _checkCancel(null, 'spontaneous');
      _reset();
    }
    super.resolve(disposition);
  }

  @override
  void didExceedDeadline() {
    _checkDown();
  }

  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    if (pointer == primaryPointer) {
      _checkDown();
      _wonArenaForPrimaryPointer = true;
      _checkUp();
    }
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    if (pointer == primaryPointer) {
      // Another gesture won the arena.
      assert(state != GestureRecognizerState.possible);
      if (_sentTapDown)
        _checkCancel(null, 'forced');
      _reset();
    }
  }

  void _checkDown() {
    if (_sentTapDown) {
      return;
    }
    handleTapDown(_down);
    _sentTapDown = true;
  }

  void _checkUp() {
    if (!_wonArenaForPrimaryPointer || _up == null) {
      return;
    }
    handleTapUp(_down, _up);
    _reset();
  }

  void _checkCancel(PointerCancelEvent event, String note) {
    handleTapCancel(_down, event, note);
  }

  void _reset() {
    _sentTapDown = false;
    _wonArenaForPrimaryPointer = false;
    _up = null;
    _down = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('wonArenaForPrimaryPointer', value: _wonArenaForPrimaryPointer, ifTrue: 'won arena'));
    properties.add(DiagnosticsProperty<Offset>('finalPosition', _up?.position, defaultValue: null));
    properties.add(DiagnosticsProperty<Offset>('finalLocalPosition', _up?.localPosition, defaultValue: _up?.position));
    properties.add(DiagnosticsProperty<int>('button', _down?.buttons, defaultValue: null));
    properties.add(FlagProperty('sentTapDown', value: _sentTapDown, ifTrue: 'sent tap down'));
  }

  String get debugDescription => 'click gesture';
}
