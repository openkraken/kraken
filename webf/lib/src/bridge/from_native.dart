/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';
import 'package:webf/src/module/performance_timing.dart';

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
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8> errmsg, Pointer<NativeString> json);
typedef DartAsyncModuleCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8> errmsg, Pointer<NativeString> json);

typedef NativeInvokeModule = Pointer<NativeString> Function(
    Pointer<Void> callbackContext,
    Int32 contextId,
    Pointer<NativeString> module,
    Pointer<NativeString> method,
    Pointer<NativeString> params,
    Pointer<NativeFunction<NativeAsyncModuleCallback>>);

String invokeModule(Pointer<Void> callbackContext, int contextId, String moduleName, String method, String? params,
    DartAsyncModuleCallback callback) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  String result = '';

  try {
    void invokeModuleCallback({String? error, data}) {
      // To make sure Promise then() and catch() executed before Promise callback called at JavaScript side.
      // We should make callback always async.
      Future.microtask(() {
        if (error != null) {
          Pointer<Utf8> errmsgPtr = error.toNativeUtf8();
          callback(callbackContext, contextId, errmsgPtr, nullptr);
          malloc.free(errmsgPtr);
        } else {
          Pointer<NativeString> dataPtr = stringToNativeString(jsonEncode(data));
          callback(callbackContext, contextId, nullptr, dataPtr);
          freeNativeString(dataPtr);
        }
      });
    }

    result = controller.module.moduleManager.invokeModule(
        moduleName, method, (params != null && params != '""') ? jsonDecode(params) : null, invokeModuleCallback);
  } catch (e, stack) {
    String error = '$e\n$stack';
    callback(callbackContext, contextId, error.toNativeUtf8(), nullptr);
  }

  return result;
}

Pointer<NativeString> _invokeModule(
    Pointer<Void> callbackContext,
    int contextId,
    Pointer<NativeString> module,
    Pointer<NativeString> method,
    Pointer<NativeString> params,
    Pointer<NativeFunction<NativeAsyncModuleCallback>> callback) {
  String result = invokeModule(callbackContext, contextId, nativeStringToString(module), nativeStringToString(method),
      params == nullptr ? null : nativeStringToString(params), callback.asFunction());
  return stringToNativeString(result);
}

final Pointer<NativeFunction<NativeInvokeModule>> _nativeInvokeModule = Pointer.fromFunction(_invokeModule);

// Register reloadApp
typedef NativeReloadApp = Void Function(Int32 contextId);

void _reloadApp(int contextId) async {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  try {
    await controller.reload();
  } catch (e, stack) {
    print('Dart Error: $e\n$stack');
  }
}

final Pointer<NativeFunction<NativeReloadApp>> _nativeReloadApp = Pointer.fromFunction(_reloadApp);

typedef NativeAsyncCallback = Void Function(Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncCallback = void Function(Pointer<Void> callbackContext, int contextId, Pointer<Utf8> errmsg);
typedef NativeRAFAsyncCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Double data, Pointer<Utf8> errmsg);
typedef DartRAFAsyncCallback = void Function(Pointer<Void>, int contextId, double data, Pointer<Utf8> errmsg);

// Register requestBatchUpdate
typedef NativeRequestBatchUpdate = Void Function(Int32 contextId);

void _requestBatchUpdate(int contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  return controller?.module.requestBatchUpdate();
}

final Pointer<NativeFunction<NativeRequestBatchUpdate>> _nativeRequestBatchUpdate =
    Pointer.fromFunction(_requestBatchUpdate);

// Register setTimeout
typedef NativeSetTimeout = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setTimeout(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  return controller.module.setTimeout(timeout, () {
    DartAsyncCallback func = callback.asFunction();

    void _runCallback() {
      try {
        func(callbackContext, contextId, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallback);
    } else {
      _runCallback();
    }
  });
}

const int SET_TIMEOUT_ERROR = -1;
final Pointer<NativeFunction<NativeSetTimeout>> _nativeSetTimeout =
    Pointer.fromFunction(_setTimeout, SET_TIMEOUT_ERROR);

// Register setInterval
typedef NativeSetInterval = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setInterval(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.setInterval(timeout, () {
    void _runCallbacks() {
      DartAsyncCallback func = callback.asFunction();
      try {
        func(callbackContext, contextId, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Dart Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallbacks);
    } else {
      _runCallbacks();
    }
  });
}

const int SET_INTERVAL_ERROR = -1;
final Pointer<NativeFunction<NativeSetInterval>> _nativeSetInterval =
    Pointer.fromFunction(_setInterval, SET_INTERVAL_ERROR);

// Register clearTimeout
typedef NativeClearTimeout = Void Function(Int32 contextId, Int32);

void _clearTimeout(int contextId, int timerId) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.clearTimeout(timerId);
}

final Pointer<NativeFunction<NativeClearTimeout>> _nativeClearTimeout = Pointer.fromFunction(_clearTimeout);

// Register requestAnimationFrame
typedef NativeRequestAnimationFrame = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>>);

