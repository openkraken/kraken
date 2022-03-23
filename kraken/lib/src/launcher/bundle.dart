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
// https://mathiasbynens.be/demo/javascript-mime-type
final ContentType javascript = ContentType('text', 'javascript', charset: 'utf-8');
final ContentType applicationJavascript = ContentType('application', 'javascript', charset: 'utf-8');
final ContentType applicationXJavascript = ContentType('application', 'x-javascript', charset: 'utf-8');
final ContentType bytecode1 = ContentType('application', 'vnd.kraken.bc1');

String? getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String? getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

List<String> _supportedByteCodeVersions = ['1'];

bool _isBytecodeSupported(String mimeType, Uri uri) {
  for (int i = 0; i < _supportedByteCodeVersions.length; i ++) {
    if (mimeType.contains('application/vnd.kraken.bc' + _supportedByteCodeVersions[i])) return true;
    if (uri.path.endsWith('.kbc' + _supportedByteCodeVersions[i])) return true;
  }
  return false;
}

// The default accept request header.
String _acceptHeader() {
  String bc = _supportedByteCodeVersions.map((String v) => 'application/vnd.kraken.bc$v').join(',');
  return 'text/html,application/javascript,$bc';
}

bool _isAssetsScheme(String path) {
  return path.startsWith('assets:');
}

bool _isFileScheme(String path) {
  return path.startsWith('file:');
}

bool _isHttpScheme(String path) {
  return path.startsWith('http:') || path.startsWith('https:');
}

bool _isDefaultUrl(String url) {
  return url == DEFAULT_URL;
}

void _failedToResolveBundle(String url) {
  throw FlutterError('Failed to resolve bundle for $url');
}

abstract class KrakenBundle {
  KrakenBundle(this.url);

  // Unique resource locator.
  final String url;

  // Uri parsed by uriParser, assigned after resolving.
  Uri? _uri;
  Uri? get resolvedUri => _uri;

  // The bundle data of raw.
  Uint8List? data;

  // Indicate the bundle is resolved.
  bool get isResolved => _uri != null && data != null;

  // Content type for data.
  ContentType contentType = ContentType.binary;

  @mustCallSuper
  Future<void> resolve(int? contextId) async {
    if (isResolved) return;

    // Source is input by user, do not trust it's a valid URL.
    _uri = Uri.tryParse(url);
    if (contextId != null && _uri != null) {
      KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
      if (controller != null) {
        _uri = controller.uriParser!.resolve(Uri.parse(controller.url), _uri!);
      }
    }
  }

  static KrakenBundle fromUrl(String url, { Map<String, String>? additionalHttpHeaders }) {
    if (_isHttpScheme(url)) {
      return NetworkBundle(url, additionalHttpHeaders: additionalHttpHeaders);
    } else if (_isAssetsScheme(url)) {
      return AssetsBundle(url);
    } else if (_isFileScheme(url)) {
      return FileBundle(url);
    } else if (_isDefaultUrl(url)) {
      return DataBundle.fromString('', url, contentType: javascript);
    } else {
      throw FlutterError('Unsupported url. $url');
    }
  }

  static KrakenBundle fromContent(String content, { String url = DEFAULT_URL }) {
    return DataBundle.fromString(content, url, contentType: javascript);
  }

  static KrakenBundle fromBytecode(Uint8List data, { String url = DEFAULT_URL }) {
    return DataBundle(data, url, contentType: bytecode1);
  }

  Future<void> eval(int? contextId) async {
    if (!isResolved) {
      debugPrint('The kraken bundle $this is not resolved to evaluate.');
      return;
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_START);
    }

    if (contextId != null) {
      Uint8List data = this.data!;
      if (_isHTML) {
        // parse html.
        parseHTML(contextId, await _resolveStringFromData(data));
      } else if (_isJavascript) {
        evaluateScripts(contextId, await _resolveStringFromData(data), url, 0);
      } else if (_isBytecode) {
        evaluateQuickjsByteCode(contextId, data);
      } else if (_isCSS) {
        _addCSSStyleSheet(await _resolveStringFromData(data), contextId: contextId);
      } else {
        // The resource type can not be evaluated.
        throw FlutterError('Can\'t evaluate content of $url');
      }
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
    }

    // To release memory.
    data = null;
  }

  bool get _isHTML => contentType.mimeType == ContentType.html.mimeType || _isUriExt('.html');
  bool get _isCSS => contentType.mimeType == css.mimeType || _isUriExt('.css');
  bool get _isJavascript => contentType.mimeType == javascript.mimeType ||
                          contentType.mimeType == applicationJavascript.mimeType ||
                          contentType.mimeType == applicationXJavascript.mimeType ||
                          _isUriExt('.js');
  bool get _isBytecode => _isBytecodeSupported(contentType.mimeType, _uri!);

  bool _isUriExt(String ext) {
    Uri? uri = resolvedUri;
    if (uri != null) {
      return uri.path.endsWith(ext);
    }
    return false;
  }

  void _addCSSStyleSheet(String css, { int? contextId }) {
    KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
    controller?.view.document.addStyleSheet(CSSStyleSheet(css));
  }
}

// The bundle that output input data.
class DataBundle extends KrakenBundle {
  DataBundle(Uint8List data, String url, { ContentType? contentType }) : super(url) {
    this.data = data;
    this.contentType = contentType ?? ContentType.binary;
  }

  DataBundle.fromString(String content, String url, { ContentType? contentType }) : super(url) {
    data = Uint8List.fromList(content.codeUnits);
    this.contentType = contentType ?? ContentType.text;
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
    request.headers.set('Accept', _acceptHeader());
    additionalHttpHeaders?.forEach(request.headers.set);
    if (contextId != null) {
      KrakenHttpOverrides.setContextHeader(request.headers, contextId);
    }

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $url'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    data = bytes.buffer.asUint8List();
    contentType = response.headers.contentType ?? ContentType.binary;
  }
}

Future<String> _resolveStringFromData(final List<int> data) async {
  // Utf8 decode is fast enough with dart 2.10
  // reference: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/services/asset_bundle.dart#L71
  // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs
  // on a Pixel 4.
  if (data.length < 50 * 1024) {
    return utf8.decode(data);
  }
  // For strings larger than 50 KB, run the computation in an isolate to
  // avoid causing main thread jank.
  return compute(_utf8decode, data);
}

String _utf8decode(List<int> data) => utf8.decode(data);

class AssetsBundle extends KrakenBundle {
  AssetsBundle(String url) : super(url);

  @override
  Future<KrakenBundle> resolve(int? contextId) async {
    super.resolve(contextId);
    final Uri? _resolvedUri = resolvedUri;
    if (_resolvedUri != null) {
      final String assetName = getAssetName(_resolvedUri);
      ByteData byteData = await rootBundle.load(assetName);
      data = byteData.buffer.asUint8List();
    } else {
      _failedToResolveBundle(url);
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
      data = await file.readAsBytes();
      if (_isHTML) {
        contentType = ContentType.html;
      } else if (_isBytecode) {
        contentType = bytecode1;
      } else if (_isCSS) {
        contentType = css;
      } else {
        // Fallback to javascript.
        contentType = javascript;
      }
    } else {
      _failedToResolveBundle(url);
    }
    return this;
  }
}
