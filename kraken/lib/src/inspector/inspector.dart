/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:io';

import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';

const int INSPECTOR_DEFAULT_PORT = 9222;

class Inspector {
  InternetAddress get address => server?.address;
  int get port => server?.port;

  ElementManager elementManager;
  HttpServer server;
  WebSocket ws;
  InspectorWebSocketAgent websocketAgent;
  InspectorHTTPAgent httpAgent;

  Inspector(this.elementManager, { int port, String address }) {
    websocketAgent = InspectorWebSocketAgent(this);
    httpAgent = InspectorHTTPAgent(this);

    startServer(address, port);
  }

  Future startServer(String address, int port) async {
    server = await HttpServer.bind(
      address ?? InternetAddress.loopbackIPv4,
      port ?? INSPECTOR_DEFAULT_PORT
    );
    print('Kraken DevTool listening at ws://${server.address.address}:${server.port}');
    print('Open Chrome/Edge and paste following url to your navigator:');
    print('        $INSPECTOR_URL?ws=${server.address.address}:${server.port}');

    await for (HttpRequest request in server) {
      HttpHeaders headers = request.headers;
      if (headers.value('upgrade') == 'websocket') {
        ws = await WebSocketTransformer.upgrade(request);
        ws.listen(onWebSocketData);
      } else {
        await httpAgent.onRequest(request);
      }
    }
  }

  void onWebSocketData(message) {
    InspectorData inspectorData = InspectorData();
    ResponseState response = websocketAgent.onRequest(inspectorData, message);
    if (response == ResponseState.Success ||
        response == ResponseState.NotFound) {
      if (inspectorData.isRequestsNotEmpty) {
        for (RequestData requestData in inspectorData.requests) {
          ws.add(jsonEncode(requestData.toJson()));
        }
      }
      ws.add(jsonEncode(inspectorData.response.toJson()));
    }

    if (response == ResponseState.Error) ws.add('');
  }
}

/// Inspector object record data, which used to response valid websocket message.
///
/// Inspector data including one response data sequence, request data sequence List (optional).
class InspectorData {
  ResponseData _response = ResponseData();
  ResponseData get response => _response;

  void setId(int id) {
    _response.setId(id);
  }

  void setResult(String key, value) {
    _response.setResult(key, value);
  }

  List<RequestData> _requests = [];
  List<RequestData> get requests => _requests;
  bool get isRequestsNotEmpty => _requests.isNotEmpty;

  void addExtra(RequestData value) {
    _requests.add(value);
  }
}

/// Inspector WebSocket response object based on JSON-RPC.
///
/// Response including [id] and [result] members.
class ResponseData {
  int id = 0;
  Map<String, dynamic> result = {};

  /// Set [id] with new [value].
  void setId(int value) {
    id = value;
  }

  /// Set item in result map with [key] and [value]
  void setResult(String key, dynamic value) {
    result[key] = value;
  }

  /// Encoding response data into the standard json format.
  Map<String, dynamic> toJson() {
    return {'id': id, 'result': result};
  }
}

/// Inspector WebSocket request object based on JSON-RPC.
///
/// Request including [id], [method] and [params] members.

class RequestData {
  int id;

  String method = '';

  Map<String, dynamic> params = {};

  void setId(int value) {
    id = value;
  }

  void setMethod(String value) {
    method = value;
  }

  void setParams(String key, dynamic value) {
    params[key] = value;
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'method': method, 'params': params};
  }
}

abstract class JSONEncodable {
  Map toJson();
}
