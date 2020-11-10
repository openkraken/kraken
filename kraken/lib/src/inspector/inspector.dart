/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';
import 'package:kraken/module.dart';
import 'server.dart';
import 'module.dart';

const String INSPECTOR_URL = 'devtools://devtools/bundled/inspector.html';
const int INSPECTOR_DEFAULT_PORT = 9222;

class Inspector {
  String get address => server?.address;
  int get port => server?.port;
  final ElementManager elementManager;
  final Map<String, InspectModule> moduleRegistrar = {};
  InspectServer server;

  Inspector(this.elementManager, { int port = INSPECTOR_DEFAULT_PORT, String address = '127.0.0.1' }) {
    registerModule(InspectDOMModule(this));

    server = InspectServer(this, address: address, port: port)
      ..onStarted = onServerStart
      ..onBackendMessage = messageRouter
      ..start();
  }

  void registerModule(InspectModule module) {
    moduleRegistrar[module.name] = module;
  }

  void onServerStart() async {
    String inspectorURL = '$INSPECTOR_URL?ws=$address:$port';
    await KrakenClipboard.writeText(inspectorURL);

    print('Kraken DevTool listening at ws://$address:$port');
    print('Open Chrome/Edge and paste following url to your navigator:');
    print('    $inspectorURL');
  }

  void messageRouter(Map<String, dynamic> data) {
    String _method = data['method'];
    Map<String, dynamic> params = data['params'];

    List<String> moduleMethod = _method.split('.');
    String module = moduleMethod[0];
    String method = moduleMethod[1];

    print('Receive $data');
    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module].invoke(method, params);
    }
  }
}

/// Inspector object record data, which used to response valid websocket message.
///
/// Inspector data including one response data sequence, request data sequence List (optional).
// class InspectorData {
//   ResponseData _response = ResponseData();
//   ResponseData get response => _response;
//
//   void setId(int id) {
//     _response.setId(id);
//   }
//
//   void setResult(String key, value) {
//     _response.setResult(key, value);
//   }
//
//   List<RequestData> _requests = [];
//   List<RequestData> get requests => _requests;
//   bool get isRequestsNotEmpty => _requests.isNotEmpty;
//
//   void addExtra(RequestData value) {
//     _requests.add(value);
//   }
// }

/// Inspector WebSocket response object based on JSON-RPC.
///
/// Response including [id] and [result] members.
// class ResponseData {
//   int id = 0;
//   Map<String, dynamic> result = {};
//
//   /// Set [id] with new [value].
//   void setId(int value) {
//     id = value;
//   }
//
//   /// Set item in result map with [key] and [value]
//   void setResult(String key, dynamic value) {
//     result[key] = value;
//   }
//
//   /// Encoding response data into the standard json format.
//   Map<String, dynamic> toJson() {
//     return {'id': id, 'result': result};
//   }
// }

/// Inspector WebSocket request object based on JSON-RPC.
///
/// Request including [id], [method] and [params] members.

// class RequestData {
//   int id;
//
//   String method = '';
//
//   Map<String, dynamic> params = {};
//
//   void setId(int value) {
//     id = value;
//   }
//
//   void setMethod(String value) {
//     method = value;
//   }
//
//   void setParams(String key, dynamic value) {
//     params[key] = value;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {if (id != null) 'id': id, 'method': method, 'params': params};
//   }
// }

abstract class JSONEncodable {
  Map toJson();
}
