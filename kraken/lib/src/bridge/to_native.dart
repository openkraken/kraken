import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'dart:io';

import 'from_native.dart';
import 'platform.dart';
import 'native_types.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

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
  Pointer<NativeString> nativeString = stringToNativeString(data);
  _invokeEventListener(contextId, type, nativeString);
  freeNativeString(nativeString);
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(int contextId, Pointer<NativeEventTarget> nativePtr, Event event) {
  Pointer<NativeEventTarget> nativeEventTarget = nativePtr;
  Dart_DispatchEvent dispatchEvent = nativeEventTarget.ref.dispatchEvent.asFunction();
  Pointer<Void> nativeEvent = event.toNativeEvent().cast<Void>();
  dispatchEvent(nativeEventTarget, event.type.index, nativeEvent);
}

void emitModuleEvent(int contextId, String data) {
  invokeEventListener(contextId, MODULE_EVENT, data);
}

void invokeOnPlatformBrightnessChangedCallback(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  Window window = controller.view.getEventTargetById(WINDOW_ID);
  ColorSchemeChangeEvent event = ColorSchemeChangeEvent();
  emitUIEvent(contextId, window.nativeWindowPtr.ref.nativeEventTarget, event);
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

typedef Native_FlushBridgeTask = Void Function();
typedef Dart_FlushBridgeTask = void Function();

final Dart_FlushBridgeTask _flushBridgeTask =
    nativeDynamicLibrary.lookup<NativeFunction<Native_FlushBridgeTask>>('flushBridgeTask').asFunction();

void flushBridgeTask() {
  _flushBridgeTask();
}

enum UICommandType {
  createElement,
  createTextNode,
  createComment,
  disposeEventTarget,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  setProperty,
  removeProperty
}

class UICommandItem extends Struct {
  @Int32()
  int type;

  Pointer<Pointer<NativeString>> args;

  @Int64()
  int id;

  @Int32()
  int length;

  Pointer nativePtr;
}

typedef Native_GetUICommandItems = Pointer<Pointer<UICommandItem>> Function(Int32 contextId);
typedef Dart_GetUICommandItems = Pointer<Pointer<UICommandItem>> Function(int contextId);

final Dart_GetUICommandItems _getUICommandItems =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetUICommandItems>>('getUICommandItems').asFunction();

typedef Native_GetUICommandItemSize = Int64 Function(Int64 contextId);
typedef Dart_GetUICommandItemSize = int Function(int contextId);

final Dart_GetUICommandItemSize _getUICommandItemSize =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetUICommandItemSize>>('getUICommandItemSize').asFunction();

typedef Native_ClearUICommandItems = Void Function(Int32 contextId);
typedef Dart_ClearUICommandItems = void Function(int contextId);

final Dart_ClearUICommandItems _clearUICommandItems =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ClearUICommandItems>>('clearUICommandItems').asFunction();

void flushUICommand() {
  Map<int, KrakenController> controllerMap = KrakenController.getControllerMap();
  for (KrakenController controller in controllerMap.values) {
    Pointer<Pointer<UICommandItem>> nativeCommandItems = _getUICommandItems(controller.view.contextId);
    int commandLength = _getUICommandItemSize(controller.view.contextId);

    // For new ui commands, we needs to tell engine to update frames.
    for (int i = 0; i < commandLength; i++) {
      Pointer<UICommandItem> nativeCommand = nativeCommandItems[i];
      if (nativeCommand == nullptr) continue;

      UICommandType commandType = UICommandType.values[nativeCommand.ref.type];
      int id = nativeCommand.ref.id;

      if (kDebugMode && Platform.environment['ENABLE_KRAKEN_JS_LOG'] == 'true') {
        String printMsg = '$commandType, id: $id';
        for (int i = 0; i < nativeCommand.ref.length; i ++) {
          printMsg += ' args[$i]: ${nativeStringToString(nativeCommand.ref.args[i])}';
        };
        printMsg += ' nativePtr: ${nativeCommand.ref.nativePtr}';
        print(printMsg);
      }

      try {
        switch (commandType) {
          case UICommandType.createElement:
            controller.view.createElement(id, nativeCommand.ref.nativePtr, nativeStringToString(nativeCommand.ref.args[0]));
            break;
          case UICommandType.createTextNode:
            controller.view.createTextNode(id, nativeCommand.ref.nativePtr.cast<NativeTextNode>(), nativeStringToString(nativeCommand.ref.args[0]));
            break;
          case UICommandType.createComment:
            controller.view.createComment(id, nativeCommand.ref.nativePtr.cast<NativeCommentNode>(), nativeStringToString(nativeCommand.ref.args[0]));
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
            controller.view.setProperty(id, key, value);
            break;
          case UICommandType.removeProperty:
            String key = nativeStringToString(nativeCommand.ref.args[0]);
            controller.view.removeProperty(id, key);
            break;
          default:
            break;
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
    }
    _clearUICommandItems(controller.view.contextId);
  }
}
