import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:kraken/foundation.dart';
import '../../local_http_server.dart';

void main() {
  var server = LocalHttpServer.getInstance();
  int contextId = 1;
  setupHttpOverrides(null, contextId: contextId);
  HttpClient httpClient = HttpClient();

  group('HttpCache', () {

    test('Simple http request with expires', () async {
      var request = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(request, contextId);
      var response = await request.close();
      expect(response.statusCode, 200);
      expect(response.headers.value(HttpHeaders.expiresHeader),
          'Mon, 16 Aug 2221 10:17:45 GMT');

      var data = await sinkStream(response);
      var content = jsonDecode(String.fromCharCodes(data));
      expect(content, {
        'method': 'GET',
        'data': {
          'userName': '12345'
        }
      });

      // second request
      var requestSecond = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(requestSecond, contextId);
      var responseSecond = await requestSecond.close();
      assert(responseSecond.headers.value('x-kraken-cache') != null);
    });

    test('Negotiation cache last-modified', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_content_length_and_last_modified'));
      KrakenHttpOverrides.setContextHeader(req, contextId);
      req.headers.ifModifiedSince = HttpDate.parse('Sun, 15 Mar 2020 11:32:20 GMT');
      var res = await req.close();
      expect(String.fromCharCodes(await sinkStream(res)), 'CachedData');

      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();

      assert(cacheObject.valid);
    });

    test('Negotiation cache eTag', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_etag_and_content_length'));
      KrakenHttpOverrides.setContextHeader(req, contextId);
      req.headers.set(HttpHeaders.ifNoneMatchHeader, '"foo"');

      var res = await req.close();
      expect(String.fromCharCodes(await sinkStream(res)), 'CachedData');

      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();

      assert(cacheObject.valid);
    });

    test('Global switch to disable cache', () async {
      HttpCacheController.setEnabled(false);
      var request = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(request, contextId);
      var response = await request.close();
      expect(response.statusCode, 200);
      expect(response.headers.value(HttpHeaders.expiresHeader),
          'Mon, 16 Aug 2221 10:17:45 GMT');

      var data = await sinkStream(response);
      var content = jsonDecode(String.fromCharCodes(data));
      expect(content, {
        'method': 'GET',
        'data': {
          'userName': '12345'
        }
      });

      // second request
      var requestSecond = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(requestSecond, contextId);
      var responseSecond = await requestSecond.close();

      // Note: This line is different.
      assert(responseSecond.headers.value('x-kraken-cache') == null);
      HttpCacheController.setEnabled(true);
    });
  });
}

Future<Uint8List> sinkStream(Stream<List<int>> stream) {
  var completer = Completer<Uint8List>();
  var buffer = BytesBuilder();
  stream
      .listen(buffer.add)
    ..onDone(() {
      completer.complete(buffer.takeBytes());
    })
    ..onError(completer.completeError);
  return completer.future;
}
