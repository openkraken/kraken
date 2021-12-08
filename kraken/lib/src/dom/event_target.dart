/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:meta/meta.dart';

typedef EventHandler = void Function(Event event);

typedef NativeAsyncAnonymousFunctionCallback = Void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncAnonymousFunctionCallback = void Function(Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, int contextId, Pointer<Utf8> errmsg);

// We have some integrated built-in behavior starting with string prefix reuse the callNativeMethod implements.
final String AnonymousFunctionCallPreFix = '_anonymous_fn_';
final String AsyncAnonymousFunctionCallPreFix = '_anonymous_async_fn_';
final String GetPropertyCallPreFix = '_getProperty_';

void _callNativeMethods(Pointer<Void> nativeEventTarget, Pointer<NativeValue> returnedValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
  String method = nativeStringToString(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    return fromNativeValue(nativeValue);
  });

  if (method.startsWith(AnonymousFunctionCallPreFix)) {
    int id = int.parse(method.substring(AnonymousFunctionCallPreFix.length));
    AnonymousNativeFunction fn = getAnonymousNativeFunctionFromId(id)!;
    try {
      dynamic result = fn(values);
      toNativeValue(returnedValue, result);
    } catch (e, stack) {
      print('$e\n$stack');
      toNativeValue(returnedValue, null);
    }
    removeAnonymousNativeFunctionFromId(id);
  } else if (method.startsWith(AsyncAnonymousFunctionCallPreFix)) {
    int id = int.parse(method.substring(AsyncAnonymousFunctionCallPreFix.length));
    AsyncAnonymousNativeFunction fn = getAsyncAnonymousNativeFunctionFromId(id)!;
    int contextId = values[0];
    Pointer<Void> callbackContext = (values[1] as Pointer).cast<Void>();
    DartAsyncAnonymousFunctionCallback callback = (values[2] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
    Future<dynamic> p = fn(values.sublist(3));
    p.then((result) {
      Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
      toNativeValue(nativeValue, result);
      callback(callbackContext, nativeValue, contextId, nullptr);
      removeAsyncAnonymousNativeFunctionFromId(id);
    }).catchError((e, stack) {
      String errorMessage = '$e';
      callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
      removeAsyncAnonymousNativeFunctionFromId(id);
    });

    toNativeValue(returnedValue, null);
  } else {
    EventTarget eventTarget = EventTarget.getEventTargetByPointer(nativeEventTarget.cast<NativeEventTarget>());
    try {
      if (method.startsWith(GetPropertyCallPreFix) && values.isEmpty) {
        String key = method.substring(GetPropertyCallPreFix.length);
        dynamic result = (eventTarget as Element).getProperty(key);
        toNativeValue(returnedValue, result);
      } else {
        dynamic result = eventTarget.handleJSCall(method, values);
        toNativeValue(returnedValue, result);
      }
    } catch (e, stack) {
      print('$e\n$stack');
      toNativeValue(returnedValue, null);
    }
  }
}

String jsMethodToKey(String method) {
  return method[3].toLowerCase() + method.substring(4);
}

Pointer<NativeFunction<NativeCallNativeMethods>> _nativeCallNativeMethods = Pointer.fromFunction(_callNativeMethods);

class EventTargetContext {
  final int contextId;
  final Pointer<NativeEventTarget> pointer;
  const EventTargetContext(this.contextId, this.pointer);
}

abstract class EventTarget {
  static final SplayTreeMap<int, EventTarget> _nativeMap = SplayTreeMap();
  static EventTarget getEventTargetByPointer(Pointer<NativeEventTarget> pointer) {
    EventTarget? target = _nativeMap[pointer.address];
    if (target == null) throw FlutterError('Can not get eventTarget by pointer: $pointer');
    return target;
  }

  // JS side context id.
  int? contextId;
  // JS side EventTarget object pointer.
  Pointer<NativeEventTarget>? pointer;

  bool _disposed = false;
  bool get disposed => _disposed;

  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  EventTarget(EventTargetContext? context) {
    if (context != null) {
      contextId = context.contextId;
      pointer = context.pointer;
      pointer!.ref.callNativeMethods = _nativeCallNativeMethods;
      _nativeMap[pointer!.address] = this;
    }
  }

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

  @mustCallSuper
  void dispatchEvent(Event event) {
    if (disposed) return;
    event.target = this;
    if (contextId != null && pointer != null) {
      emitUIEvent(contextId!, pointer!, event);
    }
  }

  Map<String, List<EventHandler>> getEventHandlers() {
    return eventHandlers;
  }

  @mustCallSuper
  dynamic handleJSCall(String method, List<dynamic> argv) {}

  @mustCallSuper
  void dispose() {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_START, uniqueId: hashCode);
    }

    _disposed = true;
    eventHandlers.clear();

    if (pointer != null) {
      _nativeMap.remove(pointer!.address);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_END, uniqueId: hashCode);
    }
  }
}
