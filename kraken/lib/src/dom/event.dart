/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:ffi';

import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:ffi/ffi.dart';

const String EVENT_CLICK = 'click';
const String EVENT_INPUT = 'input';
const String EVENT_APPEAR = 'appear';
const String EVENT_DISAPPEAR = 'disappear';
const String EVENT_COLOR_SCHEME_CHANGE = 'colorschemechange';
const String EVENT_ERROR = 'error';
const String EVENT_MEDIA_ERROR = 'mediaerror';
const String EVENT_TOUCH_START = 'touchstart';
const String EVENT_TOUCH_MOVE = 'touchmove';
const String EVENT_TOUCH_END = 'touchend';
const String EVENT_TOUCH_CANCEL = 'touchcancel';
const String EVENT_MESSAGE = 'message';
const String EVENT_CLOSE = 'close';
const String EVENT_OPEN = 'open';
const String EVENT_INTERSECTION_CHANGE = 'intersectionchange';
const String EVENT_CANCEL = 'cancel';
const String EVENT_FINISH = 'finish';
const String EVENT_TRANSITION_RUN = 'transitionrun';
const String EVENT_TRANSITION_CANCEL = 'transitioncancel';
const String EVENT_TRANSITION_START = 'transitionstart';
const String EVENT_TRANSITION_END = 'transitionend';
const String EVENT_FOCUS = 'focus';
const String EVENT_LOAD = 'load';
const String EVENT_DOM_CONTENT_LOADED = 'DOMContentLoaded';
const String EVENT_UNLOAD = 'unload';
const String EVENT_CHANGE = 'change';
const String EVENT_CAN_PLAY = 'canplay';
const String EVENT_CAN_PLAY_THROUGH = 'canplaythrough';
const String EVENT_ENDED = 'ended';
const String EVENT_PAUSE = 'pause';
const String EVENT_PLAY = 'play';
const String EVENT_SEEKED = 'seeked';
const String EVENT_SEEKING = 'seeking';
const String EVENT_VOLUME_CHANGE = 'volumechange';
const String EVENT_SCROLL = 'scroll';
const String EVENT_SWIPE = 'swipe';
const String EVENT_PAN = 'pan';
const String EVENT_SCALE = 'scale';
const String EVENT_Long_PRESS = 'longpress';

const String EVENT_STATE_START = 'start';
const String EVENT_STATE_UPDATE = 'update';
const String EVENT_STATE_END = 'end';

/// reference: https://developer.mozilla.org/zh-CN/docs/Web/API/Event
class Event {
  String type;
  bool bubbles;
  bool cancelable;
  EventTarget currentTarget;
  EventTarget target;
  num timeStamp;
  bool defaultPrevented = false;

  bool _immediateBubble = true;

  Event(this.type, [EventInit init]) {
    assert(type != null);

    if (init == null) {
      init = EventInit();
    }

    bubbles = init.bubbles;
    cancelable = init.cancelable;
    timeStamp = DateTime.now().millisecondsSinceEpoch;
  }

  void preventDefault() {
    if (cancelable) {
      defaultPrevented = true;
    }
  }

  bool canBubble() => _immediateBubble;
  void stopImmediatePropagation() {
    _immediateBubble = false;
  }

  void stopPropagation() {
    bubbles = false;
  }

  Pointer toNative() {
    Pointer<NativeEvent> event = allocate<NativeEvent>();
    event.ref.type = stringToNativeString(type);
    event.ref.bubbles = bubbles ? 1 : 0;
    event.ref.cancelable = cancelable ? 1 : 0;
    event.ref.timeStamp = timeStamp;
    event.ref.defaultPrevented = defaultPrevented ? 1 : 0;
    event.ref.target = target != null ? target.nativeEventTargetPtr : nullptr;

    return event.cast<Pointer>();
  }

  Map toJson() {
    Pointer<NativeEvent> nativeEvent = toNative().cast<NativeEvent>();
    return {
      'type': type,
      'nativeEvent': nativeEvent.address
    };
  }

  String toString() {
    return '$runtimeType(${jsonEncode(toJson())})';
  }
}

class EventInit {
  final bool bubbles;
  final bool cancelable;

  EventInit({
    this.bubbles = false,
    this.cancelable = false,
  });
}

/// reference: https://developer.mozilla.org/zh-CN/docs/Web/API/MouseEvent
class MouseEvent extends Event {
  final MouseEventInit _mouseEventInit;

