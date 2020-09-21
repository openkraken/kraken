/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kraken/bridge.dart';

Future<Response> fetch(String url, Map<String, dynamic> map) async {
  Future<Response> future;
  String method = map['method'] ?? 'GET';

  if (map['headers'] == null) {
    map['headers'] = {HttpHeaders.userAgentHeader: getKrakenInfo().userAgent};
  }

  var headers = map['headers'];
  if (headers[HttpHeaders.userAgentHeader] == null) {
    headers[HttpHeaders.userAgentHeader] = getKrakenInfo().userAgent;
  }

  BaseOptions options = BaseOptions(
      headers: headers,
      method: method,
      contentType: 'application/json',
      responseType: ResponseType.plain);

  switch (method) {
    case 'GET':
      future = Dio(options).get(url);
      break;
    case 'POST':
      future = Dio(options).post(url, data: map['body']);
      break;
    case 'PUT':
      future = Dio(options).put(url, data: map['body']);
      break;
    case 'PATCH':
      future = Dio(options).patch(url, data: map['body']);
      break;
    case 'DELETE':
      future = Dio(options).delete(url, data: map['body']);
      break;
    case 'HEAD':
      future = Dio(options).head(url);
      break;
  }

  return future;
}
