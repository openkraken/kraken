/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';


class krakenGestureRecognizer extends BaseTapGestureRecognizer {
  /// Initialize the object.
  krakenGestureRecognizer({
    Object debugOwner,
    PointerDeviceKind kind,
  }) : super(debugOwner: debugOwner);

  /// A pointer has contacted the screen at a particular location with a primary
  /// button, which might be the start of a tap.
  ///
  /// This triggers after the down event, once a short timeout ([deadline]) has
  /// elapsed, or once the gestures has won the arena, whichever comes first.
  ///
  /// If this recognizer doesn't win the arena, [onTapCancel] is called next.
  /// Otherwise, [onTapUp] is called next.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onSecondaryTapDown], a similar callback but for a secondary button.
  ///  * [TapDownDetails], which is passed as an argument to this callback.
  ///  * [GestureDetector.onTapDown], which exposes this callback.
  GestureTapDownCallback onTapDown;

  /// A pointer has stopped contacting the screen at a particular location,
  /// which is recognized as a tap of a primary button.
  ///
  /// This triggers on the up event, if the recognizer wins the arena with it
  /// or has previously won, immediately followed by [onTap].
  ///
  /// If this recognizer doesn't win the arena, [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onSecondaryTapUp], a similar callback but for a secondary button.
  ///  * [TapUpDetails], which is passed as an argument to this callback.
  ///  * [GestureDetector.onTapUp], which exposes this callback.
  GestureTapUpCallback onTapUp;

  /// A pointer has stopped contacting the screen, which is recognized as a tap
  /// of a primary button.
  ///
  /// This triggers on the up event, if the recognizer wins the arena with it
  /// or has previously won, immediately following [onTap].
  ///
  /// If this recognizer doesn't win the arena, [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onTapUp], which has the same timing but with details.
  ///  * [GestureDetector.onTap], which exposes this callback.
  GestureTapCallback onTap;

  /// A pointer that previously triggered [onTapDown] will not end up causing
  /// a tap.
  ///
  /// This triggers once the gesture loses the arena, if [onTapDown] has
  /// previously been triggered.
  ///
  /// If this recognizer wins the arena, [onTapUp] and [onTap] are called
  /// instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onSecondaryTapCancel], a similar callback but for a secondary button.
  ///  * [GestureDetector.onTapCancel], which exposes this callback.
  GestureTapCancelCallback onTapCancel;

  /// A pointer has contacted the screen at a particular location with a
  /// secondary button, which might be the start of a secondary tap.
  ///
  /// This triggers after the down event, once a short timeout ([deadline]) has
  /// elapsed, or once the gestures has won the arena, whichever comes first.
  ///
  /// If this recognizer doesn't win the arena, [onSecondaryTapCancel] is called
  /// next. Otherwise, [onSecondaryTapUp] is called next.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [onTapDown], a similar callback but for a primary button.
  ///  * [TapDownDetails], which is passed as an argument to this callback.
  ///  * [GestureDetector.onSecondaryTapDown], which exposes this callback.
  GestureTapDownCallback onSecondaryTapDown;

  /// A pointer has stopped contacting the screen at a particular location,
  /// which is recognized as a tap of a secondary button.
  ///
  /// This triggers on the up event, if the recognizer wins the arena with it
  /// or has previously won.
  ///
  /// If this recognizer doesn't win the arena, [onSecondaryTapCancel] is called
  /// instead.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [onTapUp], a similar callback but for a primary button.
  ///  * [TapUpDetails], which is passed as an argument to this callback.
  ///  * [GestureDetector.onSecondaryTapUp], which exposes this callback.
  GestureTapUpCallback onSecondaryTapUp;

  /// A pointer that previously triggered [onSecondaryTapDown] will not end up
  /// causing a tap.
  ///
  /// This triggers once the gesture loses the arena, if [onSecondaryTapDown]
  /// has previously been triggered.
  ///
  /// If this recognizer wins the arena, [onSecondaryTapUp] is called instead.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [onTapCancel], a similar callback but for a primary button.
  ///  * [GestureDetector.onTapCancel], which exposes this callback.
  GestureTapCancelCallback onSecondaryTapCancel;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    return true;
    if (onTapDown == null &&
        onTap == null &&
        onTapUp == null &&
        onTapCancel == null)
      return false;
    return super.isPointerAllowed(event);
  }

  @override
  void handleTapDown({PointerDownEvent down}) {
    final TapDownDetails details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );
    switch (down.buttons) {
      case kPrimaryButton:
        if (onTapDown != null)
          invokeCallback<void>('onTapDown', () => onTapDown(details));
        break;
      case kSecondaryButton:
        if (onSecondaryTapDown != null)
          invokeCallback<void>('onSecondaryTapDown',
                  () => onSecondaryTapDown(details));
        break;
      default:
    }
  }

  @override
  void handleTapUp({PointerDownEvent down, PointerUpEvent up}) {
    final TapUpDetails details = TapUpDetails(
      globalPosition: up.position,
      localPosition: up.localPosition,
    );
    switch (down.buttons) {
      case kPrimaryButton:
        if (onTapUp != null)
          invokeCallback<void>('onTapUp', () => onTapUp(details));
        if (onTap != null)
          invokeCallback<void>('onTap', onTap);
        break;
      case kSecondaryButton:
        if (onSecondaryTapUp != null)
          invokeCallback<void>('onSecondaryTapUp',
                  () => onSecondaryTapUp(details));
        break;
      default:
    }
  }

  @override
  void handleTapCancel({PointerDownEvent down, PointerCancelEvent cancel, String reason}) {
    final String note = reason == '' ? reason : '$reason ';
    switch (down.buttons) {
      case kPrimaryButton:
        if (onTapCancel != null)
          invokeCallback<void>('${note}onTapCancel', onTapCancel);
        break;
      case kSecondaryButton:
        if (onSecondaryTapCancel != null)
          invokeCallback<void>('${note}onSecondaryTapCancel',
              onSecondaryTapCancel);
        break;
      default:
    }
  }

  String get debugDescription => 'point';
}

mixin RenderPointerListenerMixin on RenderBox {
  /// Called when a pointer comes into contact with the screen (for touch
  /// pointers), or has its button pressed (for mouse pointers) at this widget's
  /// location.
  PointerDownEventListener onPointerDown;

  /// Called when a pointer that triggered an [onPointerDown] changes position.
  PointerMoveEventListener onPointerMove;

  /// Called when a pointer that triggered an [onPointerDown] is no longer in
  /// contact with the screen.
  PointerUpEventListener onPointerUp;

  /// Called when the input from a pointer that triggered an [onPointerDown] is
  /// no longer directed towards this receiver.
  PointerCancelEventListener onPointerCancel;

  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener onPointerSignal;

  krakenGestureRecognizer _recognizer = krakenGestureRecognizer();

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (onPointerDown != null && event is PointerDownEvent) {
      _recognizer.addPointer(event);
    }

//    if (onPointerDown != null && event is PointerDownEvent)
//      return onPointerDown(event);
//    if (onPointerMove != null && event is PointerMoveEvent)
//      return onPointerMove(event);
//    if (onPointerUp != null && event is PointerUpEvent)
//      return onPointerUp(event);
//    if (onPointerCancel != null && event is PointerCancelEvent)
//      return onPointerCancel(event);
//    if (onPointerSignal != null && event is PointerSignalEvent)
//      return onPointerSignal(event);
//    }
  }
}
