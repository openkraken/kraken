/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:requests/requests.dart';

Map<String, String> _parseHeaders(Map<String, dynamic> map) {
  Map<String, String> headerMap = {};

  if (map == null) {
    map = Map<String, dynamic>();
  }

  map.forEach((k, v) {
    headerMap[k] = v.toString();
  });

  return headerMap;
}

Future<Response> fetch(String url, String json) async {
  Map<String, dynamic> map = jsonDecode(json);
  String method = map['method'];
  Map<String, String> headers = _parseHeaders(map['headers']);
  Future<Response> future;
  switch (method) {
    case 'GET':
      future = Requests.get(url, headers: map['headers']);
      break;
    case 'POST':
      future = Requests.post(url, headers: headers, body: map['body'], bodyEncoding: RequestBodyEncoding.JSON);
      break;
    case 'PUT':
      future = Requests.put(url, headers: headers, body: map['body'], bodyEncoding: RequestBodyEncoding.JSON);
      break;
    case 'PATCH':
      future = Requests.patch(url, headers: headers);
      break;
    case 'DELETE':
      future = Requests.delete(url, headers: headers);
      break;
    case 'HEAD':
      future = Requests.head(url, headers: headers);
      break;
  }

  return future;
}
