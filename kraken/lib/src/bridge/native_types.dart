/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'from_native.dart';
import 'native_value.dart';

// MUST READ:
// All the class which extends Struct class has a corresponding struct in C++ code.
// All class members include variables and functions must be follow the same order with C++ struct, to keep the same memory layout cross dart and C++ code.

class NativeKrakenInfo extends Struct {
  external Pointer<Utf8> app_name;
  external Pointer<Utf8> app_version;
  external Pointer<Utf8> app_revision;
  external Pointer<Utf8> system_name;
}

// For memory compatibility between NativeEvent and other struct which inherit NativeEvent(exp: NativeTouchEvent, NativeGestureEvent),
// We choose to make all this structs have same memory layout. But dart lang did't provide semantically syntax to achieve this (like inheritance a class which extends Struct
// or declare struct memory by value).
// The only worked ways is use raw bytes to store NativeEvent members.
class RawNativeEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeInputEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   NativeString *inputType;
//   NativeString *data
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeMediaErrorEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   int64_t code;
//   NativeString *message;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeMessageEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   NativeString *data;
//   NativeString *origin;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}
//
class RawNativeCustomEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   NativeString *detail;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeMouseEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   double clientX;
//   double clientY;
//   double offsetX;
//   double offsetY;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeGestureEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   NativeString *state;
//   NativeString *direction;
//   double deltaX;
//   double deltaY;
//   double velocityX;
//   double velocityY;
//   double scale;
//   double rotation;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeCloseEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   int64_t code;
//   NativeString *reason;
//   int64_t wasClean;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeIntersectionChangeEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   double intersectionRatio;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class RawNativeTouchEvent extends Struct {
// Raw bytes represent the following fields.
//   NativeString *type;
//   int64_t bubbles;
//   int64_t cancelable;
//   int64_t timeStamp;
//   int64_t defaultPrevented;
//   void *target;
//   void *currentTarget;
//   double intersectionRatio;
//   NativeTouch **touches;
//   int64_t touchLength;
//   NativeTouch **targetTouches;
//   int64_t targetTouchLength;
//   NativeTouch **changedTouches;
//   int64_t changedTouchesLength;
//   int64_t altKey;
//   int64_t metaKey;
//   int64_t ctrlKey;
//   int64_t shiftKey;
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
}

class NativeTouch extends Struct {
  @Int64()
  external int identifier;

  external Pointer<NativeBindingObject> target;

  @Double()
  external double clientX;

  @Double()
  external double clientY;

  @Double()
  external double screenX;

  @Double()
  external double screenY;

  @Double()
  external double pageX;

  @Double()
  external double pageY;

  @Double()
  external double radiusX;

  @Double()
  external double radiusY;

  @Double()
  external double rotationAngle;

  @Double()
  external double force;

  @Double()
  external double altitudeAngle;

  @Double()
  external double azimuthAngle;

  @Int64()
  external int touchType;
}

class NativeBoundingClientRect extends Struct {
  @Double()
  external double x;

  @Double()
  external double y;

  @Double()
  external double width;

  @Double()
  external double height;

  @Double()
  external double top;

  @Double()
  external double right;

  @Double()
  external double bottom;

  @Double()
  external double left;
}


typedef NativeDispatchEvent = Int32 Function(
    Int32 contextId,
    Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeString> eventType,
    Pointer<Void> nativeEvent,
    Int32 isCustomEvent);
typedef NativeInvokeBindingMethod = Void Function(
    Pointer<Void> nativePtr,
    Pointer<NativeValue> returnValue,
    Pointer<NativeString> method,
    Int32 argc,
    Pointer<NativeValue> argv);

class NativeBindingObject extends Struct {
  external Pointer<Void> instance;
  external Pointer<NativeFunction<NativeDispatchEvent>> dispatchEvent;
  // Shared method called by JS side.
  external Pointer<NativeFunction> invokeBindingMethod;
}

class NativeCanvasRenderingContext2D extends Struct {
  external Pointer<NativeFunction> invokeBindingMethod;
}

class NativePerformanceEntry extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> entryType;

  @Double()
  external double startTime;
  @Double()
  external double duration;
}

class NativePerformanceEntryList extends Struct {
  external Pointer<Uint64> entries;

  @Int32()
  external int length;
}
