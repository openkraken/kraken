import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';

import 'from_native.dart';
import 'platform.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

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

typedef Native_DispatchEvent = Void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeEvent> nativeEvent);
typedef Dart_DispatchEvent = void Function(
    Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeEvent> nativeEvent);

class NativeEventTarget extends Struct {
  Pointer<Void> instance;
  Pointer<NativeFunction<Native_DispatchEvent>> dispatchEvent;
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
  Pointer<Void> instance;
  Pointer<NativeFunction<Native_DispatchEvent>> dispatchEvent;

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

class KrakenInfo {
  Pointer<NativeKrakenInfo> _nativeKrakenInfo;

  KrakenInfo(Pointer<NativeKrakenInfo> info) : _nativeKrakenInfo = info;

  String get appName {
    if (_nativeKrakenInfo.ref.app_name == nullptr) return '';
    return Utf8.fromUtf8(_nativeKrakenInfo.ref.app_name);
  }

  String get appVersion {
    if (_nativeKrakenInfo.ref.app_version == nullptr) return '';
    return Utf8.fromUtf8(_nativeKrakenInfo.ref.app_version);
  }

  String get appRevision {
    if (_nativeKrakenInfo.ref.app_revision == nullptr) return '';
    return Utf8.fromUtf8(_nativeKrakenInfo.ref.app_revision);
  }

  String get systemName {
    if (_nativeKrakenInfo.ref.system_name == nullptr) return '';
    return Utf8.fromUtf8(_nativeKrakenInfo.ref.system_name);
  }

