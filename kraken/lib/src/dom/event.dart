/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:ffi';

import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:ffi/ffi.dart';

enum EventType {
  none,
  input,
  appear,
  disappear,
  error,
  message,
  close,
  open,
  intersectionchange,
  touchstart,
  touchend,
  touchmove,
  touchcancel,
  click,
  colorschemechange,
  load,
  finish,
  cancel,
  transitionrun,
  transitionstart,
  transitionend,
  transitioncancel,
  focus,
  unload,
  change,
  canplay,
  canplaythrough,
  ended,
  play,
  pause,
  seeked,
  seeking,
  volumechange,
  scroll
}

const String CLICK = 'click';

/// reference: https://developer.mozilla.org/zh-CN/docs/Web/API/Event
class Event {
  EventType type;
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

  Pointer toNativeEvent() {
    Pointer<NativeEvent> event = allocate<NativeEvent>();
    event.ref.type = type.index;
    event.ref.bubbles = bubbles ? 1 : 0;
    event.ref.cancelable = cancelable ? 1 : 0;
    event.ref.timeStamp = timeStamp;
    event.ref.defaultPrevented = defaultPrevented ? 1 : 0;
    event.ref.target = target != null ? target.nativeEventTargetPtr : nullptr;
    event.ref.currentTarget = currentTarget != null ? currentTarget.nativeEventTargetPtr : nullptr;

    return event.cast<Pointer>();
  }

  Map toJson() {
    Pointer<NativeEvent> nativeEvent = toNativeEvent().cast<NativeEvent>();
    return {
      'type': type.index,
      'nativeEvent': nativeEvent.address
    };
  }

  String toString() {
    return '$runtimeType(${jsonEncode(toJson())})';
  }
}

class EventInit {
  bool bubbles;
  bool cancelable;

  static final Map<String, EventInit> _cache = <String, EventInit>{};

  factory EventInit({bool bubbles = false, bool cancelable = false}) {
    String key = bubbles.toString() + cancelable.toString();
    return _cache.putIfAbsent(key, () => EventInit._internal(bubbles: bubbles, cancelable: cancelable));
  }

  EventInit._internal({this.bubbles, this.cancelable});
}

class InputEvent extends Event {
  final String inputType;
  final String data;

  Pointer<NativeInputEvent> toNativeEvent() {
    Pointer<NativeInputEvent> nativeInputEvent = allocate<NativeInputEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNativeEvent().cast<NativeEvent>();
    nativeInputEvent.ref.nativeEvent = nativeEvent;
    nativeInputEvent.ref.inputType = stringToNativeString(inputType);
    nativeInputEvent.ref.data = stringToNativeString(data);
    return nativeInputEvent;
  }

  InputEvent(
    this.data, {
    this.inputType = 'insertText',
  }) : super(EventType.input, EventInit(cancelable: true));
}

class AppearEvent extends Event {
  AppearEvent() : super(EventType.appear);
}

class DisappearEvent extends Event {
  DisappearEvent() : super(EventType.disappear);
}

class ColorSchemeChangeEvent extends Event {
  ColorSchemeChangeEvent(this.platformBrightness) : super(EventType.colorschemechange);
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

  Pointer<NativeMediaErrorEvent> toNativeEvent() {
    Pointer<NativeMediaErrorEvent> nativeMediaError = allocate<NativeMediaErrorEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNativeEvent().cast<NativeEvent>();
    nativeMediaError.ref.nativeEvent = nativeEvent;
    nativeMediaError.ref.code = code;
    nativeMediaError.ref.message = stringToNativeString(message);
    return nativeMediaError;
  }

  MediaError(this.code, this.message) : super(EventType.error);
}

/// reference: https://developer.mozilla.org/en-US/docs/Web/API/MessageEvent
class MessageEvent extends Event {
  /// The data sent by the message emitter.
  final String data;

  /// A USVString representing the origin of the message emitter.
  final String origin;

  MessageEvent(this.data, {this.origin = ''}) : super(EventType.message);

  Pointer<NativeMessageEvent> toNativeEvent() {
    Pointer<NativeMessageEvent> messageEvent = allocate<NativeMessageEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNativeEvent().cast<NativeEvent>();
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

  CloseEvent(this.code, this.reason, this.wasClean) : super(EventType.close);

  Pointer<NativeCloseEvent> toNativeEvent() {
    Pointer<NativeCloseEvent> closeEvent = allocate<NativeCloseEvent>();
    Pointer<NativeEvent> nativeEvent = super.toNativeEvent().cast<NativeEvent>();
    closeEvent.ref.nativeEvent = nativeEvent;
    closeEvent.ref.code = code;
    closeEvent.ref.reason = stringToNativeString(reason);
    closeEvent.ref.wasClean = wasClean ? 1 : 0;
    return closeEvent;
  }
}

class IntersectionChangeEvent extends Event {
  IntersectionChangeEvent(this.intersectionRatio) : super(EventType.intersectionchange);
  double intersectionRatio;

  Map toJson() {
    Map eventMap = super.toJson();
    eventMap['intersectionRatio'] = intersectionRatio;
    return eventMap;
  }
}

/// reference: https://w3c.github.io/touch-events/#touchevent-interface
class TouchEvent extends Event {
  TouchEvent(EventType type) : super(type, EventInit(bubbles: true, cancelable: true));

  TouchList touches = TouchList();
  TouchList targetTouches = TouchList();
  TouchList changedTouches = TouchList();

  bool altKey = false;
  bool metaKey = false;
  bool ctrlKey = false;
  bool shiftKey = false;

  Map toJson() {
    Map eventMap = super.toJson();

    eventMap['touches'] = touches.toJson();
    eventMap['targetTouches'] = touches.toJson();
    eventMap['changedTouches'] = touches.toJson();
    eventMap['altKey'] = altKey;
    eventMap['metaKey'] = metaKey;
    eventMap['ctrlKey'] = ctrlKey;
    eventMap['shiftKey'] = shiftKey;

    return eventMap;
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

  Map toJson() {
    return {
      'identifier': identifier,
      // @NOTE: Can not get target in Touch
      // 'target': target,
      'clientX': clientX,
      'clientY': clientY,
      'screenX': screenX,
      'screenY': screenY,
      'pageX': pageX,
      'pageY': pageY,
      'radiusX': radiusX,
      'radiusY': radiusY,
      'rotationAngle': rotationAngle,
      'force': force,
      'altitudeAngle': altitudeAngle,
      'azimuthAngle': azimuthAngle,
      'touchType': touchType == TouchType.direct ? 'direct' : 'stylus',
    };
  }
}

/// reference: https://w3c.github.io/touch-events/#touchlist-interface
class TouchList {
  List<Touch> items = [];
  int get length => items.length;

  Touch item(int index) {
    return items[index];
  }

  List<Map> toJson() {
    List<Map> ret = [];
    for (Touch touch in items) {
      ret.add(touch.toJson());
    }
    return ret;
  }
}
