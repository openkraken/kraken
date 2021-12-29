/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'http_cache.dart';
import 'http_cache_object.dart';
import 'http_client.dart';
import 'http_client_interceptor.dart';
import 'http_overrides.dart';
import 'queue.dart';

final _requestQueue = Queue(parallel: 10);

class ProxyHttpClientRequest extends HttpClientRequest {
  final KrakenHttpOverrides _httpOverrides;
  final HttpClient _nativeHttpClient;
  final String _method;
  final Uri _uri;

  HttpClientRequest? _backendRequest;

  // Saving all the data before calling real `close` to [HttpClientRequest].
  final List<int> _data = [];
  // Saving cookies.
  final List<Cookie> _cookies = <Cookie>[];
  // Saving request headers.
  final HttpHeaders _httpHeaders = createHttpHeaders();

  ProxyHttpClientRequest(String method, Uri uri, KrakenHttpOverrides httpOverrides, HttpClient nativeHttpClient) :
    _method = method,
    _uri = uri,
    _httpOverrides = httpOverrides,
    _nativeHttpClient = nativeHttpClient;

  @override
  Encoding get encoding => _backendRequest?.encoding ?? utf8;

  @override
  set encoding(Encoding _encoding) {
    _backendRequest?.encoding = _encoding;
  }

  @override
  void add(List<int> data) {
    _data.addAll(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    // Consume stream.
    Completer<void> completer = Completer();
    stream.listen(
        _data.addAll,
        onError: completer.completeError,
        onDone: completer.complete,
        cancelOnError: true
    );
    return completer.future;
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _backendRequest?.abort(exception, stackTrace);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {
    _backendRequest?.addError(error, stackTrace);
  }

  Future<HttpClientRequest?> _beforeRequest(HttpClientInterceptor _clientInterceptor, HttpClientRequest _clientRequest) async {
    try {
      return await _clientInterceptor.beforeRequest(_clientRequest);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  Future<HttpClientResponse?> _afterResponse(
      HttpClientInterceptor _clientInterceptor,
      HttpClientRequest _clientRequest,
      HttpClientResponse _clientResponse) async {
    try {
      return await _clientInterceptor.afterResponse(_clientRequest, _clientResponse);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  Future<HttpClientResponse?> _shouldInterceptRequest(HttpClientInterceptor _clientInterceptor, HttpClientRequest _clientRequest) async {
    try {
      return await _clientInterceptor.shouldInterceptRequest(_clientRequest);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  static const String _HttpHeadersOrigin = 'origin';

  @override
  Future<HttpClientResponse> close() async {
    int? contextId = KrakenHttpOverrides.getContextHeader(headers);
    HttpClientRequest request = this;

    if (contextId != null) {
      // Set the default origin and referrer.
      Uri referrer = getReferrer(contextId);
      headers.set(HttpHeaders.refererHeader, referrer.toString());
      String origin = getOrigin(referrer);
      headers.set(_HttpHeadersOrigin, origin);

      HttpClientInterceptor? clientInterceptor;
      if (_httpOverrides.hasInterceptor(contextId)) {
        clientInterceptor = _httpOverrides.getInterceptor(contextId);
      }

      // Step 1: Handle request.
      if (clientInterceptor != null) {
        request = await _beforeRequest(clientInterceptor, request) ?? request;
      }

      // Step 2: Handle cache-control and expires,
      //        if hit, no need to open request.
      HttpCacheObject? cacheObject;
      if (HttpCacheController.mode != HttpCacheMode.NO_CACHE) {
        HttpCacheController cacheController = HttpCacheController.instance(origin);
        cacheObject = await cacheController.getCacheObject(request.uri);
        if (cacheObject.hitLocalCache(request)) {
          HttpClientResponse? cacheResponse = await cacheObject.toHttpClientResponse();
          if (cacheResponse != null) {
            return cacheResponse;
          }
        }

        // Step 3: Handle negotiate cache request header.
        if (headers.ifModifiedSince == null && headers.value(HttpHeaders.ifNoneMatchHeader) == null) {
          // ETag has higher priority of lastModified.
          if (cacheObject.eTag != null) {
            headers.set(HttpHeaders.ifNoneMatchHeader, cacheObject.eTag!);
          } else if (cacheObject.lastModified != null) {
            headers.set(HttpHeaders.ifModifiedSinceHeader, HttpDate.format(cacheObject.lastModified!));
          }
        }
      }

      request = await _createBackendClientRequest();
      // Send the real data to backend client.
      request.add(_data);
      _data.clear();

      // Step 4: Lifecycle of shouldInterceptRequest
      HttpClientResponse? response;
      if (clientInterceptor != null) {
        response = await _shouldInterceptRequest(clientInterceptor, request);
      }

      bool hitInterceptorResponse = response != null;
      bool hitNegotiateCache = false;

      // If cache only, but no cache hit, throw error directly.
      if (HttpCacheController.mode == HttpCacheMode.CACHE_ONLY
          && response == null) {
        throw FlutterError('HttpCacheMode is CACHE_ONLY, but no cache hit for $uri');
      }

      // After this, response should not be null.
      if (!hitInterceptorResponse) {
        // Handle 304 here.
        final HttpClientResponse rawResponse = await _requestQueue.add(request.close);
        response = cacheObject == null
            ? rawResponse
            : await HttpCacheController.instance(origin).interceptResponse(request, rawResponse, cacheObject);
        hitNegotiateCache = rawResponse != response;
      }

      // Step 5: Lifecycle of afterResponse.
      if (clientInterceptor != null) {
        final HttpClientResponse? interceptorResponse = await _afterResponse(clientInterceptor, request, response);
        if (interceptorResponse != null) {
          hitInterceptorResponse = true;
          response = interceptorResponse;
        }
      }

      // Check match cache, and then return cache.
      if (hitInterceptorResponse || hitNegotiateCache) {
        return Future.value(response);
      }

      if (cacheObject != null) {
        // Step 6: Intercept response by cache controller (handle 304).
        // Note: No need to negotiate cache here, this is final response, hit or not hit.
        return HttpCacheController.instance(origin).interceptResponse(request, response, cacheObject);
      } else {
        return response;
      }

    } else {
      request = await _createBackendClientRequest();
      request.add(_data);
      _data.clear();
    }

    return _requestQueue.add(request.close);
  }

  Future<HttpClientRequest> _createBackendClientRequest() async {
    HttpClientRequest backendRequest = await _nativeHttpClient.openUrl(_method, _uri);

    if (_cookies.isNotEmpty) {
      backendRequest.cookies.addAll(_cookies);
      _cookies.clear();
    }

    _httpHeaders.forEach(backendRequest.headers.set);
    _httpHeaders.clear();

    _backendRequest = backendRequest;
    return backendRequest;
  }

  @override
  HttpConnectionInfo? get connectionInfo => _backendRequest?.connectionInfo;

  @override
  List<Cookie> get cookies => _backendRequest?.cookies ?? _cookies;

  @override
  Future<HttpClientResponse> get done async {
   if (_backendRequest == null) {
     await _createBackendClientRequest();
   }
   return _backendRequest!.done;
  }

  @override
  Future flush() async {
    if (_backendRequest == null) {
      await _createBackendClientRequest();
    }
    return _backendRequest!.flush();
  }

  @override
  HttpHeaders get headers => _backendRequest?.headers ?? _httpHeaders;

  @override
  String get method => _method;

  @override
  Uri get uri => _uri;

  @override
  void write(Object? obj) {
    String string = '$obj';
    if (string.isEmpty) return;

    _data.addAll(Uint8List.fromList(
      utf8.encode(string),
    ));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    Iterator iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }
}
