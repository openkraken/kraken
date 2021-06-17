/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'package:kraken/launcher.dart';
import 'http_client_interceptor.dart';
import 'http_client.dart';

const String HttpHeaderContextID = 'x-kraken-context-id';
class KrakenHttpOverrides extends HttpOverrides {
  static KrakenHttpOverrides? _instance;
  KrakenHttpOverrides._();

  factory KrakenHttpOverrides.instance() {
    if (_instance == null) {
      _instance = KrakenHttpOverrides._();
    }
    return _instance!;
  }

  static void markHttpRequest(HttpClientRequest request, String contextId) {
    request.headers.set(HttpHeaderContextID, contextId);
  }

  final HttpOverrides? parentHttpOverrides = HttpOverrides.current;
  final Map<String, HttpClientInterceptor> _contextIdToHttpClientInterceptorMap = Map<String, HttpClientInterceptor>();

  void registerKrakenContext(KrakenController controller, HttpClientInterceptor httpClientInterceptor) {
    String contextId = controller.view.contextId.toString();
    _contextIdToHttpClientInterceptorMap[contextId] = httpClientInterceptor;
  }

  void unregisterKrakenContext(KrakenController controller) {
    String contextId = controller.view.contextId.toString();
    // Returns true if [value] was in the map, false otherwise.
    _contextIdToHttpClientInterceptorMap.remove(contextId);
  }

  HttpClientInterceptor getInterceptor(String contextId) {
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

    HttpClient httpClient = ProxyHttpClient(
      nativeHttpClient: nativeHttpClient,
      httpOverrides: this,
    );
    return httpClient;
  }

  bool shouldOverride(HttpClientRequest request) {
    String? contextId = request.headers.value(HttpHeaderContextID);
    return contextId != null && _contextIdToHttpClientInterceptorMap.containsKey(contextId);
  }
}

KrakenHttpOverrides setupHttpOverrides(HttpClientInterceptor httpClientInterceptor, { required KrakenController controller }) {
  KrakenHttpOverrides httpOverrides = KrakenHttpOverrides.instance();
  httpOverrides.registerKrakenContext(controller, httpClientInterceptor);
  HttpOverrides.global = httpOverrides;
  return httpOverrides;
}
