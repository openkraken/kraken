/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

import '../../local_http_server.dart';

void main() {
  group('HttpHeaders', () {
    test('Simple modification and toString', () async {
      HttpHeaders headers = createHttpHeaders();
      expect(headers.toString(), '');

      headers.add('content-type', 'x-application/vnd.foo');
      expect(headers.toString(), 'content-type: x-application/vnd.foo');

      headers.add('content-type', 'another-value');
      expect(headers.toString(), 'content-type: x-application/vnd.foo\ncontent-type: another-value');

      headers.remove('content-type', 'x-application/vnd.foo');
      expect(headers.toString(), 'content-type: another-value');
    });

    test('Initial value', () async {
      HttpHeaders headers = createHttpHeaders(initialHeaders: {
        'content-type': ['x-application/vnd.foo', 'another-value']
      });
      expect(headers.toString(), 'content-type: x-application/vnd.foo\ncontent-type: another-value');
    });

    test('Remove all', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');
      headers.removeAll('content-type');
      expect(headers.toString(), '');
    });

    test('Set', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');

      headers.set('content-type', 'overwrite-value');
      expect(headers.toString(), 'content-type: overwrite-value');
    });

    test('operator[]', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');

      expect(headers['content-type'], ['x-application/vnd.foo', 'another-value']);
    });
  });

  group('HttpRequest', () {
    var server = LocalHttpServer.getInstance();
    int contextId = 3;
    HttpOverrides.global = null;
    setupHttpOverrides(null, contextId: contextId);
    HttpClient httpClient = HttpClient();

    test('Origin', () async {
      var request = await httpClient.openUrl('POST', server.getUri('plain_text'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      await request.close();

      assert(request.headers.value('origin') != null);
    });

    test('Referrer', () async {
      var request = await httpClient.openUrl('POST', server.getUri('plain_text'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      await request.close();

      assert(request.headers.value('referer') != null);
    });

    test('Large content', () async {
      var request = await httpClient.openUrl('POST', server.getUri('plain_text'));
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
      // Mocked 3M file.
      var data = List<int>.generate(3034764, (i) => i);
      request.headers.set(HttpHeaders.contentLengthHeader, data.length);
      await request.addStream(Stream.value(data));
      request.add([13, 10, 13, 10]); // End of file, double CRLF.
      await request.close();

      // No error is ok.
    });
  });
}
