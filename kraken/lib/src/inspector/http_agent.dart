/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:io';

import 'package:kraken/kraken.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/inspector.dart';

const String CONTENT_TYPE = 'Content-Type';
const String CONTENT_LENGTH = 'Content-Length';
const String INSPECTOR_URL = 'devtools://devtools/bundled/inspector.html';

class InspectorHTTPAgent {
  Inspector inspector;
  InspectorHTTPAgent(this.inspector);

  void _writeJSONObject(HttpRequest request, Object obj) {
    String body = jsonEncode(obj);
    request.response.headers.set(CONTENT_TYPE, 'application/json; charset=UTF-8');
    request.response.headers.set(CONTENT_LENGTH, body.length);
    request.response.write(body);
  }

  void onRequestVersion(HttpRequest request) {
    request.response.headers.clear();
    KrakenInfo krakenInfo = getKrakenInfo();
    _writeJSONObject(request, {
      'Browser': 'Kraken/${krakenInfo.appVersion}',
      'Protocol-Version': '1.3',
      'User-Agent': krakenInfo.userAgent,
    });
  }

  void onRequestList(HttpRequest request) {
    request.response.headers.clear();
    String entryURL = '${inspector.address}:${inspector.port}';
    KrakenController controller = inspector.elementManager.controller;
    String bundleURL = controller.bundleURL ?? controller.bundlePath ?? '<EmbedBundle>';
    _writeJSONObject(request, [{
      'description': '',
      'devtoolsFrontendUrl': '$INSPECTOR_URL?ws=$entryURL',
      'title': 'Kraken App',
      'type': 'page',
      'url': bundleURL,
      'webSocketDebuggerUrl': 'ws://$entryURL'
    }]);
  }

  void onRequestClose(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestActivate(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestNew(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestProtocol(HttpRequest request) {
    onRequestFallback(request);
  }


  void onRequestFallback(HttpRequest request) {
    request.response.statusCode = 404;
    request.response.write('Unknown request.');
  }

  void onRequest(HttpRequest request) async {
    switch (request.requestedUri.path) {
      case '/json/version':
        onRequestVersion(request);
        break;

      case '/json':
      case '/json/list':
        onRequestList(request);
        break;

      case '/json/new':
        onRequestNew(request);
        break;

      case '/json/close':
        onRequestClose(request);
        break;

      case '/json/protocol':
        onRequestProtocol(request);
        break;

      default:
        onRequestFallback(request);
        break;
    }

    await request.response.close();
  }
}

