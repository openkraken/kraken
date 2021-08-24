/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:io';

class _HttpHeaders implements HttpHeaders {
  final Map<String, dynamic> _headers = <String, String>{};
  _HttpHeaders({ Map<String, String>? initialHeaders }) {
    if (initialHeaders != null) {
      _headers.addAll(initialHeaders);
    }
  }

  @override
  bool chunkedTransferEncoding = false;

  @override
  int get contentLength {
    String? val = value(HttpHeaders.contentLengthHeader);
    if (val == null) {
      return -1;
    }
    return int.tryParse(val) ?? -1;
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
  ContentType? get contentType {
    String? value = _headers[HttpHeaders.contentTypeHeader];
    if (value != null) {
      return ContentType.parse(value);
    } else {
      return null;
    }
  }

  @override
  set contentType(ContentType? contentType) {
    if (contentType == null) {
      removeAll(HttpHeaders.contentTypeHeader);
    } else {
      set(HttpHeaders.contentTypeHeader, contentType.toString());
    }
  }

  @override
  DateTime? get date {
    String? value = _headers[HttpHeaders.dateHeader];
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
  set date(DateTime? date) {
    if (date == null) {
      removeAll(HttpHeaders.dateHeader);
    } else {
      // Format "DateTime" header with date in Greenwich Mean Time (GMT).
      String formatted = HttpDate.format(date.toUtc());
      set(HttpHeaders.dateHeader, formatted);
    }
  }

  @override
  DateTime? get expires => DateTime.tryParse(_headers[HttpHeaders.expiresHeader] ?? '');

  @override
  set expires(DateTime? _expires) {
    if (_expires == null) return;
    String formatted = HttpDate.format(_expires.toUtc());
    set(HttpHeaders.expiresHeader, formatted);
  }

  @override
  String? get host => _headers[HttpHeaders.hostHeader];

  @override
  set host(String? _host) {
    if (_host == null) return;
    set(HttpHeaders.hostHeader, _host);
  }

  @override
  DateTime? get ifModifiedSince {
    String? value = _headers[HttpHeaders.ifModifiedSinceHeader];
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
  set ifModifiedSince(DateTime? _ifModifiedSince) {
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
  int? port = 80;

  @override
  List<String> operator [](String name) {
    String? v = _headers[name];
    if (v != null) return [v];
    return [];
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
  String? value(String name) {
    return _headers[name];
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    _headers.forEach((String name, dynamic value) {
      sb..write(name)
        ..write(': ')
        ..write(value)
        ..write('\n');
    });
    return sb.toString();
  }
}

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

  _HttpHeaders? _httpHeaders;

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
  HttpHeaders get headers => _httpHeaders ?? (_httpHeaders = _HttpHeaders(initialHeaders: _responseHeaders));

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
