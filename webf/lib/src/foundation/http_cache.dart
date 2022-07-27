/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:async/async.dart';
import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;

enum HttpCacheMode {
  /// Default cache usage mode. If the navigation type doesn't impose any specific
  /// behavior, use cached resources when they are available and not expired,
  /// otherwise load resources from the network.
  DEFAULT,

  /// Don't use the network, load from the cache.
  CACHE_ONLY,

  /// Don't use the cache, load from the network.
  NO_CACHE,
}

class HttpCacheController {
  // TODO: Add HTTP Cache for Windows and Linux
  static HttpCacheMode mode = Platform.isWindows ? HttpCacheMode.NO_CACHE : HttpCacheMode.DEFAULT;

  static final Map<String, HttpCacheController> _controllers = HashMap();

  static Directory? _cacheDirectory;
  static Future<Directory> getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final String appTemporaryPath = await getWebFTemporaryPath();
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

  HttpCacheController._(String origin, {int maxCachedObjects = 1000})
      : _origin = origin,
        _maxCachedObjects = maxCachedObjects;

  // Get the CacheObject by uri, no validation needed here.
  Future<HttpCacheObject> getCacheObject(Uri uri) async {
    HttpCacheObject cacheObject;

    // L2 cache in memory.
    final String key = _getCacheKey(uri);
    if (_caches.containsKey(key)) {
      cacheObject = _caches[key]!;
    } else {
      // Get cache in disk.
      final int hash = key.hashCode;
      final Directory cacheDirectory = await getCacheDirectory();
      cacheObject = HttpCacheObject(key, cacheDirectory.path, hash: hash, origin: _origin);
    }

    await cacheObject.read();

    return cacheObject;
  }

  // Add or update the httpCacheObject to memory cache.
  void putObject(Uri uri, HttpCacheObject cacheObject) {
    if (_caches.length == _maxCachedObjects) {
      _caches.remove(_caches.lastKey());
    }
    final String key = _getCacheKey(uri);
    _caches.update(key, (value) => cacheObject, ifAbsent: () => cacheObject);
  }

  void removeObject(Uri uri) {
    final String key = _getCacheKey(uri);
    _caches.remove(key);
  }

  Future<HttpClientResponse> interceptResponse(HttpClientRequest request, HttpClientResponse response,
      HttpCacheObject cacheObject, HttpClient httpClient) async {
    await cacheObject.updateIndex(response);

    // Negotiate cache with HTTP 304
    if (response.statusCode == HttpStatus.notModified) {
      HttpClientResponse? cachedResponse = await cacheObject.toHttpClientResponse(httpClient);
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      // Create cache object.
      HttpCacheObject cacheObject =
          HttpCacheObject.fromResponse(_getCacheKey(request.uri), response, (await getCacheDirectory()).path);

      // Cache the object.
      if (cacheObject.valid) {
        putObject(request.uri, cacheObject);
      } else {
        removeObject(request.uri);
      }

      return HttpClientCachedResponse(response, cacheObject);
    }
    return response;
  }
}

/// The HttpClientResponse that hits http cache.
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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    _blobSink ??= cacheObject.openBlobWrite();

    void _handleData(List<int> data) {
      if (onData != null) onData(data);
      _onData(data);
    }

    void _handleError(error, [stackTrace]) {
      if (onError != null) onError(error, stackTrace);
      _onError(error, stackTrace);
    }

    void _handleDone() {
      if (onDone != null) onDone();
      _onDone();
    }

    return _DelegatingStreamSubscription(
      response.listen(_handleData, onError: _handleError, onDone: _handleDone, cancelOnError: cancelOnError),
      handleData: _handleData,
      handleDone: _handleDone,
      handleError: _handleError,
    );
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
    _blobSink?.add(data);
  }

  void _onDone() async {
    await cacheObject.writeIndex();
    _blobSink?.close();
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    print('Error while saving cache file, which has been removed.\n$error');
    if (stackTrace != null) {
      print('\n$stackTrace');
    }
    cacheObject.remove();
  }
}

class _DelegatingStreamSubscription extends DelegatingStreamSubscription<List<int>> {
  final void Function(List<int>) _handleData;
  final Function _handleError;
  final void Function() _handleDone;

  _DelegatingStreamSubscription(
    StreamSubscription<List<int>> source, {
    required void Function(List<int>) handleData,
    required Function handleError,
    required void Function() handleDone,
  })  : _handleData = handleData,
        _handleError = handleError,
        _handleDone = handleDone,
        super(source);

  @override
  void onData(void Function(List<int>)? handleData) {
    super.onData((List<int> data) {
      if (handleData != null) {
        handleData(data);
      }
      _handleData(data);
    });
  }

  @override
  void onError(Function? handleError) {
    super.onError((Object error, [StackTrace? stackTrace]) {
      if (handleError != null) {
        handleError(error, stackTrace: stackTrace);
      }
      _handleError(error, stackTrace: stackTrace);
    });
  }

  @override
  void onDone(void Function()? handleDone) {
    super.onDone(() {
      if (handleDone != null) {
        handleDone();
      }
      _handleDone();
    });
  }
}
