/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:io';

import 'package:kraken/bridge.dart';
import 'package:kraken/module.dart';
import 'package:kraken/foundation.dart';

String EMPTY_STRING = '';

class FetchModule extends BaseModule {
  @override
  String get name => 'Fetch';

  FetchModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {
    _httpClient?.close(force: true);
    _httpClient = null;
  }

  HttpClient? _httpClient;
  HttpClient get httpClient => _httpClient ?? (_httpClient = HttpClient());

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    String href = moduleManager!.controller.href;
    Uri url = moduleManager!.controller.uriParser!.resolve(Uri.parse(href), Uri.parse(method));

    Map<String, dynamic> options = params;

    _handleError(Object error, StackTrace? stackTrace) {
      print('Error while fetching for $url, message: \n$error');
      if (stackTrace != null) {
        print('\n$stackTrace');
      }
      callback(error: '$error\n$stackTrace');
    }

    httpClient.openUrl(options['method'] ?? 'GET', url)
      .then((HttpClientRequest request) {
        // Reset Kraken UA.
        request.headers.removeAll(HttpHeaders.userAgentHeader);
        request.headers.add(HttpHeaders.userAgentHeader, getKrakenInfo().userAgent);

        // Set ContextID Header
        request.headers.set(HttpHeaderContext, moduleManager!.contextId.toString());

        var data = options['body'];
        if (data is List<int>) {
          request.add(data);
        } else if (data != null) {
          // Treat as string as default.
          request.add(data.toString().codeUnits);
        }

        return request.close();
      })
      .then((HttpClientResponse response) {
        StringBuffer contentBuffer = StringBuffer();

        response
          // @TODO: Consider binary format, now callback tunnel only accept strings.
          .transform(utf8.decoder)
          .listen(contentBuffer.write)
          ..onDone(() {
            // @TODO: response.headers not transmitted.
            callback(data: [EMPTY_STRING, response.statusCode, contentBuffer.toString()]);
          })
          ..onError(_handleError);
      })
      .catchError(_handleError);

    return EMPTY_STRING;
  }
}
