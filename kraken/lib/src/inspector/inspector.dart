/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:io';

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

class DebugInspector {
  dynamic address = InternetAddress.anyIPv6;
  int port;
  InspectorWebSocketAgent websocketAgent;
  InspectorHttpHandler httpHandler;

  DebugInspector(Node root, {this.port = 8082, String address}) {
    websocketAgent = InspectorWebSocketAgent(root);
    httpHandler = InspectorHttpHandler();
    serverStart();
  }

  void serverStart() async {
    try {
      HttpServer server = await HttpServer.bind(address, port);
      await for (HttpRequest request in server) {
        HttpHeaders headers = request.headers;

        if (headers.value('upgrade') == 'websocket') {
          print(true);
          WebSocket ws = await WebSocketTransformer.upgrade(request);

          ws.listen((message) {
            ResponseData responseData = new ResponseData();
            ResponseState response =
                websocketAgent.onRequest(responseData, message);
            if (response == ResponseState.Success ||
                response == ResponseState.NotFound)
              ws.add(jsonEncode(responseData.toJson()));
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

/// Inspector WebSocket response object based on JSON-RPC.
/// 
/// Response including [id] and [result] members.
class ResponseData {
  int id;
  Map<String, Object> result = {};

  /// Set [id] with new [connectId].
  void setId(int connectId) {
    id = connectId;
  }

  /// Set item in result map with [key] and [value]
  void setResult(String key, Object value) {
    result[key] = value;
  }

  /// Encoding response data into the standard json format.
  Map<String, Object> toJson() {
    return {'id': id, 'result': result};
  }
}