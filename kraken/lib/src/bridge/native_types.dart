import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'from_native.dart';

// MUST READ:
// All the class which extends Struct class has a corresponding struct in C++ code.
// All class members include variables and functions must be follow the same order with C++ struct, to keep the same memory layout cross dart and C++ code.

typedef NativeGetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);
typedef DartGetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);

class NativeKrakenInfo extends Struct {
  Pointer<Utf8> app_name;
  Pointer<Utf8> app_version;
  Pointer<Utf8> app_revision;
  Pointer<Utf8> system_name;
  Pointer<NativeFunction<NativeGetUserAgent>> getUserAgent;
}

class NativeEvent extends Struct {
  Pointer<NativeString> type;

  @Int64()
  int bubbles;

  @Int64()
  int cancelable;

  @Int64()
  int timeStamp;

  @Int64()
  int defaultPrevented;

  Pointer target;

  Pointer currentTarget;
}

class NativeInputEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;
  Pointer<NativeString> inputType;
  Pointer<NativeString> data;
}

class NativeMediaErrorEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  @Int64()
  int code;

  Pointer<NativeString> message;
}

class NativeMessageEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  Pointer<NativeString> data;
  Pointer<NativeString> origin;
}

class NativeCustomEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  Pointer<NativeString> detail;
}

class NativeMouseEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  @Double()
  double clientX;

  @Double()
  double clientY;

  @Double()
  double offsetX;

  @Double()
  double offsetY;
}

class NativeGestureEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  Pointer<NativeString> state;

  Pointer<NativeString> direction;

  @Double()
  double deltaX;

  @Double()
  double deltaY;

  @Double()
  double velocityX;

  @Double()
  double velocityY;

  @Double()
  double scale;

  @Double()
  double rotation;
}

class NativeCloseEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  @Int64()
  int code;

  Pointer<NativeString> reason;

  @Int64()
  int wasClean;
}

class NativeIntersectionChangeEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  @Double()
  double intersectionRatio;
}

class NativeTouchEvent extends Struct {
  Pointer<NativeEvent> nativeEvent;

  Pointer<Pointer<NativeTouch>> touches;
  @Int64()
  int touchLength;

  Pointer<Pointer<NativeTouch>> targetTouches;

  @Int64()
  int targetTouchesLength;

  Pointer<Pointer<NativeTouch>> changedTouches;

  @Int64()
  int changedTouchesLength;

  @Int64()
  int altKey;

  @Int64()
  int metaKey;

  @Int64()
  int ctrlKey;

  @Int64()
  int shiftKey;
}

class NativeTouch extends Struct {
  @Int64()
  int identifier;

  Pointer<NativeEventTarget> target;

  @Double()
  double clientX;

  @Double()
  double clientY;

  @Double()
  double screenX;

  @Double()
  double screenY;

  @Double()
  double pageX;

  @Double()
  double pageY;

  @Double()
  double radiusX;

  @Double()
  double radiusY;

  @Double()
  double rotationAngle;

  @Double()
  double force;

  @Double()
  double altitudeAngle;

  @Double()
  double azimuthAngle;

  @Int64()
  int touchType;
}

class NativeBoundingClientRect extends Struct {
  @Double()
  double x;

  @Double()
  double y;

  @Double()
  double width;

  @Double()
  double height;

  @Double()
  double top;

  @Double()
  double right;

  @Double()
  double bottom;

  @Double()
  double left;
}

typedef NativeDispatchEvent = Void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeString> eventType, Pointer<Void> nativeEvent, Int32 isCustomEvent);
typedef DartDispatchEvent = void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeString> eventType, Pointer<Void> nativeEvent, int isCustomEvent);

class NativeEventTarget extends Struct {
  Pointer<Void> instance;
  Pointer<NativeFunction<NativeDispatchEvent>> dispatchEvent;
}

class NativeNode extends Struct {
  Pointer<NativeEventTarget> nativeEventTarget;
}

typedef NativeGetViewModuleProperty = Double Function(Pointer<NativeElement> nativeElement, Int64 property);
typedef NativeGetBoundingClientRect = Pointer<NativeBoundingClientRect> Function(Pointer<NativeElement> nativeElement);
typedef NativeGetStringValueProperty = Pointer<NativeString> Function(Pointer<NativeElement> nativeElement, Pointer<NativeString> property);
typedef NativeClick = Void Function(Pointer<NativeElement> nativeElement);
typedef NativeScroll = Void Function(Pointer<NativeElement> nativeElement, Int32 x, Int32 y);
typedef NativeScrollBy = Void Function(Pointer<NativeElement> nativeElement, Int32 x, Int32 y);
typedef NativeSetViewModuleProperty = Void Function(Pointer<NativeElement> nativeElement, Int64 property, Double value);

class NativeElement extends Struct {
  Pointer<NativeNode> nativeNode;

  Pointer<NativeFunction<NativeGetViewModuleProperty>> getViewModuleProperty;
  Pointer<NativeFunction<NativeSetViewModuleProperty>> setViewModuleProperty;
  Pointer<NativeFunction<NativeGetBoundingClientRect>> getBoundingClientRect;
  Pointer<NativeFunction<NativeGetStringValueProperty>> getStringValueProperty;
  Pointer<NativeFunction<NativeClick>> click;
  Pointer<NativeFunction<NativeScroll>> scroll;
  Pointer<NativeFunction<NativeScrollBy>> scrollBy;
}

typedef NativeWindowOpen = Void Function(Pointer<NativeWindow> nativeWindow, Pointer<NativeString> url);
typedef NativeWindowScrollX = Double Function(Pointer<NativeWindow> nativeWindow);
typedef NativeWindowScrollY = Double Function(Pointer<NativeWindow> nativeWindow);
typedef NativeWindowScrollTo = Void Function(Pointer<NativeWindow> nativeWindow, Int32 x, Int32 y);
typedef NativeWindowScrollBy = Void Function(Pointer<NativeWindow> nativeWindow, Int32 x, Int32 y);

