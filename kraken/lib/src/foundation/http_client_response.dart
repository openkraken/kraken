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

class SimpleHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  String mime;
  String encoding;
  Stream data;

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
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData, { Function onError, void Function() onDone, bool cancelOnError }) {
    return data.listen(onData, onDone: onDone, cancelOnError: cancelOnError);
  }
}
