/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    String url = method;
    Map<String, dynamic> options = params;

    _fetch(url, options, contextId: moduleManager!.contextId).then((http.Response response) {
      callback(data: ['', response.statusCode, response.body]);
    }).catchError((e, stack) {
      callback(error: '$e\n$stack');
    });

    return '';
  }
}

Future<http.Response> _fetch(String url, Map<String, dynamic> options, { required int contextId }) async {
  Uri uri = Uri.parse(url);
  String method = options['method'] ?? 'GET';

  if (options['headers'] == null) {
    options['headers'] = {HttpHeaders.userAgentHeader: getKrakenInfo().userAgent};
  }

  Map<String, String> headers = Map<String, String>.from(options['headers']);

  if (headers[HttpHeaders.userAgentHeader] == null) {
    headers[HttpHeaders.userAgentHeader] = getKrakenInfo().userAgent;
  }

  headers[HttpHeaderContext] = contextId.toString();

  switch (method) {
    case 'POST':
      return http.post(uri, headers: headers, body: options['body']);
    case 'PUT':
      return http.put(uri, headers: headers, body: options['body']);
    case 'PATCH':
      return http.patch(uri, headers: headers, body: options['body']);
    case 'DELETE':
      return http.delete(uri, headers: headers, body: options['body']);
    case 'HEAD':
      return http.head(uri, headers: headers);
    case 'GET':
    default:
      return http.get(uri, headers: headers);
  }
}
