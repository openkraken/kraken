/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

import '../../local_http_server.dart';

const int contextId = 2;
void main() {
  var server = LocalHttpServer.getInstance();
  group('HttpClientInterceptor', () {
    setupHttpOverrides(TestHttpClientInterceptor(), contextId: contextId);
    HttpClient httpClient = HttpClient();

    test('beforeRequest', () async {
      var request = await httpClient.openUrl('GET', server.getUri('json_with_content_length'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      request.headers.add('x-test-id', 'beforeRequest-001');

      var res = await request.close();
      expect(request.headers.value('x-test-before-request'), 'modified');

      expect(jsonDecode(String.fromCharCodes(await res.single)), {
        'method': 'GET',
        'data': {'userName': '12345'}
      });
    });

    test('afterResponse', () async {
      var request = await httpClient.openUrl('GET', server.getUri('json_with_content_length'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      request.headers.add('x-test-id', 'afterResponse-001');

      var response = await request.close();
      expect(response.headers.value('x-test-after-response'), 'modified');
    });

    test('shouldInterceptRequest', () async {
      var request = await httpClient.openUrl('GET', server.getUri('json_with_content_length'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      request.headers.add('x-test-id', 'shouldInterceptRequest-001');

      var response = await request.close();
      expect(String.fromCharCodes(await response.single), 'HelloWorld');
    });
  });
}

class TestHttpClientInterceptor implements HttpClientInterceptor {
  @override
  Future<HttpClientRequest?> beforeRequest(HttpClientRequest request) async {
    if (request.headers.value('x-test-id') == 'beforeRequest-001') {
      request.headers.add('x-test-before-request', 'modified');
    }
    return request;
  }

  @override
  Future<HttpClientResponse?> afterResponse(HttpClientRequest request, HttpClientResponse response) async {
    if (request.headers.value('x-test-id') == 'afterResponse-001') {
      return HttpClientStreamResponse(response,
          initialHeaders: createHttpHeaders(initialHeaders: {
            'x-test-after-response': ['modified'],
          }));
    }
    return response;
  }

  @override
  Future<HttpClientResponse?> shouldInterceptRequest(HttpClientRequest request) async {
    if (request.headers.value('x-test-id') == 'shouldInterceptRequest-001') {
      return HttpClientStreamResponse(Stream.value('HelloWorld'.codeUnits));
    }
    return null;
  }
}
