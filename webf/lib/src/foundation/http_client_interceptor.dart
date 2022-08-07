/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';

abstract class HttpClientInterceptor {
  /// @params
  ///   kraken: The `Kraken` widget that is requesting the resource.
  ///   request: [HttpClientRequest] that containing the detail of the request.
  /// @return newRequest: A [HttpClientRequest] containing the response information or null if the kraken should load the resource itself.
  Future<HttpClientRequest?> beforeRequest(HttpClientRequest request);

  /// @params
  ///   kraken: The `Kraken` widget that is requesting the resource.
  ///   request: [HttpClientResponse] that containing the detail of the request.
  /// @return newRequest: A [HttpClientResponse] containing the response information or null if the kraken should load the resource itself.
  Future<HttpClientResponse?> afterResponse(HttpClientRequest request, HttpClientResponse response);

  Future<HttpClientResponse?> shouldInterceptRequest(HttpClientRequest request);
}
