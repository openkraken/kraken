/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/module.dart';
import 'package:kraken/foundation.dart';

String EMPTY_STRING = '';

class FetchModule extends BaseModule {
  @override
  String get name => 'Fetch';

  FetchModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, InvokeModuleCallback callback) {
    String url = (moduleManager!.controller.uriParser.parse(Uri.parse(method))).toString();
    Map<String, dynamic> options = params;

    _fetch(url, options, contextId: moduleManager!.contextId).then((Response response) {
      callback(data: ['', response.statusCode, response.data]);
    }).catchError((e, stack) {
      if (e is DioError && e.type == DioErrorType.response) {
        callback(data: [e.toString(), e.response!.statusCode, EMPTY_STRING]);
      } else {
        callback(error: '$e\n$stack');
      }
    });

    return '';
  }
}

Future<Response> _fetch(String url, Map<String, dynamic> map, { required int contextId }) async {
  Future<Response> future;
  String method = map['method'] ?? 'GET';

  if (map['headers'] == null) {
    map['headers'] = {HttpHeaders.userAgentHeader: getKrakenInfo().userAgent};
  }

  var headers = map['headers'];
  if (headers[HttpHeaders.userAgentHeader] == null) {
    headers[HttpHeaders.userAgentHeader] = getKrakenInfo().userAgent;
  }
  headers[HttpHeaderContextID] = contextId.toString();

  BaseOptions options =
      BaseOptions(headers: headers, method: method, responseType: ResponseType.plain);

  switch (method) {
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
    case 'GET':
    default:
      future = Dio(options).get(url);
      break;
  }

  return future;
}
