/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:meta/meta.dart';
import 'package:kraken/element.dart';
import 'package:kraken/bridge.dart';
import 'dart:ffi';

typedef EventHandler = void Function(Event event);

class EventTarget {
  // A unique target identifier.
  int targetId;
  // The Add
  Pointer<NativeEventTarget> nativePtr;

  // the self reference the ElementManager
  ElementManager elementManager;

  @protected
  Map<EventType, List<EventHandler>> eventHandlers = {};

  EventTarget(this.targetId, this.nativePtr, this.elementManager) {
    assert(targetId != null);
    assert(elementManager != null);
  }

  void addEvent(EventType eventType) {}

  void addEventListener(EventType eventType, EventHandler eventHandler) {
    if (!eventHandlers.containsKey(eventHandler)) {
      eventHandlers[eventType] = [];
    }
    eventHandlers[eventType].add(eventHandler);
  }

  void removeEventListener(EventType eventType, EventHandler eventHandler) {
    if (!eventHandlers.containsKey(eventType)) {
      return;
    }
    List<EventHandler> currentHandlers = eventHandlers[eventType];
    currentHandlers.remove(eventHandler);
  }

  /// return whether event is cancelled.
  bool dispatchEvent(Event event) {
    bool cancelled = true;
    event.currentTarget = event.target = this;
    if (event.currentTarget != null) {
      List<EventHandler> handlers = event.currentTarget.getEventHandlers(event.type);
      cancelled = _dispatchEventToTarget(event.currentTarget, handlers, event);
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

  List<EventHandler> getEventHandlers(EventType type) {
    assert(type != null);
    return eventHandlers[type];
  }
}
