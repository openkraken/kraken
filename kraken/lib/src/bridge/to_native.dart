/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

class KrakenInfo {
  final Pointer<NativeKrakenInfo> _nativeKrakenInfo;

  KrakenInfo(Pointer<NativeKrakenInfo> info) : _nativeKrakenInfo = info;

  String get appName {
    if (_nativeKrakenInfo.ref.app_name == nullptr) return '';
    return _nativeKrakenInfo.ref.app_name.toDartString();
  }

  String get appVersion {
    if (_nativeKrakenInfo.ref.app_version == nullptr) return '';
    return _nativeKrakenInfo.ref.app_version.toDartString();
  }

  String get appRevision {
    if (_nativeKrakenInfo.ref.app_revision == nullptr) return '';
    return _nativeKrakenInfo.ref.app_revision.toDartString();
  }

  String get systemName {
    if (_nativeKrakenInfo.ref.system_name == nullptr) return '';
    return _nativeKrakenInfo.ref.system_name.toDartString();
  }
}

typedef NativeGetKrakenInfo = Pointer<NativeKrakenInfo> Function();
typedef DartGetKrakenInfo = Pointer<NativeKrakenInfo> Function();

final DartGetKrakenInfo _getKrakenInfo = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeGetKrakenInfo>>('getKrakenInfo')
    .asFunction();

final KrakenInfo _cachedInfo = KrakenInfo(_getKrakenInfo());

KrakenInfo getKrakenInfo() {
  return _cachedInfo;
}

// Register invokeEventListener
typedef NativeInvokeEventListener = Void Function(
    Int32 contextId,
    Pointer<NativeString>,
    Pointer<Utf8> eventType,
    Pointer<Void> nativeEvent,
    Pointer<NativeString>);
typedef DartInvokeEventListener = void Function(
    int contextId,
    Pointer<NativeString>,
    Pointer<Utf8> eventType,
    Pointer<Void> nativeEvent,
    Pointer<NativeString>);

final DartInvokeEventListener _invokeModuleEvent = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeInvokeEventListener>>('invokeModuleEvent')
    .asFunction();