  int get clientX => _mouseEventInit?.clientX;
  int get clientY => _mouseEventInit?.clientY;
  int get offsetX => _mouseEventInit?.offsetX;
  int get offsetY => _mouseEventInit?.offsetY;

  MouseEvent(String type, [MouseEventInit mouseEventInit])
      : _mouseEventInit = mouseEventInit, super(type, mouseEventInit);

  Pointer<NativeMouseEvent> toNative() {
    Pointer<NativeMouseEvent> nativeMouseEventPointer = allocate<NativeMouseEvent>();
    nativeMouseEventPointer.ref.nativeEvent = super.toNative().cast<NativeEvent>();
    nativeMouseEventPointer.ref.clientX = clientX;
    nativeMouseEventPointer.ref.clientY = clientY;
    nativeMouseEventPointer.ref.offsetX = offsetX;
    nativeMouseEventPointer.ref.offsetY = offsetY;
    return nativeMouseEventPointer;
  }
}

class MouseEventInit extends EventInit {
  final int clientX;
  final int clientY;
  final int offsetX;
  final int offsetY;

  MouseEventInit({
    bool bubbles = false,
    bool cancelable = false,
    this.clientX = 0,
    this.clientY = 0,
    this.offsetX = 0,
    this.offsetY = 0,
  })
      : super(bubbles: bubbles, cancelable: cancelable);
}


class GestureEventInit extends EventInit {
  final String state;
  final String direction;
  final double rotation;
  final double deltaX;
  final double deltaY;
  final double velocityX;
  final double velocityY;
  final double scale;

  GestureEventInit({
    bool bubbles = false,
    bool cancelable = false,
    this.state = '',
    this.direction = '',
    this.rotation = 0.0,
    this.deltaX = 0.0,
    this.deltaY = 0.0,
    this.velocityX = 0.0,
    this.velocityY = 0.0,
    this.scale = 0.0,
  })
      : super(bubbles: bubbles, cancelable: cancelable);
}

/// reference: https://developer.mozilla.org/en-US/docs/Web/API/GestureEvent
class GestureEvent extends Event {
  final GestureEventInit _gestureEventInit;

  String get state => _gestureEventInit?.state;
  String get direction => _gestureEventInit?.direction;
  double get rotation => _gestureEventInit?.rotation;
  double get deltaX => _gestureEventInit?.deltaX;
  double get deltaY => _gestureEventInit?.deltaY;
  double get velocityX => _gestureEventInit?.velocityX;
  double get velocityY => _gestureEventInit?.velocityY;
  double get scale => _gestureEventInit?.scale;


  GestureEvent(String type, [GestureEventInit gestureEventInit])
      : _gestureEventInit = gestureEventInit, super(type, gestureEventInit);

  Pointer<NativeGestureEvent> toNative() {
    Pointer<NativeGestureEvent> nativeGestureEventPointer = allocate<NativeGestureEvent>();
    nativeGestureEventPointer.ref.nativeEvent = super.toNative().cast<NativeEvent>();
    nativeGestureEventPointer.ref.state = stringToNativeString(state);
    nativeGestureEventPointer.ref.direction = stringToNativeString(direction);
    nativeGestureEventPointer.ref.deltaX = deltaX;
    nativeGestureEventPointer.ref.deltaY = deltaY;
    nativeGestureEventPointer.ref.velocityX = velocityX;
    nativeGestureEventPointer.ref.velocityY = velocityY;
    nativeGestureEventPointer.ref.scale = scale;
    nativeGestureEventPointer.ref.rotation = rotation;
    return nativeGestureEventPointer;
  }
}

class CustomEventInit extends EventInit {
  final String detail;

  CustomEventInit({bool bubbles = false, bool cancelable = false, this.detail })
      : super(bubbles: bubbles, cancelable: cancelable);
}

/// reference: http://dev.w3.org/2006/webapi/DOM-Level-3-Events/html/DOM3-Events.html#interface-CustomEvent
/// Attention: Detail now only can be a string.
class CustomEvent extends Event {
  final CustomEventInit _customEventInit;
  String get detail => _customEventInit?.detail;

  CustomEvent(String type, [CustomEventInit customEventInit])
      : _customEventInit = customEventInit, super(type, customEventInit);

  Pointer<NativeCustomEvent> toNative() {
    Pointer<NativeCustomEvent> nativeCustomEventPointer = allocate<NativeCustomEvent>();
    nativeCustomEventPointer.ref.nativeEvent = super.toNative().cast<NativeEvent>();
    nativeCustomEventPointer.ref.detail = stringToNativeString(detail);
    return nativeCustomEventPointer;
  }
}

