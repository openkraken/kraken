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

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_URL = 'about:blank';

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

bool _isSchemeAssets(String path) {
  return path.startsWith('assets:');
}

bool _isSchemeFile(String path) {
  return path.startsWith('file:');
}

bool _isSchemeHttp(String path) {
  return path.startsWith('http:') || path.startsWith('https:');
}

bool _isSchemeAbout(String url) {
  return url.startsWith('about:');
}

void _failedToResolveBundle(String url) {
  throw FlutterError('Failed to resolve bundle for $url');
}

abstract class KrakenBundle {
  KrakenBundle(this.src);

  // Unique resource locator.
  final String src;

  // Uri parsed by uriParser, assigned after resolving.
  Uri? _uri;

  ByteData? rawBundle;
  // JS Content in UTF-8 bytes.
  Uint8List? bytecode;
  // JS Content is String
  String? content;
  // JS line offset, default to 0.
  int lineOffset = 0;

  bool isResolved = false;

  // Bundle contentType.
  ContentType contentType = ContentType.binary;

  bool get isEmpty => src.isEmpty && content == null && bytecode == null;

  Uri? get resolvedUri {
    if (isResolved) {
      return _uri;
    }
    return null;
  }

  @mustCallSuper
  Future<void> resolve(int? contextId) async {
    if (isResolved) return;

    // Source is input by user, do not trust it's a valid URL.
    _uri = Uri.tryParse(src);
    if (contextId != null && _uri != null) {
      KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
      if (controller != null) {
        _uri = controller.uriParser!.resolve(Uri.parse(controller.url), _uri!);
      }
      isResolved = true;
    }
  }

  Future<void> resolveAndEvaluate(int? contextId) async {
    await resolve(contextId);
    eval(contextId);
  }

  static KrakenBundle fromUrl(String url, { Map<String, String>? additionalHttpHeaders }) {
    if (_isSchemeHttp(url)) {
      return NetworkBundle(url, additionalHttpHeaders: additionalHttpHeaders);
    } else if (_isSchemeAssets(url)) {
      return AssetsBundle(url);
    } else if (_isSchemeFile(url)) {
      return FileBundle(url);
    } else if (_isSchemeAbout(url)) {
      return _EmptyBundle(url);
    } else {
      throw FlutterError('Unsupported url. $url');
    }
  }

  static KrakenBundle fromContent(String content, { String url = DEFAULT_URL }) {
    return RawBundle.fromString(content, url);
  }

  static KrakenBundle fromBytecode(Uint8List bytecode, { String url = DEFAULT_URL }) {
    return RawBundle.fromBytecode(bytecode, url);
  }

  void eval(int? contextId) {
    if (!isResolved) {
      debugPrint('The kraken bundle $this is not resolved to evaluate.');
      return;
    }

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
        String code = _resolveStringFromData(rawBundle!);
        // parse html.
        parseHTML(contextId, code);
      } else if (contentType.mimeType == css.mimeType || src.contains('.css')) {
        KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
        controller?.view.document.addStyleSheet(CSSStyleSheet(_resolveStringFromData(rawBundle!)));
      } else if (isByteCodeSupported(contentType.mimeType, src)) {
        Uint8List buffer = rawBundle!.buffer.asUint8List();
        evaluateQuickjsByteCode(contextId, buffer);
      } else {
        String code = _resolveStringFromData(rawBundle!);
        // eval JavaScript.
        evaluateScripts(contextId, code, src, lineOffset);
      }
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
    }
  }
}

// The bundle that output input content.
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

// The bundle that source from http or https.
class NetworkBundle extends KrakenBundle {
  static final HttpClient _sharedHttpClient = HttpClient()..userAgent = NavigatorModule.getUserAgent();

  NetworkBundle(String url, { this.additionalHttpHeaders })
      : super(url);

  Map<String, String>? additionalHttpHeaders = {};

  @override
  Future<void> resolve(int? contextId) async {
    super.resolve(contextId);
    final HttpClientRequest request = await _sharedHttpClient.getUrl(_uri!);

    // Prepare request headers.
    request.headers.set('Accept', getAcceptHeader());
    additionalHttpHeaders?.forEach(request.headers.set);
    if (contextId != null) {
      KrakenHttpOverrides.setContextHeader(request.headers, contextId);
    }

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $src'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    contentType = response.headers.contentType ?? ContentType.binary;
    rawBundle = bytes.buffer.asByteData();
    contentType = response.headers.contentType ?? ContentType.binary;
    isResolved = true;
  }
}

String _resolveStringFromData(ByteData data) {
  // Utf8 decode is fast enough with dart 2.10
  return utf8.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

class AssetsBundle extends KrakenBundle {
  AssetsBundle(String url) : super(url);

  @override
  Future<KrakenBundle> resolve(int? contextId) async {
    super.resolve(contextId);
    final Uri? _resolvedUri = resolvedUri;
    if (_resolvedUri != null) {
      final String assetName = getAssetName(_resolvedUri);
      rawBundle = await rootBundle.load(assetName);
    } else {
      _failedToResolveBundle(src);
    }
    return this;
  }

  /// Get flutter asset name from uri scheme asset.
  ///   eg: assets:///foo/bar.html -> foo/bar.html
  ///       assets:foo/bar.html -> foo/bar.html
  static String getAssetName(Uri assetUri) {
    String assetName = assetUri.path;

    // Remove leading `/`.
    if (assetName.startsWith('/')) {
      assetName = assetName.substring(1);
    }
    return assetName;
  }
}

/// The bundle that source from local io.
class FileBundle extends KrakenBundle {
  FileBundle(String url) : super(url);

  @override
  Future<KrakenBundle> resolve(int? contextId) async {
    super.resolve(contextId);

    Uri uri = _uri!;
    final String path = uri.path;
    File file = File(path);
    if (await file.exists()) {
      if (path.endsWith('.html')) {
        contentType = ContentType.html;
        content = await file.readAsString();
      } else if (isByteCodeSupported('', path)) {
        contentType = ContentType.binary;
        bytecode = await file.readAsBytes();
      } else {
        contentType = ContentType.text;
        content = await file.readAsString();
      }
    } else {
      _failedToResolveBundle(src);
    }
    return this;
  }
}

/// The bundle that store nothing.
class _EmptyBundle extends KrakenBundle {
  _EmptyBundle(String url) : super(url);

  @override
  String get content => '';
}
