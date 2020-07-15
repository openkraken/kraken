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
class JSContext extends Struct {}

// Register invokeEventListener
typedef Native_InvokeEventListener = Void Function(
    Pointer<JSContext> context, Int32 contextIndex, Int32 type, Pointer<Utf8>);
typedef Dart_InvokeEventListener = void Function(Pointer<JSContext> context, int contextIndex, int type, Pointer<Utf8>);

final Dart_InvokeEventListener _invokeEventListener =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InvokeEventListener>>('invokeEventListener').asFunction();

void invokeEventListener(Pointer<JSContext> context, int contextIndex, int type, String data) {
  _invokeEventListener(context, contextIndex, type, Utf8.toUtf8(data));
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(Pointer<JSContext> context, int contextIndex, String data) {
  invokeEventListener(context, contextIndex, UI_EVENT, data);
}

void emitModuleEvent(Pointer<JSContext> context, int contextIndex, String data) {
  invokeEventListener(context, contextIndex, MODULE_EVENT, data);
}

void invokeOnPlatformBrightnessChangedCallback(Pointer<JSContext> context, int contextIndex) {
  String json = jsonEncode([WINDOW_ID, Event('colorschemechange')]);
  emitUIEvent(context, contextIndex, json);
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
    Pointer<JSContext> context, Int32 contextIndex, Pointer<Utf8> code, Pointer<Utf8> url, Int32 startLine);
typedef Dart_EvaluateScripts = void Function(
    Pointer<JSContext> context, int contextIndex, Pointer<Utf8> code, Pointer<Utf8> url, int startLine);

final Dart_EvaluateScripts _evaluateScripts =
    nativeDynamicLibrary.lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts').asFunction();

void evaluateScripts(Pointer<JSContext> context, int contextIndex, String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  try {
    _evaluateScripts(context, contextIndex, _code, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
}

// Register initJsEngine
typedef Native_InitJSContextPool = Pointer<JSContext> Function(Int32 poolSize);
typedef Dart_InitJSContextPool = Pointer<JSContext> Function(int poolSize);

final Dart_InitJSContextPool _initJSContextPool =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InitJSContextPool>>('initJSContextPool').asFunction();

Pointer<JSContext> initJSContextPool(int poolSize) {
  return _initJSContextPool(poolSize);
}

typedef Native_DisposeContext = Void Function(Pointer<JSContext> context, Int32 contextIndex);
typedef Dart_DisposeContext = void Function(Pointer<JSContext> context, int contextIndex);

final Dart_DisposeContext _disposeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_DisposeContext>>('disposeContext').asFunction();

void disposeContext(Pointer<JSContext> context, int contextIndex) {
  _disposeContext(context, contextIndex);
}

typedef Native_AllocateNewContext = Int32 Function();
typedef Dart_AllocateNewContext = int Function();

final Dart_AllocateNewContext _allocateNewContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_AllocateNewContext>>('allocateNewContext').asFunction();

int allocateNewContext() {
  return _allocateNewContext();
}

typedef Native_GetJSContext = Pointer<JSContext> Function(Int32 contextIndex);
typedef Dart_GetJSContext = Pointer<JSContext> Function(int contextIndex);

final Dart_GetJSContext _getJSContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetJSContext>>('getJSContext').asFunction();

Pointer<JSContext> getJSContext(int contextIndex) {
  return _getJSContext(contextIndex);
}

typedef Native_FreezeContext = Void Function(Pointer<JSContext> context, Int32 contextIndex);
typedef Dart_FreezeContext = void Function(Pointer<JSContext> context, int contextIndex);

final Dart_FreezeContext _freezeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_FreezeContext>>('freezeContext').asFunction();

void freezeContext(Pointer<JSContext> context, int contextIndex) {
  _freezeContext(context, contextIndex);
}

typedef Native_UnFreezeContext = Void Function(Pointer<JSContext> context, Int32 contextIndex);
typedef Dart_UnFreezeContext = void Function(Pointer<JSContext> context, int contextIndex);

final Dart_UnFreezeContext _unfreezeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_UnFreezeContext>>('unfreezeContext').asFunction();

void unfreezeContext(Pointer<JSContext> context, int contextIndex) {
  _unfreezeContext(context, contextIndex);
}

// Register reloadJsContext
typedef Native_ReloadJSContext = Void Function(Pointer<JSContext> context, Int32 contextIndex);
typedef Dart_ReloadJSContext = void Function(Pointer<JSContext> context, int contextIndex);

final Dart_ReloadJSContext _reloadJSContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ReloadJSContext>>('reloadJsContext').asFunction();

Future<void> reloadJSContext(Pointer<JSContext> context, int contextIndex) async {
  return Future.microtask(() {
    _reloadJSContext(context, contextIndex);
  });
}
