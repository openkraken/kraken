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
    if (!eventHandlers.containsKey(eventName)) {
      return;
    }
    List<EventHandler> currentHandlers = eventHandlers[eventName];
    currentHandlers.remove(eventHandler);
  }

  /// return whether event is cancelled.
  bool dispatchEvent(Event event) {
    if (!eventHandlers.containsKey(event.type)) {
      return true;
    }

    bool cancelled = true;
    event.currentTarget = event.target = this;
    while (event.currentTarget != null) {
      List<EventHandler> handlers = event.currentTarget.getEventHandlers(event.type);
      cancelled = _dispatchEventToTarget(event.currentTarget, handlers, event);
      if (!event.bubbles || cancelled) break;
      event.currentTarget = event.currentTarget?.parentNode;
    }
    return cancelled;
  }

  bool _dispatchEventToTarget(
      Node node, List<EventHandler> handlers, Event event) {
    if (handlers != null) {
      for (var handler in handlers) {
        handler(event);
        if (event.defaultPrevented || !event.canBubble()) {
          return true;
        }
      }
    }
    return false;
  }

  List<EventHandler> getEventHandlers(String type) {
    assert(type != null);
    return eventHandlers[type];
  }
}
