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
  final int targetId;

  // The Add
  final Pointer<NativeEventTarget> nativeEventTargetPtr;

  // the self reference the ElementManager
  ElementManager elementManager;

  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  EventTarget(this.targetId, this.nativeEventTargetPtr, this.elementManager);

  void addEvent(String eventType) {}

  void addEventListener(String eventType, EventHandler eventHandler) {
    List<EventHandler>? existHandler = eventHandlers[eventType];
    if (existHandler == null) {
      eventHandlers[eventType] = existHandler = [];
    }
    existHandler.add(eventHandler);
  }

  void removeEventListener(String eventType, EventHandler eventHandler) {
    List<EventHandler>? currentHandlers = eventHandlers[eventType];
    if (currentHandlers == null) {
      return;
    }
    currentHandlers.remove(eventHandler);
  }

  void dispatchEvent(Event event) {
    event.currentTarget = event.target = this;
    if (event.currentTarget != null && this is Element) {
      (this as Element).eventResponder(event);
    }
  }

  Map<String, List<EventHandler>> getEventHandlers() {
    return eventHandlers;
  }

  @mustCallSuper
  void dispose() {
    elementManager.removeTarget(this);
    eventHandlers.clear();
  }
}
