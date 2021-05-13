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
      : assert(clientRequest != null), _clientRequest = clientRequest,
        _httpOverrides = httpOverrides;

  String _getContextId(HttpClientRequest request) {
    if (request != null) {
      return request.headers.value(HttpHeaderContextID);
    }
    return null;
  }

  @override
  Encoding get encoding => _clientRequest.encoding;

  @override
  set encoding(Encoding _encoding) {
    _clientRequest.encoding = _encoding;
  }

  @override
  void abort([Object exception, StackTrace stackTrace]) {
    _clientRequest.abort(exception, stackTrace);
  }

  @override
  void add(List<int> data) {
    _clientRequest.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _clientRequest.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return _clientRequest.addStream(stream);
  }

  Future<HttpClientRequest> _beforeRequest(HttpClientInterceptor _clientInterceptor, HttpClientRequest _clientRequest) async {
    try {
      return await _clientInterceptor.beforeRequest(_clientRequest);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  Future<HttpClientResponse> _afterResponse(HttpClientInterceptor _clientInterceptor, HttpClientResponse _clientResponse) async {
    try {
      return await _clientInterceptor.afterResponse(_clientResponse);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  Future<HttpClientResponse> _shouldInterceptRequest(HttpClientInterceptor _clientInterceptor, HttpClientRequest _clientRequest) async {
    try {
      return await _clientInterceptor.shouldInterceptRequest(_clientRequest);
    } catch (err, stack) {
      print('$err $stack');
    }
    return null;
  }

  @override
  Future<HttpClientResponse> close() async {
    if (_httpOverrides != null && _httpOverrides.shouldInterceptRequest(_clientRequest)) {
      String contextId = _getContextId(_clientRequest);
      if (contextId != null) {
        _clientRequest.headers.removeAll(HttpHeaderContextID);
        HttpClientInterceptor _clientInterceptor = _httpOverrides.getInterceptor(contextId);
        if (_clientInterceptor != null) {
          HttpClientRequest _request = await _beforeRequest(_clientInterceptor, _clientRequest) ?? _clientRequest;
          HttpClientResponse simpleHttpResponse = await _shouldInterceptRequest(_clientInterceptor, _request);
          if (simpleHttpResponse != null) {
            return simpleHttpResponse;
          } else {
            HttpClientResponse _clientResponse = await _request.close();
            HttpClientResponse _response = await _afterResponse(_clientInterceptor, _clientResponse) ?? _clientResponse;
            return _response;
          }
        }
      }
    }

    return _clientRequest.close();
  }

  @override
  HttpConnectionInfo get connectionInfo => _clientRequest.connectionInfo;

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
  void write(Object obj) {
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
  void writeln([Object obj = ""]) {
    _clientRequest.writeln(obj);
  }
}
