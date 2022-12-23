/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'dart:async';
import 'dart:io';

import 'http_client_request.dart';
import 'http_overrides.dart';

class ProxyHttpClient implements HttpClient {
  ProxyHttpClient(HttpClient nativeHttpClient, KrakenHttpOverrides httpOverrides)
      : _nativeHttpClient = nativeHttpClient,
        _httpOverrides = httpOverrides;

  final KrakenHttpOverrides _httpOverrides;
  final HttpClient _nativeHttpClient;

  bool _closed = false;

  @override
  bool get autoUncompress => _nativeHttpClient.autoUncompress;

  @override
  set autoUncompress(bool _autoUncompress) {
    _nativeHttpClient.autoUncompress = _autoUncompress;
  }

  @override
  Duration get connectionTimeout => _nativeHttpClient.connectionTimeout!;

  @override
  set connectionTimeout(Duration? _connectionTimeout) {
    _nativeHttpClient.connectionTimeout = _connectionTimeout;
  }

  @override
  Duration get idleTimeout => _nativeHttpClient.idleTimeout;

  @override
  set idleTimeout(Duration _idleTimeout) {
    _nativeHttpClient.idleTimeout = _idleTimeout;
  }

  @override
  int get maxConnectionsPerHost => _nativeHttpClient.maxConnectionsPerHost!;

  @override
  set maxConnectionsPerHost(int? _maxConnectionsPerHost) {
    _nativeHttpClient.maxConnectionsPerHost = _maxConnectionsPerHost;
  }

  @override
  String get userAgent => _nativeHttpClient.userAgent!;

  @override
  set userAgent(String? _userAgent) {
    _nativeHttpClient.userAgent = _userAgent;
  }

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {
    _nativeHttpClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {
    _nativeHttpClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(f) {
    _nativeHttpClient.authenticate = f;
  }

  @override
  set authenticateProxy(f) {
    _nativeHttpClient.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {
    _nativeHttpClient.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    _nativeHttpClient.close(force: force);
    _closed = true;
  }

  @override
  set findProxy(String Function(Uri url)? f) {
    _nativeHttpClient.findProxy = f;
  }

  Future<HttpClientRequest> _openUrl(String method, Uri uri) async {
    if (_closed) {
      throw StateError('Http client is closed.');
    }

    // Ignore any fragments on the request URI.
    uri = uri.removeFragment();

    return ProxyHttpClientRequest(method, uri, _httpOverrides, _nativeHttpClient);
  }

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    const int hashMark = 0x23;
    const int questionMark = 0x3f;
    int fragmentStart = path.length;
    int queryStart = path.length;
    for (int i = path.length - 1; i >= 0; i--) {
      var char = path.codeUnitAt(i);
      if (char == hashMark) {
        fragmentStart = i;
        queryStart = i;
      } else if (char == questionMark) {
        queryStart = i;
      }
    }
    String? query;
    if (queryStart < fragmentStart) {
      query = path.substring(queryStart + 1, fragmentStart);
      path = path.substring(0, queryStart);
    }
    // Default to https.
    Uri uri = Uri(scheme: 'https', host: host, port: port, path: path, query: query);
    return _openUrl(method, uri);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => _openUrl(method, url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) => open('get', host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => _openUrl('get', url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) => open('head', host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _openUrl('head', url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) => open('patch', host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _openUrl('patch', url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) => open('post', host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _openUrl('post', url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) => open('put', host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _openUrl('put', url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) => open('delete', host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _openUrl('delete', url);
}

HttpHeaders createHttpHeaders({ Map<String, List<String>>? initialHeaders }) {
  return _HttpHeaders(initialHeaders: initialHeaders);
}

class _HttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = <String, List<String>>{};
  _HttpHeaders({ Map<String, List<String>>? initialHeaders }) {
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
    String? val = value(HttpHeaders.contentTypeHeader);
    if (val != null) {
      return ContentType.parse(val);
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
    String? val = value(HttpHeaders.dateHeader);
    if (val != null) {
      try {
        return HttpDate.parse(val);
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
  DateTime? get expires => tryParseHttpDate(value(HttpHeaders.expiresHeader) ?? '');

  @override
  set expires(DateTime? _expires) {
    if (_expires == null) return;
    String formatted = HttpDate.format(_expires.toUtc());
    set(HttpHeaders.expiresHeader, formatted);
  }

  @override
  String? get host => value(HttpHeaders.hostHeader);

  @override
  set host(String? _host) {
    if (_host == null) return;
    set(HttpHeaders.hostHeader, _host);
  }

  @override
  DateTime? get ifModifiedSince {
    String? val = value(HttpHeaders.ifModifiedSinceHeader);
    if (val != null) {
      try {
        return HttpDate.parse(val);
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
    return _headers[name] ?? [];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    if (!preserveHeaderCase) {
      name = name.toLowerCase();
    }
    _addAll(name, value);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {
    List<String>? values = _headers[name];
    if (values != null) {
      values.remove(value);
    }
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
    _headers.remove(name);
    _addAll(name, value);
  }

  @override
  String? value(String name) {
    name = name.toLowerCase();
    List<String>? values = _headers[name];
    if (values == null) return null;
    assert(values.isNotEmpty);
    if (values.length > 1) {
      throw HttpException('More than one value for header $name');
    }
    return values[0];
  }


  void _addAll(String name, value) {
    if (value is Iterable) {
      for (var v in value) {
        _addValue(name, v);
      }
    } else {
      _addValue(name, value);
    }
  }

  void _addValue(String name, Object value) {
    List<String> values = (_headers[name] ??= <String>[]);
    values.add(_valueToString(value));
  }

  String _valueToString(Object value) {
    if (value is DateTime) {
      return HttpDate.format(value);
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    bool hasValue = false;
    _headers.forEach((String name, List<String> values) {
      values.forEach((String value) {
        if (hasValue) {
          sb.write('\n');
        }
        sb..write(name)
          ..write(': ')
          ..write(value);
        hasValue = true;
      });
    });
    return sb.toString();
  }
}

DateTime? tryParseHttpDate(String input) {
  try {
    return HttpDate.parse(input);
  } catch (ignored) {
    // Ignore all exceptions.
    return null;
  }
}
