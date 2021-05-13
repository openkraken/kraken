/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:meta/meta.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

typedef EventHandler = void Function(Event event);

class EventTarget {
  // A unique target identifier.
  int targetId;

  // The Add
  final Pointer<NativeEventTarget> nativeEventTargetPtr;

  // the self reference the ElementManager
  ElementManager elementManager;

  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  EventTarget(this.targetId, this.nativeEventTargetPtr, this.elementManager) {
    assert(targetId != null);
    assert(elementManager != null);
  }

  void addEvent(String eventType) {}

  void addEventListener(String eventType, EventHandler eventHandler) {
    if (!eventHandlers.containsKey(eventType)) {
      eventHandlers[eventType] = [];
    }
    eventHandlers[eventType].add(eventHandler);
  }

  void removeEventListener(String eventType, EventHandler eventHandler) {
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

  @mustCallSuper
  void dispose() {
    elementManager.removeTarget(this);
    // Remove elementManager reference.
    elementManager = null;
    eventHandlers.clear();
  }

  List<EventHandler> getEventHandlers(String type) {
    assert(type != null);
    return eventHandlers[type];
  }
}
