/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';

enum ResponseState {
  Success,
  Error,
  NotFound,
}

class InspectorWebSocketAgent {
  ElementManager _elementManager;
  InspectorCSSAgent cssAgent;
  InspectorDOMAgent domAgent;

  InspectorWebSocketAgent(this._elementManager) {
    domAgent = InspectorDOMAgent(_elementManager);
    cssAgent = InspectorCSSAgent(domAgent);
  }

  ResponseState onRequest(InspectorData protocolData, String message) {
    Map<String, dynamic> data = jsonDecode(message ?? '');

    assert(data['id'] is int);
    assert(data['method'] is String);
    assert(data['params'] is Map<String, dynamic> || data['params'] == null);

    int connectId = data['id'];
    String method = data['method'];
    Map<String, dynamic> params = data['params'] ?? {};
    List<String> methodList = method.split('.');

    if (methodList.length != 2) {
      return ResponseState.Error;
    }

    String methodType = methodList[0];
    ResponseData responseData = protocolData.response;

    responseData.setId(connectId);

    switch (methodType) {
      case ('CSS'):
        return cssAgent.onRequest(params, method, protocolData);
        break;
      case ('DOM'):
        return domAgent.onRequest(params, method, protocolData);
        break;
    }

    return ResponseState.NotFound;
  }
}
