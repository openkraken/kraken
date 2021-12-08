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
    EventTarget eventTarget = EventTarget.getEventTargetOfNativePtr(nativeEventTarget.cast<NativeEventTarget>());
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

abstract class EventTarget {
  static final SplayTreeMap<int, EventTarget> _nativeMap = SplayTreeMap();
  static EventTarget getEventTargetOfNativePtr(Pointer<NativeEventTarget> nativePtr) {
    EventTarget? target = _nativeMap[nativePtr.address];
    if (target == null) throw FlutterError('Can not get eventTarget of nativePtr: $nativePtr');
    return target;
  }

  // A unique target identifier.
  final int targetId;

  bool _disposed = false;
  bool get disposed => _disposed;

  // The Add
  final Pointer<NativeEventTarget> nativeEventTargetPtr;

  // the self reference the ElementManager
  ElementManager elementManager;

  @protected
  Map<String, List<EventHandler>> eventHandlers = {};

  EventTarget(this.targetId, this.nativeEventTargetPtr, this.elementManager) {
    nativeEventTargetPtr.ref.callNativeMethods = _nativeCallNativeMethods;
    _nativeMap[nativeEventTargetPtr.address] = this;
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

  void dispatchEvent(Event event) {
    if (disposed) return;

    event.target = this;

    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
    // Dispatch listener for widget.
    if (elementManager.gestureListener != null) {
      if (elementManager.gestureListener?.onTouchStart != null && event.type == EVENT_TOUCH_START) {
        elementManager.gestureListener?.onTouchStart!(event as TouchEvent);
      }

      if (elementManager.gestureListener?.onTouchMove != null && event.type == EVENT_TOUCH_MOVE) {
        elementManager.gestureListener?.onTouchMove!(event as TouchEvent);
      }

      if (elementManager.gestureListener?.onTouchEnd != null && event.type == EVENT_TOUCH_END) {
        elementManager.gestureListener?.onTouchEnd!(event as TouchEvent);
      }
    }
  }

  Map<String, List<EventHandler>> getEventHandlers() {
    return eventHandlers;
  }

  @mustCallSuper
  dynamic handleJSCall(String method, List<dynamic> argv) {
  }

  @mustCallSuper
  void dispose() {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_START, uniqueId: targetId);
    }

    elementManager.removeTarget(this);
    eventHandlers.clear();
    _nativeMap.remove(nativeEventTargetPtr.address);
    _disposed = true;

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DISPOSE_EVENT_TARGET_END, uniqueId: targetId);
    }
  }

  // void addEvent(String eventType) {}
}
