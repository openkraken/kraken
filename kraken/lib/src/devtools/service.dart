/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:isolate';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/devtools.dart';
import '../bridge/platform.dart';

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

void spawnIsolateInspectorServer(ChromeDevToolsService devTool, KrakenController controller, { int port = INSPECTOR_DEFAULT_PORT, String? address }) {
  ReceivePort serverIsolateReceivePort = ReceivePort();

  serverIsolateReceivePort.listen((data) {
    if (data is SendPort) {
      devTool._isolateServerPort = data;
      String bundleURL = controller.bundle?.uri.toString() ?? '<EmbedBundle>';
      devTool._isolateServerPort!.send(InspectorServerInit(controller.view.contextId, port, '0.0.0.0', bundleURL));
    } else if (data is InspectorFrontEndMessage) {
      devTool.uiInspector!.messageRouter(data.id, data.module, data.method, data.params);
    } else if (data is InspectorServerStart) {
      devTool.uiInspector!.onServerStart(port);
    } else if (data is InspectorPostTaskMessage) {
      if (devTool.isReloading) return;
      dispatchUITask(controller.view.contextId, Pointer.fromAddress(data.context), Pointer.fromAddress(data.callback));
    }
  });

  Isolate.spawn(serverIsolateEntryPoint, serverIsolateReceivePort.sendPort).then((Isolate isolate) {
    devTool._isolateServerIsolate = isolate;
  });
}

class ChromeDevToolsService extends DevToolsService {
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static ChromeDevToolsService? prevDevTools;

  static final Map<int, ChromeDevToolsService> _contextDevToolMap = {};
  static ChromeDevToolsService? getDevToolOfContextId(int contextId) {
    return _contextDevToolMap[contextId];
  }

  late Isolate _isolateServerIsolate;
  SendPort? _isolateServerPort;
  SendPort? get isolateServerPort => _isolateServerPort;

  /// Used for debugger inspector.
  UIInspector? _uiInspector;
  UIInspector? get uiInspector => _uiInspector;

  KrakenController? _controller;
  KrakenController? get controller => _controller;

  bool get isReloading => _reloading;
  bool _reloading = false;

  @override
  void dispose() {
    _uiInspector?.dispose();
    _contextDevToolMap.remove(controller!.view.contextId);
    _controller = null;
    _isolateServerPort = null;
    _isolateServerIsolate.kill();
  }

  @override
  void init(KrakenController controller) {
    _contextDevToolMap[controller.view.contextId] = this;
    _controller = controller;
    // @TODO: Add JS debug support for QuickJS.
    // bool nativeInited = _registerUIDartMethodsToCpp();
    // if (!nativeInited) {
    //   print('Warning: kraken_devtools is not supported on your platform.');
    //   return;
    // }
    spawnIsolateInspectorServer(this, controller);
    _uiInspector = UIInspector(this);
    controller.view.debugDOMTreeChanged = uiInspector!.onDOMTreeChanged;
  }

  @override
  void willReload() {
    _reloading = true;
  }

  @override
  void didReload() {
    _reloading = false;
    controller!.view.debugDOMTreeChanged = _uiInspector!.onDOMTreeChanged;
    _isolateServerPort!.send(InspectorReload(_controller!.view.contextId));
  }

  // @TODO: Implement and remove.
  // ignore: unused_element
  static bool _registerUIDartMethodsToCpp() {
    final DartRegisterDartMethods _registerDartMethods = nativeDynamicLibrary.lookup<NativeFunction<NativeRegisterDartMethods>>('registerUIDartMethods').asFunction();
    Pointer<Uint64> bytes = malloc.allocate<Uint64>(_dartNativeMethods.length * sizeOf<Uint64>());
    Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
    nativeMethodList.setAll(0, _dartNativeMethods);
    _registerDartMethods(bytes, _dartNativeMethods.length);
    return true;
  }
}
