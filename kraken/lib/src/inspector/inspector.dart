/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:io';

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

class DebugInspector {
  dynamic address;
  int port;
  InspectorWebSocketAgent websocketAgent;
  InspectorHttpHandler httpHandler;

  DebugInspector(ElementManager elementManager,
      {this.port = 8082, this.address = '127.0.0.1'}) {
    websocketAgent = InspectorWebSocketAgent(elementManager);
    httpHandler = InspectorHttpHandler();
    serverStart();
  }

  void serverStart() async {
    try {
      HttpServer server = await HttpServer.bind(address, port);
      print('DevTool WebSocket listening at -- ws://${address}:${port}');
      await for (HttpRequest request in server) {
        HttpHeaders headers = request.headers;

        if (headers.value('upgrade') == 'websocket') {
          WebSocket ws = await WebSocketTransformer.upgrade(request);

          ws.listen((message) {
            JsonData protocolData = new JsonData();
            ResponseState response =
                websocketAgent.onRequest(protocolData, message);
            if (response == ResponseState.Success ||
                response == ResponseState.NotFound) {
              if (protocolData.isNotEmptyExtra()) {
                protocolData.extra.forEach((RequestData req) {
                  ws.add(jsonEncode(req.toJson()));
                });
              }

              ws.add(jsonEncode(protocolData.response.toJson()));
            }

            if (response == ResponseState.Error) ws.add('');
          });
        } else {
          httpHandler.onHttpRequest(request);
        }
      }
    } catch (error) {
      print(error);
    }
  }
}

class JsonData {
  ResponseData res = new ResponseData();
  List<RequestData> reqList = [];

  bool isNotEmptyExtra() => reqList.isNotEmpty;

  get response => res;

  void addExtra(RequestData value) {
    reqList.add(value);
  }

  void setId(int id) {
    res.setId(id);
  }

  void setResult(String key, dynamic value) {
    res.setResult(key, value);
  }

  List<RequestData> get extra {
    return reqList;
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
