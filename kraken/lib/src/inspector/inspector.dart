/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';

import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'server.dart';
import 'module.dart';

const String INSPECTOR_URL = 'devtools://devtools/bundled/inspector.html';
const int INSPECTOR_DEFAULT_PORT = 9222;
const String INSPECTOR_DEFAULT_ADDRESS = '127.0.0.1';

class DOMUpdatedEvent extends InspectorEvent {
  @override
  String get method => 'DOM.documentUpdated';

  @override
  JSONEncodable get params => null;
}

typedef NativeInspectorMessageHandler = void Function(String message);

class InspectorServerInit {
  final int port;
  final String address;
  final String bundleURL;
  final int contextId;

  InspectorServerInit(this.contextId, this.port, this.address, this.bundleURL);
}

class InspectorServerStart {
}

class InspectorFrontEndMessage {
  InspectorFrontEndMessage(this.message);
  final Map<String, dynamic> message;
}

class InspectorMethodResult {
  final int id;
  final JSONEncodable result;
  InspectorMethodResult(this.id, this.result);
}

class InspectorNativeMessage {
  final String message;
  InspectorNativeMessage(this.message);
}

class InspectorPostTaskMessage {
  final int taskId;
  InspectorPostTaskMessage(this.taskId);
}

class Inspector {
  /// Design preInspector for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static Inspector prevInspector;

  ElementManager elementManager;
  final Map<String, InspectModule> moduleRegistrar = {};

  Isolate _serverIsolate;
  SendPort _serverPort;
  SendPort get serverPort => _serverPort;

  factory Inspector(ElementManager elementManager, { int port = INSPECTOR_DEFAULT_PORT, String address }) {
    if (Inspector.prevInspector != null) {
      // Apply reload page, reuse prev inspector instance.
      Inspector prevInspector = Inspector.prevInspector;

      prevInspector.elementManager = elementManager;
      elementManager.debugDOMTreeChanged = prevInspector.onDOMTreeChanged;

      Inspector.prevInspector = null;
      return prevInspector;
    } else {
      return Inspector._(elementManager, port: port, address: address);
    }
  }

  Inspector._(this.elementManager, { int port = INSPECTOR_DEFAULT_PORT, String address }) {
    registerModule(InspectDOMModule(this));
    registerModule(InspectOverlayModule(this));
    registerModule(InspectPageModule(this));
    registerModule(InspectCSSModule(this));
    registerModule(InspectRuntimeModule(this));
    registerModule(InspectDebuggerModule(this));

    ReceivePort serverIsolateReceivePort = ReceivePort();

    serverIsolateReceivePort.listen((data) {
      if (data is SendPort) {
        _serverPort = data;
        KrakenController controller = elementManager.controller;
        String bundleURL = controller.bundleURL ?? controller.bundlePath ?? '<EmbedBundle>';
        _serverPort.send(InspectorServerInit(controller.view.contextId, port, '0.0.0.0', bundleURL));
      } else if (data is InspectorFrontEndMessage) {
        messageRouter(data.message);
      } else if (data is InspectorServerStart) {
        onServerStart(port);
      }
    });

    Isolate.spawn(serverIsolateEntryPoint, serverIsolateReceivePort.sendPort);
  }

  void registerModule(InspectModule module) {
    moduleRegistrar[module.name] = module;
  }

  void onServerStart(int port) async {
    String remoteAddress = await Inspector.getConnectedLocalNetworkAddress();
    String inspectorURL = '$INSPECTOR_URL?ws=$remoteAddress:$port';
    await ClipBoardModule.writeText(inspectorURL);

    print('Kraken DevTool listening at ws://$remoteAddress:$port');
    print('Open Chrome/Edge and paste following url to your navigator:');
    print('    $inspectorURL');
  }

  void messageRouter(Map<String, dynamic> data) {
    int id = data['id'];
    String _method = data['method'];
    Map<String, dynamic> params = data['params'];

    List<String> moduleMethod = _method.split('.');
    String module = moduleMethod[0];
    String method = moduleMethod[1];

    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module].invoke(id, method, params);
    }
  }

  void onDOMTreeChanged() {
    _serverPort.send(DOMUpdatedEvent());
  }

  void dispose() {
    moduleRegistrar.clear();
    _serverIsolate.kill();
  }

  static Future<String> getConnectedLocalNetworkAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false, type: InternetAddressType.IPv4);

    String result = INSPECTOR_DEFAULT_ADDRESS;
    if (interfaces != null) {
      for (NetworkInterface interface in interfaces) {
        if (interface.name == 'en0' || interface.name == 'eth0' || interface.name == 'wlan0') {
          result = interface.addresses.first.address;
          break;
        }
      }
    }

    return result;
  }
}

abstract class JSONEncodable {
  Map toJson();
  String toString() {
    return jsonEncode(toJson());
  }
}

abstract class InspectorEvent extends JSONEncodable {
  String get method;
  JSONEncodable get params;
  InspectorEvent();

  Map toJson() {
    return {
      'method': method,
      'params': params?.toJson() ?? {},
    };
  }
}

class JSONEncodableMap extends JSONEncodable {
  Map<String, dynamic> map;
  JSONEncodableMap(this.map);

  Map toJson() => map;
}
