/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

// We have some integrated built-in behavior starting with string prefix reuse the callNativeMethod implements.
const String AnonymousFunctionCallPreFix = '_anonymous_fn_';
const String AsyncAnonymousFunctionCallPreFix = '_anonymous_async_fn_';
const String GetPropertyMagic = '%g';
const String SetPropertyMagic = '%s';

typedef NativeAsyncAnonymousFunctionCallback = Void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncAnonymousFunctionCallback = void Function(Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, int contextId, Pointer<Utf8> errmsg);

// This function receive calling from binding side.
void _invokeBindingMethod(Pointer<Void> nativeBindingObject, Pointer<NativeValue> returnValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
  String method = nativeStringToString(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    return fromNativeValue(nativeValue);
  });

  if (method.startsWith(AnonymousFunctionCallPreFix)) {
    int id = int.parse(method.substring(AnonymousFunctionCallPreFix.length));
    AnonymousNativeFunction fn = getAnonymousNativeFunctionFromId(id)!;
    try {
      var result = fn(values);
      toNativeValue(returnValue, result);
    } catch (e, stack) {
      print('$e\n$stack');
      toNativeValue(returnValue, null);
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

    toNativeValue(returnValue, null);
  } else {
    // @TODO: Should not share the same binding method, and separate by magic.
    BindingObject bindingObject = BindingBridge.getBindingObject(nativeBindingObject.cast<NativeBindingObject>());
    var result;
    try {
      if (method == GetPropertyMagic && argc == 1) {
        result = bindingObject.getBindingProperty(values[0]);
      } else if (method == SetPropertyMagic && argc == 2) {
        bindingObject.setBindingProperty(values[0], values[1]);
        result = null;
      } else {
        result = bindingObject.invokeBindingMethod(method, values);
      }
    } catch (e, stack) {
      print('$e\n$stack');
    } finally {
      toNativeValue(returnValue, result);
    }
  }
}

// Dispatch the event to the binding side.
void _dispatchBindingEvent(Event event) {
  Pointer<NativeBindingObject>? pointer = event.currentTarget?.pointer;
  int? contextId = event.target?.contextId;
  if (contextId != null && pointer != null) {
    emitUIEvent(contextId, pointer, event);
  }
}

abstract class BindingBridge {
  static final Pointer<NativeFunction<NativeInvokeBindingMethod>> _nativeInvokeBindingMethod = Pointer.fromFunction(_invokeBindingMethod);
  static  Pointer<NativeFunction<NativeInvokeBindingMethod>> get nativeInvokeBindingMethod => _nativeInvokeBindingMethod;

  static final SplayTreeMap<int, BindingObject> _nativeObjects = SplayTreeMap();

  static BindingObject getBindingObject(Pointer<NativeBindingObject> pointer) {
    BindingObject? target = _nativeObjects[pointer.address];
    if (target == null) {
      throw FlutterError('Can not get binding object: $pointer');
    }
    return target;
  }

  static void _bindObject(BindingObject object) {
    Pointer? nativeBindingObject = castToType<Pointer?>(object.pointer);
    if (nativeBindingObject != null) {
      _nativeObjects[nativeBindingObject.address] = object;
      if (nativeBindingObject is Pointer<NativeBindingObject>) {
        nativeBindingObject.ref.invokeBindingMethod = _nativeInvokeBindingMethod;
      } else if (nativeBindingObject is Pointer<NativeCanvasRenderingContext2D>) {
        // @TODO: Remove it.
        nativeBindingObject.ref.invokeBindingMethod = _nativeInvokeBindingMethod;
      }
    }
  }

  static void _unbindObject(BindingObject object) {
    Pointer? nativeBindingObject = castToType<Pointer?>(object.pointer);
    if (nativeBindingObject != null) {
      _nativeObjects.remove(nativeBindingObject.address);
      if (nativeBindingObject is Pointer<NativeBindingObject>) {
        nativeBindingObject.ref.invokeBindingMethod = nullptr;
      } else if (nativeBindingObject is Pointer<NativeCanvasRenderingContext2D>)  {
        // @TODO: Remove it.
        nativeBindingObject.ref.invokeBindingMethod = nullptr;
      }
    }
  }

  static void setup() {
    BindingObject.bind = _bindObject;
    BindingObject.unbind = _unbindObject;
  }

  static void teardown() {
    BindingObject.bind = null;
    BindingObject.unbind = null;
  }

  static void listenEvent(EventTarget target, String type) {
    target.addEventListener(type, _dispatchBindingEvent);
  }

  static void unlistenEvent(EventTarget target, String type) {
    target.removeEventListener(type, _dispatchBindingEvent);
  }
}
