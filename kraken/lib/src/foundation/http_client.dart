/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'http_client_interceptor.dart';
import 'http_overrides.dart';

typedef ShouldInterceptRequest = bool Function(HttpClientRequest request);

class ProxyHttpClient implements HttpClient {
  ProxyHttpClient({ this.nativeHttpClient, this.httpOverrides });

  final KrakenHttpOverrides httpOverrides;
  final HttpClient nativeHttpClient;

  @override
  bool get autoUncompress => nativeHttpClient.autoUncompress;

  @override
  set autoUncompress(bool _autoUncompress) {
    nativeHttpClient.autoUncompress = _autoUncompress;
  }

  @override
  Duration get connectionTimeout => nativeHttpClient.connectionTimeout;

  @override
  set connectionTimeout(Duration _connectionTimeout) {
    nativeHttpClient.connectionTimeout = _connectionTimeout;
  }

  @override
  Duration get idleTimeout => nativeHttpClient.idleTimeout;

  @override
  set idleTimeout(Duration _idleTimeout) {
    nativeHttpClient.idleTimeout = _idleTimeout;
  }

  @override
  int get maxConnectionsPerHost => nativeHttpClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int _maxConnectionsPerHost) {
    nativeHttpClient.maxConnectionsPerHost = _maxConnectionsPerHost;
  }

  @override
  String get userAgent => nativeHttpClient.userAgent;

  @override
  set userAgent(String _userAgent) {
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
  set authenticate(Future<bool> Function(Uri url, String scheme, String realm) f) {
    nativeHttpClient.authenticate = f;
  }

  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String realm) f) {
    nativeHttpClient.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port) callback) {
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
  set findProxy(String Function(Uri url) f) {
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
    print('open $method $host $port $path');
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
    if (httpOverrides != null) {
      return ProxyHttpClientRequest(request, httpOverrides);
    }
    return request;
  }
}

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

class _HttpConnectionInfo implements HttpConnectionInfo {
  int localPort;
  InternetAddress remoteAddress;
  int remotePort;
  _HttpConnectionInfo(this.localPort, this.remoteAddress, this.remotePort);
}

class SimpleHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  String mime;
  String encoding;
  Uint8List data;

  int statusCode;
  String reasonPhrase;
  Map<String, String> responseHeaders;

  SimpleHttpClientResponse(this.mime, this.encoding, this.data, {
    this.statusCode = 200,
    this.reasonPhrase = '',
    this.responseHeaders = const {},
  }) : assert(mime != null),
      assert(encoding != null),
      assert(data != null);

  @override
  X509Certificate get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  HttpConnectionInfo get connectionInfo => _HttpConnectionInfo(80, InternetAddress.loopbackIPv4, 80);

  @override
  int get contentLength => -1;

  @override
  List<Cookie> get cookies => null;

  @override
  Future<Socket> detachSocket() async {
    return null;
  }

  @override
  HttpHeaders get headers => SingleHttpHeaders(initialHeaders: responseHeaders);

  @override
  bool get isRedirect => statusCode >= 300 && statusCode < 400;

  @override
  bool get persistentConnection => false;

  @override
  Future<HttpClientResponse> redirect([String method, Uri url, bool followLoops]) {
    return Future.error(RedirectException('Redirect is unsupported.', redirects));
  }

  @override
  List<RedirectInfo> get redirects => [];

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData, {Function onError, void Function() onDone, bool cancelOnError}) {
    return Stream<Uint8List>.value(data).listen(onData, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class SingleHttpHeaders implements HttpHeaders {
  final Map<String, String> _headers = Map<String, String>();
  SingleHttpHeaders({ Map<String, String> initialHeaders }) {
    if (initialHeaders != null) {
      _headers.addAll(initialHeaders);
    }
  }

  @override
  bool chunkedTransferEncoding = false;

  @override
  int get contentLength {
    String val = value(HttpHeaders.contentLengthHeader);
    if (val != null) {
      return int.tryParse(val) ?? -1;
    } else {
      return -1;
    }
  }

  @override
  set contentLength(int contentLength) {
    if (contentLength == -1) {
      removeAll(HttpHeaders.contentLengthHeader);
    } else {
      set(HttpHeaders.contentLengthHeader, contentLength.toString());
    }
  }

  @override
  ContentType get contentType {
    String value = _headers[HttpHeaders.contentTypeHeader];
    if (value != null) {
      return ContentType.parse(value);
    } else {
      return null;
    }
  }

  @override
  set contentType(ContentType contentType) {
    if (contentType == null) {
      removeAll(HttpHeaders.contentTypeHeader);
    } else {
      set(HttpHeaders.contentTypeHeader, contentType.toString());
    }
  }

  @override
  DateTime get date {
    String value = _headers[HttpHeaders.dateHeader];
    if (String != null) {
      try {
        return HttpDate.parse(value);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  @override
  set date(DateTime date) {
    if (date == null) {
      removeAll(HttpHeaders.dateHeader);
    } else {
      // Format "DateTime" header with date in Greenwich Mean Time (GMT).
      String formatted = HttpDate.format(date.toUtc());
      set(HttpHeaders.dateHeader, formatted);
    }
  }

  @override
  DateTime get expires => DateTime.tryParse(_headers[HttpHeaders.expiresHeader]);

  @override
  set expires(DateTime _expires) {
    String formatted = HttpDate.format(_expires.toUtc());
    set(HttpHeaders.expiresHeader, formatted);
  }

  @override
  String get host => _headers[HttpHeaders.hostHeader];

  @override
  set host(String _host) {
    set(HttpHeaders.hostHeader, _host);
  }

  @override
  DateTime get ifModifiedSince {
    String value = _headers[HttpHeaders.ifModifiedSinceHeader];
    if (value != null) {
      try {
        return HttpDate.parse(value);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  @override
  set ifModifiedSince(DateTime _ifModifiedSince) {
    if (_ifModifiedSince == null) {
      _headers.remove(HttpHeaders.ifModifiedSinceHeader);
    } else {
      // Format "ifModifiedSince" header with date in Greenwich Mean Time (GMT).
      String formatted = HttpDate.format(_ifModifiedSince.toUtc());
      set(HttpHeaders.ifModifiedSinceHeader, formatted);
    }
  }


  @override
  bool persistentConnection = false;

  @override
  int port = 80;

  @override
  List<String> operator [](String name) {
    return [_headers[name]];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    set(name, value, preserveHeaderCase: preserveHeaderCase);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach((key, value) {
      action(key, [value]);
    });
  }

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {
    removeAll(name);
  }

  @override
  void removeAll(String name) {
    _headers.remove(name);
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    if (!preserveHeaderCase) {
      name = name.toLowerCase();
    }
    _headers[name] = value;
  }

  @override
  String value(String name) {
    return _headers[name];
  }
}
