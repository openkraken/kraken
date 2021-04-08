import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/dom.dart';

import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/module.dart';
import 'package:kraken/src/module/performance_timing.dart';
import 'platform.dart';
import 'native_types.dart';

// An native struct can be directly convert to javaScript String without any conversion cost.
class NativeString extends Struct {
  Pointer<Uint16> string;

  @Int32()
  int length;
}

String uint16ToString(Pointer<Uint16> pointer, int length) {
  return String.fromCharCodes(pointer.asTypedList(length));
}

Pointer<Uint16> _stringToUint16(String string) {
  final units = string.codeUnits;
  final Pointer<Uint16> result = allocate<Uint16>(count: units.length);
  final Uint16List nativeString = result.asTypedList(units.length);
  nativeString.setAll(0, units);
  return result;
}

Pointer<NativeString> stringToNativeString(String string) {
  assert(string != null);
  Pointer<NativeString> nativeString = allocate<NativeString>();
  nativeString.ref.string = _stringToUint16(string);
  nativeString.ref.length = string.length;
  return nativeString;
}

String nativeStringToString(Pointer<NativeString> pointer) {
  return uint16ToString(pointer.ref.string, pointer.ref.length);
}

void freeNativeString(Pointer<NativeString> pointer) {
  free(pointer.ref.string);
  free(pointer);
}

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the
//    Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

// Register InvokeModule
typedef NativeAsyncModuleCallback = Void Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<NativeString> errmsg,  Pointer<NativeString> json);
typedef DartAsyncModuleCallback = void Function(
    Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<NativeString> errmsg, Pointer<NativeString> json);

typedef Native_InvokeModule = Pointer<NativeString> Function(Pointer<JSCallbackContext> callbackContext,
    Int32 contextId, Pointer<NativeString> module, Pointer<NativeString> method, Pointer<NativeString> params, Pointer<NativeFunction<NativeAsyncModuleCallback>>);

String invokeModule(
    Pointer<JSCallbackContext> callbackContext, int contextId, String moduleName, String method, String params, DartAsyncModuleCallback callback) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  String result = '';

  try {
    void invokeModuleCallback({String errmsg, dynamic data}) {
      if (errmsg != null) {
        Pointer<NativeString> errmsgPtr = stringToNativeString(errmsg);
        callback(callbackContext, contextId, errmsgPtr, nullptr);
        freeNativeString(errmsgPtr);
      } else {
        Pointer<NativeString> dataPtr = stringToNativeString(jsonEncode(data));
        callback(callbackContext, contextId, nullptr, dataPtr);
        freeNativeString(dataPtr);
      }
    }
    result = controller.module.moduleManager.invokeModule(moduleName, method, (params != null && params != '""') ? jsonDecode(params) : null, invokeModuleCallback);
  } catch (e, stack) {
    String errmsg = '$e\n$stack';
    // print module error on the dart side.
    print('$e\n$stack');
    callback(callbackContext, contextId, stringToNativeString(errmsg), nullptr);
  }

  return result;
}

Pointer<NativeString> _invokeModule(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeString> module, Pointer<NativeString> method, Pointer<NativeString> params, Pointer<NativeFunction<NativeAsyncModuleCallback>> callback) {
  String result = invokeModule(
    callbackContext,
    contextId,
    nativeStringToString(module),
    nativeStringToString(method),
    params == nullptr ? null : nativeStringToString(params),
    callback.asFunction()
  );
  return stringToNativeString(result);
}

final Pointer<NativeFunction<Native_InvokeModule>> _nativeInvokeModule = Pointer.fromFunction(_invokeModule);

// Register reloadApp
typedef Native_ReloadApp = Void Function(Int32 contextId);

void _reloadApp(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);

  try {
    controller.reload();
  } catch (e, stack) {
    print('Dart Error: $e\n$stack');
  }
}

final Pointer<NativeFunction<Native_ReloadApp>> _nativeReloadApp = Pointer.fromFunction(_reloadApp);

typedef NativeAsyncCallback = Void Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncCallback = void Function(
    Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<Utf8> errmsg);
typedef NativeRAFAsyncCallback = Void Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Double data, Pointer<Utf8> errmsg);
typedef DartRAFAsyncCallback = void Function(
    Pointer<JSCallbackContext>, int contextId, double data, Pointer<Utf8> errmsg);

// Register requestBatchUpdate
typedef Native_RequestBatchUpdate = Void Function(Int32 contextId);

void _requestBatchUpdate(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  return controller.module.requestBatchUpdate();
}

