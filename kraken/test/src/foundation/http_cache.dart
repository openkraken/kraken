import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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

      var data = await consolidateHttpClientResponseBytes(response);
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
      expect(responseSecond.headers.value(HttpHeadersCacheHits), HttpCacheHit);
    });

    test('Negotiation cache last-modified', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_content_length_and_last_modified'));
      KrakenHttpOverrides.setContextHeader(req, contextId);
      req.headers.ifModifiedSince = HttpDate.parse('Sun, 15 Mar 2020 11:32:20 GMT');
      var res = await req.close();
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

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
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();

      assert(cacheObject.valid);
    });

    // Solve problem that consuming response multi times,
    // causing cache file > 2 * chunk (each chunk default to 64kb) will be truncated.
    test('File over 128K', () async {
      Uri uri = server.getUri('js_over_128k');

      // Local request to save cache.
      var req = await httpClient.openUrl('GET', uri);
      KrakenHttpOverrides.setContextHeader(req, contextId);
      var res = await req.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(res);
      expect(bytes.lengthInBytes, res.contentLength);

      // Assert cache object.
      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();
      assert(cacheObject.valid);

      var response = await cacheObject.toHttpClientResponse();
      assert(response != null);
      expect(response!.headers.value(HttpHeadersCacheHits), HttpCacheHit);

      Uint8List bytesFromCache = await consolidateHttpClientResponseBytes(response);
      expect(bytesFromCache.length, response.contentLength);
    });
  });
}
