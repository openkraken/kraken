/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:kraken/widget.dart';

import 'http.dart';
import 'http_client.dart';

class KrakenHttpOverrides extends HttpOverrides {
  KrakenHttpOverrides(this.parentHttpOverrides, { this.interceptor });

  bool shouldOverride = false;
  final HttpClientInterceptor interceptor;
  final HttpOverrides parentHttpOverrides;

  @override
  HttpClient createHttpClient(SecurityContext context) {
    HttpClient nativeHttpClient;
    if (parentHttpOverrides != null) {
      nativeHttpClient = parentHttpOverrides.createHttpClient(context);
    } else {
      nativeHttpClient = super.createHttpClient(context);
    }

    if (!shouldOverride) {
      return nativeHttpClient;
    }

    HttpClient httpClient = KrakenHttpClient(
      nativeHttpClient: nativeHttpClient,
      httpRequestInterceptor: interceptor,
    );
    return httpClient;
  }
}

class MyCustomHttpClientInterceptor implements HttpClientInterceptor {
  @override
  Future<HttpClientRequest> beforeRequest(Kraken kraken, HttpClientRequest request) {
    request.headers.set('x-foo', 'bar');
    return Future.value(request);
  }

  @override
  Future<HttpClientResponse> afterResponse(Kraken kraken, HttpClientResponse response) {
    response.headers.set('x-response-modified', 'YES');
    return Future.value(response);
  }

  @override
  Future<HttpClientResponse> shouldInterceptRequest(Kraken kraken, HttpClientRequest request) {
    HttpClientResponse httpClientResponse = MockHttpResponse();
    return Future.value(httpClientResponse);
  }
}

/// A mocked [HttpClientRequest] which always returns a [_MockHttpClientResponse].
class MockHttpRequest extends HttpClientRequest {
  @override
  Encoding encoding;

  @override
  final HttpHeaders headers = CustomHttpHeaders();

  @override
  void add(List<int> data) { }

  @override
  void addError(Object error, [ StackTrace stackTrace ]) { }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    return Future<void>.value();
  }

  @override
  Future<HttpClientResponse> close() {
    return Future<HttpClientResponse>.value(MockHttpResponse());
  }

  @override
  // ignore: override_on_non_overriding_member
  void abort([Object exception, StackTrace stackTrace]) {}

  @override
  HttpConnectionInfo get connectionInfo => null;

  @override
  List<Cookie> get cookies => null;

  @override
  Future<HttpClientResponse> get done async => null;

  @override
  Future<void> flush() {
    return Future<void>.value();
  }

  @override
  String get method => null;

  @override
  Uri get uri => null;

  @override
  void write(Object obj) { }

  @override
  void writeAll(Iterable<Object> objects, [ String separator = '' ]) { }

  @override
  void writeCharCode(int charCode) { }

  @override
  void writeln([ Object obj = '' ]) { }
}

/// A mocked [HttpClientResponse] which is empty and has a [statusCode] of 400.
// TODO(tvolkert): Change to `extends Stream<Uint8List>` once
// https://dart-review.googlesource.com/c/sdk/+/104525 is rolled into the framework.
class MockHttpResponse implements HttpClientResponse {
  final Stream<Uint8List> _delegate = Stream<Uint8List>.fromIterable(const Iterable<Uint8List>.empty());

  @override
  final HttpHeaders headers = CustomHttpHeaders();

  @override
  X509Certificate get certificate => null;

  @override
  HttpConnectionInfo get connectionInfo => null;

  @override
  int get contentLength => -1;

  @override
  HttpClientResponseCompressionState get compressionState {
    return HttpClientResponseCompressionState.decompressed;
  }

  @override
  List<Cookie> get cookies => null;

  @override
  Future<Socket> detachSocket() {
    return Future<Socket>.error(UnsupportedError('Mocked response'));
  }

