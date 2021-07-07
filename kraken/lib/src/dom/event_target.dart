/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'dart:collection';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

typedef EventHandler = void Function(Event event);

void callNativeMethods(Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeValue> returnedValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
  String method = nativeStringToString(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    JSValueType valueType = JSValueType.values[nativeValue.ref.tag];
    switch(valueType) {
      case JSValueType.TAG_STRING:
        return nativeStringToString(Pointer.fromAddress(nativeValue.ref.u));
      case JSValueType.TAG_INT:
        return nativeValue.ref.u;
      case JSValueType.TAG_BOOL:
        return nativeValue.ref.u == 1;
      case JSValueType.TAG_NULL:
        return null;
      case JSValueType.TAG_FLOAT64:
        return nativeValue.ref.float64;
    }
  });

  EventTarget eventTarget = EventTarget.getEventTargetOfNativePtr(nativeEventTarget);
  dynamic result = eventTarget.handleJSCall(method, values);

  if (result == null) {
    returnedValue.ref.tag = JSValueType.TAG_NULL.index;
  } else if (result is int) {
    returnedValue.ref.tag = JSValueType.TAG_INT.index;
    returnedValue.ref.u = result;
  } else if (result is bool) {
    returnedValue.ref.tag = JSValueType.TAG_BOOL.index;
    returnedValue.ref.u = result ? 1 : 0;
  } else if (result is double) {
    returnedValue.ref.tag = JSValueType.TAG_FLOAT64.index;
    returnedValue.ref.float64 = result;
  } else if (result is String) {
    returnedValue.ref.tag = JSValueType.TAG_STRING.index;
    returnedValue.ref.u = stringToNativeString(result).address;
  } else if (result is Object) {
    String str = jsonEncode(result);
    returnedValue.ref.tag = JSValueType.TAG_JSON.index;
    returnedValue.ref.u = str.toNativeUtf8().address;
  }
}

Pointer<NativeFunction<NativeCallNativeMethods>> _nativeCallNativeMethods = Pointer.fromFunction(callNativeMethods);

class EventTarget {
  static SplayTreeMap<int, EventTarget> _nativeMap = SplayTreeMap();
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

  dynamic handleJSCall(String method, List<dynamic> argv) {
    return {
      'name': 1
    };
  }

  @mustCallSuper
  void dispose() {
    elementManager.removeTarget(this);
    eventHandlers.clear();
    _nativeMap.remove(nativeEventTargetPtr.address);
  }
}
