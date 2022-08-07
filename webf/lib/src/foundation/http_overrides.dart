/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';

import 'package:webf/webf.dart';

// TODO: Don't use header to mark context.
const String HttpHeaderContext = 'x-context';

class WebFHttpOverrides extends HttpOverrides {
  static WebFHttpOverrides? _instance;

  WebFHttpOverrides._();

  factory WebFHttpOverrides.instance() {
    _instance ??= WebFHttpOverrides._();
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

  void registerWebFContext(int contextId, HttpClientInterceptor httpClientInterceptor) {
    _contextIdToHttpClientInterceptorMap[contextId] = httpClientInterceptor;
  }

  bool unregisterWebFContext(int contextId) {
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

WebFHttpOverrides setupHttpOverrides(HttpClientInterceptor? httpClientInterceptor, {required int contextId}) {
  final WebFHttpOverrides httpOverrides = WebFHttpOverrides.instance();

  if (httpClientInterceptor != null) {
    httpOverrides.registerWebFContext(contextId, httpClientInterceptor);
  }

  HttpOverrides.global = httpOverrides;
  return httpOverrides;
}

// Returns the origin of the URI in the form scheme://host:port
String getOrigin(Uri uri) {
  if (uri.isScheme('http') || uri.isScheme('https')) {
    return uri.origin;
  } else {
    return uri.path;
  }
}

// @TODO: Remove controller dependency.
Uri getEntrypointUri(int? contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  String url = controller?.url ?? '';
  return Uri.tryParse(url) ?? WebFController.fallbackBundleUri(contextId ?? 0);
}
