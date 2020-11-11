/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';
import 'package:kraken/module.dart';
import 'server.dart';
import 'module.dart';

const String INSPECTOR_URL = 'devtools://devtools/bundled/inspector.html';
const int INSPECTOR_DEFAULT_PORT = 9222;
const String INSPECTOR_DEFAULT_ADDRESS = '127.0.0.1';

class Inspector {
  String get address => server?.address;
  int get port => server?.port;
  final ElementManager elementManager;
  final Map<String, InspectModule> moduleRegistrar = {};
  InspectServer server;

  Inspector(this.elementManager, { int port = INSPECTOR_DEFAULT_PORT, String address }) {
    registerModule(InspectDOMModule(this));
    registerModule(InspectOverlayModule(this));
    registerModule(InspectPageModule(this));
    registerModule(InspectCSSModule(this));

    server = InspectServer(this, address: '0.0.0.0', port: port)
      ..onStarted = onServerStart
      ..onBackendMessage = messageRouter
      ..start();
  }

  void registerModule(InspectModule module) {
    moduleRegistrar[module.name] = module;
  }

  void onServerStart() async {
    String remoteAddress = await Inspector.getConnectedLocalNetworkAddress();
    String inspectorURL = '$INSPECTOR_URL?ws=$remoteAddress:$port';
    await KrakenClipboard.writeText(inspectorURL);

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

    if (!kReleaseMode) {
      print('Receive $data');
    }

    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module].invoke(id, method, params);
    }
  }

  void dispose() {
    moduleRegistrar.clear();
    server?.dispose();
  }

  static Future<String> getConnectedLocalNetworkAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false, type: InternetAddressType.IPv4);

    String result = INSPECTOR_DEFAULT_ADDRESS;
    if (interfaces != null) {
      for (NetworkInterface interface in interfaces) {
        if (interface.name == 'en0' || interface.name == 'eth0') {
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
}
