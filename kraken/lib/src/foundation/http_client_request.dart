/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:io';

import 'package:kraken/foundation.dart';

class ProxyHttpClientRequest extends HttpClientRequest {
  final HttpClientRequest _clientRequest;
  final KrakenHttpOverrides _httpOverrides;
  ProxyHttpClientRequest(HttpClientRequest clientRequest, KrakenHttpOverrides httpOverrides)
      : _clientRequest = clientRequest,
        _httpOverrides = httpOverrides;

  String? _getContextId(HttpClientRequest request) {
    return request.headers.value(HttpHeaderContextID);
  }

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

  @override
  void add(List<int> data) {
    _clientRequest.add(data);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {
    _clientRequest.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return _clientRequest.addStream(stream);
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

  @override
  Future<HttpClientResponse> close() async {
    // HttpOverrides
    if (_httpOverrides.shouldOverride(_clientRequest)) {
      String? contextId = _getContextId(_clientRequest);
      if (contextId != null) {
        _clientRequest.headers.removeAll(HttpHeaderContextID);

        HttpClientInterceptor _clientInterceptor = _httpOverrides.getInterceptor(contextId);
        HttpClientRequest _request = await _beforeRequest(_clientInterceptor, _clientRequest) ?? _clientRequest;

        // Cache: handle cache-control and expires,
        //        if hit, no need to open request.
        HttpCacheManager cacheManager = HttpCacheManager.instanceWithContextId(contextId);
        HttpCacheObject? cacheObject = await cacheManager.getCacheObject(_request);
        if (cacheObject != null) {
          HttpClientResponse? cacheResponse = await cacheObject.toHttpClientResponse();
          if (cacheResponse != null) {
            return cacheResponse;
          }
        }

        HttpClientResponse _interceptedResponse = await _shouldInterceptRequest(_clientInterceptor, _request) ?? await _request.close();
        HttpClientResponse response = await _afterResponse(_clientInterceptor, _request, _interceptedResponse) ?? _interceptedResponse;
        return HttpCacheManager.cacheHttpResource(contextId, response, _request);
      }
    }

    return _clientRequest.close();
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
