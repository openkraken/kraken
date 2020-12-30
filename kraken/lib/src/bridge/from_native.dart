import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/dom.dart';

import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/module.dart';
import 'package:kraken/css.dart';
import 'package:kraken/src/module/performance_timing.dart';
import 'package:vibration/vibration.dart';
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
    Pointer<JSCallbackContext> callbackContext, Int32 contextId, Pointer<NativeString> json);
typedef DartAsyncModuleCallback = void Function(
    Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<NativeString> json);

typedef Native_InvokeModule = Pointer<NativeString> Function(Pointer<JSCallbackContext> callbackContext,
    Int32 contextId, Pointer<NativeString>, Pointer<NativeFunction<NativeAsyncModuleCallback>>);

String invokeModule(
    Pointer<JSCallbackContext> callbackContext, int contextId, String json, DartAsyncModuleCallback callback) {
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  dynamic args = jsonDecode(json);
  String module = args[0];
  String result = EMPTY_STRING;
  try {
    if (module == 'Connection') {
      String method = args[1];
      if (method == 'getConnectivity') {
        Connection.getConnectivity((String json) {
          callback(callbackContext, contextId, stringToNativeString(json));
        });
      } else if (method == 'onConnectivityChanged') {
        Connection.onConnectivityChanged((String json) {
          emitModuleEvent(contextId, '["onConnectivityChanged", $json]');
        });
      }
    } else if (module == 'fetch') {
      List fetchArgs = args[1];
      String url = fetchArgs[0];
      Map<String, dynamic> options = fetchArgs[1];
      fetch(url, options).then((Response response) {
        String json = jsonEncode(['', response.statusCode, response.data]);
        callback(callbackContext, contextId, stringToNativeString(json));
      }).catchError((e, stack) {
        String errorMessage = e.toString();
        String json;
        if (e is DioError && e.type == DioErrorType.RESPONSE) {
          json = jsonEncode([errorMessage, e.response.statusCode, EMPTY_STRING]);
        } else {
          json = jsonEncode(['$errorMessage\n$stack', null, EMPTY_STRING]);
        }
        callback(callbackContext, contextId, stringToNativeString(json));
      });
    } else if (module == 'DeviceInfo') {
      String method = args[1];
      if (method == 'getDeviceInfo') {
        DeviceInfo.getDeviceInfo().then((String json) {
          callback(callbackContext, contextId, stringToNativeString(json));
        });
      } else if (method == 'getHardwareConcurrency') {
        result = DeviceInfo.getHardwareConcurrency().toString();
      }
    } else if (module == 'AsyncStorage') {
      String method = args[1];
      if (method == 'getItem') {
        List methodArgs = args[2];
        String key = methodArgs[0];
        // @TODO: catch error case
        AsyncStorage.getItem(key).then((String value) {
          callback(callbackContext, contextId, stringToNativeString(value ?? EMPTY_STRING));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'setItem') {
        List methodArgs = args[2];
        String key = methodArgs[0];
        String value = methodArgs[1];
        AsyncStorage.setItem(key, value).then((bool isSuccess) {
          callback(callbackContext, contextId, stringToNativeString(isSuccess.toString()));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'removeItem') {
        List methodArgs = args[2];
        String key = methodArgs[0];
        AsyncStorage.removeItem(key).then((bool isSuccess) {
          callback(callbackContext, contextId, stringToNativeString(isSuccess.toString()));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'getAllKeys') {
        // @TODO: catch error case
        AsyncStorage.getAllKeys().then((Set<String> set) {
          List<String> list = List.from(set);
          callback(callbackContext, contextId, stringToNativeString(jsonEncode(list)));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'clear') {
        AsyncStorage.clear().then((bool isSuccess) {
          callback(callbackContext, contextId, stringToNativeString(isSuccess.toString()));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      }
    } else if (module == 'MQTT') {
      String method = args[1];
      if (method == 'init') {
        List methodArgs = args[2];
        return controller.module.mqtt.init(methodArgs[0], methodArgs[1]);
      } else if (method == 'open') {
        List methodArgs = args[2];
        controller.module.mqtt.open(methodArgs[0], methodArgs[1]);
      } else if (method == 'close') {
        List methodArgs = args[2];
        controller.module.mqtt.close(methodArgs[0]);
      } else if (method == 'publish') {
        List methodArgs = args[2];
        controller.module.mqtt.publish(methodArgs[0], methodArgs[1], methodArgs[2], methodArgs[3], methodArgs[4]);
      } else if (method == 'subscribe') {
        List methodArgs = args[2];
        controller.module.mqtt.subscribe(methodArgs[0], methodArgs[1], methodArgs[2]);
      } else if (method == 'unsubscribe') {
        List methodArgs = args[2];
        controller.module.mqtt.unsubscribe(methodArgs[0], methodArgs[1]);
      } else if (method == 'getReadyState') {
        List methodArgs = args[2];
        return controller.module.mqtt.getReadyState(methodArgs[0]);
      } else if (method == 'addEvent') {
        List methodArgs = args[2];
        controller.module.mqtt.addEvent(methodArgs[0], methodArgs[1], (String id, String event) {
          emitModuleEvent(contextId, '["MQTT", $id, $event]');
        });
      }
    } else if (module == 'Geolocation') {
      String method = args[1];
      if (method == 'getCurrentPosition') {
        List positionArgs = args[2];
        Map<String, dynamic> options;
        if (positionArgs.length > 0) {
          options = positionArgs[0];
        }
        Geolocation.getCurrentPosition(options, (json) {
          callback(callbackContext, contextId, stringToNativeString(json));
        });
      } else if (method == 'watchPosition') {
        List positionArgs = args[2];
        Map<String, dynamic> options;
        if (positionArgs.length > 0) {
          options = positionArgs[0];
        }
        return Geolocation.watchPosition(options, (String result) {
          emitModuleEvent(contextId, '["watchPosition", $result]');
        }).toString();
      } else if (method == 'clearWatch') {
        List positionArgs = args[2];
        int id = positionArgs[0];
        Geolocation.clearWatch(id);
      }
    } else if (module == 'MethodChannel') {
      String method = args[1];
      assert(controller.methodChannel != null);
      if (method == 'invokeMethod') {
        List methodArgs = args[2];
        invokeMethodFromJavaScript(controller, methodArgs[0], methodArgs[1]).then((result) {
          String ret;
          if (result is String) {
            ret = result;
          } else {
            ret = jsonEncode(result);
          }
          callback(callbackContext, contextId, stringToNativeString(ret));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'setMethodCallHandler') {
        onJSMethodCall(controller, (String method, dynamic arguments) async {
          emitModuleEvent(contextId, jsonEncode(['MethodChannel', method, arguments]));
        });
      }
    } else if (module == 'Clipboard') {
      String method = args[1];
      if (method == 'readText') {
        KrakenClipboard.readText().then((String value) {
          callback(callbackContext, contextId, stringToNativeString(value ?? ''));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      } else if (method == 'writeText') {
        List methodArgs = args[2];
        KrakenClipboard.writeText(methodArgs[0]).then((_) {
          callback(callbackContext, contextId, stringToNativeString(EMPTY_STRING));
        }).catchError((e, stack) {
          callback(callbackContext, contextId, stringToNativeString('Error: $e\n$stack'));
        });
      }
    } else if (module == 'WebSocket') {
      String method = args[1];
      if (method == 'init') {
        List methodArgs = args[2];
        return controller.module.websocket.init(methodArgs[0], (String id, String event) {
          emitModuleEvent(contextId, '["WebSocket", $id, $event]');
        });
      } else if (method == 'addEvent') {
        List methodArgs = args[2];
        controller.module.websocket.addEvent(methodArgs[0], methodArgs[1]);
      } else if (method == 'send') {
        List methodArgs = args[2];
        controller.module.websocket.send(methodArgs[0], methodArgs[1]);
      } else if (method == 'close') {
        List methodArgs = args[2];
        controller.module.websocket.close(methodArgs[0], methodArgs[1], methodArgs[2]);
      }
    } else if (module == 'Navigator') {
      String method = args[1];
      if (method == 'vibrate') {
        List methodArgs = args[2];
        if (methodArgs.length == 1) {
          int duration = methodArgs[0];
          Vibration.vibrate(duration: duration);
        } else {
          List<int> filteredArgs = [];
          for (var number in methodArgs) {
            if (number is double)
              filteredArgs.add(number.floor());
            else if (number is int) filteredArgs.add(number);
          }
          // Pattern must have even number of elements, default duration to 500ms.
          if (filteredArgs.length.isOdd) filteredArgs.add(500);
          Vibration.vibrate(pattern: filteredArgs);
        }
      } else if (method == 'cancelVibrate') {
        Vibration.cancel();
      }
    } else if (module == 'Navigation') {
      String method = args[1];
      List navigationArgs = args[2];
      if (method == 'goTo') {
        String url = navigationArgs[0];
        String sourceUrl = controller.bundleURL;

        Uri targetUri = Uri.parse(url);
        Uri sourceUri = Uri.parse(sourceUrl);

        if (targetUri.scheme != sourceUri.scheme ||
            targetUri.host != sourceUri.host ||
            targetUri.port != sourceUri.port ||
            targetUri.path != sourceUri.path ||
            targetUri.query != sourceUri.query) {
          controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.reload);
        }
      }
    }
  } catch (e, stack) {
    // Dart side internal error should print it directly.
    print('$e\n$stack');
  }

  return result;
}

Pointer<NativeString> _invokeModule(Pointer<JSCallbackContext> callbackContext, int contextId,
    Pointer<NativeString> json, Pointer<NativeFunction<NativeAsyncModuleCallback>> callback) {
  String result = invokeModule(callbackContext, contextId, nativeStringToString(json), callback.asFunction());
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
