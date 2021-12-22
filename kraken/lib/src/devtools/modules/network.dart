/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:kraken/devtools.dart';
import 'package:kraken/foundation.dart';

class InspectNetworkModule extends UIInspectorModule implements HttpClientInterceptor {
  InspectNetworkModule(ChromeDevToolsService devtoolsService) : super(devtoolsService) {
    _registerHttpClientInterceptor();
  }

  void _registerHttpClientInterceptor() {
    setupHttpOverrides(this, contextId: devtoolsService.controller!.view.contextId);
  }

  HttpClientInterceptor? get _customHttpClientInterceptor => devtoolsService.controller?.httpClientInterceptor;

  @override
  String get name => 'Network';

  final HttpCacheMode _httpCacheOriginalMode = HttpCacheController.mode;

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'setCacheDisabled':
        bool cacheDisabled = params?['cacheDisabled'];
        if (cacheDisabled) {
          HttpCacheController.mode = HttpCacheMode.NO_CACHE;
        } else {
          HttpCacheController.mode = _httpCacheOriginalMode;
        }
        sendToFrontend(id, null);
        break;
      case 'getResponseBody':
        // String requestId = params!['requestId'];
        sendToFrontend(id, JSONEncodableMap({
          'body': '{"content":"the body"}',
          // True, if content was sent as base64.
          'base64Encoded': false,
        }));
        break;
    }
  }

  @override
  Future<HttpClientRequest?> beforeRequest(HttpClientRequest request) {
    sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: _getRequestId(request),
      loaderId: devtoolsService.controller!.view.contextId.toString(),
      requestMethod: request.method,
      url: request.uri.toString(),
      headers: _getHttpHeaders(request.headers),
    ));
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.beforeRequest(request);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<HttpClientResponse?> afterResponse(HttpClientRequest request, HttpClientResponse response) async {
    sendEventToFrontend(NetworkResponseReceivedEvent(
      requestId: _getRequestId(request),
      loaderId: devtoolsService.controller!.view.contextId.toString(),
      url: request.uri.toString(),
      headers: _getHttpHeaders(request.headers),
      status: response.statusCode,
      statusText: response.reasonPhrase,
      mimeType: response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain',
      remoteIPAddress: response.connectionInfo!.remoteAddress.address,
      remotePort: response.connectionInfo!.remotePort,
      // HttpClientStreamResponse is the internal implementation for disk cache.
      fromDiskCache: response is HttpClientStreamResponse,
      encodedDataLength: response.contentLength,
      protocol: request.uri.scheme,
      type: _getRequestType(request),
    ));
    sendEventToFrontend(NetworkLoadingFinishedEvent(
      requestId: _getRequestId(request),
      contentLength: response.contentLength,
    ));

    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.afterResponse(request, response);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<HttpClientResponse?> shouldInterceptRequest(HttpClientRequest request) {
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.shouldInterceptRequest(request);
    } else {
      return Future.value(null);
    }
  }
}

class NetworkRequestWillBeSentEvent extends InspectorEvent {

  final String requestId;
  final String loaderId;
  final String url;
  final String requestMethod;
  final Map<String, String> headers;

  NetworkRequestWillBeSentEvent({
    required this.requestId,
    required this.loaderId,
    required this.requestMethod,
    required this.url,
    required this.headers,
  });

  @override
  String get method => 'Network.requestWillBeSent';

  @override
  JSONEncodable? get params => JSONEncodableMap({
    'requestId': requestId,
    'loaderId': loaderId,
    'documentURL': '',
    'request': {
      'url': url,
      'method': requestMethod,
      'headers': headers,
      'initialPriority': 'Medium',
      'referrerPolicy': '',
    },
    'timestamp': DateTime.now().microsecondsSinceEpoch,
    'initiator': {
      'type': 'script',
      'lineNumber': 0,
      'columnNumber': 0,
    },
    'redirectHasExtraInfo': false,
  });
}

class NetworkResponseReceivedEvent extends InspectorEvent {
  final String requestId;
  final String loaderId;
  final String url;
  final Map<String, String> headers;
  final int status;
  final String statusText;
  final String mimeType;
  final String remoteIPAddress;
  final int remotePort;
  final bool fromDiskCache;
  final int encodedDataLength;
  final String protocol;
  final String type;

  NetworkResponseReceivedEvent({
    required this.requestId,
    required this.loaderId,
    required this.url,
    required this.headers,
    required this.status,
    required this.statusText,
    required this.mimeType,
    required this.remoteIPAddress,
    required this.remotePort,
    required this.fromDiskCache,
    required this.encodedDataLength,
    required this.protocol,
    required this.type,
  });
  final int now = DateTime.now().millisecondsSinceEpoch;

  @override
  String get method => 'Network.responseReceived';

  @override
  JSONEncodable? get params => JSONEncodableMap({
    'requestId': requestId,
    'loaderId': loaderId,
    'timestamp': now,
    'type': type,
    'response': {
      'url': url,
      'status': status,
      'statusText': statusText,
      'headers': headers,
      'mimeType': mimeType,
      'connectionReused': false,
      'connectionId': 0,
      'remoteIPAddress': remoteIPAddress,
      'remotePort': remotePort,
      'fromDiskCache': fromDiskCache,
      'encodedDataLength': encodedDataLength,
      'protocol': protocol,
      'securityState': 'secure',
      'responseTime': now,
    },
    'hasExtraInfo': false,
  });
}

class NetworkLoadingFinishedEvent extends InspectorEvent {
  final String requestId;
  final int contentLength;

  NetworkLoadingFinishedEvent({ required this.requestId, required this.contentLength });

  @override
  String get method => 'Network.loadingFinished';

  @override
  JSONEncodable? get params => JSONEncodableMap({
    'requestId': requestId,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'encodedDataLength': contentLength,
  });

}

Map<String, String> _getHttpHeaders(HttpHeaders headers) {
  Map<String, String> map = {};
  headers.forEach((String name, values) {
    map[name] = headers.value(name) ?? '';
  });
  return map;
}

String _getRequestId(HttpClientRequest request) {
  // @NOTE: For creating backend request, only uri is the same object reference.
  // See http_client_request.dart [_createBackendClientRequest]
  return request.uri.hashCode.toString();
}

// Allowed Values: Document, Stylesheet, Image, Media, Font, Script, TextTrack, XHR, Fetch, EventSource, WebSocket,
// Manifest, SignedExchange, Ping, CSPViolationReport, Preflight, Other
String _getRequestType(HttpClientRequest request) {
  String urlPath = request.uri.path;
  if (urlPath.endsWith('.js')) {
    return 'Script';
  } else if (urlPath.endsWith('.css')) {
    return 'Stylesheet';
  } else if (urlPath.endsWith('.jpg') || urlPath.endsWith('.png')
      || urlPath.endsWith('.gif') || urlPath.endsWith('.webp')) {
    return 'Image';
  } else if (urlPath.endsWith('.html') || urlPath.endsWith('.htm')) {
    return 'Document';
  } else {
    return 'Fetch';
  }
}
