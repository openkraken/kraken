/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/module.dart';
import 'package:meta/meta.dart';

typedef EventHandler = void Function(Event event);

abstract class EventTarget extends BindingObject with _Focusable {
  EventTarget(BindingContext? context) : super(context);

  bool _disposed = false;
  bool get disposed => _disposed;

  @protected
  final Map<String, List<EventHandler>> _eventHandlers = {};

  @protected
  Map<String, List<EventHandler>> getEventHandlers() => _eventHandlers;

  @protected
  bool hasEventListener(String type) => _eventHandlers.containsKey(type);

  @mustCallSuper
  void addEventListener(String eventType, EventHandler eventHandler) {
    if (_disposed) return;

    List<EventHandler>? existHandler = _eventHandlers[eventType];
    if (existHandler == null) {
      _eventHandlers[eventType] = existHandler = [];
    }

    if (existHandler.isEmpty) {
      addEventsToRenderBoxModel(eventType);
    }

    existHandler.add(eventHandler);
  }

  @mustCallSuper
  void removeEventListener(String eventType, EventHandler eventHandler) {
    if (_disposed) return;

    List<EventHandler>? currentHandlers = _eventHandlers[eventType];
    if (currentHandlers != null) {
      currentHandlers.remove(eventHandler);
      if (currentHandlers.isEmpty) {
        _eventHandlers.remove(eventType);
        removeEventsFromRenderBoxModel(eventType);
      }
    }
  }

  @protected
  void addAllEventsToRenderBoxModel() {
    _eventHandlers.keys.forEach(addEventsToRenderBoxModel);
  }

  @protected
  void removeAllEventsFromRenderBoxModel() {
    _eventHandlers.keys.forEach(removeEventsFromRenderBoxModel);
  }

  // Add event to events of render when listening is required to add corresponding events on the element.
  @protected
  void addEventsToRenderBoxModel(String eventType);

  // Remove event from events of render when there is no corresponding event to listen for on the element.
  @protected
  void removeEventsFromRenderBoxModel(String eventType);

  @mustCallSuper
  void dispatchEvent(Event event) {
    if (_disposed) return;

    event.currentTarget = this;
    String eventType = event.type;
    List<EventHandler>? existHandler = _eventHandlers[eventType];
    if (existHandler != null) {
      for (EventHandler handler in existHandler) {
        handler(event);
      }
    }

    // Bubble event to root event target.
    if (event.bubbles && parent != null) {
      parent?.dispatchEvent(event);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_START, uniqueId: hashCode);
    }

    _disposed = true;
    _eventHandlers.clear();
    super.dispose();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_END, uniqueId: hashCode);
    }
  }

  EventTarget? get parent;
}

// Used for input.
// @TODO: Should remove it.
mixin _Focusable {
  void focus() {}
  void blur() {}
}
