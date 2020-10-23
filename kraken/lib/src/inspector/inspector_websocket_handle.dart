/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

enum ResponseState { Success, Error, NotFound }

class InspectorWebSocketAgent {
  Node _root;
  InspectorCssAgent cssAgent;
  InspectorDomAgent domAgent;

  InspectorWebSocketAgent(this._root) {
    domAgent = InspectorDomAgent(_root);
    cssAgent = InspectorCssAgent(domAgent);
  }

  ResponseState onRequest(ResponseData responseData, String message) {
    Map<String, Object> data = jsonDecode(message ?? '');

    if (!(data['id'] is int && data['method'] is String)) {
      return ResponseState.Error;
    }

    if (!(data['params'] == null || data['params'] is Map<String, Object>)) {
      return ResponseState.Error;
    }

    int connectId = data['id'];
    String method = data['method'];
    Map<String, Object> params = data['params'] ?? {};

    List<String> methodList = method.split('.');

    if (methodList.length != 2) {
      return ResponseState.Error;
    }

    String methodType = methodList[0];

    responseData.setId(connectId);

    switch (methodType) {
      case ('CSS'):
        return cssAgent.onRequest(params, method, responseData);
        break;
      case ('DOM'):
        return domAgent.onRequest(params, method, responseData);
        break;
    }

    return ResponseState.NotFound;
  }
}