final Pointer<NativeFunction<Native_RequestBatchUpdate>> _nativeRequestBatchUpdate =
    Pointer.fromFunction(_requestBatchUpdate);

// Register setTimeout
typedef Native_SetTimeout = Int32 Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setTimeout(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);

  return controller.module.setTimeout(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, nullptr);
    } catch (e, stack) {
      func(callbackContext, contextId, Utf8.toUtf8('Error: $e\n$stack'));
    }
  });
}

const int SET_TIMEOUT_ERROR = -1;
final Pointer<NativeFunction<Native_SetTimeout>> _nativeSetTimeout = Pointer.fromFunction(_setTimeout, SET_TIMEOUT_ERROR);

// Register setInterval
typedef Native_SetInterval = Int32 Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setInterval(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  return controller.module.setInterval(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, nullptr);
    } catch (e, stack) {
      func(callbackContext, contextId, Utf8.toUtf8('Dart Error: $e\n$stack'));
    }
  });
}

const int SET_INTERVAL_ERROR = -1;
final Pointer<NativeFunction<Native_SetInterval>> _nativeSetInterval =
    Pointer.fromFunction(_setInterval, SET_INTERVAL_ERROR);

// Register clearTimeout
typedef Native_ClearTimeout = Void Function(Int32 contextId, Int32);

void _clearTimeout(int contextId, int timerId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  return controller.module.clearTimeout(timerId);
}

final Pointer<NativeFunction<Native_ClearTimeout>> _nativeClearTimeout = Pointer.fromFunction(_clearTimeout);

// Register requestAnimationFrame
typedef Native_RequestAnimationFrame = Int32 Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>>);

int _requestAnimationFrame(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeFunction<NativeRAFAsyncCallback>> callback) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  return controller.module.requestAnimationFrame((double highResTimeStamp) {
    DartRAFAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, highResTimeStamp, nullptr);
    } catch (e, stack) {
      func(callbackContext, contextId, highResTimeStamp, Utf8.toUtf8('Error: $e\n$stack'));
    }
  });
}

const int RAF_ERROR_CODE = -1;
final Pointer<NativeFunction<Native_RequestAnimationFrame>> _nativeRequestAnimationFrame =
    Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);

// Register cancelAnimationFrame
typedef Native_CancelAnimationFrame = Void Function(Int32 contextId, Int32 id);

void _cancelAnimationFrame(int contextId, int timerId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  controller.module.cancelAnimationFrame(timerId);
}

final Pointer<NativeFunction<Native_CancelAnimationFrame>> _nativeCancelAnimationFrame =
    Pointer.fromFunction(_cancelAnimationFrame);

// Register devicePixelRatio
typedef Native_DevicePixelRatio = Double Function();

double _devicePixelRatio() {
  return window.devicePixelRatio;
}

final Pointer<NativeFunction<Native_DevicePixelRatio>> _nativeDevicePixelRatio =
    Pointer.fromFunction(_devicePixelRatio, 0.0);

// Register platformBrightness
typedef Native_PlatformBrightness = Pointer<NativeString> Function();

final Pointer<NativeString> _dark = stringToNativeString('dark');
final Pointer<NativeString> _light = stringToNativeString('light');

Pointer<NativeString> _platformBrightness() {
  return window.platformBrightness == Brightness.dark ? _dark : _light;
}

final Pointer<NativeFunction<Native_PlatformBrightness>> _nativePlatformBrightness =
    Pointer.fromFunction(_platformBrightness);

// Register getScreen
class ScreenSize extends Struct {}

typedef Native_GetScreen = Pointer<ScreenSize> Function();

Pointer<ScreenSize> _getScreen() {
  Size size = window.physicalSize;
  return createScreen(size.width / window.devicePixelRatio, size.height / window.devicePixelRatio);
}

final Pointer<NativeFunction<Native_GetScreen>> _nativeGetScreen = Pointer.fromFunction(_getScreen);

typedef NativeAsyncBlobCallback = Void Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef DartAsyncBlobCallback = void Function(
    Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<Utf8>, Pointer<Uint8>, int);
typedef Native_ToBlob = Void Function(Pointer<JSCallbackContext> callbackContext, Int32 contextId,
    Pointer<NativeFunction<NativeAsyncBlobCallback>>, Int32, Double);

void _toBlob(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncBlobCallback>> callback, int id, double devicePixelRatio) {
  DartAsyncBlobCallback func = callback.asFunction();
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  controller.view.toImage(devicePixelRatio, id).then((Uint8List bytes) {
    Pointer<Uint8> bytePtr = allocate<Uint8>(count: bytes.length);
    Uint8List byteList = bytePtr.asTypedList(bytes.length);
    byteList.setAll(0, bytes);
    func(callbackContext, contextId, nullptr, bytePtr, bytes.length);
  }).catchError((error, stack) {
    Pointer<Utf8> msg = Utf8.toUtf8('$error\n$stack');
    func(callbackContext, contextId, msg, nullptr, 0);
  });
}

