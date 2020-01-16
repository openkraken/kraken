/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:meta/meta.dart';
import 'package:kraken/element.dart';

typedef EventHandler = void Function(Event event);

abstract class EventTarget {
  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  void addEventListener(String eventName, EventHandler eventHandler) {
    if (!eventHandlers.containsKey(eventHandler)) {
      eventHandlers[eventName] = [];
    }
    eventHandlers[eventName].add(eventHandler);
  }

  void removeEventListener(String eventName, EventHandler eventHandler) {
    if (!eventHandlers.containsKey(eventHandler)) {
      return;
    }
    eventHandlers.remove(eventHandler);
  }

  /// return whether event is cancelled.
  bool dispatchEvent(Event event) {
    if (!eventHandlers.containsKey(event.type)) {
      return true;
    }

    List<EventHandler> handlers = _getEventHandlers(event.type);
    if (handlers != null) {
      bool cancelled;
      event.currentTarget = event.target = this;
      _dispatchEventToTarget(event.currentTarget, handlers, event);
      return cancelled;
    } else {
      return true;
    }
  }

  bool _dispatchEventToTarget(
      Node node, List<EventHandler> handlers, Event event) {
    for (var handler in handlers) {
      handler(event);
      if (event.defaultPrevented || !event.canBubble()) {
        return true;
      }
    }
    return false;
  }

  List<EventHandler> _getEventHandlers(String type) {
    assert(type != null);
    return eventHandlers[type];
  }
}
