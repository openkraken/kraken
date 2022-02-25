/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/module.dart';
import 'package:meta/meta.dart';

import 'dart:ffi';

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

  void addEventListener(String eventType, EventHandler eventHandler) {
    if (_disposed) return;

    List<EventHandler>? existHandler = _eventHandlers[eventType];
    if (existHandler == null) {
      _eventHandlers[eventType] = existHandler = [];
    }
    existHandler.add(eventHandler);
  }

  void removeEventListener(String eventType, EventHandler eventHandler) {
    if (_disposed) return;

    List<EventHandler>? currentHandlers = _eventHandlers[eventType];
    currentHandlers?.remove(eventHandler);
  }

  @mustCallSuper
  void dispatchEvent(Event event) {
    if (_disposed) return;

    event.target = this;
    if (contextId != null && pointer != null) {
      emitUIEvent(contextId!, pointer!, event);
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
}

// Used for input.
// @TODO: Should remove it.
mixin _Focusable {
  void focus() {}
  void blur() {}
}
