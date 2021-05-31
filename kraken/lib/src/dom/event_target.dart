// @dart=2.9

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

  void dispatchEvent(Event event) {
    event.currentTarget = event.target = this;
    if (event.currentTarget != null && this is Element) {
      (this as Element).eventResponder(event);
    }
  }

  @mustCallSuper
  void dispose() {
    elementManager.removeTarget(this);
    // Remove elementManager reference.
    elementManager = null;
    eventHandlers.clear();
  }
}
