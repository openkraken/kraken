/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'http_overrides.dart';
import 'http_client_interceptor.dart';
import 'queue.dart';

final _requestQueue = Queue(parallel: 10);

class ProxyHttpClientRequest extends HttpClientRequest {
  final HttpClientRequest _clientRequest;
  final KrakenHttpOverrides _httpOverrides;
  ProxyHttpClientRequest(HttpClientRequest clientRequest, KrakenHttpOverrides httpOverrides)
      : _clientRequest = clientRequest,
        _httpOverrides = httpOverrides;

  @override
  Encoding get encoding => _clientRequest.encoding;

  @override
  set encoding(Encoding _encoding) {
    _clientRequest.encoding = _encoding;
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _clientRequest.abort(exception, stackTrace);
  }

  // Saving all the data before calling real `close` to [HttpClientRequest].
  final List<int> _data = [];

  @override
  void add(List<int> data) {
    _data.addAll(data);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {
    _clientRequest.addError(error, stackTrace);
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
    HttpClientRequest request = _clientRequest;
    String? contextId = KrakenHttpOverrides.getContextHeader(_clientRequest);
    if (contextId != null) {
      // Set the default origin and referrer.
      Uri referrer = getReferrer(int.tryParse(contextId));
      request.headers.set(HttpHeaders.refererHeader, referrer.toString());
      String origin = getOrigin(referrer);
      request.headers.set(_HttpHeadersOrigin, origin);

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
      HttpCacheController cacheController = HttpCacheController.instance(origin);
      HttpCacheObject? cacheObject = await cacheController.getCacheObject(request.uri);
      if (cacheObject != null
          && cacheObject.hitLocalCache(request)) {
        HttpClientResponse? cacheResponse = await cacheObject.toHttpClientResponse();
        if (cacheResponse != null) {
          return cacheResponse;
        }
      }

      // Step 3: Handle negotiate cache request header.
      if (cacheObject != null
          && request.headers.ifModifiedSince == null
          && request.headers.value(HttpHeaders.ifNoneMatchHeader) == null) {
        // ETag has higher priority of lastModified.
        if (cacheObject.eTag != null) {
          request.headers.set(HttpHeaders.ifNoneMatchHeader, cacheObject.eTag!);
        } else if (cacheObject.lastModified != null) {
          request.headers.set(HttpHeaders.ifModifiedSinceHeader,
              HttpDate.format(cacheObject.lastModified!));
        }
      }

      // Send the real data to backend client.
      _clientRequest.add(_data);
      _data.clear();

      // Step 4: Lifecycle of shouldInterceptRequest
      HttpClientResponse? response;
      if (clientInterceptor != null) {
        response = await _shouldInterceptRequest(clientInterceptor, request);
      }

      // After this, response should not be null.
      if (response == null) {
        response = await _requestQueue.add(() async => cacheController
            .interceptResponse(request, await request.close(), cacheObject));
      }

      // Step 5: Lifecycle of afterResponse.
      if (clientInterceptor != null) {
        response = await _afterResponse(clientInterceptor, request, response!) ?? response;
      }

      // Step 6: Intercept response by cache controller (handle 304).
      return cacheController.interceptResponse(request, response!, cacheObject);
    } else {
      _clientRequest.add(_data);
      _data.clear();
    }

    return _requestQueue.add(request.close);
  }

  @override
  HttpConnectionInfo get connectionInfo => _clientRequest.connectionInfo!;

  @override
  List<Cookie> get cookies => _clientRequest.cookies;

  @override
  Future<HttpClientResponse> get done => _clientRequest.done;

  @override
  Future flush() {
    return _clientRequest.flush();
  }

  @override
  HttpHeaders get headers => _clientRequest.headers;

  @override
  String get method => _clientRequest.method;

  @override
  Uri get uri => _clientRequest.uri;

  @override
  void write(Object? obj) {
    _clientRequest.write(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _clientRequest.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _clientRequest.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    _clientRequest.writeln(object);
  }
}