  @override
  bool get isRedirect => false;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event) onData, { Function onError, void Function() onDone, bool cancelOnError }) {
    return const Stream<Uint8List>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  bool get persistentConnection => null;

  @override
  String get reasonPhrase => null;

  @override
  Future<HttpClientResponse> redirect([ String method, Uri url, bool followLoops ]) {
    return Future<HttpClientResponse>.error(UnsupportedError('Mocked response'));
  }

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  int get statusCode => 400;

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    return _delegate.any(test);
  }

  @override
  Stream<Uint8List> asBroadcastStream({
    void Function(StreamSubscription<Uint8List> subscription) onListen,
    void Function(StreamSubscription<Uint8List> subscription) onCancel,
  }) {
    return _delegate.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E> Function(Uint8List event) convert) {
    return _delegate.asyncExpand<E>(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    return _delegate.asyncMap<E>(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _delegate.cast<R>();
  }

  @override
  Future<bool> contains(Object needle) {
    return _delegate.contains(needle);
  }

  @override
  Stream<Uint8List> distinct([bool Function(Uint8List previous, Uint8List next) equals]) {
    return _delegate.distinct(equals);
  }

  @override
  Future<E> drain<E>([E futureValue]) {
    return _delegate.drain<E>(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    return _delegate.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    return _delegate.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    return _delegate.expand(convert);
  }

  @override
  Future<Uint8List> get first => _delegate.first;

  @override
  Future<Uint8List> firstWhere(
      bool Function(Uint8List element) test, {
        List<int> Function() orElse,
      }) {
    return _delegate.firstWhere(test, orElse: () {
      return Uint8List.fromList(orElse());
    });
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, Uint8List element) combine) {
    return _delegate.fold<S>(initialValue, combine);
  }

  @override
  Future<dynamic> forEach(void Function(Uint8List element) action) {
    return _delegate.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(
      Function onError, {
        bool Function(dynamic error) test,
      }) {
    return _delegate.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => _delegate.isBroadcast;

  @override
  Future<bool> get isEmpty => _delegate.isEmpty;

  @override
  Future<String> join([String separator = '']) {
    return _delegate.join(separator);
  }

  @override
  Future<Uint8List> get last => _delegate.last;

  @override
  Future<Uint8List> lastWhere(
      bool Function(Uint8List element) test, {
        List<int> Function() orElse,
      }) {
    return _delegate.lastWhere(test, orElse: () {
      return Uint8List.fromList(orElse());
    });
  }

  @override
  Future<int> get length => _delegate.length;

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    return _delegate.map<S>(convert);
  }

  @override
  Future<dynamic> pipe(StreamConsumer<List<int>> streamConsumer) {
    return _delegate.cast<List<int>>().pipe(streamConsumer);
  }

  @override
  Future<Uint8List> reduce(List<int> Function(Uint8List previous, Uint8List element) combine) {
    return _delegate.reduce((Uint8List previous, Uint8List element) {
      return Uint8List.fromList(combine(previous, element));
    });
  }

  @override
  Future<Uint8List> get single => _delegate.single;

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test, {List<int> Function() orElse}) {
    return _delegate.singleWhere(test, orElse: () {
      return Uint8List.fromList(orElse());
    });
  }

  @override
  Stream<Uint8List> skip(int count) {
    return _delegate.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    return _delegate.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    return _delegate.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    return _delegate.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(
      Duration timeLimit, {
        void Function(EventSink<Uint8List> sink) onTimeout,
      }) {
    return _delegate.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Uint8List>> toList() {
    return _delegate.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    return _delegate.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return _delegate.cast<List<int>>().transform<S>(streamTransformer);
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    return _delegate.where(test);
  }
}

class CustomHttpHeaders implements HttpHeaders {
  final Map<String, String> _headers;

  CustomHttpHeaders() : _headers = HashMap<String, String>();

  @override
  bool chunkedTransferEncoding;

  @override
  int contentLength;

  @override
  ContentType contentType;

  @override
  DateTime date;

  @override
  DateTime expires;

  @override
  String host;

  @override
  DateTime ifModifiedSince;

  @override
  bool persistentConnection;

  @override
  int port;

  @override
  List<String> operator [](String name) {
    throw UnimplementedError();
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    set(name, value, preserveHeaderCase: persistentConnection);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach((String key, String value) {
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
    if (name != null) {
      String lowercaseName = preserveHeaderCase ? name : name.toLowerCase();
      if (value != null) {
        value = value.toString();
      }
      _headers[lowercaseName] = value;
    }
  }

  @override
  String value(String name) {
    return _headers[name];
  }
}

KrakenHttpOverrides setupHttpOverrides() {
  KrakenHttpOverrides httpOverrides = KrakenHttpOverrides(HttpOverrides.current, interceptor: MyCustomHttpClientInterceptor())
    ..shouldOverride = true;
  HttpOverrides.global = httpOverrides;
  return httpOverrides;
}
