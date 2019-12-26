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
