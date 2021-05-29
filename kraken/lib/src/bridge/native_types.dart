import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'from_native.dart';

// MUST READ:
// All the class which extends Struct class has a corresponding struct in C++ code.
// All class members include variables and functions must be follow the same order with C++ struct, to keep the same memory layout cross dart and C++ code.

typedef NativeGetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);
typedef DartGetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);

class NativeKrakenInfo extends Struct {
  external Pointer<Utf8> app_name;
  external Pointer<Utf8> app_version;
  external Pointer<Utf8> app_revision;
  external Pointer<Utf8> system_name;
  external Pointer<NativeFunction<NativeGetUserAgent>> getUserAgent;
}

class NativeEvent extends Struct {
  external Pointer<NativeString> type;

  @Int64()
  external int bubbles;

  @Int64()
  external int cancelable;

  @Int64()
  external int timeStamp;

  @Int64()
  external int defaultPrevented;

  external Pointer target;

  external Pointer currentTarget;
}

class NativeInputEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;
  external Pointer<NativeString> inputType;
  external Pointer<NativeString> data;
}

class NativeMediaErrorEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  @Int64()
  external int code;

  external Pointer<NativeString> message;
}

class NativeMessageEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  external Pointer<NativeString> data;
  external Pointer<NativeString> origin;
}

class NativeCustomEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  external Pointer<NativeString> detail;
}

class NativeMouseEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  @Double()
  external double clientX;

  @Double()
  external double clientY;

  @Double()
  external double offsetX;

  @Double()
  external double offsetY;
}

class NativeGestureEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  external Pointer<NativeString> state;

  external Pointer<NativeString> direction;

  @Double()
  external double deltaX;

  @Double()
  external double deltaY;

  @Double()
  external double velocityX;

  @Double()
  external double velocityY;

  @Double()
  external double scale;

  @Double()
  external double rotation;
}

class NativeCloseEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  @Int64()
  external int code;

  external Pointer<NativeString> reason;

  @Int64()
  external int wasClean;
}

class NativeIntersectionChangeEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  @Double()
  external double intersectionRatio;
}

class NativeTouchEvent extends Struct {
  external Pointer<NativeEvent> nativeEvent;

  external Pointer<Pointer<NativeTouch>> touches;
  @Int64()
  external int touchLength;

  external Pointer<Pointer<NativeTouch>> targetTouches;

  @Int64()
  external int targetTouchesLength;

  external Pointer<Pointer<NativeTouch>> changedTouches;

  @Int64()
  external int changedTouchesLength;

  @Int64()
  external int altKey;

  @Int64()
  external int metaKey;

  @Int64()
  external int ctrlKey;

  @Int64()
  external int shiftKey;
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
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeString> eventType, Pointer<Void> nativeEvent, Int32 isCustomEvent);
typedef DartDispatchEvent = void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeString> eventType, Pointer<Void> nativeEvent, int isCustomEvent);

class NativeEventTarget extends Struct {
  external Pointer<Void> instance;
  external Pointer<NativeFunction<NativeDispatchEvent>> dispatchEvent;
}

class NativeNode extends Struct {
  external Pointer<NativeEventTarget> nativeEventTarget;
}

typedef NativeGetViewModuleProperty = Double Function(Pointer<NativeElement> nativeElement, Int64 property);
typedef NativeGetBoundingClientRect = Pointer<NativeBoundingClientRect> Function(Pointer<NativeElement> nativeElement);
typedef NativeGetStringValueProperty = Pointer<NativeString> Function(Pointer<NativeElement> nativeElement, Pointer<NativeString> property);
typedef NativeClick = Void Function(Pointer<NativeElement> nativeElement);
typedef NativeScroll = Void Function(Pointer<NativeElement> nativeElement, Int32 x, Int32 y);
typedef NativeScrollBy = Void Function(Pointer<NativeElement> nativeElement, Int32 x, Int32 y);
typedef NativeSetViewModuleProperty = Void Function(Pointer<NativeElement> nativeElement, Int64 property, Double value);

class NativeElement extends Struct {
  external Pointer<NativeNode> nativeNode;

