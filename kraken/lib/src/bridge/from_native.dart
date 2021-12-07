/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';
import 'package:kraken/src/module/performance_timing.dart';

import 'native_types.dart';
import 'platform.dart';

// An native struct can be directly convert to javaScript String without any conversion cost.
class NativeString extends Struct {
  external Pointer<Uint16> string;

  @Uint32()
  external int length;
}

String uint16ToString(Pointer<Uint16> pointer, int length) {
  return String.fromCharCodes(pointer.asTypedList(length));
}

Pointer<Uint16> _stringToUint16(String string) {
  final units = string.codeUnits;
  final Pointer<Uint16> result = malloc.allocate<Uint16>(units.length * sizeOf<Uint16>());
  final Uint16List nativeString = result.asTypedList(units.length);
  nativeString.setAll(0, units);
  return result;
}

Pointer<NativeString> stringToNativeString(String string) {
  Pointer<NativeString> nativeString = malloc.allocate<NativeString>(sizeOf<NativeString>());
  nativeString.ref.string = _stringToUint16(string);
  nativeString.ref.length = string.length;
  return nativeString;
}

int doubleToUint64(double value) {
  var byteData = ByteData(8);
  byteData.setFloat64(0, value);
  return byteData.getUint64(0);
}

double uInt64ToDouble(int value) {
  var byteData = ByteData(8);
  byteData.setInt64(0, value);
  return byteData.getFloat64(0);
}

String nativeStringToString(Pointer<NativeString> pointer) {
  return uint16ToString(pointer.ref.string, pointer.ref.length);
}

void freeNativeString(Pointer<NativeString> pointer) {
  malloc.free(pointer.ref.string);
  malloc.free(pointer);
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
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeString> errmsg,  Pointer<NativeString> json);
typedef DartAsyncModuleCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeString> errmsg, Pointer<NativeString> json);

typedef NativeInvokeModule = Pointer<NativeString> Function(Pointer<Void> callbackContext,
    Int32 contextId, Pointer<NativeString> module, Pointer<NativeString> method, Pointer<NativeString> params, Pointer<NativeFunction<NativeAsyncModuleCallback>>);

String invokeModule(
    Pointer<Void> callbackContext, int contextId, String moduleName, String method, String? params, DartAsyncModuleCallback callback) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  String result = '';

  try {
    void invokeModuleCallback({String ?error, dynamic data}) {
      if (error != null) {
        Pointer<NativeString> errmsgPtr = stringToNativeString(error);
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
    String error = '$e\n$stack';
    // print module error on the dart side.
    print('$e\n$stack');
    callback(callbackContext, contextId, stringToNativeString(error), nullptr);
  }

  return result;
}

Pointer<NativeString> _invokeModule(Pointer<Void> callbackContext, int contextId,
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

final Pointer<NativeFunction<NativeInvokeModule>> _nativeInvokeModule = Pointer.fromFunction(_invokeModule);

// Register reloadApp
typedef NativeReloadApp = Void Function(Int32 contextId);

void _reloadApp(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;

  try {
    controller.reload();
  } catch (e, stack) {
    print('Dart Error: $e\n$stack');
  }
}

final Pointer<NativeFunction<NativeReloadApp>> _nativeReloadApp = Pointer.fromFunction(_reloadApp);

typedef NativeAsyncCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8> errmsg);
typedef NativeRAFAsyncCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Double data, Pointer<Utf8> errmsg);
typedef DartRAFAsyncCallback = void Function(
    Pointer<Void>, int contextId, double data, Pointer<Utf8> errmsg);

// Register requestBatchUpdate
typedef NativeRequestBatchUpdate = Void Function(Int32 contextId);

void _requestBatchUpdate(int contextId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  return controller.module.requestBatchUpdate();
}

final Pointer<NativeFunction<NativeRequestBatchUpdate>> _nativeRequestBatchUpdate =
    Pointer.fromFunction(_requestBatchUpdate);

// Register setTimeout
typedef NativeSetTimeout = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setTimeout(Pointer<Void> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;

  return controller.module.setTimeout(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, nullptr);
    } catch (e, stack) {
      Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
      func(callbackContext, contextId, nativeErrorMessage);
      malloc.free(nativeErrorMessage);
    }
  });
}

