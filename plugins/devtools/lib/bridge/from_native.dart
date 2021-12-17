import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:kraken_devtools/kraken_devtools.dart';
import 'package:kraken_devtools/inspector/ui_inspector.dart';

import 'platform.dart';

typedef NativePostTaskToInspectorThread = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartPostTaskToInspectorThread = void Function(int contextId, Pointer<Void> context, Pointer<Void> callback);

void _postTaskToInspectorThread(int contextId, Pointer<Void> context, Pointer<Void> callback) {
  ChromeDevToolsService? devTool = ChromeDevToolsService.getDevToolOfContextId(contextId);
  if (devTool != null) {
    devTool.isolateServerPort!.send(InspectorPostTaskMessage(context.address, callback.address));
  }
}

final Pointer<NativeFunction<NativePostTaskToInspectorThread>> _nativePostTaskToInspectorThread = Pointer.fromFunction(_postTaskToInspectorThread);

final List<int> _dartNativeMethods = [
  _nativePostTaskToInspectorThread.address
];

typedef NativeRegisterDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef DartRegisterDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

bool registerUIDartMethodsToCpp() {
  DynamicLibrary? nativeDynamicLibrary = getDynamicLibrary();
  if (nativeDynamicLibrary == null) return false;
  final DartRegisterDartMethods _registerDartMethods =
  nativeDynamicLibrary.lookup<NativeFunction<NativeRegisterDartMethods>>('registerUIDartMethods').asFunction();
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(_dartNativeMethods.length * sizeOf<Uint64>());
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerDartMethods(bytes, _dartNativeMethods.length);
  return true;
}