void invokeModuleEvent(
    int contextId, String moduleName, Event? event, String extra) {
  if (KrakenController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  Pointer<NativeString> nativeModuleName = stringToNativeString(moduleName);
  Pointer<Void> rawEvent = event == null ? nullptr : event.toRaw().cast<Void>();
  _invokeModuleEvent(
      contextId,
      nativeModuleName,
      event == null ? nullptr : event.type.toNativeUtf8(),
      rawEvent,
      stringToNativeString(extra));
  freeNativeString(nativeModuleName);
}

typedef DartDispatchEvent = int Function(
  int contextId,
  Pointer<NativeBindingObject> nativeBindingObject,
  Pointer<NativeString> eventType,
  Pointer<Void> nativeEvent,
  int isCustomEvent
);

void emitUIEvent(
    int contextId, Pointer<NativeBindingObject> nativeBindingObject, Event event) {
  if (KrakenController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  DartDispatchEvent dispatchEvent = nativeBindingObject.ref.dispatchEvent.asFunction();
  Pointer<Void> rawEvent = event.toRaw().cast<Void>();
  bool isCustomEvent = event is CustomEvent;
  Pointer<NativeString> eventTypeString = stringToNativeString(event.type);
  // @TODO: Make Event inherit BindingObject to pass value from bridge to dart.
  int propagationStopped = dispatchEvent(contextId, nativeBindingObject, eventTypeString, rawEvent, isCustomEvent ? 1 : 0);
  event.propagationStopped = propagationStopped == 1 ? true : false;
  freeNativeString(eventTypeString);
}

void emitModuleEvent(
    int contextId, String moduleName, Event? event, String extra) {
  invokeModuleEvent(contextId, moduleName, event, extra);
}

// Register createScreen
typedef NativeCreateScreen = Pointer<Void> Function(Double, Double);
typedef DartCreateScreen = Pointer<Void> Function(double, double);

final DartCreateScreen _createScreen = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeCreateScreen>>('createScreen')
    .asFunction();

Pointer<Void> createScreen(double width, double height) {
  return _createScreen(width, height);
}

// Register evaluateScripts
typedef NativeEvaluateScripts = Void Function(Int32 contextId,
    Pointer<NativeString> code, Pointer<Utf8> url, Int32 startLine);
typedef DartEvaluateScripts = void Function(int contextId,
    Pointer<NativeString> code, Pointer<Utf8> url, int startLine);

// Register parseHTML
typedef NativeParseHTML = Void Function(
    Int32 contextId, Pointer<Utf8> code, Int32 length);
typedef DartParseHTML = void Function(
    int contextId, Pointer<Utf8> code, int length);

final DartEvaluateScripts _evaluateScripts = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeEvaluateScripts>>('evaluateScripts')
    .asFunction();

final DartParseHTML _parseHTML = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeParseHTML>>('parseHTML')
    .asFunction();

int _anonymousScriptEvaluationId = 0;
void evaluateScripts(int contextId, String code, {String? url, int line = 0}) {
  if (KrakenController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  // Assign `vm://$id` for no url (anonymous scripts).
  if (url == null) {
    url = 'vm://$_anonymousScriptEvaluationId';
    _anonymousScriptEvaluationId++;
  }

  Pointer<NativeString> nativeString = stringToNativeString(code);
  Pointer<Utf8> _url = url.toNativeUtf8();
  try {
    _evaluateScripts(contextId, nativeString, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
  freeNativeString(nativeString);
}

typedef NativeEvaluateQuickjsByteCode = Void Function(
    Int32 contextId, Pointer<Uint8> bytes, Int32 byteLen);
typedef DartEvaluateQuickjsByteCode = void Function(
    int contextId, Pointer<Uint8> bytes, int byteLen);

final DartEvaluateQuickjsByteCode _evaluateQuickjsByteCode = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeEvaluateQuickjsByteCode>>('evaluateQuickjsByteCode')
    .asFunction();

void evaluateQuickjsByteCode(int contextId, Uint8List bytes) {
  if (KrakenController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  Pointer<Uint8> byteData = malloc.allocate(sizeOf<Uint8>() * bytes.length);
  byteData.asTypedList(bytes.length).setAll(0, bytes);
  _evaluateQuickjsByteCode(contextId, byteData, bytes.length);
  malloc.free(byteData);
}

void parseHTML(int contextId, String code) {
  if (KrakenController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  Pointer<Utf8> nativeCode = code.toNativeUtf8();
  try {
    _parseHTML(contextId, nativeCode, nativeCode.length);
  } catch (e, stack) {
    print('$e\n$stack');
  }
  malloc.free(nativeCode);
}

// Register initJsEngine
typedef NativeInitJSPagePool = Void Function(Int32 poolSize);
typedef DartInitJSPagePool = void Function(int poolSize);

final DartInitJSPagePool _initJSPagePool = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeInitJSPagePool>>('initJSPagePool')
    .asFunction();

void initJSPagePool(int poolSize) {
  _initJSPagePool(poolSize);
}

typedef NativeDisposePage = Void Function(Int32 contextId);
typedef DartDisposePage = void Function(int contextId);

final DartDisposePage _disposePage = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeDisposePage>>('disposePage')
    .asFunction();

void disposePage(int contextId) {
  _disposePage(contextId);
}

typedef NativeAllocateNewPage = Int32 Function(Int32);
typedef DartAllocateNewPage = int Function(int);

final DartAllocateNewPage _allocateNewPage = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeAllocateNewPage>>('allocateNewPage')
    .asFunction();

int allocateNewPage([int targetContextId = -1]) {
  return _allocateNewPage(targetContextId);
}

typedef NativeRegisterPluginByteCode = Void Function(
    Pointer<Uint8> bytes, Int32 length, Pointer<Utf8> pluginName);
typedef DartRegisterPluginByteCode = void Function(
    Pointer<Uint8> bytes, int length, Pointer<Utf8> pluginName);

final DartRegisterPluginByteCode _registerPluginByteCode = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeRegisterPluginByteCode>>(
        'registerPluginByteCode')
    .asFunction();

void registerPluginByteCode(Uint8List bytecode, String name) {
  Pointer<Uint8> bytes = malloc.allocate(sizeOf<Uint8>() * bytecode.length);
  bytes.asTypedList(bytecode.length).setAll(0, bytecode);
  _registerPluginByteCode(bytes, bytecode.length, name.toNativeUtf8());
}

typedef NativeProfileModeEnabled = Int32 Function();
typedef DartProfileModeEnabled = int Function();

final DartProfileModeEnabled _profileModeEnabled = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeProfileModeEnabled>>('profileModeEnabled')
    .asFunction();

const _CODE_ENABLED = 1;

bool profileModeEnabled() {
  return _profileModeEnabled() == _CODE_ENABLED;
}

// Regisdster reloadJsContext
typedef NativeReloadJSContext = Void Function(Int32 contextId);
typedef DartReloadJSContext = void Function(int contextId);

final DartReloadJSContext _reloadJSContext = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeReloadJSContext>>('reloadJsContext')
    .asFunction();

Future<void> reloadJSContext(int contextId) async {
  Completer completer = Completer<void>();
  Future.microtask(() {
    _reloadJSContext(contextId);
    completer.complete();
  });
  return completer.future;
}

typedef NativeFlushUICommandCallback = Void Function();
typedef DartFlushUICommandCallback = void Function();

final DartFlushUICommandCallback _flushUICommandCallback = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeFlushUICommandCallback>>(
        'flushUICommandCallback')
    .asFunction();

void flushUICommandCallback() {
  _flushUICommandCallback();
}

typedef NativeDispatchUITask = Void Function(
    Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartDispatchUITask = void Function(
    int contextId, Pointer<Void> context, Pointer<Void> callback);

final DartDispatchUITask _dispatchUITask = KrakenDynamicLibrary.ref
    .lookup<NativeFunction<NativeDispatchUITask>>('dispatchUITask')
    .asFunction();

void dispatchUITask(
    int contextId, Pointer<Void> context, Pointer<Void> callback) {
  _dispatchUITask(contextId, context, callback);
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
  setAttribute,
  removeAttribute,
  cloneNode,
  removeEvent,
  createDocumentFragment,
}

class UICommandItem extends Struct {
  @Int64()
  external int type;

  external Pointer<Pointer<NativeString>> args;

  @Int64()
  external int id;

  @Int64()
  external int length;

  external Pointer nativePtr;
}

typedef NativeGetUICommandItems = Pointer<Uint64> Function(Int32 contextId);
typedef DartGetUICommandItems = Pointer<Uint64> Function(int contextId);

final DartGetUICommandItems _getUICommandItems = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeGetUICommandItems>>('getUICommandItems')
    .asFunction();

typedef NativeGetUICommandItemSize = Int64 Function(Int64 contextId);
typedef DartGetUICommandItemSize = int Function(int contextId);

final DartGetUICommandItemSize _getUICommandItemSize = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeGetUICommandItemSize>>('getUICommandItemSize')
    .asFunction();

typedef NativeClearUICommandItems = Void Function(Int32 contextId);
typedef DartClearUICommandItems = void Function(int contextId);

final DartClearUICommandItems _clearUICommandItems = KrakenDynamicLibrary
    .ref
    .lookup<NativeFunction<NativeClearUICommandItems>>('clearUICommandItems')
    .asFunction();

class UICommand {
  late final UICommandType type;
  late final int id;
  late final List<String> args;
  late final Pointer nativePtr;

  @override
  String toString() {
    return 'UICommand(type: $type, id: $id, args: $args, nativePtr: $nativePtr)';
  }
}

// struct UICommandItem {
//   int32_t type;             // offset: 0 ~ 0.5
//   int32_t id;               // offset: 0.5 ~ 1
//   int32_t args_01_length;   // offset: 1 ~ 1.5
//   int32_t args_02_length;   // offset: 1.5 ~ 2
//   const uint16_t *string_01;// offset: 2
//   const uint16_t *string_02;// offset: 3
//   void* nativePtr;          // offset: 4
// };
const int nativeCommandSize = 5;
const int typeAndIdMemOffset = 0;
const int args01And02LengthMemOffset = 1;
const int args01StringMemOffset = 2;
const int args02StringMemOffset = 3;
const int nativePtrMemOffset = 4;

final bool isEnabledLog =
    kDebugMode && Platform.environment['ENABLE_KRAKEN_JS_LOG'] == 'true';

// We found there are performance bottleneck of reading native memory with Dart FFI API.
// So we align all UI instructions to a whole block of memory, and then convert them into a dart array at one time,
// To ensure the fastest subsequent random access.
List<UICommand> readNativeUICommandToDart(
    Pointer<Uint64> nativeCommandItems, int commandLength, int contextId) {
  List<int> rawMemory = nativeCommandItems
      .cast<Int64>()
      .asTypedList(commandLength * nativeCommandSize)
      .toList(growable: false);
  List<UICommand> results = List.generate(commandLength, (int _i) {
    int i = _i * nativeCommandSize;
    UICommand command = UICommand();

    int typeIdCombine = rawMemory[i + typeAndIdMemOffset];

    // int32_t  int32_t
    // +-------+-------+
    // |  id   | type  |
    // +-------+-------+
    int id = (typeIdCombine >> 32).toSigned(32);
    int type = (typeIdCombine ^ (id << 32)).toSigned(32);

    command.type = UICommandType.values[type];
    command.id = id;
    int nativePtrValue = rawMemory[i + nativePtrMemOffset];
    command.nativePtr = nativePtrValue != 0
        ? Pointer.fromAddress(rawMemory[i + nativePtrMemOffset])
        : nullptr;
    command.args = List.empty(growable: true);

    int args01And02Length = rawMemory[i + args01And02LengthMemOffset];
    int args01Length;
    int args02Length;

    if (args01And02Length == 0) {
      args01Length = args02Length = 0;
    } else {
      args02Length = (args01And02Length >> 32).toSigned(32);
      args01Length = (args01And02Length ^ (args02Length << 32)).toSigned(32);
    }

    int args01StringMemory = rawMemory[i + args01StringMemOffset];
    if (args01StringMemory != 0) {
      Pointer<Uint16> args_01 = Pointer.fromAddress(args01StringMemory);
      command.args.add(uint16ToString(args_01, args01Length));

      int args02StringMemory = rawMemory[i + args02StringMemOffset];
      if (args02StringMemory != 0) {
        Pointer<Uint16> args_02 = Pointer.fromAddress(args02StringMemory);
        command.args.add(uint16ToString(args_02, args02Length));
      }
    }

    if (isEnabledLog) {
      String printMsg = '${command.type}, id: ${command.id}';
      for (int i = 0; i < command.args.length; i++) {
        printMsg += ' args[$i]: ${command.args[i]}';
      }
      printMsg += ' nativePtr: ${command.nativePtr}';
      print(printMsg);
    }
    return command;
  }, growable: false);

  // Clear native command.
  _clearUICommandItems(contextId);

  return results;
}

void clearUICommand(int contextId) {
  _clearUICommandItems(contextId);
}

void flushUICommand() {
  Map<int, KrakenController?> controllerMap =
      KrakenController.getControllerMap();
  for (KrakenController? controller in controllerMap.values) {
    if (controller == null) continue;
    Pointer<Uint64> nativeCommandItems =
        _getUICommandItems(controller.view.contextId);
    int commandLength = _getUICommandItemSize(controller.view.contextId);

    if (commandLength == 0 || nativeCommandItems == nullptr) {
      continue;
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_FLUSH_UI_COMMAND_START);
    }

    List<UICommand> commands = readNativeUICommandToDart(
        nativeCommandItems, commandLength, controller.view.contextId);

    SchedulerBinding.instance!.scheduleFrame();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_FLUSH_UI_COMMAND_END);
    }

    Map<int, bool> pendingStylePropertiesTargets = {};

    // For new ui commands, we needs to tell engine to update frames.
    for (int i = 0; i < commandLength; i++) {
      UICommand command = commands[i];
      UICommandType commandType = command.type;
      int id = command.id;
      Pointer nativePtr = command.nativePtr;

      try {
        switch (commandType) {
          case UICommandType.createElement:
            controller.view.createElement(
                id, nativePtr.cast<NativeBindingObject>(), command.args[0]);
            break;
          case UICommandType.createTextNode:
            controller.view.createTextNode(
                id, nativePtr.cast<NativeBindingObject>(), command.args[0]);
            break;
          case UICommandType.createComment:
            controller.view
                .createComment(id, nativePtr.cast<NativeBindingObject>());
            break;
          case UICommandType.disposeEventTarget:
            controller.view.disposeEventTarget(id);
            break;
          case UICommandType.addEvent:
            controller.view.addEvent(id, command.args[0]);
            break;
          case UICommandType.removeEvent:
            controller.view.removeEvent(id, command.args[0]);
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
            controller.view.setInlineStyle(id, key, value);
            pendingStylePropertiesTargets[id] = true;
            break;
          case UICommandType.setAttribute:
            String key = command.args[0];
            String value = command.args[1];
            controller.view.setAttribute(id, key, value);
            break;
          case UICommandType.removeAttribute:
            String key = command.args[0];
            controller.view.removeAttribute(id, key);
            break;
          case UICommandType.createDocumentFragment:
            controller.view.createDocumentFragment(
                id, nativePtr.cast<NativeBindingObject>());
            break;
          default:
            break;
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
    }

    // For pending style properties, we needs to flush to render style.
    for (int id in pendingStylePropertiesTargets.keys) {
      try {
        controller.view.flushPendingStyleProperties(id);
      } catch (e, stack) {
        print('$e\n$stack');
      }
    }
    pendingStylePropertiesTargets.clear();
  }
}