const int SET_TIMEOUT_ERROR = -1;
final Pointer<NativeFunction<NativeSetTimeout>> _nativeSetTimeout = Pointer.fromFunction(_setTimeout, SET_TIMEOUT_ERROR);

// Register setInterval
typedef NativeSetInterval = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setInterval(Pointer<Void> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  return controller.module.setInterval(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, nullptr);
    } catch (e, stack) {
      Pointer<Utf8> nativeErrorMessage = ('Dart Error: $e\n$stack').toNativeUtf8();
      func(callbackContext, contextId, nativeErrorMessage);
      malloc.free(nativeErrorMessage);
    }
  });
}

const int SET_INTERVAL_ERROR = -1;
final Pointer<NativeFunction<NativeSetInterval>> _nativeSetInterval =
    Pointer.fromFunction(_setInterval, SET_INTERVAL_ERROR);

// Register clearTimeout
typedef NativeClearTimeout = Void Function(Int32 contextId, Int32);

void _clearTimeout(int contextId, int timerId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  return controller.module.clearTimeout(timerId);
}

final Pointer<NativeFunction<NativeClearTimeout>> _nativeClearTimeout = Pointer.fromFunction(_clearTimeout);

// Register requestAnimationFrame
typedef NativeRequestAnimationFrame = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>>);

int _requestAnimationFrame(Pointer<Void> callbackContext, int contextId,
    Pointer<NativeFunction<NativeRAFAsyncCallback>> callback) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  return controller.module.requestAnimationFrame((double highResTimeStamp) {
    DartRAFAsyncCallback func = callback.asFunction();
    try {
      func(callbackContext, contextId, highResTimeStamp, nullptr);
    } catch (e, stack) {
      Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
      func(callbackContext, contextId, highResTimeStamp, nativeErrorMessage);
      malloc.free(nativeErrorMessage);
    }
  });
}

const int RAF_ERROR_CODE = -1;
final Pointer<NativeFunction<NativeRequestAnimationFrame>> _nativeRequestAnimationFrame =
    Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);

// Register cancelAnimationFrame
typedef NativeCancelAnimationFrame = Void Function(Int32 contextId, Int32 id);

void _cancelAnimationFrame(int contextId, int timerId) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  controller.module.cancelAnimationFrame(timerId);
}

final Pointer<NativeFunction<NativeCancelAnimationFrame>> _nativeCancelAnimationFrame =
    Pointer.fromFunction(_cancelAnimationFrame);

// Register devicePixelRatio
typedef NativeDevicePixelRatio = Double Function();

double _devicePixelRatio() {
  return window.devicePixelRatio;
}

final Pointer<NativeFunction<NativeDevicePixelRatio>> _nativeDevicePixelRatio =
    Pointer.fromFunction(_devicePixelRatio, 0.0);

// Register platformBrightness
typedef NativePlatformBrightness = Pointer<NativeString> Function();

final Pointer<NativeString> _dark = stringToNativeString('dark');
final Pointer<NativeString> _light = stringToNativeString('light');

Pointer<NativeString> _platformBrightness() {
  return window.platformBrightness == Brightness.dark ? _dark : _light;
}

final Pointer<NativeFunction<NativePlatformBrightness>> _nativePlatformBrightness =
    Pointer.fromFunction(_platformBrightness);

typedef NativeGetScreen = Pointer<Void> Function();

Pointer<Void> _getScreen() {
  Size size = window.physicalSize;
  return createScreen(size.width / window.devicePixelRatio, size.height / window.devicePixelRatio);
}

final Pointer<NativeFunction<NativeGetScreen>> _nativeGetScreen = Pointer.fromFunction(_getScreen);

typedef NativeAsyncBlobCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef DartAsyncBlobCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8>, Pointer<Uint8>, int);
typedef NativeToBlob = Void Function(Pointer<Void> callbackContext, Int32 contextId,
    Pointer<NativeFunction<NativeAsyncBlobCallback>>, Int32, Double);

