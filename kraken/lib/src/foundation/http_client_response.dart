/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:io';
import 'http_headers.dart';

class _HttpConnectionInfo implements HttpConnectionInfo {
  int localPort;
  InternetAddress remoteAddress;
  int remotePort;
  _HttpConnectionInfo(this.localPort, this.remoteAddress, this.remotePort);
}

class HttpClientStreamResponse extends Stream<List<int>> implements HttpClientResponse {
  Stream<List<int>> data;

  int statusCode;
  String reasonPhrase;
  Map<String, String> responseHeaders;
  SingleHttpHeaders? _singleHttpHeaders;

  HttpClientStreamResponse(this.data, {
    this.statusCode = HttpStatus.ok,
    this.reasonPhrase = '',
    this.responseHeaders = const {},
  });

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  HttpConnectionInfo get connectionInfo => _HttpConnectionInfo(80, InternetAddress.loopbackIPv4, 80);

  @override
  int get contentLength => -1;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<Socket> detachSocket() async {
    return Future<Socket>.error(UnsupportedError('Mocked response'));
  }

  @override
  HttpHeaders get headers => _singleHttpHeaders ?? (_singleHttpHeaders = SingleHttpHeaders(initialHeaders: responseHeaders));

  @override
  bool get isRedirect => statusCode >= 300 && statusCode < 400;

  @override
  bool get persistentConnection => false;

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) {
    return Future.error(RedirectException('Redirect is unsupported.', redirects));
  }

  @override
  List<RedirectInfo> get redirects => [];

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, { Function? onError, void Function()? onDone, bool? cancelOnError }) {
    return data.listen(onData, onDone: onDone, cancelOnError: cancelOnError);
  }
}
