/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'http_client_interceptor.dart';
import 'http_client.dart';

class KrakenHttpOverrides extends HttpOverrides {
  KrakenHttpOverrides(this.parentHttpOverrides, { this.interceptor });

  bool shouldOverride = false;
  final HttpClientInterceptor interceptor;
  final HttpOverrides parentHttpOverrides;

  @override
  HttpClient createHttpClient(SecurityContext context) {
    HttpClient nativeHttpClient;
    if (parentHttpOverrides != null) {
      nativeHttpClient = parentHttpOverrides.createHttpClient(context);
    } else {
      nativeHttpClient = super.createHttpClient(context);
    }

    if (!shouldOverride) {
      return nativeHttpClient;
    }

    HttpClient httpClient = ProxyHttpClient(
      nativeHttpClient: nativeHttpClient,
      httpRequestInterceptor: interceptor,
    );
    return httpClient;
  }
}

KrakenHttpOverrides setupHttpOverrides(HttpClientInterceptor httpClientInterceptor) {
  KrakenHttpOverrides httpOverrides = KrakenHttpOverrides(HttpOverrides.current, interceptor: httpClientInterceptor)
    ..shouldOverride = true;
  HttpOverrides.global = httpOverrides;
  return httpOverrides;
}
