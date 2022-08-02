/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';

String EMPTY_STRING = '';

class FetchModule extends BaseModule {
  @override
  String get name => 'Fetch';

  bool _disposed = false;

  FetchModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {
    _httpClient?.close(force: true);
    _httpClient = null;
    _disposed = true;
  }

  HttpClient? _httpClient;
  HttpClient get httpClient => _httpClient ?? (_httpClient = HttpClient());

  Uri _resolveUri(String input) {
    final Uri parsedUri = Uri.parse(input);

    if (moduleManager != null) {
      Uri base = Uri.parse(moduleManager!.controller.url);
      UriParser uriParser = moduleManager!.controller.uriParser!;
      return uriParser.resolve(base, parsedUri);
    } else {
      return parsedUri;
    }
  }

  static const String fallbackUserAgent = 'WebF';
  static String? _defaultUserAgent;
  static String _getDefaultUserAgent() {
    if (_defaultUserAgent == null) {
      try {
        _defaultUserAgent = NavigatorModule.getUserAgent();
      } catch (error) {
        // Ignore if dynamic library is missing.
        return fallbackUserAgent;
      }
    }
    return _defaultUserAgent!;
  }

  @visibleForTesting
  Future<HttpClientRequest> getRequest(Uri uri, String? method, Map? headers, data) {
    return httpClient.openUrl(method ?? 'GET', uri).then((HttpClientRequest request) {
      // Reset Kraken UA.
      request.headers.removeAll(HttpHeaders.userAgentHeader);
      request.headers.add(HttpHeaders.userAgentHeader, _getDefaultUserAgent());

      // Add additional headers.
      if (headers is Map<String, dynamic>) {
        for (MapEntry<String, dynamic> entry in headers.entries) {
          request.headers.add(entry.key, entry.value);
        }
      }

      // Set ContextID Header
      if (moduleManager != null) {
        request.headers.set(HttpHeaderContext, moduleManager!.contextId.toString());
      }

      if (data is List<int>) {
        request.add(data);
      } else if (data != null) {
        // Treat as string as default.
        request.add(data.toString().codeUnits);
      }

      return request;
    });
  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    Uri uri = _resolveUri(method);
    Map<String, dynamic> options = params;

    _handleError(Object error, StackTrace? stackTrace) {
      String errmsg = '$error';
      if (stackTrace != null) {
        errmsg += '\n$stackTrace';
      }
      callback(error: errmsg);
    }

    if (uri.host.isEmpty) {
      // No host specified in URI.
      _handleError('Failed to parse URL from $uri.', null);
    } else {
      HttpClientResponse? response;
      getRequest(uri, options['method'], options['headers'], options['body']).then((HttpClientRequest request) {
        if (_disposed) return Future.value(null);
        return request.close();
      }).then((HttpClientResponse? res) {
        if (res == null) {
          return Future.value(null);
        } else {
          response = res;
          return consolidateHttpClientResponseBytes(res);
        }
      }).then((Uint8List? bytes) {
        if (bytes == null)
          return Future.value(null);
        else
          return resolveStringFromData(bytes);
      }).then((String? content) {
        if (content != null) {
          callback(data: [EMPTY_STRING, response?.statusCode, content]);
        } else {
          throw FlutterError('Failed to read response.');
        }
      }).catchError(_handleError);
    }

    return EMPTY_STRING;
  }
}
