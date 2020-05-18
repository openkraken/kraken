/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:dio/dio.dart';

Future<Response> fetch(String url, Map<String, dynamic> map) async {
  Future<Response> future;

  BaseOptions options = BaseOptions(
      headers: map['headers'],
      method: map['method'],
      contentType: 'application/json',
      responseType: ResponseType.plain);

  switch (map['method']) {
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
