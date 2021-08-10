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
  void dispose() {}

  @override
  String invoke(String method, dynamic params, InvokeModuleCallback callback) {
    String url = method;
    Map<String, dynamic> options = params;
    HttpClient httpClient = HttpClient();
    Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (err, stack) {
      callback(error: '$err $stack');
      return EMPTY_STRING;
    }

    httpClient.openUrl(options['method'] ?? 'GET', uri)
      .then((HttpClientRequest request) {
        // Reset Kraken UA.
        request.headers.removeAll(HttpHeaders.userAgentHeader);
        request.headers.add(HttpHeaders.userAgentHeader, getKrakenInfo().userAgent);

        // Add ContextID Header
        request.headers.add(HttpHeaderContextID, moduleManager!.contextId.toString());

        var data = options['body'];
        if (data != null) {
          // @TODO: how to encode and convert type?
          request.add(data);
        }

        return request.close();
      })
      .then((HttpClientResponse response) {
        StringBuffer content = StringBuffer();
        response.transform(utf8.decoder).listen((String contents) {
          content.write(contents);
        }).onDone(() {
          if (response.statusCode == HttpStatus.ok) {
            callback(data: [EMPTY_STRING, response.statusCode, content.toString()]);
          } else {
            callback(error: '${response.statusCode} ${response.reasonPhrase}');
          }

          // Terminate the httpClient instance.
          httpClient.close();
        });
      });
    return EMPTY_STRING;
  }
}