void _toBlob(Pointer<Void> callbackContext, int contextId,
    Pointer<NativeFunction<NativeAsyncBlobCallback>> callback, int id, double devicePixelRatio) {
  DartAsyncBlobCallback func = callback.asFunction();
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  controller.view.toImage(devicePixelRatio, id).then((Uint8List bytes) {
    Pointer<Uint8> bytePtr = malloc.allocate<Uint8>(sizeOf<Uint8>() * bytes.length);
    Uint8List byteList = bytePtr.asTypedList(bytes.length);
    byteList.setAll(0, bytes);
    func(callbackContext, contextId, nullptr, bytePtr, bytes.length);
  }).catchError((error, stack) {
    Pointer<Utf8> nativeErrorMessage = ('$error\n$stack').toNativeUtf8();
    func(callbackContext, contextId, nativeErrorMessage, nullptr, 0);
    malloc.free(nativeErrorMessage);
  });
}

final Pointer<NativeFunction<NativeToBlob>> _nativeToBlob = Pointer.fromFunction(_toBlob);

typedef NativeFlushUICommand = Void Function();
typedef DartFlushUICommand = void Function();

void _flushUICommand() {
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_DOM_FLUSH_UI_COMMAND_START);
  }
  flushUICommand();
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_DOM_FLUSH_UI_COMMAND_END);
  }
}

final Pointer<NativeFunction<NativeFlushUICommand>> _nativeFlushUICommand = Pointer.fromFunction(_flushUICommand);

// HTML Element is special element which created at initialize time, so we can't use UICommandQueue to init.
typedef NativeInitHTML = Void Function(Int32 contextId, Pointer<NativeEventTarget> nativePtr);
void _initHTML(int contextId, Pointer<NativeEventTarget> nativePtr) {
  ElementManager.htmlNativePtrMap[contextId] = nativePtr;
}
final Pointer<NativeFunction<NativeInitHTML>> _nativeInitHTML = Pointer.fromFunction(_initHTML);

typedef NativeInitWindow = Void Function(Int32 contextId, Pointer<NativeEventTarget> nativePtr);
typedef DartInitWindow = void Function(int contextId, Pointer<NativeEventTarget> nativePtr);

void _initWindow(int contextId, Pointer<NativeEventTarget> nativePtr) {
  ElementManager.windowNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<NativeInitWindow>> _nativeInitWindow = Pointer.fromFunction(_initWindow);

typedef NativeInitDocument = Void Function(Int32 contextId, Pointer<NativeEventTarget> nativePtr);
typedef DartInitDocument = void Function(int contextId, Pointer<NativeEventTarget> nativePtr);

void _initDocument(int contextId, Pointer<NativeEventTarget> nativePtr) {
  ElementManager.documentNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<NativeInitDocument>> _nativeInitDocument = Pointer.fromFunction(_initDocument);

typedef NativePerformanceGetEntries = Pointer<NativePerformanceEntryList> Function(Int32 contextId);
typedef DartPerformanceGetEntries = Pointer<NativePerformanceEntryList> Function(int contextId);

Pointer<NativePerformanceEntryList> _performanceGetEntries(int contextId) {
  if (kProfileMode) {
    return PerformanceTiming.instance().toNative();
  }
  return nullptr;
}

final Pointer<NativeFunction<NativePerformanceGetEntries>> _nativeGetEntries = Pointer.fromFunction(_performanceGetEntries);

typedef NativeJSError = Void Function(Int32 contextId, Pointer<Utf8>);

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
  JSErrorHandler? handler = controller.onJSError;
  if (handler != null) {
    String msg = charStr.toDartString();
    handler(msg);
  }
}

final Pointer<NativeFunction<NativeJSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

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
  _nativeInitHTML.address,
  _nativeInitWindow.address,
  _nativeInitDocument.address,
  _nativeGetEntries.address,
  _nativeOnJsError.address,
];

typedef NativeRegisterDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef DartRegisterDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

final DartRegisterDartMethods _registerDartMethods =
    nativeDynamicLibrary.lookup<NativeFunction<NativeRegisterDartMethods>>('registerDartMethods').asFunction();

void registerDartMethodsToCpp() {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerDartMethods(bytes, _dartNativeMethods.length);
}
