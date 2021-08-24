/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:io';
import 'http_client_request.dart';
import 'http_overrides.dart';

class ProxyHttpClient implements HttpClient {
  ProxyHttpClient({ required this.nativeHttpClient, required this.httpOverrides });

  final KrakenHttpOverrides httpOverrides;
  final HttpClient nativeHttpClient;

  @override
  bool get autoUncompress => nativeHttpClient.autoUncompress;

  @override
  set autoUncompress(bool _autoUncompress) {
    nativeHttpClient.autoUncompress = _autoUncompress;
  }

  @override
  Duration get connectionTimeout => nativeHttpClient.connectionTimeout!;

  @override
  set connectionTimeout(Duration? _connectionTimeout) {
    nativeHttpClient.connectionTimeout = _connectionTimeout;
  }

  @override
  Duration get idleTimeout => nativeHttpClient.idleTimeout;

  @override
  set idleTimeout(Duration _idleTimeout) {
    nativeHttpClient.idleTimeout = _idleTimeout;
  }

  @override
  int get maxConnectionsPerHost => nativeHttpClient.maxConnectionsPerHost!;

  @override
  set maxConnectionsPerHost(int? _maxConnectionsPerHost) {
    nativeHttpClient.maxConnectionsPerHost = _maxConnectionsPerHost;
  }

  @override
  String get userAgent => nativeHttpClient.userAgent!;

  @override
  set userAgent(String? _userAgent) {
    nativeHttpClient.userAgent = _userAgent;
  }

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {
    nativeHttpClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {
    nativeHttpClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String realm)? f) {
    nativeHttpClient.authenticate = f;
  }

  @override
  set authenticateProxy( Future<bool> Function(String host, int port, String scheme, String realm)? f) {
    nativeHttpClient.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {
    nativeHttpClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    nativeHttpClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return nativeHttpClient.delete(host, port, path);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return nativeHttpClient.deleteUrl(url);
  }

  @override
  set findProxy(String Function(Uri url)? f) {
    nativeHttpClient.findProxy = f;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return nativeHttpClient.get(host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return nativeHttpClient.getUrl(url).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return nativeHttpClient.head(host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return nativeHttpClient.headUrl(url).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    return nativeHttpClient.open(method, host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return nativeHttpClient.openUrl(method, url).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return nativeHttpClient.patch(host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return nativeHttpClient.patchUrl(url).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return nativeHttpClient.post(host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return nativeHttpClient.postUrl(url).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return nativeHttpClient.put(host, port, path).then(_proxyClientRequest);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return nativeHttpClient.putUrl(url).then(_proxyClientRequest);
  }

  Future<HttpClientRequest> _proxyClientRequest(HttpClientRequest request) async {
    return ProxyHttpClientRequest(request, httpOverrides);
  }
}