final Pointer<NativeFunction<Native_ToBlob>> _nativeToBlob = Pointer.fromFunction(_toBlob);

typedef Native_FlushUICommand = Void Function();
typedef Dart_FlushUICommand = void Function();

void _flushUICommand() {
  flushUICommand();
}

final Pointer<NativeFunction<Native_FlushUICommand>> _nativeFlushUICommand = Pointer.fromFunction(_flushUICommand);

// Body Element are special element which created at initialize time, so we can't use UICommandQueue to init body element.
typedef Native_InitBody = Void Function(Int32 contextId, Pointer<NativeElement> nativePtr);
typedef Dart_InitBody = void Function(int contextId, Pointer<NativeElement> nativePtr);

void _initBody(int contextId, Pointer<NativeElement> nativePtr) {
  ElementManager.bodyNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<Native_InitBody>> _nativeInitBody = Pointer.fromFunction(_initBody);

typedef Native_InitWindow = Void Function(Int32 contextId, Pointer<NativeWindow> nativePtr);
typedef Dart_InitWindow = void Function(int contextId, Pointer<NativeWindow> nativePtr);

void _initWindow(int contextId, Pointer<NativeWindow> nativePtr) {
  ElementManager.windowNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<Native_InitWindow>> _nativeInitWindow = Pointer.fromFunction(_initWindow);

typedef Native_InitDocument = Void Function(Int32 contextId, Pointer<NativeDocument> nativePtr);
typedef Dart_InitDocument = void Function(int contextId, Pointer<NativeDocument> nativePtr);

void _initDocument(int contextId, Pointer<NativeDocument> nativePtr) {
  ElementManager.documentNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<Native_InitDocument>> _nativeInitDocument = Pointer.fromFunction(_initDocument);

typedef Native_Performance_GetEntries = Pointer<NativePerformanceEntryList> Function(Int32 contextId);
typedef Dart_Performance_GetEntries = Pointer<NativePerformanceEntryList> Function(int contextId);

Pointer<NativePerformanceEntryList> _performanceGetEntries(int contextId) {
  if (kProfileMode) {
    return PerformanceTiming.instance(contextId).toNative();
  }
  return nullptr;
}

final Pointer<NativeFunction<Native_Performance_GetEntries>> _nativeGetEntries = Pointer.fromFunction(_performanceGetEntries);

typedef Native_JSError = Void Function(Int32 contextId, Pointer<Utf8>);

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  if (controller.onJSError != null) {
    String msg = Utf8.fromUtf8(charStr);
    controller.onJSError(msg);
  }
}

final Pointer<NativeFunction<Native_JSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

typedef Native_InspectorMessage = Void Function(Int32 contextId, Pointer<Utf8>);

void _onInspectorMessage(int contextId, Pointer<Utf8> message) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  if (controller.view.inspector != null) {
    controller.view.inspector.server.sendRawJSONToFrontend(Utf8.fromUtf8(message));
  }
}

final Pointer<NativeFunction<Native_InspectorMessage>> _nativeInspectorMessage = Pointer.fromFunction(_onInspectorMessage);

final List<int> _dartNativeMethods = [
  _nativeInvokeModule.address,
  _nativeRequestBatchUpdate.address,
  _nativeReloadApp.address,
  _nativeSetTimeout.address,
  _nativeSetInterval.address,
  _nativeClearTimeout.address,
  _nativeRequestAnimationFrame.address,
  _nativeCancelAnimationFrame.address,
  _nativeGetScreen.address,
  _nativeDevicePixelRatio.address,
  _nativePlatformBrightness.address,
  _nativeToBlob.address,
  _nativeFlushUICommand.address,
  _nativeInitBody.address,
  _nativeInitWindow.address,
  _nativeInitDocument.address,
  _nativeGetEntries.address,
  _nativeOnJsError.address,
  _nativeInspectorMessage.address
];

typedef Native_RegisterDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef Dart_RegisterDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

final Dart_RegisterDartMethods _registerDartMethods =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterDartMethods>>('registerDartMethods').asFunction();

void registerDartMethodsToCpp() {
  Pointer<Uint64> bytes = allocate<Uint64>(count: _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerDartMethods(bytes, _dartNativeMethods.length);
}