  external Pointer<NativeFunction<NativeGetViewModuleProperty>> getViewModuleProperty;
  external Pointer<NativeFunction<NativeSetViewModuleProperty>> setViewModuleProperty;
  external Pointer<NativeFunction<NativeGetBoundingClientRect>> getBoundingClientRect;
  external Pointer<NativeFunction<NativeGetStringValueProperty>> getStringValueProperty;
  external Pointer<NativeFunction<NativeClick>> click;
  external Pointer<NativeFunction<NativeScroll>> scroll;
  external Pointer<NativeFunction<NativeScrollBy>> scrollBy;
}

typedef NativeWindowOpen = Void Function(Pointer<NativeWindow> nativeWindow, Pointer<NativeString> url);
typedef NativeWindowScrollX = Double Function(Pointer<NativeWindow> nativeWindow);
typedef NativeWindowScrollY = Double Function(Pointer<NativeWindow> nativeWindow);
typedef NativeWindowScrollTo = Void Function(Pointer<NativeWindow> nativeWindow, Int32 x, Int32 y);
typedef NativeWindowScrollBy = Void Function(Pointer<NativeWindow> nativeWindow, Int32 x, Int32 y);

class NativeWindow extends Struct {
  external Pointer<NativeEventTarget> nativeEventTarget;
  external Pointer<NativeFunction<NativeWindowOpen>> open;
  external Pointer<NativeFunction<NativeWindowScrollX>> scrollX;
  external Pointer<NativeFunction<NativeWindowScrollY>> scrollY;
  external Pointer<NativeFunction<NativeWindowScrollTo>> scrollTo;
  external Pointer<NativeFunction<NativeWindowScrollBy>> scrollBy;
}

class NativeDocument extends Struct {
  external Pointer<NativeNode> nativeNode;
}

class NativeTextNode extends Struct {
  external Pointer<NativeNode> nativeNode;
}

class NativeCommentNode extends Struct {
  external Pointer<NativeNode> nativeNode;
}

class NativeAnchorElement extends Struct {
  external Pointer<NativeElement> nativeElement;
}

typedef GetImageWidth = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageHeight = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageNaturalWidth = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageNaturalHeight = Double Function(Pointer<NativeImgElement> nativePtr);

typedef GetInputWidth = Double Function(Pointer<NativeInputElement> nativePtr);
typedef GetInputHeight = Double Function(Pointer<NativeInputElement> nativePtr);
typedef InputElementMethodVoidCallback = Void Function(Pointer<NativeInputElement> nativePtr);

class NativeImgElement extends Struct {
  external Pointer<NativeElement> nativeElement;

  external Pointer<NativeFunction<GetImageWidth>> getImageWidth;
  external Pointer<NativeFunction<GetImageHeight>> getImageHeight;
  external Pointer<NativeFunction<GetImageNaturalWidth>> getImageNaturalWidth;
  external Pointer<NativeFunction<GetImageNaturalHeight>> getImageNaturalHeight;
}

class NativeObjectElement extends Struct {
  external Pointer<NativeElement> nativeElement;
}

class NativeInputElement extends Struct {
  external Pointer<NativeElement> nativeElement;

  external Pointer<NativeFunction<GetInputWidth>> getInputWidth;
  external Pointer<NativeFunction<GetInputHeight>> getInputHeight;
  external Pointer<NativeFunction<InputElementMethodVoidCallback>> focus;
  external Pointer<NativeFunction<InputElementMethodVoidCallback>> blur;
}

typedef NativeCanvasGetContext = Pointer<NativeCanvasRenderingContext2D> Function(
    Pointer<NativeCanvasElement> nativeCanvasElement, Pointer<NativeString> contextId);

class NativeCanvasElement extends Struct {
  external Pointer<NativeElement> nativeElement;
  external Pointer<NativeFunction<NativeCanvasGetContext>> getContext;
}

typedef NativeRenderingContextSetProperty = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value);

typedef NativeRenderingContextArc = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double radius, Double startAngle, Double endAngle, Double counterclockwise);
typedef NativeRenderingContextArcTo = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x1, Double y1, Double x2, Double y2, Double radius);
typedef NativeRenderingContextBeginPath = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextClosePath = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr);
typedef NativeRenderingContextClearRect = Void Function(Pointer<NativeCanvasRenderingContext2D> nativePtr, Double x, Double y, Double width, Double height);
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
