import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/module.dart';
import 'package:kraken/launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'manifest.dart';

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';

String? getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String? getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

abstract class KrakenBundle {
  KrakenBundle(this.url);

  // Unique resource locator.
  final Uri url;
  // JS Content
  late String content;
  // JS line offset, default to 0.
  int lineOffset = 0;
  // Kraken bundle manifest
  AppManifest? manifest;

  bool isResolved = false;

  // Bundle contentType.
  ContentType? contentType;

  Future<void> resolve();

  static Future<KrakenBundle> getBundle(String path, { String? contentOverride, required int contextId }) async {
    KrakenBundle bundle;

    if (kDebugMode) {
      print('Kraken getting bundle for contextId: $contextId, path: $path');
    }

    Uri uri = Uri.parse(path);
    KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
    if (controller != null) {
      uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri);
    }

    if (contentOverride != null && contentOverride.isNotEmpty) {
      bundle = RawBundle(contentOverride, uri);
    } else if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
      bundle = NetworkBundle(uri, contextId: contextId);
    } else {
      bundle = AssetsBundle(uri);
    }

    await bundle.resolve();

    return bundle;
  }

  Future<void> eval(int contextId) async {
    if (!isResolved) await resolve();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_START);
    }

    if (contentType?.mimeType == ContentType.html.mimeType || url.toString().contains('.html')) {
      // parse html.
      parseHTML(contextId, content, url.toString());
    } else {
      // eval JavaScript.
      evaluateScripts(contextId, content, url.toString(), lineOffset);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
    }
  }
}

class RawBundle extends KrakenBundle {
  RawBundle(String content, Uri url)
      : super(url) {
    this.content = content;
  }

  @override
  Future<void> resolve() async {
    isResolved = true;
  }
}

class NetworkBundle extends KrakenBundle {
  int contextId;
  NetworkBundle(Uri url, { required this.contextId })
      : super(url);

  @override
  Future<void> resolve() async {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
    Uri baseUrl = Uri.parse(controller.href);
    NetworkAssetBundle bundle = NetworkAssetBundle(controller.uriParser!.resolve(baseUrl, url), contextId: contextId);
    bundle.httpClient.userAgent = getKrakenInfo().userAgent;
    String absoluteURL = url.toString();
    ByteData bytes = await bundle.load(absoluteURL);
    contentType = bundle.contentType;
    content = await _resolveStringFromData(bytes, absoluteURL);
    isResolved = true;
  }
}

String _resolveStringFromData(ByteData data, String key) {
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
  NetworkAssetBundle(Uri baseUrl, { required this.contextId })
      : _baseUrl = baseUrl,
        httpClient = HttpClient();

  final Uri _baseUrl;
  final int contextId;
  final HttpClient httpClient;
  ContentType? contentType;

  Uri _urlFromKey(String key) => _baseUrl.resolve(key);

  @override
  Future<ByteData> load(String key) async {
    final HttpClientRequest request = await httpClient.getUrl(_urlFromKey(key));
    KrakenHttpOverrides.setContextHeader(request.headers, contextId);
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $key'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    contentType = response.headers.contentType;
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
  AssetsBundle(Uri url)
      : super(url);

  @override
  Future<void> resolve() async {
    // JSBundle get default bundle manifest.
    manifest = AppManifest();
    String localPath = url.toString();
    ByteData bytes = await rootBundle.load(localPath);
    content = await _resolveStringFromData(bytes, localPath);
    isResolved = true;
  }
}
