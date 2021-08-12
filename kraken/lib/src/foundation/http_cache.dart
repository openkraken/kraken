/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:kraken/foundation.dart';
import 'package:path/path.dart' as path;

import 'http_cache_object.dart';

class HttpCacheController {
  static Map<String, HttpCacheController> _controllers = HashMap();

  static Directory? _cacheDirectory;
  static Future<Directory> getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final String appTemporaryPath = await getKrakenTemporaryPath();
    final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches'));
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

  factory HttpCacheController.instance(String origin) {
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

  // Get the CacheObject by uri, no validation needed here.
  Future<HttpCacheObject?> getCacheObject(Uri uri) async {
    // L2 cache in memory.
    final String key = _getCacheKey(uri);
    if (_caches.containsKey(key)) {
      return _caches[key];
    }

    // Get cache in disk.
    final int hash = key.hashCode;
    final Directory cacheDirectory = await getCacheDirectory();
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

  Future<HttpClientResponse> interceptResponse(
      HttpClientRequest request,
      HttpClientResponse response,
      HttpCacheObject? cacheObject) async {

    if (cacheObject != null) {
      await cacheObject.updateIndex(response);

      // Handle with HTTP 304
      if (response.statusCode == HttpStatus.notModified) {
        HttpClientResponse? cachedResponse  = await cacheObject.toHttpClientResponse();
        if (cachedResponse != null) {
          return cachedResponse;
        }
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      // Create cache object.
      HttpCacheObject cacheObject = HttpCacheObject
          .fromResponse(
          _getCacheKey(request.uri),
          response,
          (await getCacheDirectory()).path
      );

      // Cache the object.
      putObject(request.uri, cacheObject);

      return HttpClientCachedResponse(response, cacheObject);
    }
    return response;
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