// https://w3c.github.io/input-events/
class InputEvent extends Event {
  // A String containing the type of input that was made.
  // There are many possible values, such as insertText,
  // deleteContentBackward, insertFromPaste, and formatBold.
  final String inputType;
  final String data;

  Pointer<NativeInputEvent> toNative() {
    Pointer<NativeInputEvent> nativeInputEvent = allocate<NativeInputEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNative().cast<NativeEvent>();
    nativeInputEvent.ref.nativeEvent = nativeEvent;
    nativeInputEvent.ref.inputType = stringToNativeString(inputType);
    nativeInputEvent.ref.data = stringToNativeString(data);
    return nativeInputEvent;
  }

  InputEvent(
    this.data, {
    this.inputType = '',
  }) :  assert(data != null),
        super(EVENT_INPUT, EventInit(cancelable: true));
}

class AppearEvent extends Event {
  AppearEvent() : super(EVENT_APPEAR);
}

class DisappearEvent extends Event {
  DisappearEvent() : super(EVENT_DISAPPEAR);
}

class ColorSchemeChangeEvent extends Event {
  ColorSchemeChangeEvent(this.platformBrightness) : super(EVENT_COLOR_SCHEME_CHANGE);
  final String platformBrightness;
}

class MediaErrorCode {
  // The fetching of the associated resource was aborted by the user's request.
  static const double MEDIA_ERR_ABORTED = 1;
  // Some kind of network error occurred which prevented the media from being successfully fetched, despite having previously been available.
  static const double MEDIA_ERR_NETWORK = 2;
  // Despite having previously been determined to be usable, an error occurred while trying to decode the media resource, resulting in an error.
  static const double MEDIA_ERR_DECODE = 3;
  // The associated resource or media provider object (such as a MediaStream) has been found to be unsuitable.
  static const double MEDIA_ERR_SRC_NOT_SUPPORTED = 4;
}

class MediaError extends Event {
  /// A number which represents the general type of error that occurred, as follow
  final int code;

  /// a human-readable string which provides specific diagnostic information to help the reader understand the error condition which occurred;
  /// specifically, it isn't simply a summary of what the error code means, but actual diagnostic information to help in understanding what exactly went wrong.
  /// This text and its format is not defined by the specification and will vary from one user agent to another.
  /// If no diagnostics are available, or no explanation can be provided, this value is an empty string ("").
  final String message;

  Pointer<NativeMediaErrorEvent> toNative() {
    Pointer<NativeMediaErrorEvent> nativeMediaError = allocate<NativeMediaErrorEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNative().cast<NativeEvent>();
    nativeMediaError.ref.nativeEvent = nativeEvent;
    nativeMediaError.ref.code = code;
    nativeMediaError.ref.message = stringToNativeString(message);
    return nativeMediaError;
  }

  MediaError(this.code, this.message) :
        assert(message != null),
        super(EVENT_MEDIA_ERROR);
}

/// reference: https://developer.mozilla.org/en-US/docs/Web/API/MessageEvent
class MessageEvent extends Event {
  /// The data sent by the message emitter.
  final String data;

  /// A USVString representing the origin of the message emitter.
  final String origin;

  MessageEvent(this.data, {this.origin = ''}) :
        assert(data != null),
        super(EVENT_MESSAGE);

  Pointer<NativeMessageEvent> toNative() {
    Pointer<NativeMessageEvent> messageEvent = allocate<NativeMessageEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNative().cast<NativeEvent>();
    messageEvent.ref.nativeEvent = nativeEvent;
    messageEvent.ref.data = stringToNativeString(data);
    messageEvent.ref.origin = stringToNativeString(origin);
    return messageEvent;
  }
}

/// reference: https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent/CloseEvent
class CloseEvent extends Event {
  /// An unsigned short containing the close code sent by the server
  final int code;

  /// Indicating the reason the server closed the connection.
  final String reason;

  /// Indicates whether or not the connection was cleanly closed
  final bool wasClean;

  CloseEvent(this.code, this.reason, this.wasClean) :
        assert(reason != null),
        super(EVENT_CLOSE);

  Pointer<NativeCloseEvent> toNative() {
    Pointer<NativeCloseEvent> closeEvent = allocate<NativeCloseEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNative().cast<NativeEvent>();
    closeEvent.ref.nativeEvent = nativeEvent;
    closeEvent.ref.code = code;
    closeEvent.ref.reason = stringToNativeString(reason);
    closeEvent.ref.wasClean = wasClean ? 1 : 0;
    return closeEvent;
  }
}

