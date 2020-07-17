import 'dart:async';
import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:kraken/element.dart';

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

// Register invokeEventListener
typedef Native_InvokeEventListener = Void Function(Int32 contextId, Int32 type, Pointer<Utf8>);
typedef Dart_InvokeEventListener = void Function(int contextId, int type, Pointer<Utf8>);

final Dart_InvokeEventListener _invokeEventListener =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InvokeEventListener>>('invokeEventListener').asFunction();

void invokeEventListener(int contextId, int type, String data) {
  _invokeEventListener(contextId, type, Utf8.toUtf8(data));
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(int contextId, String data) {
  invokeEventListener(contextId, UI_EVENT, data);
}

void emitModuleEvent(int contextId, String data) {
  invokeEventListener(contextId, MODULE_EVENT, data);
}

void invokeOnPlatformBrightnessChangedCallback(int contextId) {
  String json = jsonEncode([WINDOW_ID, Event('colorschemechange')]);
  emitUIEvent(contextId, json);
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
typedef Native_EvaluateScripts = Void Function(Int32 contextId, Pointer<Utf8> code, Pointer<Utf8> url, Int32 startLine);
typedef Dart_EvaluateScripts = void Function(int contextId, Pointer<Utf8> code, Pointer<Utf8> url, int startLine);

final Dart_EvaluateScripts _evaluateScripts =
    nativeDynamicLibrary.lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts').asFunction();

void evaluateScripts(int contextId, String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  try {
    _evaluateScripts(contextId, _code, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
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

typedef Native_FreezeContext = Void Function(Int32 contextId);
typedef Dart_FreezeContext = void Function(int contextId);

final Dart_FreezeContext _freezeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_FreezeContext>>('freezeContext').asFunction();

void freezeContext(int contextId) {
  _freezeContext(contextId);
}

typedef Native_UnFreezeContext = Void Function(Int32 contextId);
typedef Dart_UnFreezeContext = void Function(int contextId);

final Dart_UnFreezeContext _unfreezeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_UnFreezeContext>>('unfreezeContext').asFunction();

void unfreezeContext(int contextId) {
  _unfreezeContext(contextId);
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
