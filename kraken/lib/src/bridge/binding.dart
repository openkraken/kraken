/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
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
void _callNativeMethods(Pointer<Void> nativeBindingObject, Pointer<NativeValue> returnedValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
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
    BindingObject bindingObject = BindingObjectBridge.getBindingObject(nativeBindingObject.cast<NativeBindingObject>());
    var result;
    try {
      if (method == GetPropertyMagic && argc == 1) {
        result = bindingObject.getProperty(values[0]);
      } else if (method == SetPropertyMagic && argc == 2) {
        bindingObject.setProperty(values[0], values[1]);
        result = null;
      } else {
        result = bindingObject.invokeMethod(method, values);
      }
    } catch (e, stack) {
      print('$e\n$stack');
    } finally {
      toNativeValue(returnedValue, result);
    }
  }
}

abstract class BindingObjectBridge {
  static final Pointer<NativeFunction<NativeCallNativeMethods>> _nativeCallNativeMethods = Pointer.fromFunction(_callNativeMethods);

  static final SplayTreeMap<int, BindingObject> _nativeObjects = SplayTreeMap();

  static BindingObject getBindingObject(Pointer<NativeBindingObject> pointer) {
    BindingObject? target = _nativeObjects[pointer.address];
    if (target == null) {
      throw FlutterError('Can not get binding object: $pointer');
    }
    return target;
  }

  static void _bindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = castToType<Pointer<NativeBindingObject>?>(object.pointer);
    if (nativeBindingObject != null) {
      nativeBindingObject.ref.callNativeMethods = _nativeCallNativeMethods;
      _nativeObjects[nativeBindingObject.address] = object;
    }
  }

  static void _unbindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = castToType<Pointer<NativeBindingObject>?>(object.pointer);
    if (nativeBindingObject != null) {
      _nativeObjects.remove(nativeBindingObject.address);
    }
  }

  static void setup() {
    BindingObject.bind = _bindObject;
    BindingObject.unbind = _unbindObject;
  }
}
