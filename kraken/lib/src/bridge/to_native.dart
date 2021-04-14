import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
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
typedef Native_InvokeEventListener = Void Function(Int32 contextId, Pointer<NativeString>, Pointer<Utf8> eventType,  Pointer<Void> nativeEvent, Pointer<NativeString>);
typedef Dart_InvokeEventListener = void Function(int contextId, Pointer<NativeString>, Pointer<Utf8> eventType, Pointer<Void> nativeEvent, Pointer<NativeString>);

final Dart_InvokeEventListener _invokeModuleEvent =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InvokeEventListener>>('invokeModuleEvent').asFunction();

void invokeModuleEvent(int contextId, String moduleName, Event event, String extra) {
  assert(moduleName != null);
  Pointer<NativeString> nativeModuleName = stringToNativeString(moduleName);
  Pointer<Void> nativeEvent = event == null ? nullptr : event.toNative().cast<Void>();
  _invokeModuleEvent(contextId, nativeModuleName, event == null ? nullptr : Utf8.toUtf8(event.type), nativeEvent, stringToNativeString(extra ?? ''));
  freeNativeString(nativeModuleName);
}

void emitUIEvent(int contextId, Pointer<NativeEventTarget> nativePtr, Event event) {
  Pointer<NativeEventTarget> nativeEventTarget = nativePtr;
  Dart_DispatchEvent dispatchEvent = nativeEventTarget.ref.dispatchEvent.asFunction();
  Pointer<Void> nativeEvent = event.toNative().cast<Void>();
  bool isCustomEvent = event is CustomEvent;
  Pointer<NativeString> eventTypeString = stringToNativeString(event.type);
  dispatchEvent(nativeEventTarget, eventTypeString, nativeEvent, isCustomEvent ? 1 : 0);
  freeNativeString(eventTypeString);
}

