/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

class SingleHttpHeaders implements HttpHeaders {
  final Map<String, dynamic> _headers = Map<String, String>();
  SingleHttpHeaders({ Map<String, String>? initialHeaders }) {
    if (initialHeaders != null) {
      _headers.addAll(initialHeaders);
    }
  }

  @override
  bool chunkedTransferEncoding = false;

  @override
  int get contentLength {
    String val = value(HttpHeaders.contentLengthHeader);
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
  DateTime? get expires => DateTime.tryParse(_headers[HttpHeaders.expiresHeader]!);

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
  String value(String name) {
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