  String get userAgent {
    if (_nativeKrakenInfo.ref.getUserAgent == nullptr) return '';
    Dart_GetUserAgent getUserAgent = _nativeKrakenInfo.ref.getUserAgent.asFunction();
    return Utf8.fromUtf8(getUserAgent(_nativeKrakenInfo));
  }
}

typedef Native_GetKrakenInfo = Pointer<NativeKrakenInfo> Function();
typedef Dart_GetKrakenInfo = Pointer<NativeKrakenInfo> Function();

final Dart_GetKrakenInfo _getKrakenInfo =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetKrakenInfo>>('getKrakenInfo').asFunction();

KrakenInfo _cachedInfo;

KrakenInfo getKrakenInfo() {
  if (_cachedInfo != null) return _cachedInfo;
  Pointer<NativeKrakenInfo> nativeKrakenInfo = _getKrakenInfo();
  KrakenInfo info = KrakenInfo(nativeKrakenInfo);
  _cachedInfo = info;
  return info;
}

// Register invokeEventListener
typedef Native_InvokeEventListener = Void Function(Int32 contextId, Int32 type, Pointer<NativeString>);
typedef Dart_InvokeEventListener = void Function(int contextId, int type, Pointer<NativeString>);

final Dart_InvokeEventListener _invokeEventListener =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InvokeEventListener>>('invokeEventListener').asFunction();

void invokeEventListener(int contextId, int type, String data) {
  print('type: $type, data: $data');
  Pointer<NativeString> nativeString = stringToNativeString(data);
  _invokeEventListener(contextId, type, nativeString);
  freeNativeString(nativeString);
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(int contextId, Pointer<NativeEventTarget> nativePtr, Pointer<NativeEvent> nativeEvent) {
  print('emit UI Event: $nativePtr');
  Pointer<NativeEventTarget> nativeEventTarget = nativePtr;
  Dart_DispatchEvent dispatchEvent = nativeEventTarget.ref.dispatchEvent.asFunction();
  dispatchEvent(nativeEventTarget, nativeEvent);
  ;
}

void emitModuleEvent(int contextId, String data) {
  invokeEventListener(contextId, MODULE_EVENT, data);
}

void invokeOnPlatformBrightnessChangedCallback(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  EventTarget window = controller.view.getEventTargetById(WINDOW_ID);
  ColorSchemeChangeEvent event = ColorSchemeChangeEvent();
  emitUIEvent(contextId, window.nativePtr, event.toNativeEvent());
}

// Register createScreen
typedef Native_CreateScreen = Pointer<ScreenSize> Function(Double, Double);
typedef Dart_CreateScreen = Pointer<ScreenSize> Function(double, double);

final Dart_CreateScreen _createScreen =
    nativeDynamicLibrary.lookup<NativeFunction<Native_CreateScreen>>('createScreen').asFunction();

Pointer<ScreenSize> createScreen(double width, double height) {
  return _createScreen(width, height);
}

// Register evaluateScripts
typedef Native_EvaluateScripts = Void Function(
    Int32 contextId, Pointer<NativeString> code, Pointer<Utf8> url, Int32 startLine);
typedef Dart_EvaluateScripts = void Function(
    int contextId, Pointer<NativeString> code, Pointer<Utf8> url, int startLine);

final Dart_EvaluateScripts _evaluateScripts =
    nativeDynamicLibrary.lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts').asFunction();

void evaluateScripts(int contextId, String code, String url, int line) {
  Pointer<NativeString> nativeString = stringToNativeString(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  try {
    _evaluateScripts(contextId, nativeString, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
  freeNativeString(nativeString);
}

// Register initJsEngine
typedef Native_InitJSContextPool = Void Function(Int32 poolSize);
typedef Dart_InitJSContextPool = void Function(int poolSize);

final Dart_InitJSContextPool _initJSContextPool =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InitJSContextPool>>('initJSContextPool').asFunction();

void initJSContextPool(int poolSize) {
  _initJSContextPool(poolSize);
}

typedef Native_DisposeContext = Void Function(Int32 contextId);
typedef Dart_DisposeContext = void Function(int contextId);

final Dart_DisposeContext _disposeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_DisposeContext>>('disposeContext').asFunction();

void disposeBridge(int contextId) {
  _disposeContext(contextId);
}

typedef Native_AllocateNewContext = Int32 Function();
typedef Dart_AllocateNewContext = int Function();

final Dart_AllocateNewContext _allocateNewContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_AllocateNewContext>>('allocateNewContext').asFunction();

int allocateNewContext() {
  return _allocateNewContext();
}

// Regisdster reloadJsContext
typedef Native_ReloadJSContext = Void Function(Int32 contextId);
typedef Dart_ReloadJSContext = void Function(int contextId);

final Dart_ReloadJSContext _reloadJSContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ReloadJSContext>>('reloadJsContext').asFunction();

void reloadJSContext(int contextId) async {
  Completer completer = Completer<void>();
  Future.microtask(() {
    _reloadJSContext(contextId);
    completer.complete();
  });
  return completer.future;
}

typedef Native_FrameCallback = Void Function();
typedef Dart_FrameCallback = void Function();

final Dart_FrameCallback _frameCallback =
    nativeDynamicLibrary.lookup<NativeFunction<Native_FrameCallback>>('uiFrameCallback').asFunction();

void bridgeFrameCallback() {
  _frameCallback();
}

enum UICommandType {
  initWindow,
  initBody,
  createElement,
  createTextNode,
  disposeEventTarget,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  setProperty
}

class UICommandItem extends Struct {
  @Int8()
  int type;

  Pointer<Pointer<NativeString>> args;

  @Int64()
  int id;

  @Int32()
  int length;

  Pointer<NativeEventTarget> nativePtr;
}

typedef Native_GetUICommandItems = Pointer<Pointer<UICommandItem>> Function(Int32 contextId);
typedef Dart_GetUICommandItems = Pointer<Pointer<UICommandItem>> Function(int contextId);

final Dart_GetUICommandItems _getUICommandItems =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetUICommandItems>>('getUICommandItems').asFunction();

typedef Native_GetUICommandItemSize = Int32 Function(Int32 contextId);
typedef Dart_GetUICommandItemSize = int Function(int contextId);

final Dart_GetUICommandItemSize _getUICommandItemSize =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetUICommandItemSize>>('getUICommandItemSize').asFunction();

typedef Native_ClearUICommandItems = Void Function(Int32 contextId);
typedef Dart_ClearUICommandItems = void Function(int contextId);

final Dart_ClearUICommandItems _clearUICommandItems =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ClearUICommandItems>>('clearUICommandItems').asFunction();

void _freeUICommand(Pointer<UICommandItem> nativeCommand) {
  for (int i = 0; i < nativeCommand.ref.length; i++) {
    freeNativeString(nativeCommand.ref.args[i]);
  }
  free(nativeCommand.ref.args);
  free(nativeCommand);
}

void flushUICommand() {
  Map<int, KrakenController> controllerMap = KrakenController.getControllerMap();
  for (KrakenController controller in controllerMap.values) {
    Pointer<Pointer<UICommandItem>> nativeCommandItems = _getUICommandItems(controller.view.contextId);
    int itemSize = _getUICommandItemSize(controller.view.contextId);

    // For new ui commands, we needs to tell engine to update frames.
    if (itemSize > 0) {
      window.scheduleFrame();
    }

    for (int i = 0; i < itemSize; i++) {
      Pointer<UICommandItem> nativeCommand = nativeCommandItems[i];
      if (nativeCommand == nullptr) continue;

      UICommandType commandType = UICommandType.values[nativeCommand.ref.type];
      int id = nativeCommand.ref.id;
      switch (commandType) {
        case UICommandType.initWindow:
          controller.view.initWindow(nativeCommand.ref.nativePtr);
          break;
        case UICommandType.initBody:
          controller.view.initBody(nativeCommand.ref.nativePtr);
          break;
        case UICommandType.createElement:
          controller.view
              .createElement(id, nativeCommand.ref.nativePtr, nativeStringToString(nativeCommand.ref.args[0]));
          break;
        case UICommandType.createTextNode:
          controller.view.createTextNode(id, nativeCommand.ref.nativePtr, nativeStringToString(nativeCommand.ref.args[0]));
          break;
        case UICommandType.disposeEventTarget:
          ElementManager.disposeEventTarget(controller.view.contextId, id);
          break;
        case UICommandType.addEvent:
          String eventType = nativeStringToString(nativeCommand.ref.args[0]);
          controller.view.addEvent(id, int.parse(eventType));
          break;
        case UICommandType.insertAdjacentNode:
          int childId = int.parse(nativeStringToString(nativeCommand.ref.args[0]));
          String position = nativeStringToString(nativeCommand.ref.args[1]);
          controller.view.insertAdjacentNode(id, position, childId);
          break;
        case UICommandType.removeNode:
          controller.view.removeNode(id);
          break;
        case UICommandType.setStyle:
          String key = nativeStringToString(nativeCommand.ref.args[0]);
          String value = nativeStringToString(nativeCommand.ref.args[1]);
          controller.view.setStyle(id, key, value);
          break;
        case UICommandType.setProperty:
          String key = nativeStringToString(nativeCommand.ref.args[0]);
          String value = nativeStringToString(nativeCommand.ref.args[1]);
          controller.view.setStyle(id, key, value);
          break;
        default:
          return;
      }
      _clearUICommandItems(controller.view.contextId);
      _freeUICommand(nativeCommand);
    }
  }
}