void emitModuleEvent(int contextId, String moduleName, Event event, String extra) {
  invokeModuleEvent(contextId, moduleName, event, extra);
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

typedef Native_FlushUICommandCallback = Void Function();
typedef Dart_FlushUICommandCallback = void Function();

final Dart_FlushUICommandCallback _flushUICommandCallback =
nativeDynamicLibrary.lookup<NativeFunction<Native_FlushUICommandCallback>>('flushUICommandCallback').asFunction();

void flushUICommandCallback() {
  _flushUICommandCallback();
}

typedef Native_DispatchUITask = Void Function(Int32 contextId, Int32 taskId);
typedef Dart_DispatchUITask = void Function(int contextId, int taskId);

final Dart_DispatchUITask _dispatchUITask =
  nativeDynamicLibrary.lookup<NativeFunction<Native_DispatchUITask>>('dispatchUITask').asFunction();

void dispatchUITask(int contextId, int taskId) {
  _dispatchUITask(contextId, taskId);
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
  removeProperty,
  cloneNode,
}

class UICommandItem extends Struct {
  @Int64()
  int type;

  Pointer<Pointer<NativeString>> args;

  @Int64()
  int id;

  @Int64()
  int length;

  Pointer nativePtr;
}

typedef Native_GetUICommandItems = Pointer<Uint64> Function(Int32 contextId);
typedef Dart_GetUICommandItems = Pointer<Uint64> Function(int contextId);

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

class UICommand {
  UICommandType type;
  int id;
  List<String> args;
  Pointer nativePtr;

  String toString() {
    return 'UICommand(type: $type, id: $id, args: $args, nativePtr: $nativePtr)';
  }
}

/**
 * struct UICommandItem {
    int32_t type;             // offset: 0 ~ 0.5
    int32_t id;               // offset: 0.5 ~ 1
    int32_t args_01_length;   // offset: 1 ~ 1.5
    int32_t args_02_length;   // offset: 1.5 ~ 2
    const uint16_t *string_01;// offset: 2
    const uint16_t *string_02;// offset: 3
    void* nativePtr;          // offset: 4
  };
 */
const int nativeCommandSize = 5;
const int typeAndIdMemOffset = 0;
const int args01And02LengthMemOffset = 1;
const int args01StringMemOffset = 2;
const int args02StringMemOffset = 3;
const int nativePtrMemOffset = 4;

// We found there are performance bottleneck of reading native memory with Dart FFI API.
// So we align all UI instructions to a whole block of memory, and then convert them into a dart array at one time,
// To ensure the fastest subsequent random access.
List<UICommand> readNativeUICommandToDart(Pointer<Uint64> nativeCommandItems, int commandLength, int contextId) {
  List<UICommand> results = List(commandLength);
  Uint64List rawMemory = nativeCommandItems.asTypedList(commandLength * nativeCommandSize);

  for (int i = 0; i < commandLength * nativeCommandSize; i += nativeCommandSize) {
    UICommand command = UICommand();

    int typeIdCombine = rawMemory[i + typeAndIdMemOffset];

    // int32_t  int32_t
    // +-------+-------+
    // |  id   | type  |
    // +-------+-------+
    int id = typeIdCombine >> 32;
    int type = typeIdCombine ^ (id << 32);

    command.type = UICommandType.values[type];
    command.id = id;
    int nativePtrValue = rawMemory[i + nativePtrMemOffset];
    command.nativePtr = nativePtrValue != 0 ? Pointer.fromAddress(rawMemory[i + nativePtrMemOffset]) : nullptr;
    command.args = List(2);

    int args01And02Length = rawMemory[i + args01And02LengthMemOffset];
    int args01Length;
    int args02Length;

    if (args01And02Length == 0) {
      args01Length = args02Length = 0;
    } else {
      args02Length = args01And02Length >> 32;
      args01Length = args01And02Length ^ (args02Length << 32);
    }

    int args01StringMemory = rawMemory[i + args01StringMemOffset];
    if (args01StringMemory != 0) {
      Pointer<Uint16> args_01 = Pointer.fromAddress(args01StringMemory);
      command.args[0] = uint16ToString(args_01, args01Length);

      int args02StringMemory = rawMemory[i + args02StringMemOffset];
      if (args02StringMemory != 0) {
        Pointer<Uint16> args_02 = Pointer.fromAddress(args02StringMemory);
        command.args[1] = uint16ToString(args_02, args02Length);
      }
    }

    if (kDebugMode && Platform.environment['ENABLE_KRAKEN_JS_LOG'] == 'true') {
      String printMsg = '${command.type}, id: ${command.id}';
      for (int i = 0; i < command.args.length; i ++) {
        printMsg += ' args[$i]: ${command.args[i]}';
      };
      printMsg += ' nativePtr: ${command.nativePtr}';
      print(printMsg);
    }
    results[i ~/ nativeCommandSize] = command;
  }

  // Clear native command.
  _clearUICommandItems(contextId);

  return results;
}

void clearUICommand(int contextId) {
  _clearUICommandItems(contextId);
}

void flushUICommand() {
  Map<int, KrakenController> controllerMap = KrakenController.getControllerMap();
  for (KrakenController controller in controllerMap.values) {
    Pointer<Uint64> nativeCommandItems = _getUICommandItems(controller.view.contextId);
    int commandLength = _getUICommandItemSize(controller.view.contextId);

    if (commandLength == 0) {
      continue;
    }

    if (kProfileMode) {
      PerformanceTiming.instance(controller.view.contextId).mark(PERF_FLUSH_UI_COMMAND_START);
    }

    List<UICommand> commands = readNativeUICommandToDart(nativeCommandItems, commandLength, controller.view.contextId);

    SchedulerBinding.instance.scheduleFrame();

    if (kProfileMode) {
      PerformanceTiming.instance(controller.view.contextId).mark(PERF_FLUSH_UI_COMMAND_END);
    }

    // For new ui commands, we needs to tell engine to update frames.
    for (int i = 0; i < commandLength; i++) {
      UICommand command = commands[i];
      UICommandType commandType = command.type;
      int id = command.id;
      Pointer nativePtr = command.nativePtr;

      try {
        switch (commandType) {
          case UICommandType.createElement:
            controller.view.createElement(id, nativePtr, command.args[0]);
            break;
          case UICommandType.createTextNode:
            controller.view.createTextNode(id, nativePtr.cast<NativeTextNode>(), command.args[0]);
            break;
          case UICommandType.createComment:
            controller.view.createComment(id, nativePtr.cast<NativeCommentNode>(), command.args[0]);
            break;
          case UICommandType.disposeEventTarget:
            ElementManager.disposeEventTarget(controller.view.contextId, id);
            break;
          case UICommandType.addEvent:
            controller.view.addEvent(id, command.args[0]);
            break;
          case UICommandType.insertAdjacentNode:
            int childId = int.parse(command.args[0]);
            String position = command.args[1];
            controller.view.insertAdjacentNode(id, position, childId);
            break;
          case UICommandType.removeNode:
            controller.view.removeNode(id);
            break;
          case UICommandType.cloneNode:
            int newId = int.parse(command.args[0]);
            controller.view.cloneNode(id, newId);
            break;
          case UICommandType.setStyle:
            String key = command.args[0];
            String value = command.args[1];
            controller.view.setStyle(id, key, value);
            break;
          case UICommandType.setProperty:
            String key = command.args[0];
            String value = command.args[1];
            controller.view.setProperty(id, key, value);
            break;
          case UICommandType.removeProperty:
            String key = command.args[0];
            controller.view.removeProperty(id, key);
            break;
          default:
            break;
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
    }
  }
}
