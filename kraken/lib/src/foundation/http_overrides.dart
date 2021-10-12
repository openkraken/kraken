/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:kraken/foundation.dart';
import 'package:kraken/kraken.dart';

// TODO: Don't use header to mark context.
const String HttpHeaderContext = 'x-context';
class KrakenHttpOverrides extends HttpOverrides {
  static KrakenHttpOverrides? _instance;

  KrakenHttpOverrides._();

  factory KrakenHttpOverrides.instance() {
    _instance ??= KrakenHttpOverrides._();
    return _instance!;
  }

  static int? getContextHeader(HttpHeaders headers) {
    String? intVal = headers.value(HttpHeaderContext);
    if (intVal == null) {
      return null;
    }
    return int.tryParse(intVal);
  }

  static void setContextHeader(HttpHeaders headers, int contextId) {
    headers.set(HttpHeaderContext, contextId.toString());
  }

  final HttpOverrides? parentHttpOverrides = HttpOverrides.current;
  final Map<int, HttpClientInterceptor> _contextIdToHttpClientInterceptorMap = <int, HttpClientInterceptor>{};

  void registerKrakenContext(int contextId, HttpClientInterceptor httpClientInterceptor) {
    _contextIdToHttpClientInterceptorMap[contextId] = httpClientInterceptor;
  }

  bool unregisterKrakenContext(int contextId) {
    // Returns true if [value] was in the map, false otherwise.
    return _contextIdToHttpClientInterceptorMap.remove(contextId) != null;
  }

  bool hasInterceptor(int contextId) {
    return _contextIdToHttpClientInterceptorMap.containsKey(contextId);
  }

  HttpClientInterceptor getInterceptor(int contextId) {
    return _contextIdToHttpClientInterceptorMap[contextId]!;
  }

  void clearInterceptors() {
    _contextIdToHttpClientInterceptorMap.clear();
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient nativeHttpClient;
    if (parentHttpOverrides != null) {
      nativeHttpClient = parentHttpOverrides!.createHttpClient(context);
    } else {
      nativeHttpClient = super.createHttpClient(context);
    }

    return ProxyHttpClient(nativeHttpClient, this);
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (parentHttpOverrides != null) {
      return parentHttpOverrides!.findProxyFromEnvironment(url, environment);
    } else {
      return super.findProxyFromEnvironment(url, environment);
    }
  }
}

KrakenHttpOverrides setupHttpOverrides(HttpClientInterceptor? httpClientInterceptor, { required int contextId }) {
  final KrakenHttpOverrides httpOverrides = KrakenHttpOverrides.instance();

  if (httpClientInterceptor != null) {
    httpOverrides.registerKrakenContext(contextId, httpClientInterceptor);
  }

  HttpOverrides.global = httpOverrides;
  return httpOverrides;
}

// Returns the origin of the URI in the form scheme://host:port
String getOrigin(Uri uri) {
  if (uri.isScheme('http')
      || uri.isScheme('https')) {
    return uri.origin;
  } else {
    return uri.path;
  }
}

// @TODO: Remove controller dependency.
Uri getReferrer(int? contextId) {
  KrakenController? controller = KrakenController
      .getControllerOfJSContextId(contextId);
  if (controller != null) {
    return controller.referrer;
  }
  return KrakenController.fallbackBundleUri(contextId ?? 0);
}
