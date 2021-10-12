/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
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

  final Map<String, String> _responseHeaders;

  HttpHeaders? _httpHeaders;

  HttpClientStreamResponse(this._data, {
    this.statusCode = HttpStatus.ok,
    this.reasonPhrase = '',
    Map<String, String> responseHeaders = const {},
  }) : _responseHeaders = responseHeaders;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

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
  HttpHeaders get headers => _httpHeaders ?? (_httpHeaders = createHttpHeaders(initialHeaders: _responseHeaders));

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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, { Function? onError, void Function()? onDone, bool? cancelOnError }) {
    return _data.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