class IntersectionChangeEvent extends Event {
  IntersectionChangeEvent(this.intersectionRatio) : super(EVENT_INTERSECTION_CHANGE);
  final double intersectionRatio;

  Pointer<NativeIntersectionChangeEvent> toNative() {
    Pointer<NativeIntersectionChangeEvent> intersectionChangeEvent = allocate<NativeIntersectionChangeEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNative().cast<NativeEvent>();
    intersectionChangeEvent.ref.nativeEvent = nativeEvent;
    intersectionChangeEvent.ref.intersectionRatio = intersectionRatio;
    return intersectionChangeEvent;
  }
}

/// reference: https://w3c.github.io/touch-events/#touchevent-interface
class TouchEvent extends Event {
  TouchEvent(String type) : super(type, EventInit(bubbles: true, cancelable: true));

  TouchList touches = TouchList();
  TouchList targetTouches = TouchList();
  TouchList changedTouches = TouchList();

  bool altKey = false;
  bool metaKey = false;
  bool ctrlKey = false;
  bool shiftKey = false;

  Pointer<NativeTouchEvent> toNative() {
    Pointer<NativeTouchEvent> touchEvent = allocate<NativeTouchEvent>();
    touchEvent.ref.nativeEvent = super.toNative().cast<NativeEvent>();
    touchEvent.ref.touches = touches.toNative();
    touchEvent.ref.touchLength = touches.length;
    touchEvent.ref.targetTouches = targetTouches.toNative();
    touchEvent.ref.targetTouchesLength = targetTouches.length;
    touchEvent.ref.changedTouches = changedTouches.toNative();
    touchEvent.ref.changedTouchesLength = changedTouches.length;
    touchEvent.ref.altKey = altKey ? 1 : 0;
    touchEvent.ref.metaKey = metaKey ? 1 : 0;
    touchEvent.ref.ctrlKey = ctrlKey ? 1 : 0;
    touchEvent.ref.shiftKey = shiftKey ? 1 : 0;
    return touchEvent;
  }
}

enum TouchType {
  direct,
  stylus,
}

/// reference: https://w3c.github.io/touch-events/#dom-touch
class Touch {
  final int identifier;
  final EventTarget target;
  final double clientX;
  final double clientY;
  final double screenX;
  final double screenY;
  final double pageX;
  final double pageY;
  final double radiusX;
  final double radiusY;
  final double rotationAngle;
  final double force;
  final double altitudeAngle;
  final double azimuthAngle;
  final TouchType touchType;

  Touch({
    this.identifier,
    this.target,
    this.clientX = 0,
    this.clientY = 0,
    this.screenX = 0,
    this.screenY = 0,
    this.pageX = 0,
    this.pageY = 0,
    this.radiusX = 0,
    this.radiusY = 0,
    this.rotationAngle = 0,
    this.force = 0,
    this.altitudeAngle = 0,
    this.azimuthAngle = 0,
    this.touchType = TouchType.direct,
  });

  Pointer<NativeTouch> toNative() {
    Pointer<NativeTouch> nativeTouch = allocate<NativeTouch>();
    nativeTouch.ref.identifier = identifier;
    nativeTouch.ref.target = target.nativeEventTargetPtr;
    nativeTouch.ref.clientX = clientX;
    nativeTouch.ref.clientY = clientY;
    nativeTouch.ref.screenX = screenX;
    nativeTouch.ref.screenY = screenY;
    nativeTouch.ref.pageX = pageX;
    nativeTouch.ref.pageY = pageY;
    nativeTouch.ref.radiusX = radiusX;
    nativeTouch.ref.radiusY = radiusY;
    nativeTouch.ref.rotationAngle = rotationAngle;
    nativeTouch.ref.force = force;
    nativeTouch.ref.altitudeAngle = altitudeAngle;
    nativeTouch.ref.azimuthAngle = azimuthAngle;
    nativeTouch.ref.touchType = touchType.index;
    return nativeTouch;
  }
}

/// reference: https://w3c.github.io/touch-events/#touchlist-interface
class TouchList {
  List<Touch> items = [];
  int get length => items.length;

  Touch item(int index) {
    return items[index];
  }

  Touch operator[](int index) {
    return items[index];
  }

  Pointer<Pointer<NativeTouch>> toNative() {
    Pointer<Pointer<NativeTouch>> touchList = allocate<NativeTouch>(count: items.length).cast<Pointer<NativeTouch>>();
    for (int i = 0; i < items.length; i ++) {
      touchList[i] = items[i].toNative();
    }

    return touchList;
  }
}
