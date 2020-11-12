import 'dart:ffi';
import 'package:ffi/ffi.dart';


// representation of JSContext
class JSCallbackContext extends Struct {}

typedef Native_GetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);
typedef Dart_GetUserAgent = Pointer<Utf8> Function(Pointer<NativeKrakenInfo>);

class NativeKrakenInfo extends Struct {
  Pointer<Utf8> app_name;
  Pointer<Utf8> app_version;
  Pointer<Utf8> app_revision;
  Pointer<Utf8> system_name;
  Pointer<NativeFunction<Native_GetUserAgent>> getUserAgent;
}

class NativeEvent extends Struct {
  @Int8()
  int type;

  @Int8()
  int bubbles;

  @Int8()
  int cancelable;

  @Int64()
  int timeStamp;

  @Int8()
  int defaultPrevented;

  Pointer target;

  Pointer currentTarget;
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


typedef Native_DispatchEvent = Void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeEvent> nativeEvent);
typedef Dart_DispatchEvent = void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeEvent> nativeEvent);

class NativeEventTarget extends Struct {
  Pointer<Void> instance;
  Pointer<NativeFunction<Native_DispatchEvent>> dispatchEvent;
}

class NativeNode extends Struct {
  Pointer<NativeEventTarget> nativeEventTarget;
}

typedef Native_GetOffsetTop = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetOffsetLeft = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetOffsetWidth = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetOffsetHeight = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetClientWidth = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetClientHeight = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetClientTop = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetClientLeft = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetScrollLeft = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetScrollTop = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetScrollWidth = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetScrollHeight = Double Function(Int32 contextId, Int64 targetId);
typedef Native_GetBoundingClientRect = Pointer<NativeBoundingClientRect> Function(Int32 contextId, Int64 targetId);
typedef Native_Click = Void Function(Int32 contextId, Int64 targetId);
typedef Native_Scroll = Void Function(Int32 contextId, Int64 targetId, Int32 x, Int32 y);
typedef Native_ScrollBy = Void Function(Int32 contextId, Int64 targetId, Int32 x, Int32 y);

class NativeElement extends Struct {
  Pointer<NativeNode> nativeNode;

  Pointer<NativeFunction<Native_GetOffsetTop>> getOffsetTop;
  Pointer<NativeFunction<Native_GetOffsetLeft>> getOffsetLeft;
  Pointer<NativeFunction<Native_GetOffsetWidth>> getOffsetWidth;
  Pointer<NativeFunction<Native_GetOffsetHeight>> getOffsetHeight;
  Pointer<NativeFunction<Native_GetOffsetWidth>> getClientWidth;
  Pointer<NativeFunction<Native_GetOffsetHeight>> getClientHeight;
  Pointer<NativeFunction<Native_GetClientTop>> getClientTop;
  Pointer<NativeFunction<Native_GetClientLeft>> getClientLeft;
  Pointer<NativeFunction<Native_GetScrollTop>> getScrollTop;
  Pointer<NativeFunction<Native_GetScrollLeft>> getScrollLeft;
  Pointer<NativeFunction<Native_GetScrollWidth>> getScrollWidth;
  Pointer<NativeFunction<Native_GetScrollHeight>> getScrollHeight;
  Pointer<NativeFunction<Native_GetBoundingClientRect>> getBoundingClientRect;
  Pointer<NativeFunction<Native_Click>> click;
  Pointer<NativeFunction<Native_Scroll>> scroll;
  Pointer<NativeFunction<Native_ScrollBy>> scrollBy;
}

class NativeWindow extends Struct {
  Pointer<NativeEventTarget> nativeEventTarget;
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
