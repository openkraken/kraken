import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'from_native.dart';
import 'native_value.dart';

// MUST READ:
// All the class which extends Struct class has a corresponding struct in C++ code.
// All class members include variables and functions must be follow the same order with C++ struct, to keep the same memory layout cross dart and C++ code.

typedef NativeGetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);

class NativeKrakenInfo extends Struct {
  external Pointer<Utf8> app_name;
  external Pointer<Utf8> app_version;
  external Pointer<Utf8> app_revision;
  external Pointer<Utf8> system_name;
  external Pointer<NativeFunction<NativeGetUserAgent>> getUserAgent;
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

  external Pointer<NativeEventTarget> target;

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


typedef NativeDispatchEvent = Void Function(
    Pointer<NativeEventTarget> nativeEventTarget,
    Pointer<NativeString> eventType,
    Pointer<Void> nativeEvent,
    Int32 isCustomEvent);
typedef NativeCallNativeMethods = Void Function(
    Pointer<NativeEventTarget> nativeEventTarget,
    Pointer<NativeValue> returnedValue,
    Pointer<NativeString> method,
    Int32 argc,
    Pointer<NativeValue> argv);

class NativeEventTarget extends Struct {
  external Pointer<Void> instance;
  external Pointer<NativeFunction<NativeDispatchEvent>> dispatchEvent;
  external Pointer<NativeFunction<NativeCallNativeMethods>> callNativeMethods;
}

typedef NativeCanvasGetContext = Pointer<NativeCanvasRenderingContext2D> Function(
    Pointer<NativeEventTarget> nativeCanvasElement, Pointer<NativeString> contextId);

typedef NativeRenderingContextSetProperty = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value);
typedef NativeRenderingContextArc = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double radius, Double startAngle, Double endAngle, Double counterclockwise);
typedef NativeRenderingContextArcTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x1, Double y1, Double x2, Double y2, Double radius);
typedef NativeRenderingContextBeginPath = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextClosePath = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextClearRect = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double width, Double height);
typedef NativeRenderingContextDrawImage = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Int32 argumentCount, Pointer<NativeEventTarget> image,
  Double sx, Double sy, Double sWidth, Double sHeight, Double dx, Double dy, Double dWidth, Double dHeight);
typedef NativeRenderingContextStrokeRect = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double width, Double height);
typedef NativeRenderingContextStrokeText = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text, Double x, Double y, Double maxWidth);
typedef NativeRenderingContextSave = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextRestore = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextBezierCurveTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x1, Double y1, Double x2, Double y2, Double x, Double y);
typedef NativeRenderingContextClip = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> fillRule);
typedef NativeRenderingContextEllipse = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double radiusX, Double radiusY, Double rotation, Double startAngle, Double endAngle, Double counterclockwise);
typedef NativeRenderingContextFill = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> fillRule);
typedef NativeRenderingContextFillRect = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double width, Double height);
typedef NativeRenderingContextFillText = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text, Double x, Double y, Double maxWidth);
typedef NativeRenderingContextLineTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y);
typedef NativeRenderingContextMoveTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y);
typedef NativeRenderingContextQuadraticCurveTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double cpx, Double cpy, Double x, Double y);
typedef NativeRenderingContextRect = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double width, Double height);
typedef NativeRenderingContextRotate = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double angle);
typedef NativeRenderingContextResetTransform = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextScale = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y);
typedef NativeRenderingContextStroke = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextSetTransform = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double a, Double b, Double c, Double d, Double e, Double f);
typedef NativeRenderingContextTransform = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double a, Double b, Double c, Double d, Double e, Double f);
typedef NativeRenderingContextTranslate = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y);

class NativeCanvasRenderingContext2D extends Struct {
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setDirection;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setFont;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setFillStyle;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setStrokeStyle;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineCap;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineDashOffset;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineJoin;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineWidth;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setMiterLimit;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setTextAlign;
  external Pointer<NativeFunction<NativeRenderingContextSetProperty>> setTextBaseline;
  external Pointer<NativeFunction<NativeRenderingContextArc>> arc;
  external Pointer<NativeFunction<NativeRenderingContextArcTo>> arcTo;
  external Pointer<NativeFunction<NativeRenderingContextBeginPath>> beginPath;
  external Pointer<NativeFunction<NativeRenderingContextBezierCurveTo>> bezierCurveTo;
  external Pointer<NativeFunction<NativeRenderingContextClearRect>> clearRect;
  external Pointer<NativeFunction<NativeRenderingContextClip>> clip;
  external Pointer<NativeFunction<NativeRenderingContextClosePath>> closePath;
  external Pointer<NativeFunction<NativeRenderingContextDrawImage>> drawImage;
  external Pointer<NativeFunction<NativeRenderingContextEllipse>> ellipse;
  external Pointer<NativeFunction<NativeRenderingContextFill>> fill;
  external Pointer<NativeFunction<NativeRenderingContextFillRect>> fillRect;
  external Pointer<NativeFunction<NativeRenderingContextFillText>> fillText;
  external Pointer<NativeFunction<NativeRenderingContextLineTo>> lineTo;
  external Pointer<NativeFunction<NativeRenderingContextMoveTo>> moveTo;
  external Pointer<NativeFunction<NativeRenderingContextQuadraticCurveTo>> quadraticCurveTo;
  external Pointer<NativeFunction<NativeRenderingContextRect>> rect;
  external Pointer<NativeFunction<NativeRenderingContextRestore>> restore;
  external Pointer<NativeFunction<NativeRenderingContextRotate>> rotate;
  external Pointer<NativeFunction<NativeRenderingContextResetTransform>> resetTransform;
  external Pointer<NativeFunction<NativeRenderingContextSave>> save;
  external Pointer<NativeFunction<NativeRenderingContextScale>> scale;
  external Pointer<NativeFunction<NativeRenderingContextStroke>> stroke;
  external Pointer<NativeFunction<NativeRenderingContextStrokeRect>> strokeRect;
  external Pointer<NativeFunction<NativeRenderingContextStrokeText>> strokeText;
  external Pointer<NativeFunction<NativeRenderingContextSetTransform>> setTransform;
  external Pointer<NativeFunction<NativeRenderingContextTransform>> transform;
  external Pointer<NativeFunction<NativeRenderingContextTranslate>> translate;
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
