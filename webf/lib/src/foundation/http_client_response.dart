/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'http_client.dart';

class _HttpConnectionInfo implements HttpConnectionInfo {
  static final _localHttpConnectionInfo = _HttpConnectionInfo(0, InternetAddress.anyIPv4, HttpClient.defaultHttpPort);

  @override
  final int localPort;

  @override
  final InternetAddress remoteAddress;

  @override
  final int remotePort;

  const _HttpConnectionInfo(this.localPort, this.remoteAddress, this.remotePort);
}

class HttpClientStreamResponse extends Stream<List<int>> implements HttpClientResponse {
  // The response stream that be consumed.
  final Stream<List<int>> _data;

  @override
  final int statusCode;

  @override
  final String reasonPhrase;

  final HttpHeaders _headers;

  HttpClientStreamResponse(
    this._data, {
    this.statusCode = HttpStatus.ok,
    this.reasonPhrase = '',
    this.compressionState = HttpClientResponseCompressionState.notCompressed,
    HttpHeaders? initialHeaders,
  }) : _headers = initialHeaders ?? createHttpHeaders();

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState compressionState;

  @override
  HttpConnectionInfo? get connectionInfo => _HttpConnectionInfo._localHttpConnectionInfo;

  @override
  int get contentLength => headers.contentLength;

  @override
  List<Cookie> get cookies => const [];

  @override
  Future<Socket> detachSocket() async {
    return Future<Socket>.error(UnsupportedError('Mocked response'));
  }

  @override
  HttpHeaders get headers => _headers;

  @override
  bool get isRedirect => statusCode >= 300 && statusCode < 400;

  @override
  bool get persistentConnection => false;

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) {
    return Future.error(RedirectException('Redirect is unsupported.', redirects));
  }

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _data.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
