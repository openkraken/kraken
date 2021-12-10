/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';
import 'package:kraken/css.dart';

import 'manifest.dart';

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';

const String ASSETS_PROROCOL = 'assets://';
final ContentType css = ContentType('text', 'css', charset: 'utf-8');

String? getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String? getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

List<String> _supportedByteCodeVersions = ['1'];

bool isByteCodeSupported(String mimeType, String filename) {
  for (int i = 0; i < _supportedByteCodeVersions.length; i ++) {
    if (mimeType.contains('application/vnd.kraken.bc' + _supportedByteCodeVersions[i])) return true;
    if (filename.contains('kbc' + _supportedByteCodeVersions[i])) return true;
  }
  return false;
}

String getAcceptHeader() {
  String krakenKbcAccept = _supportedByteCodeVersions.map((String str) => 'application/vnd.kraken.bc$str').join(',');
  return 'text/html,application/javascript,$krakenKbcAccept';
}

bool isAssetAbsolutePath(String path) {
  return path.startsWith(ASSETS_PROROCOL);
}

abstract class KrakenBundle {
  KrakenBundle(this.src);

  // Unique resource locator.
  final String src;

  // Customize the parsed uri by uriParser.
  Uri? uri;

  late ByteData rawBundle;
  // JS Content in UTF-8 bytes.
  Uint8List? bytecode;
  // JS Content is String
  String? content;
  // JS line offset, default to 0.
  int lineOffset = 0;
  // Kraken bundle manifest
  AppManifest? manifest;

  bool isResolved = false;

  // Bundle contentType.
  ContentType contentType = ContentType.binary;

  @mustCallSuper
  Future<void> resolve(int? contextId) async {
    uri = Uri.parse(src);
    if (contextId != null) {
      if (kDebugMode) {
        print('Getting bundle for contextId: $contextId, src: $src');
      }
      KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
      if (controller != null && !isAssetAbsolutePath(src)) {
        uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri!);
      }
    }

    isResolved = true;
  }

  static KrakenBundle fromUrl(String url, { Map<String, String>? additionalHttpHeaders }) {
    if (isAssetAbsolutePath(url)) {
      return AssetsBundle(url);
    } else {
      return NetworkBundle(url, additionalHttpHeaders: additionalHttpHeaders);
    }
  }

  static KrakenBundle fromContent(String content, { String url = '' }) {
    return RawBundle.fromString(content, url);
  }

  static KrakenBundle fromBytecode(Uint8List bytecode, { String url = '' }) {
    return RawBundle.fromBytecode(bytecode, url);
  }


  Future<void> eval(int? contextId) async {
    if (!isResolved) await resolve(contextId);

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_START);
    }

    if (contextId != null) {
      // For raw javascript code or bytecode from API directly.
      if (content != null) {
        evaluateScripts(contextId, content!, src, lineOffset);
      } else if (bytecode != null) {
        evaluateQuickjsByteCode(contextId, bytecode!);
      }

      // For javascript code, HTML or bytecode from networks and hardware disk.
      else if (contentType.mimeType == ContentType.html.mimeType || src.contains('.html')) {
        String code = _resolveStringFromData(rawBundle);
        // parse html.
        parseHTML(contextId, code);
      } else if (contentType.mimeType == css.mimeType || src.contains('.css')) {
        KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
        controller?.view.document.addStyleSheet(CSSStyleSheet(_resolveStringFromData(rawBundle)));
      } else if (isByteCodeSupported(contentType.mimeType, src)) {
        Uint8List buffer = rawBundle.buffer.asUint8List();
        evaluateQuickjsByteCode(contextId, buffer);
      } else {
        String code = _resolveStringFromData(rawBundle);
        // eval JavaScript.
        evaluateScripts(contextId, code, src, lineOffset);
      }
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
    }
  }
}

class RawBundle extends KrakenBundle {
  RawBundle.fromString(String content, String url)
      : super(url) {
    this.content = content;
  }

  RawBundle.fromBytecode(Uint8List bytecode, String url)
      : super(url) {
    this.bytecode = bytecode;
  }

  @override
  Future<void> resolve(int? contextId) async {
    super.resolve(contextId);
    isResolved = true;
  }
}

class NetworkBundle extends KrakenBundle {
  NetworkBundle(String url, { this.additionalHttpHeaders })
      : super(url);

  Map<String, String>? additionalHttpHeaders = {};

  @override
  Future<void> resolve(int? contextId) async {
    super.resolve(contextId);
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
    Uri baseUrl = Uri.parse(controller.href);
    NetworkAssetBundle bundle = NetworkAssetBundle(controller.uriParser!.resolve(baseUrl, Uri.parse(src)), contextId: contextId, additionalHttpHeaders: additionalHttpHeaders);
    bundle.httpClient.userAgent = getKrakenInfo().userAgent;
    String absoluteURL = src;
    rawBundle = await bundle.load(absoluteURL);
    contentType = bundle.contentType;
    isResolved = true;
  }
}

String _resolveStringFromData(ByteData data) {
  // Utf8 decode is fast enough with dart 2.10
  return utf8.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

/// An [AssetBundle] that loads resources over the network.
///
/// This asset bundle does not cache any resources, though the underlying
/// network stack may implement some level of caching itself.
class NetworkAssetBundle extends AssetBundle {
  /// Creates an network asset bundle that resolves asset keys as URLs relative
  /// to the given base URL.
  NetworkAssetBundle(Uri baseUrl, {int? contextId, Map<String, String>? additionalHttpHeaders })
      : _baseUrl = baseUrl,
        _additionalHttpHeaders = additionalHttpHeaders,
        httpClient = HttpClient();

  int? contextId;
  final Uri _baseUrl;
  final HttpClient httpClient;
  final Map<String, String>? _additionalHttpHeaders;
  ContentType contentType = ContentType.binary;

  Uri _urlFromKey(String key) => _baseUrl.resolve(key);

  @override
  Future<ByteData> load(String key) async {
    final HttpClientRequest request = await httpClient.getUrl(_urlFromKey(key));
    request.headers.set('Accept', getAcceptHeader());
    if (_additionalHttpHeaders != null) {
      _additionalHttpHeaders?.forEach(request.headers.set);
    }

    if (contextId != null) {
      KrakenHttpOverrides.setContextHeader(request.headers, contextId!);
    }

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $key'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    contentType = response.headers.contentType ?? ContentType.binary;
    return bytes.buffer.asByteData();
  }

  /// Retrieve a string from the asset bundle, parse it with the given function,
  /// and return the function's result.
  ///
  /// The result is not cached. The parser is run each time the resource is
  /// fetched.
  @override
  Future<T> loadStructuredData<T>(String key, Future<T> Function(String value) parser) async {
    return parser(await loadString(key));
  }

  // TODO(ianh): Once the underlying network logic learns about caching, we
  // should implement evict().

  @override
  String toString() => '${describeIdentity(this)}($_baseUrl)';
}

class AssetsBundle extends KrakenBundle {
  AssetsBundle(String url)
      : super(url);

  @override
  Future<KrakenBundle> resolve(int? contextId) async {
    super.resolve(contextId);
    // JSBundle get default bundle manifest.
    manifest = AppManifest();
    if (isAssetAbsolutePath(src)) {
      String localPath = src.substring(ASSETS_PROROCOL.length);
      rawBundle = await rootBundle.load(localPath);
    }
    return this;
  }
}
