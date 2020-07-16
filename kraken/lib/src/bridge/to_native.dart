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
class JSBridge extends Struct {}
class JSCallbackContext extends Struct {}

// Register invokeEventListener
typedef Native_InvokeEventListener = Void Function(
    Pointer<JSBridge> bridge, Int32 contextIndex, Int32 type, Pointer<Utf8>);
typedef Dart_InvokeEventListener = void Function(Pointer<JSBridge> bridge, int contextIndex, int type, Pointer<Utf8>);

final Dart_InvokeEventListener _invokeEventListener =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InvokeEventListener>>('invokeEventListener').asFunction();

void invokeEventListener(Pointer<JSBridge> bridge, int contextIndex, int type, String data) {
  _invokeEventListener(bridge, contextIndex, type, Utf8.toUtf8(data));
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(Pointer<JSBridge> bridge, int contextIndex, String data) {
  invokeEventListener(bridge, contextIndex, UI_EVENT, data);
}

void emitModuleEvent(Pointer<JSBridge> bridge, int contextIndex, String data) {
  invokeEventListener(bridge, contextIndex, MODULE_EVENT, data);
}

void invokeOnPlatformBrightnessChangedCallback(Pointer<JSBridge> bridge, int contextIndex) {
  String json = jsonEncode([WINDOW_ID, Event('colorschemechange')]);
  emitUIEvent(bridge, contextIndex, json);
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
    Pointer<JSBridge> bridge, Int32 contextIndex, Pointer<Utf8> code, Pointer<Utf8> url, Int32 startLine);
typedef Dart_EvaluateScripts = void Function(
    Pointer<JSBridge> bridge, int contextIndex, Pointer<Utf8> code, Pointer<Utf8> url, int startLine);

final Dart_EvaluateScripts _evaluateScripts =
    nativeDynamicLibrary.lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts').asFunction();

void evaluateScripts(Pointer<JSBridge> bridge, int contextIndex, String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  try {
    _evaluateScripts(bridge, contextIndex, _code, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
}

// Register initJsEngine
typedef Native_InitJSBridgePool = Pointer<JSBridge> Function(Int32 poolSize);
typedef Dart_InitJSBridgePool = Pointer<JSBridge> Function(int poolSize);

final Dart_InitJSBridgePool _initJSBridgePool =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InitJSBridgePool>>('initJSBridgePool').asFunction();

Pointer<JSBridge> initJSBridgePool(int poolSize) {
  return _initJSBridgePool(poolSize);
}

typedef Native_DisposeBridge = Void Function(Pointer<JSBridge> bridge, Int32 contextIndex);
typedef Dart_DisposeBridge = void Function(Pointer<JSBridge> bridge, int contextIndex);

final Dart_DisposeBridge _disposeBridge =
    nativeDynamicLibrary.lookup<NativeFunction<Native_DisposeBridge>>('disposeBridge').asFunction();

void disposeBridge(Pointer<JSBridge> bridge, int contextIndex) {
  _disposeBridge(bridge, contextIndex);
}

typedef Native_AllocateNewBridge = Int32 Function(Int32);
typedef Dart_AllocateNewBridge = int Function(int);

final Dart_AllocateNewBridge _allocateNewBridge =
    nativeDynamicLibrary.lookup<NativeFunction<Native_AllocateNewBridge>>('allocateNewBridge').asFunction();

int allocateNewBridge([int bridgeIndex = -1]) {
  return _allocateNewBridge(bridgeIndex);
}

typedef Native_GetJSBridge = Pointer<JSBridge> Function(Int32 contextIndex);
typedef Dart_GetJSBridge = Pointer<JSBridge> Function(int contextIndex);

final Dart_GetJSBridge _getJSBridge =
    nativeDynamicLibrary.lookup<NativeFunction<Native_GetJSBridge>>('getJSBridge').asFunction();

Pointer<JSBridge> getJSBridge(int contextIndex) {
  return _getJSBridge(contextIndex);
}

typedef Native_FreezeContext = Void Function(Pointer<JSBridge> bridge, Int32 contextIndex);
typedef Dart_FreezeContext = void Function(Pointer<JSBridge> bridge, int contextIndex);

final Dart_FreezeContext _freezeBridge =
    nativeDynamicLibrary.lookup<NativeFunction<Native_FreezeContext>>('freezeBridge').asFunction();

void freezeContext(Pointer<JSBridge> bridge, int contextIndex) {
  _freezeBridge(bridge, contextIndex);
}

typedef Native_UnFreezeContext = Void Function(Pointer<JSBridge> bridge, Int32 contextIndex);
typedef Dart_UnFreezeContext = void Function(Pointer<JSBridge> bridge, int contextIndex);

final Dart_UnFreezeContext _unfreezeContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_UnFreezeContext>>('unfreezeContext').asFunction();

void unfreezeContext(Pointer<JSBridge> bridge, int contextIndex) {
  _unfreezeContext(bridge, contextIndex);
}

// Register reloadJsContext
typedef Native_ReloadJSContext = Pointer<JSBridge> Function(Pointer<JSBridge> bridge, Int32 contextIndex);
typedef Dart_ReloadJSContext = Pointer<JSBridge> Function(Pointer<JSBridge> bridge, int contextIndex);

final Dart_ReloadJSContext _reloadJSContext =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ReloadJSContext>>('reloadJsContext').asFunction();

Future<Pointer<JSBridge>> reloadJSContext(Pointer<JSBridge> bridge, int contextIndex) async {
  Completer completer = Completer<Pointer<JSBridge>>();
  Future.microtask(() {
    Pointer<JSBridge> newBridge = _reloadJSContext(bridge, contextIndex);
    completer.complete(newBridge);
  });
  return completer.future;
}
