/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

import 'from_native.dart';

class NativeValue extends Struct {
  @Double()
  external double float64;

  @Int64()
  external int u;

  @Int64()
  external int tag;
}

enum JSValueType {
  TAG_STRING,
  TAG_INT,
  TAG_BOOL,
  TAG_NULL,
  TAG_FLOAT64,
  TAG_JSON,
  TAG_POINTER,
  TAG_FUNCTION,
  TAG_ASYNC_FUNCTION
}

enum JSPointerType {
  AsyncFunctionContext,
  NativeFunctionContext,
  NativeBoundingClientRect,
  NativeCanvasRenderingContext2D,
  NativeEventTarget
}

typedef AnonymousNativeFunction = dynamic Function(List<dynamic> args);
typedef AsyncAnonymousNativeFunction = Future<dynamic> Function(List<dynamic> args);

int _functionId = 0;
LinkedHashMap<int, AnonymousNativeFunction> _functionMap = LinkedHashMap();
LinkedHashMap<int, AsyncAnonymousNativeFunction> _asyncFunctionMap = LinkedHashMap();

AnonymousNativeFunction? getAnonymousNativeFunctionFromId(int id) {
  return _functionMap[id];
}
AsyncAnonymousNativeFunction? getAsyncAnonymousNativeFunctionFromId(int id) {
  return _asyncFunctionMap[id];
}

void removeAnonymousNativeFunctionFromId(int id) {
  _functionMap.remove(id);
}
void removeAsyncAnonymousNativeFunctionFromId(int id) {
  _asyncFunctionMap.remove(id);
}

dynamic fromNativeValue(Pointer<NativeValue> nativeValue) {
  if (nativeValue == nullptr) return null;

  JSValueType type = JSValueType.values[nativeValue.ref.tag];
  switch(type) {
    case JSValueType.TAG_STRING:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      String result = nativeStringToString(nativeString);
      freeNativeString(nativeString);
      return result;
    case JSValueType.TAG_INT:
      return nativeValue.ref.u;
    case JSValueType.TAG_BOOL:
      return nativeValue.ref.u == 1;
    case JSValueType.TAG_NULL:
      return null;
    case JSValueType.TAG_FLOAT64:
      return nativeValue.ref.float64;
    case JSValueType.TAG_POINTER:
      JSPointerType pointerType = JSPointerType.values[nativeValue.ref.float64.toInt()];
      switch (pointerType) {
        case JSPointerType.NativeBoundingClientRect:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeBoundingClientRect>();
        case JSPointerType.NativeCanvasRenderingContext2D:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeCanvasRenderingContext2D>();
        case JSPointerType.NativeEventTarget:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeEventTarget>();
        default:
          return Pointer.fromAddress(nativeValue.ref.u);
      }
    case JSValueType.TAG_FUNCTION:
    case JSValueType.TAG_ASYNC_FUNCTION:
      break;
    case JSValueType.TAG_JSON:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      dynamic value = jsonDecode(nativeStringToString(nativeString));
      freeNativeString(nativeString);
      return value;
  }
}

void toNativeValue(Pointer<NativeValue> target, dynamic value) {

  if (value == null) {
    target.ref.tag = JSValueType.TAG_NULL.index;
  } else if (value is int) {
    target.ref.tag = JSValueType.TAG_INT.index;
    target.ref.u = value;
  } else if (value is bool) {
    target.ref.tag = JSValueType.TAG_BOOL.index;
    target.ref.u = value ? 1 : 0;
  } else if (value is double) {
    target.ref.tag = JSValueType.TAG_FLOAT64.index;
    target.ref.float64 = value;
  } else if (value is String) {
    target.ref.tag = JSValueType.TAG_STRING.index;
    target.ref.u = stringToNativeString(value).address;
  } else if (value is Pointer) {
    target.ref.tag = JSValueType.TAG_POINTER.index;
    target.ref.u = value.address;
    if (value is Pointer<NativeBoundingClientRect>) {
      target.ref.float64 = JSPointerType.NativeBoundingClientRect.index.toDouble();
    } else if (value is Pointer<NativeCanvasRenderingContext2D>) {
      target.ref.float64 = JSPointerType.NativeCanvasRenderingContext2D.index.toDouble();
    } else if (value is Pointer<NativeEventTarget>) {
      target.ref.float64 = JSPointerType.NativeEventTarget.index.toDouble();
    }
  } else if (value is AsyncAnonymousNativeFunction) {
    int id = _functionId++;
    _asyncFunctionMap[id] = value;
    target.ref.tag = JSValueType.TAG_ASYNC_FUNCTION.index;
    target.ref.u = id;
  } else if (value is AnonymousNativeFunction) {
    int id = _functionId++;
    _functionMap[id] = value;
    target.ref.tag = JSValueType.TAG_FUNCTION.index;
    target.ref.u = id;
  } else if (value is Object) {
    String str = jsonEncode(value);
    target.ref.tag = JSValueType.TAG_JSON.index;
    target.ref.u = str.toNativeUtf8().address;
  }
}
