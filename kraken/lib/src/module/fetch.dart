/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/src/module/module_manager.dart';

String EMPTY_STRING = '';

class FetchModule extends BaseModule {
  @override
  String get name => 'Fetch';

  FetchModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, InvokeModuleCallback callback) {
    String url = method;
    Map<String, dynamic> options = params;

    _fetch(url, options).then((Response response) {
      callback(data: ['', response.statusCode, response.data]);
    }).catchError((e, stack) {
      if (e is DioError && e.type == DioErrorType.RESPONSE) {
        callback(data: [e.toString(), e.response.statusCode, EMPTY_STRING]);
      } else {
        callback(errmsg: '$e\n$stack');
      }
    });

    return '';
  }
}

Future<Response> _fetch(String url, Map<String, dynamic> map) async {
  Future<Response> future;
  String method = map['method'] ?? 'GET';

  if (map['headers'] == null) {
    map['headers'] = {HttpHeaders.userAgentHeader: getKrakenInfo().userAgent};
  }

  var headers = map['headers'];
  if (headers[HttpHeaders.userAgentHeader] == null) {
    headers[HttpHeaders.userAgentHeader] = getKrakenInfo().userAgent;
  }

  BaseOptions options =
      BaseOptions(headers: headers, method: method, contentType: 'application/json', responseType: ResponseType.plain);

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
