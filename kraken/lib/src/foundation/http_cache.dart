/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'http_cache_object.dart';

class HttpCacheController {
  static final String _cachePath = "Kraken/HttpCaches";
  static Map<String, HttpCacheController> _controllers = HashMap();

  static String _getOrigin(Uri contextUri) {
    if (contextUri.scheme.isEmpty) {
      // Set https as default scheme.
      contextUri = Uri(scheme: 'https', host: contextUri.host, port: contextUri.port);
    }
    if (contextUri.isScheme('http') || contextUri.isScheme('https')) {
      return contextUri.origin;
    } else {
      return '<local>';
    }
  }

  static Directory? _cacheDirectory;
  static Future<Directory> _getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final Directory appTempDirectory = await getTemporaryDirectory();
    final Directory cacheDirectory = Directory(path.join(appTempDirectory.path, _cachePath));
    bool isThere = await cacheDirectory.exists();
    if (!isThere) {
      await cacheDirectory.create(recursive: true);
    }
    return _cacheDirectory = cacheDirectory;
  }

  static String _getCacheKey(Uri uri) {
    // Fragment not included in cache.
    Uri uriWithoutFragment = uri;
    if (uriWithoutFragment.hasFragment) {
      uriWithoutFragment = uriWithoutFragment.removeFragment();
    }
    return uriWithoutFragment.toString();
  }

  /**
   * Entry for saving a http client response to cache.
   */
  static Future<HttpClientResponse> cacheHttpResource(
      String contextId,
      HttpClientResponse response,
      HttpClientRequest request) async {
    final Directory cacheDirectory = await _getCacheDirectory();
    final String key = _getCacheKey(request.uri);

    // Create cache object.
    HttpCacheObject cacheObject = HttpCacheObject
        .fromResponse(key, response, cacheDirectory.path);

    // Cache the object.
    HttpCacheController
        .instanceWithContextId(contextId)
        .putObject(request.uri, cacheObject);

    return HttpClientCachedResponse(response, cacheObject);
  }

  factory HttpCacheController.instanceWithContextId(String id) {
    KrakenController? controller = KrakenController.getControllerOfJSContextId(int.tryParse(id));
    String? contextUrl;
    if (controller != null) {
      if (controller.bundleContent != null) {
        contextUrl = 'vm://bundle_content/$id';
      } if (controller.bundleURL != null) {
        contextUrl = controller.bundleURL!;
      } else if (controller.bundlePath != null) {
        contextUrl = 'file://${controller.bundlePath}';
      }
    }
    String origin = _getOrigin(Uri.parse(contextUrl ?? 'anonymous://'));
    if (_controllers.containsKey(origin)) {
      return _controllers[origin]!;
    } else {
      return _controllers[origin] = HttpCacheController._(origin);
    }
  }

  // The context bundle url.
  final String _origin;

  // The max cache object count.
  final int _maxCachedObjects;

  // Memory cache.
  //   [String cacheKey] -> [HttpCacheObject object]
  // A splay tree is a good choice for data that is stored and accessed frequently.
  final SplayTreeMap<String, HttpCacheObject> _caches = SplayTreeMap();

  HttpCacheController._(String origin, { int maxCachedObjects = 1000 })
      : _origin = origin,
        _maxCachedObjects = maxCachedObjects;

  // The entry for getting cache by request.
  Future<HttpCacheObject?> getCacheObject(HttpClientRequest request) async {
    HttpCacheObject? cacheObject = await _getObject(request.uri);
    if (cacheObject != null) {
      // 1. Check cache-control rule
      // 2. Check expires
      if (cacheObject.isDateTimeValid()) return cacheObject;

      // 3. Check eTag by if-non-match
      final String? requestEtag = request.headers[HttpHeaders.ifNoneMatchHeader]?.single;
      if (requestEtag != null
          && requestEtag == cacheObject.eTag) {
        return cacheObject;
      }

      // 4. Check last-modified by if-modified-since
      DateTime? ifModifiedSince = request.headers.ifModifiedSince;
      if (ifModifiedSince != null
          && cacheObject.lastModified != null
          && ifModifiedSince.isAtSameMomentAs(cacheObject.lastModified!)) {
        return cacheObject;
      }

      // Miss cache.
    }
    return null;
  }

  // Get the CacheObject by uri, no validation needed here.
  Future<HttpCacheObject?> _getObject(Uri uri) async {
    // L2 cache in memory.
    final String key = _getCacheKey(uri);
    if (_caches.containsKey(key)) {
      return _caches[key];
    }

    // Get cache in disk.
    final String hash = md5.convert(utf8.encode(key)).toString();
    final Directory cacheDirectory = await _getCacheDirectory();
    HttpCacheObject cacheObject = HttpCacheObject(key, cacheDirectory.path, hash: hash, origin: _origin);

    await cacheObject.read();

    if (cacheObject.valid) {
      return cacheObject;
    }

    return null;
  }

  // Add or update the httpCacheObject to memory cache.
  void putObject(Uri uri, HttpCacheObject cacheObject) {
    if (_caches.length == _maxCachedObjects) {
        _caches.remove(_caches.lastKey());
    }
    final String key = _getCacheKey(uri);
    _caches.update(key, (value) => cacheObject, ifAbsent: () => cacheObject);
  }
}

/**
 * The HttpClientResponse that hits http cache.
 */
class HttpClientCachedResponse extends Stream<List<int>> implements HttpClientResponse {
  final HttpClientResponse response;
  final HttpCacheObject cacheObject;

  EventSink<List<int>>? _blobSink;

  HttpClientCachedResponse(this.response, this.cacheObject);

  @override
  X509Certificate? get certificate => response.certificate;

  @override
  HttpClientResponseCompressionState get compressionState => response.compressionState;

  @override
  HttpConnectionInfo? get connectionInfo => response.connectionInfo;

  @override
  int get contentLength => response.contentLength;

  @override
  List<Cookie> get cookies => response.cookies;

  @override
  Future<Socket> detachSocket() {
    return response.detachSocket();
  }

  @override
  HttpHeaders get headers => response.headers;

  @override
  bool get isRedirect => response.isRedirect;

  @override
  StreamSubscription<List<int>> listen(
      void Function(List<int> event)? onData, {
        Function? onError, void Function()? onDone, bool? cancelOnError
      }) {
    _blobSink = cacheObject.openBlobWrite();
    return response.listen((List<int> data) {
      if (onData != null) onData(data);
      _onData(data);
    }, onError: (error, [stackTrace]) {
      if (onError != null) onError(error, stackTrace);
      _onError(error, stackTrace);
    }, onDone: () {
      if (onDone != null) onDone();
      _onDone();
    }, cancelOnError: cancelOnError);
  }

  @override
  bool get persistentConnection => response.persistentConnection;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) {
    return response.redirect(method, url, followLoops);
  }

  @override
  List<RedirectInfo> get redirects => response.redirects;

  @override
  int get statusCode => response.statusCode;

  void _onData(List<int> data) {
    if (_blobSink != null) {
      _blobSink!.add(data);
    }
  }

  void _onDone() async {
    await cacheObject.writeIndex();
    if (_blobSink != null) {
      _blobSink!.close();
    }
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    print('Error while saving cache file, which has been removed.\n$error');
    if (stackTrace != null) {
      print('\n$stackTrace');
    }
    cacheObject.remove();
  }
}
