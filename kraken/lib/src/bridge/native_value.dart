import 'dart:ffi';
import 'package:kraken/bridge.dart';

import 'from_native.dart';
import 'dart:convert';
import 'package:ffi/ffi.dart';

class NativeValue extends Struct {
  @Double()
  external double float64;

  @Int64()
  external int u;

  @Int32()
  external int tag;
}

enum JSValueType {
  TAG_STRING,
  TAG_INT,
  TAG_BOOL,
  TAG_NULL,
  TAG_FLOAT64,
  TAG_JSON,
  TAG_POINTER
}

enum JSPointerType {
  NativeBoundingClientRect
}

dynamic fromNativeValue(JSValueType type, Pointer<NativeValue> nativeValue) {
  switch(type) {
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
    case JSValueType.TAG_POINTER:
      JSPointerType pointerType = JSPointerType.values[nativeValue.ref.float64.toInt()];
      switch (pointerType) {
        case JSPointerType.NativeBoundingClientRect:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeBoundingClientRect>();
      }
    case JSValueType.TAG_JSON:
      return jsonDecode(nativeStringToString(Pointer.fromAddress(nativeValue.ref.u)));
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
    }
  } else if (value is Object) {
    String str = jsonEncode(value);
    target.ref.tag = JSValueType.TAG_JSON.index;
    target.ref.u = str.toNativeUtf8().address;
  }
}
