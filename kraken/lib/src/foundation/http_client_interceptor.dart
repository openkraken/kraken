/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'package:kraken/widget.dart';

abstract class HttpClientInterceptor {
  /**
   * @params
   *   kraken: The `Kraken` widget that is requesting the resource.
   *   request: [HttpClientRequest] that containing the detail of the request.
   * @return newRequest: A [HttpClientRequest] containing the response information or null if the kraken should load the resource itself.
   */
  Future<HttpClientRequest> beforeRequest(Kraken kraken, HttpClientRequest request);

  /**
   * @params
   *   kraken: The `Kraken` widget that is requesting the resource.
   *   request: [HttpClientResponse] that containing the detail of the request.
   * @return newRequest: A [HttpClientResponse] containing the response information or null if the kraken should load the resource itself.
   */
  Future<HttpClientResponse> afterResponse(Kraken kraken, HttpClientResponse response);

  Future<HttpClientResponse> shouldInterceptRequest(Kraken kraken, HttpClientRequest request);
}
