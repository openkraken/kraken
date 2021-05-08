/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'http_client_interceptor.dart';

class ProxyHttpClient implements HttpClient {
  ProxyHttpClient({ this.nativeHttpClient, this.httpRequestInterceptor });

  final HttpClientInterceptor httpRequestInterceptor;
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
    print('openUrl $method $url');
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
    if (httpRequestInterceptor != null) {
      return ProxyHttpClientRequest(request, httpRequestInterceptor);
    }
    return request;
  }
}

class ProxyHttpClientRequest extends HttpClientRequest {
  final HttpClientRequest _clientRequest;
  final HttpClientInterceptor _clientInterceptor;
  ProxyHttpClientRequest(HttpClientRequest clientRequest, HttpClientInterceptor clientInterceptor)
      : assert(clientRequest != null), _clientRequest = clientRequest,
        _clientInterceptor = clientInterceptor;

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

  @override
  Future<HttpClientResponse> close() async {
    HttpClientRequest _request = await _clientInterceptor.beforeRequest(null, _clientRequest);
    HttpClientResponse _clientResponse = await _clientInterceptor.shouldInterceptRequest(null, _request);
    if (_clientResponse == null) {
      _clientResponse = await (_request ?? _clientRequest).close();
    }
    HttpClientResponse _response = await _clientInterceptor.afterResponse(null, _clientResponse);
    return ProxyHttpClientResponse(_response, _clientInterceptor);
  }

  @override
  HttpConnectionInfo get connectionInfo => _clientRequest.connectionInfo;

  @override
  List<Cookie> get cookies => _clientRequest.cookies;

  @override
  Future<HttpClientResponse> get done => _clientRequest.done.then((clientResponse) {
    if (clientResponse is ProxyHttpClientResponse) {
      return clientResponse;
    } else {
      return ProxyHttpClientResponse(clientResponse, _clientInterceptor);
    }
  });

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

class ProxyHttpClientResponse implements HttpClientResponse {
  final HttpClientResponse _clientResponse;
  final HttpClientInterceptor _clientInterceptor;
  ProxyHttpClientResponse(HttpClientResponse clientResponse, HttpClientInterceptor clientInterceptor)
      : assert(clientResponse != null), _clientResponse = clientResponse,
        _clientInterceptor = clientInterceptor;

  @override
  Future<bool> any(bool Function(List<int> element) test) {
    return _clientResponse.any(test);
  }

  @override
  Stream<List<int>> asBroadcastStream({void Function(StreamSubscription<List<int>> subscription) onListen, void Function(StreamSubscription<List<int>> subscription) onCancel}) {
    return _clientResponse.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E> Function(List<int> event) convert) {
    return _clientResponse.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(List<int> event) convert) {
    return _clientResponse.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _clientResponse.cast();
  }

  @override
  X509Certificate get certificate => _clientResponse.certificate;

  @override
  HttpClientResponseCompressionState get compressionState => _clientResponse.compressionState;

  @override
  HttpConnectionInfo get connectionInfo => _clientResponse.connectionInfo;

  @override
  Future<bool> contains(Object needle) {
    return _clientResponse.contains(needle);
  }

  @override
  int get contentLength => _clientResponse.contentLength;

  @override
  List<Cookie> get cookies => _clientResponse.cookies;

  @override
  Future<Socket> detachSocket() {
    return _clientResponse.detachSocket();
  }

  @override
  Stream<List<int>> distinct([bool Function(List<int> previous, List<int> next) equals]) {
    return _clientResponse.distinct(equals);
  }

  @override
  Future<E> drain<E>([E futureValue]) {
    return _clientResponse.drain(futureValue);
  }

  @override
  Future<List<int>> elementAt(int index) {
    return _clientResponse.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(List<int> element) test) {
    return _clientResponse.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(List<int> element) convert) {
    return _clientResponse.expand(convert);
  }

  @override
  Future<List<int>> get first => _clientResponse.first;

  @override
  Future<List<int>> firstWhere(bool Function(List<int> element) test, {List<int> Function() orElse}) {
    return _clientResponse.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, List<int> element) combine) {
    return _clientResponse.fold(initialValue, combine);
  }

  @override
  Future forEach(void Function(List<int> element) action) {
    return _clientResponse.forEach(action);
  }

  @override
  Stream<List<int>> handleError(Function onError, {bool Function(Error error) test}) {
    return _clientResponse.handleError(onError, test: test);
  }

  @override
  HttpHeaders get headers => _clientResponse.headers;

  @override
  bool get isBroadcast => _clientResponse.isBroadcast;

  @override
  Future<bool> get isEmpty => _clientResponse.isEmpty;

  @override
  bool get isRedirect => _clientResponse.isRedirect;

  @override
  Future<String> join([String separator = ""]) {
    return _clientResponse.join(separator);
  }

  @override
  Future<List<int>> get last => _clientResponse.last;

  @override
  Future<List<int>> lastWhere(bool Function(List<int> element) test, {List<int> Function() orElse}) {
    return _clientResponse.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _clientResponse.length;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData, {Function onError, void Function() onDone, bool cancelOnError}) {
    return _clientResponse.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(List<int> event) convert) {
    return _clientResponse.map(convert);
  }

  @override
  bool get persistentConnection => _clientResponse.persistentConnection;

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) {
    return _clientResponse.pipe(streamConsumer);
  }

  @override
  String get reasonPhrase => _clientResponse.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect([String method, Uri url, bool followLoops]) {
    return _clientResponse.redirect(method, url, followLoops);
  }

  @override
  List<RedirectInfo> get redirects => _clientResponse.redirects;

  @override
  Future<List<int>> reduce(List<int> Function(List<int> previous, List<int> element) combine) {
    return _clientResponse.reduce(combine);
  }

  @override
  Future<List<int>> get single => _clientResponse.single;

  @override
  Future<List<int>> singleWhere(bool Function(List<int> element) test, {List<int> Function() orElse}) {
    return _clientResponse.singleWhere(test, orElse: orElse);
  }

  @override
  Stream<List<int>> skip(int count) {
    return _clientResponse.skip(count);
  }

  @override
  Stream<List<int>> skipWhile(bool Function(List<int> element) test) {
    return _clientResponse.skipWhile(test);
  }

  @override
  int get statusCode => _clientResponse.statusCode;

  @override
  Stream<List<int>> take(int count) {
    return _clientResponse.take(count);
  }

  @override
  Stream<List<int>> takeWhile(bool Function(List<int> element) test) {
    return _clientResponse.takeWhile(test);
  }

  @override
  Stream<List<int>> timeout(Duration timeLimit, {void Function(EventSink<List<int>> sink) onTimeout}) {
    return _clientResponse.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<List<int>>> toList() {
    return _clientResponse.toList();
  }

  @override
  Future<Set<List<int>>> toSet() {
    return _clientResponse.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return _clientResponse.transform(streamTransformer);
  }

  @override
  Stream<List<int>> where(bool Function(List<int> event) test) {
    return _clientResponse.where(test);
  }

}
