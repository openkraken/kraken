/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:meta/meta.dart';
import 'package:kraken/element.dart';

typedef EventHandler = void Function(Event event);

Map<int, EventTarget> _eventTargets = <int, EventTarget>{};

T getEventTargetByTargetId<T>(int targetId) {
  assert(targetId != null);
  EventTarget target = _eventTargets[targetId];
  if (target is T)
    return target as T;
  else
    return null;
}

bool existsTarget(int id) {
  return _eventTargets.containsKey(id);
}

void removeTarget(int targetId) {
  assert(targetId != null);
  _eventTargets.remove(targetId);
}

void setEventTarget(EventTarget target) {
  assert(target != null);

  _eventTargets[target.targetId] = target;
}

void clearTargets() {
  // Set current eventTargets to a new object, clean old targets by gc.
  _eventTargets = <int, EventTarget>{};
}

class EventTarget {
  // A unique target identifier.
  int targetId;

  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  EventTarget(int targetId) {
    assert(targetId != null);
    this.targetId = targetId;
  }

  void addEvent(String eventName) {}

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
    bool cancelled = true;
    event.currentTarget = event.target = this;
    while (event.currentTarget != null) {
      List<EventHandler> handlers = event.currentTarget.getEventHandlers(event.type);
      cancelled = _dispatchEventToTarget(event.currentTarget, handlers, event);
      if (!event.bubbles || cancelled) break;
      if (event.currentTarget is Node) {
        Node currentTarget = event.currentTarget;
        event.currentTarget = currentTarget?.parentNode;
      }
    }
    return cancelled;
  }

  bool _dispatchEventToTarget(EventTarget target, List<EventHandler> handlers, Event event) {
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