class NativeWindow extends Struct {
  Pointer<NativeEventTarget> nativeEventTarget;
  Pointer<NativeFunction<NativeWindowOpen>> open;
  Pointer<NativeFunction<NativeWindowScrollX>> scrollX;
  Pointer<NativeFunction<NativeWindowScrollY>> scrollY;
  Pointer<NativeFunction<NativeWindowScrollTo>> scrollTo;
  Pointer<NativeFunction<NativeWindowScrollBy>> scrollBy;
}

class NativeDocument extends Struct {
  Pointer<NativeNode> nativeNode;
}

class NativeTextNode extends Struct {
  Pointer<NativeNode> nativeNode;
}

class NativeCommentNode extends Struct {
  Pointer<NativeNode> nativeNode;
}

class NativeAnchorElement extends Struct {
  Pointer<NativeElement> nativeElement;
}

typedef GetImageWidth = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageHeight = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageNaturalWidth = Double Function(Pointer<NativeImgElement> nativePtr);
typedef GetImageNaturalHeight = Double Function(Pointer<NativeImgElement> nativePtr);

typedef GetInputWidth = Double Function(Pointer<NativeInputElement> nativePtr);
typedef GetInputHeight = Double Function(Pointer<NativeInputElement> nativePtr);
typedef InputElementMethodVoidCallback = Void Function(Pointer<NativeInputElement> nativePtr);

class NativeImgElement extends Struct {
  Pointer<NativeElement> nativeElement;

  Pointer<NativeFunction<GetImageWidth>> getImageWidth;
  Pointer<NativeFunction<GetImageHeight>> getImageHeight;
  Pointer<NativeFunction<GetImageNaturalWidth>> getImageNaturalWidth;
  Pointer<NativeFunction<GetImageNaturalHeight>> getImageNaturalHeight;
}

class NativeObjectElement extends Struct {
  Pointer<NativeElement> nativeElement;
}

class NativeInputElement extends Struct {
  Pointer<NativeElement> nativeElement;

  Pointer<NativeFunction<GetInputWidth>> getInputWidth;
  Pointer<NativeFunction<GetInputHeight>> getInputHeight;
  Pointer<NativeFunction<InputElementMethodVoidCallback>> focus;
  Pointer<NativeFunction<InputElementMethodVoidCallback>> blur;
}

typedef NativeCanvasGetContext = Pointer<NativeCanvasRenderingContext2D> Function(
    Pointer<NativeCanvasElement> nativeCanvasElement, Pointer<NativeString> contextId);

class NativeCanvasElement extends Struct {
  Pointer<NativeElement> nativeElement;
  Pointer<NativeFunction<NativeCanvasGetContext>> getContext;
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
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setDirection;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setFont;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setFillStyle;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setStrokeStyle;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineCap;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineDashOffset;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineJoin;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setLineWidth;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setMiterLimit;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setTextAlign;
  Pointer<NativeFunction<NativeRenderingContextSetProperty>> setTextBaseline;
  Pointer<NativeFunction<NativeRenderingContextArc>> arc;
  Pointer<NativeFunction<NativeRenderingContextArcTo>> arcTo;
  Pointer<NativeFunction<NativeRenderingContextBeginPath>> beginPath;
  Pointer<NativeFunction<NativeRenderingContextBezierCurveTo>> bezierCurveTo;
  Pointer<NativeFunction<NativeRenderingContextClearRect>> clearRect;
  Pointer<NativeFunction<NativeRenderingContextClip>> clip;
  Pointer<NativeFunction<NativeRenderingContextClosePath>> closePath;
  Pointer<NativeFunction<NativeRenderingContextEllipse>> ellipse;
  Pointer<NativeFunction<NativeRenderingContextFill>> fill;
  Pointer<NativeFunction<NativeRenderingContextFillRect>> fillRect;
  Pointer<NativeFunction<NativeRenderingContextFillText>> fillText;
  Pointer<NativeFunction<NativeRenderingContextLineTo>> lineTo;
  Pointer<NativeFunction<NativeRenderingContextMoveTo>> moveTo;
  Pointer<NativeFunction<NativeRenderingContextQuadraticCurveTo>> quadraticCurveTo;
  Pointer<NativeFunction<NativeRenderingContextRect>> rect;
  Pointer<NativeFunction<NativeRenderingContextRestore>> restore;
  Pointer<NativeFunction<NativeRenderingContextRotate>> rotate;
  Pointer<NativeFunction<NativeRenderingContextResetTransform>> resetTransform;
  Pointer<NativeFunction<NativeRenderingContextSave>> save;
  Pointer<NativeFunction<NativeRenderingContextScale>> scale;
  Pointer<NativeFunction<NativeRenderingContextStroke>> stroke;
  Pointer<NativeFunction<NativeRenderingContextStrokeRect>> strokeRect;
  Pointer<NativeFunction<NativeRenderingContextStrokeText>> strokeText;
  Pointer<NativeFunction<NativeRenderingContextSetTransform>> setTransform;
  Pointer<NativeFunction<NativeRenderingContextTransform>> transform;
  Pointer<NativeFunction<NativeRenderingContextTranslate>> translate;
}

class NativePerformanceEntry extends Struct {
  Pointer<Utf8> name;
  Pointer<Utf8> entryType;

  @Double()
  double startTime;
  @Double()
  double duration;
}

class NativePerformanceEntryList extends Struct {
  Pointer<Uint64> entries;

  @Int32()
  int length;
}
