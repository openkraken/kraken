/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';

/// reference: https://developer.mozilla.org/zh-CN/docs/Web/API/Event
class Event {
  String type;
  bool bubbles;
  bool cancelable;
  bool composed;
  Node currentTarget;
  Node target;
  num timeStamp;
  bool defaultPrevented = false;
  dynamic detail;

  bool _immediateBubble = true;

  Event(this.type, EventInit init) {
    assert(type != null);
    assert(init != null);

    bubbles = init.bubbles;
    cancelable = init.cancelable;
    composed = init.composed;

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

  Map toJson() {
    return {
      'type': type,
      'bubbles': bubbles,
      'cancelable': cancelable,
      'composed': composed,
      'timeStamp': timeStamp,
      'defaultPrevented': defaultPrevented,
      'target': target?.nodeId,
      'currentTarget': currentTarget?.nodeId,
      'detail': detail,
    };
  }
}

class EventInit {
  bool bubbles;
  bool cancelable;
  bool composed;

  EventInit(
      {this.bubbles = false, this.cancelable = false, this.composed = false});
}

class InputEvent extends Event {
  String inputType;
  dynamic detail;

  InputEvent(
    this.detail, {
    this.inputType = 'insertText',
  }) : super('input',
            EventInit(bubbles: false, cancelable: true, composed: true));
}

/// reference: https://w3c.github.io/touch-events/#touchevent-interface
class TouchEvent extends Event {
  TouchEvent(String type)
      : super(type, EventInit(bubbles: true, cancelable: true, composed: true));

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
