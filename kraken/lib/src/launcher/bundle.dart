import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/module.dart';
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
  List<String> assets = [];
  int lineOffset = 0;
  // Kraken bundle manifest
  AppManifest? manifest;

  bool isResolved = false;

  Future<void> resolve();

  static Future<KrakenBundle> getBundle(String path, { String? contentOverride, required int contextId }) async {
    KrakenBundle bundle;
    Uri uri = Uri.parse(path);
    if (contentOverride != null && contentOverride.isNotEmpty) {
      bundle = RawBundle(contentOverride, uri);
    } else {
      // Treat empty scheme as https.
      if (path.startsWith('//')) path = 'https' + path;

      if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
        bundle = NetworkBundle(uri, contextId: contextId);
      } else {
        bundle = AssetsBundle(uri);
      }
    }

    if (bundle != null) {
      await bundle.resolve();
    }

    return bundle;
  }

  Future<void> eval(int contextId) async {
    if (!isResolved) await resolve();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_START);
    }

    evaluateScripts(contextId, content, url.toString(), lineOffset);

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
    }
  }
}

class RawBundle extends KrakenBundle {
  RawBundle(String content, Uri url)
      : assert(content != null),
        super(url) {
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
    NetworkAssetBundle bundle = NetworkAssetBundle(url, contextId: contextId);
    bundle.httpClient.userAgent = getKrakenInfo().userAgent;
    String absoluteURL = url.toString();
    ByteData bytes = await bundle.load(absoluteURL);
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

  Uri _urlFromKey(String key) => _baseUrl.resolve(key);

  @override
  Future<ByteData> load(String key) async {
    final HttpClientRequest request = await httpClient.getUrl(_urlFromKey(key));
    KrakenHttpOverrides.markHttpRequest(request, contextId.toString());
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $key'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    return bytes.buffer.asByteData();
  }

  /// Retrieve a string from the asset bundle, parse it with the given function,
  /// and return the function's result.
  ///
  /// The result is not cached. The parser is run each time the resource is
  /// fetched.
  @override
  Future<T> loadStructuredData<T>(String key, Future<T> parser(String value)) async {
    assert(key != null);
    assert(parser != null);
    return parser(await loadString(key));
  }

  // TODO(ianh): Once the underlying network logic learns about caching, we
  // should implement evict().

  @override
  String toString() => '${describeIdentity(this)}($_baseUrl)';
}

class AssetsBundle extends KrakenBundle {
  AssetsBundle(Uri url)
      : assert(url != null),
        super(url);

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
