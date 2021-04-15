/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:io';

import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
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
  InspectorFrontEndMessage(this.id, this.module, this.method, this.params);
  int id;
  String module;
  String method;
  final Map<String, dynamic> params;
}

class InspectorMethodResult {
  final int id;
  final Map result;
  InspectorMethodResult(this.id, this.result);
}

class InspectorPostTaskMessage {
  final int taskId;
  InspectorPostTaskMessage(this.taskId);
}

class UIInspector {
  /// Design preInspector for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static UIInspector prevInspector;

  KrakenViewController viewController;
  final Map<String, UIInspectorModule> moduleRegistrar = {};

  factory UIInspector(KrakenViewController viewController) {
    if (UIInspector.prevInspector != null) {
      // Apply reload page, reuse prev inspector instance.
      UIInspector prevInspector = UIInspector.prevInspector;

      prevInspector.viewController = viewController;
      viewController.elementManager.debugDOMTreeChanged = prevInspector.onDOMTreeChanged;

      UIInspector.prevInspector = null;
      return prevInspector;
    } else {
      return UIInspector._(viewController);
    }
  }

  UIInspector._(this.viewController) {
    registerModule(InspectDOMModule(this));
    registerModule(InspectOverlayModule(this));
    registerModule(InspectPageModule(this));
    registerModule(InspectCSSModule(this));
  }

  void registerModule(UIInspectorModule module) {
    moduleRegistrar[module.name] = module;
  }

  void onServerStart(int port) async {
    String remoteAddress = await UIInspector.getConnectedLocalNetworkAddress();
    String inspectorURL = '$INSPECTOR_URL?ws=$remoteAddress:$port';
    await ClipBoardModule.writeText(inspectorURL);

    print('Kraken DevTool listening at ws://$remoteAddress:$port');
    print('Open Chrome/Edge and paste following url to your navigator:');
    print('    $inspectorURL');
  }

  void messageRouter(int id, String module, String method, Map<String, dynamic> params) {
    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module].invoke(id, method, params);
    }
  }

  void onDOMTreeChanged() {
    viewController.isolateServerPort.send(DOMUpdatedEvent());
  }

  void dispose() {
    moduleRegistrar.clear();
    viewController = null;
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
