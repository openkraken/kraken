/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

enum ResponseState { Success, Error, NotFound }

class InspectorWebSocketAgent {
  ElementManager _elementManager;
  InspectorCssAgent cssAgent;
  InspectorDomAgent domAgent;

  InspectorWebSocketAgent(this._elementManager) {
    domAgent = InspectorDomAgent(_elementManager);
    cssAgent = InspectorCssAgent(domAgent);
  }

  ResponseState onRequest(JsonData protocolData, String message) {
    Map<String, dynamic> data = jsonDecode(message ?? '');

    if (!(data['id'] is int && data['method'] is String)) {
      return ResponseState.Error;
    }

    if (!(data['params'] == null || data['params'] is Map<String, dynamic>)) {
      return ResponseState.Error;
    }

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
      default:
        break;
    }

    return ResponseState.NotFound;
  }
}
