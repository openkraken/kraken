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
  HttpOverrides.global = null;
  setupHttpOverrides(null, contextId: contextId);
  HttpClient httpClient = HttpClient();

  group('HttpCache', () {

    test('Simple http request with expires', () async {
      var request = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(request.headers, contextId);
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
      KrakenHttpOverrides.setContextHeader(requestSecond.headers, contextId);
      var responseSecond = await requestSecond.close();
      expect(responseSecond.headers.value('cache-hits'), 'HIT');
    });

    test('Negotiation cache last-modified', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_content_length_and_last_modified'));
      KrakenHttpOverrides.setContextHeader(req.headers, contextId);
      req.headers.ifModifiedSince = HttpDate.parse('Sun, 15 Mar 2020 11:32:20 GMT');
      var res = await req.close();
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();

      assert(cacheObject.valid);
    });

    // The second request that last-modified has updated, then controller should update local
    // expire time and save new response.
    test('Update cache last-modified', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_current_time_last_modified'));
      KrakenHttpOverrides.setContextHeader(req.headers, contextId);
      req.headers.ifModifiedSince = HttpDate.parse('Sun, 15 Mar 2020 11:32:20 GMT');
      var res = await req.close();
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

      // Second request and updating cache.
      var req2 = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_current_time_last_modified'));
      KrakenHttpOverrides.setContextHeader(req2.headers, contextId);
      var res2 = await req2.close();

      // Must miss cache, and update cache.
      String httpDateNow = HttpDate.format(DateTime.now());
      expect(res2.headers.value('cache-hits'), null);
      expect(res2.headers.value(HttpHeaders.lastModifiedHeader), httpDateNow);

      // Check cache object updated.
      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      assert(cacheObject.lastModified != null);
      // Difference <= 1ms.
      assert(DateTime.now().compareTo(cacheObject.lastModified!) <= 1);
    });

    test('Negotiation cache eTag', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_etag_and_content_length'));
      KrakenHttpOverrides.setContextHeader(req.headers, contextId);
      req.headers.set(HttpHeaders.ifNoneMatchHeader, '"foo"');

      var res = await req.close();
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();

      assert(cacheObject.valid);
    });

    test('HttpCacheMode.NO_CACHE', () async {
      HttpCacheController.mode = HttpCacheMode.NO_CACHE;
      var request = await httpClient.openUrl('GET',
          server.getUri('json_with_content_length_expires_etag_last_modified'));
      KrakenHttpOverrides.setContextHeader(request.headers, contextId);
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
      KrakenHttpOverrides.setContextHeader(requestSecond.headers, contextId);
      var responseSecond = await requestSecond.close();

      // Note: This line is different.
      assert(responseSecond.headers.value('cache-hits') == null);
      HttpCacheController.mode = HttpCacheMode.DEFAULT;
    });

    test('HttpCacheMode.CACHE_ONLY', () async {
      HttpCacheController.mode = HttpCacheMode.CACHE_ONLY;
      var request = await httpClient.openUrl('GET',
          server.getUri('network'));
      KrakenHttpOverrides.setContextHeader(request.headers, contextId);

      var error;
      try {
        await request.close();
      } catch (_error) {
        error = _error;
      }
      assert(error is FlutterError);

      HttpCacheController.mode = HttpCacheMode.DEFAULT;
    });

    // Solve problem that consuming response multi times,
    // causing cache file > 2 * chunk (each chunk default to 64kb) will be truncated.
    test('File over 128K', () async {
      Uri uri = server.getUri('js_over_128k');

      // Local request to save cache.
      var req = await httpClient.openUrl('GET', uri);
      KrakenHttpOverrides.setContextHeader(req.headers, contextId);
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
      expect(response!.headers.value('cache-hits'), 'HIT');

      Uint8List bytesFromCache = await consolidateHttpClientResponseBytes(response);
      expect(bytesFromCache.length, response.contentLength);
    });

    test('Cache should contain response headers.', () async {
      // First request to save cache.
      var req = await httpClient.openUrl('GET',
          server.getUri('plain_text_with_etag_and_content_length'));
      KrakenHttpOverrides.setContextHeader(req.headers, contextId);
      var res = await req.close();
      expect(String.fromCharCodes(await consolidateHttpClientResponseBytes(res)), 'CachedData');

      // Assert cache object.
      HttpCacheController cacheController = HttpCacheController.instance(req.headers.value('origin')!);
      var cacheObject = await cacheController.getCacheObject(req.uri);
      await cacheObject.read();
      assert(cacheObject.valid);

      var response = await cacheObject.toHttpClientResponse();
      assert(response != null);
      expect(response!.headers.value('cache-hits'), 'HIT');
      expect(response.headers.value('x-custom-header'), 'hello-world');
    });
  });
}