int _requestAnimationFrame(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>> callback) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.requestAnimationFrame((double highResTimeStamp) {
    void _runCallback() {
      DartRAFAsyncCallback func = callback.asFunction();
      try {
        func(callbackContext, contextId, highResTimeStamp, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, highResTimeStamp, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallback);
    } else {
      _runCallback();
    }
  });
}

const int RAF_ERROR_CODE = -1;
final Pointer<NativeFunction<NativeRequestAnimationFrame>> _nativeRequestAnimationFrame =
    Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);

// Register cancelAnimationFrame
typedef NativeCancelAnimationFrame = Void Function(Int32 contextId, Int32 id);

void _cancelAnimationFrame(int contextId, int timerId) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  controller.module.cancelAnimationFrame(timerId);
}

final Pointer<NativeFunction<NativeCancelAnimationFrame>> _nativeCancelAnimationFrame =
    Pointer.fromFunction(_cancelAnimationFrame);

typedef NativeGetScreen = Pointer<Void> Function();

Pointer<Void> _getScreen() {
  ui.Size size = ui.window.physicalSize;
  return createScreen(size.width / ui.window.devicePixelRatio, size.height / ui.window.devicePixelRatio);
}

final Pointer<NativeFunction<NativeGetScreen>> _nativeGetScreen = Pointer.fromFunction(_getScreen);

typedef NativeAsyncBlobCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef DartAsyncBlobCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8>, Pointer<Uint8>, int);
typedef NativeToBlob = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncBlobCallback>>, Int32, Double);

void _toBlob(Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncBlobCallback>> callback,
    int id, double devicePixelRatio) {
  DartAsyncBlobCallback func = callback.asFunction();
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
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

typedef NativeInitWindow = Void Function(Int32 contextId, Pointer<NativeBindingObject> nativePtr);
typedef DartInitWindow = void Function(int contextId, Pointer<NativeBindingObject> nativePtr);

void _initWindow(int contextId, Pointer<NativeBindingObject> nativePtr) {
  WebFViewController.windowNativePtrMap[contextId] = nativePtr;
}

final Pointer<NativeFunction<NativeInitWindow>> _nativeInitWindow = Pointer.fromFunction(_initWindow);

typedef NativeInitDocument = Void Function(Int32 contextId, Pointer<NativeBindingObject> nativePtr);
typedef DartInitDocument = void Function(int contextId, Pointer<NativeBindingObject> nativePtr);

void _initDocument(int contextId, Pointer<NativeBindingObject> nativePtr) {
  WebFViewController.documentNativePtrMap[contextId] = nativePtr;
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

final Pointer<NativeFunction<NativePerformanceGetEntries>> _nativeGetEntries =
    Pointer.fromFunction(_performanceGetEntries);

typedef NativeJSError = Void Function(Int32 contextId, Pointer<Utf8>);

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  JSErrorHandler? handler = controller.onJSError;
  if (handler != null) {
    String msg = charStr.toDartString();
    handler(msg);
  }
}

final Pointer<NativeFunction<NativeJSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

typedef NativeJSLog = Void Function(Int32 contextId, Int32 level, Pointer<Utf8>);

void _onJSLog(int contextId, int level, Pointer<Utf8> charStr) {
  String msg = charStr.toDartString();
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  if (controller != null) {
    JSLogHandler? jsLogHandler = controller.onJSLog;
    if (jsLogHandler != null) {
      jsLogHandler(level, msg);
    }
  }
}

final Pointer<NativeFunction<NativeJSLog>> _nativeOnJsLog = Pointer.fromFunction(_onJSLog);

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
  _nativeToBlob.address,
  _nativeFlushUICommand.address,
  _nativeInitWindow.address,
  _nativeInitDocument.address,
  _nativeGetEntries.address,
  _nativeOnJsError.address,
  _nativeOnJsLog.address,
];

typedef NativeRegisterDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef DartRegisterDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

final DartRegisterDartMethods _registerDartMethods =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeRegisterDartMethods>>('registerDartMethods').asFunction();

void registerDartMethodsToCpp() {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerDartMethods(bytes, _dartNativeMethods.length);
}
