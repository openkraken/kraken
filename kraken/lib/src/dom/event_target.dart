/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'dart:collection';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

typedef EventHandler = void Function(Event event);

typedef NativeAsyncAnonymousFunctionCallback = Void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncAnonymousFunctionCallback = void Function(Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, int contextId, Pointer<Utf8> errmsg);

void _callNativeMethods(Pointer<Void> nativeEventTarget, Pointer<NativeValue> returnedValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
  String method = nativeStringToString(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    JSValueType type = JSValueType.values[nativeValue.ref.tag];
    return fromNativeValue(type, nativeValue);
  });

  if (method.startsWith('_anonymous_fn_')) {
    int id = int.parse(method.substring('_anonymous_fn_'.length));
    AnonymousNativeFunction fn = getAnonymousNativeFunctionFromId(id)!;
    try {
      dynamic result = fn(values);
      toNativeValue(returnedValue, result);
    } catch (e, stack) {
      print('$e\n$stack');
      toNativeValue(returnedValue, null);
    }
    removeAnonymousNativeFunctionFromId(id);
  } else if (method.startsWith('_anonymous_async_fn_')) {
    int id = int.parse(method.substring('_anonymous_fn_'.length));
    AsyncAnonymousNativeFunction fn = getAsyncAnonymousNativeFunctionFromId(id)!;
    int contextId = values[0];
    Pointer<Void> callbackContext = values[1];
    DartAsyncAnonymousFunctionCallback callback = (values[2] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
    Future<dynamic> p = fn(values);
    p.then((result) {
      Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
      toNativeValue(nativeValue, result);
      callback(callbackContext, nativeValue, contextId, nullptr);
      removeAsyncAnonymousNativeFunctionFromId(id);
    }).catchError((e, stack) {
      String errorMessage = '$e\n$stack';
      callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
      removeAsyncAnonymousNativeFunctionFromId(id);
    });

    toNativeValue(returnedValue, null);
  } else {
    EventTarget eventTarget = EventTarget.getEventTargetOfNativePtr(nativeEventTarget.cast<NativeEventTarget>());
    try {
      if (method.startsWith('_getProperty_') && values.isEmpty) {
        String key = method.substring('_getProperty_'.length);
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
    if(elementManager.controller.view.disposed) {
      return;
    }
    event.currentTarget = event.target = this;
    if (event.currentTarget != null && this is Element) {
      (this as Element).eventResponder(event);

      // dispatch listener of widget.
      if ((this as Element).elementManager.eventClient != null) {
        (this as Element).elementManager.eventClient!.eventListener(event);
      }
    }
  }

  Map<String, List<EventHandler>> getEventHandlers() {
    return eventHandlers;
  }

  dynamic handleJSCall(String method, List<dynamic> argv);

  @mustCallSuper
  void dispose() {
    elementManager.removeTarget(this);
    eventHandlers.clear();
    _nativeMap.remove(nativeEventTargetPtr.address);
  }
}
