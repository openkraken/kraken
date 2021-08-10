/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HttpCacheManager {
  static final String _cachePath = "Kraken/HttpCaches";
  static Map<String, HttpCacheManager> _managers = HashMap();

  static String _getOrigin(Uri contextUri) {
    if (contextUri.scheme.isEmpty) {
      // Set https as default scheme.
      contextUri = Uri(scheme: 'https', host: contextUri.host, port: contextUri.port);
    }
    return contextUri.origin;
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

  static Future<HttpClientResponse> cacheHttpResource(String contextId, HttpClientResponse response, HttpClientRequest request) async {
    final Directory cacheDirectory = await _getCacheDirectory();
    final String url = _getCacheKey(request.uri);

    // Create cache object.
    HttpCacheObject cacheObject = HttpCacheObject
        .fromResponse(url, response, cacheDirectory.path);

    // Cache to memory.
    HttpCacheManager cacheManager = HttpCacheManager.instanceWithContextId(contextId);
    cacheManager.putObject(request.uri, cacheObject);

    return HttpClientProxyResponse(response, cacheObject);
  }

  factory HttpCacheManager.instanceWithContextId(String id) {
    KrakenController? controller = KrakenController.getControllerOfJSContextId(int.tryParse(id));
    String? contextUrl;
    if (controller != null) {
      if (controller.bundleURL != null) {
        contextUrl = controller.bundleURL!;
      } else {
        contextUrl = 'file://${controller.bundlePath}';
      }
    }
    String origin = _getOrigin(Uri.parse(contextUrl ?? 'anonymous://'));
    if (_managers.containsKey(origin)) {
      return _managers[origin]!;
    } else {
      return _managers[origin] = HttpCacheManager._(origin);
    }
  }

  final String _origin;
  final int _maxCachedObjects;
  // Memory cache. cacheKey -> Cache
  // A splay tree is a good choice for data that is stored and accessed frequently.
  final SplayTreeMap<String, HttpCacheObject> _caches = SplayTreeMap();

  HttpCacheManager._(String origin, { int maxCachedObjects = 1000 })
      : _origin = origin,
        _maxCachedObjects = maxCachedObjects;

  Future<HttpCacheObject?> getCacheObject(HttpClientRequest request) async {
    print('Get cache object, origin $_origin, url: ${request.uri}');
    HttpCacheObject? cacheObject = await getObject(request.uri);
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
      if (ifModifiedSince != null && cacheObject.lastModified != null
          && ifModifiedSince.isAtSameMomentAs(cacheObject.lastModified!)) {
        return cacheObject;
      }
    }
    return null;
  }

  static Future<bool> _hitDiskCache(String hash, String cacheDirectory) {

    final indexFile = File(path.join(cacheDirectory, hash));
    return indexFile.exists();
  }

  Future<HttpCacheObject?> getObject(Uri uri) async {
    String key = _getCacheKey(uri);
    if (_caches.containsKey(key)) {
      return _caches[key];
    }

    final String hash = md5.convert(utf8.encode(key)).toString();
    final Directory cacheDirectory = await _getCacheDirectory();
    final bool isHitDiskCache = await _hitDiskCache(hash, cacheDirectory.path);
    if (isHitDiskCache) {
      // @TODO: 整合这里的逻辑到 HttpCacheObject 里
      String url = _getCacheKey(uri);

      File indexFile = File(path.join(cacheDirectory.path, hash));
      final bool isIndexFileExist = await indexFile.exists();
      if (isIndexFileExist) {
        File blobFile = File(path.join(cacheDirectory.path, '$hash-blob'));
        HttpCacheObject cacheObject = HttpCacheObject._(url, cacheDirectory.path, hash: hash, data: blobFile.openRead());
        return cacheObject;
      }
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

class HttpClientProxyResponse extends Stream<List<int>> implements HttpClientResponse {
  final HttpClientResponse response;
  final HttpCacheObject cacheObject;

  IOSink? _blobSink;

  HttpClientProxyResponse(this.response, this.cacheObject);

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
      cacheObject.fullySaved = true;
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

class HttpCacheObject {
  // The cached url of resource.
  final String url;

  // When the file is out-of-date
  final DateTime? expiredTime;

  // The eTag provided by the server.
  final String? eTag;

  // The length of content.
  final int? contentLength;

  // When file was last used.
  final DateTime? lastUsed;

  // When file was last modified.
  final DateTime? lastModified;

  // The directory to store cache file.
  final String cacheDirectory;

  // The storage filename.
  final String hash;

  // The stream data in raw format.
  final Stream<List<int>> data;

  // Whether finished.
  bool fullySaved = false;

  HttpCacheObject._(this.url, this.cacheDirectory, {
    this.expiredTime,
    this.eTag,
    this.contentLength,
    this.lastUsed,
    this.lastModified,
    required this.hash,
    required this.data
  });

  factory HttpCacheObject.fromResponse(String url, HttpClientResponse response, String cacheDirectory) {
    DateTime expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
    List<String>? eTags = response.headers[HttpHeaders.etagHeader];
    int contentLength = response.headers.contentLength;
    String? lastModifiedValue = response.headers[HttpHeaders.lastModifiedHeader]?.single;
    DateTime? lastModified = lastModifiedValue != null
        ? DateTime.tryParse(lastModifiedValue)
        : null;

    // Since md5 is more efficient among other hashing algorithms.
    final String hash = md5.convert(utf8.encode(url)).toString();

    return HttpCacheObject._(url, cacheDirectory,
      eTag: eTags?.single,
      expiredTime: expiredTime,
      contentLength: contentLength,
      hash: hash,
      lastModified: lastModified,
      lastUsed: DateTime.now(),
      data: response,
    );
  }

  static final DateTime alwaysExpired = DateTime.fromMicrosecondsSinceEpoch(0);

  static DateTime _getExpiredTimeFromResponseHeaders(HttpHeaders headers) {
    List<String>? cacheControls = headers[HttpHeaders.cacheControlHeader];
    if (cacheControls != null) {
      for (String cacheControl in cacheControls) {
        // @TODO: maxAge rule.
      }
    }

    return headers.expires ?? alwaysExpired;
  }

  bool isDateTimeValid() => expiredTime != null && expiredTime!.isBefore(DateTime.now());

  Future<void> writeIndex() async {
    final String indexFilename = hash;
    final File indexFile = File(path.join(cacheDirectory, indexFilename));

    await indexFile.writeAsBytes([
      0x01,
      0x00
    ]);
  }

  String get blobFilename => '$hash-blob';

  IOSink openBlobWrite() {
    final File blobFile = File(path.join(cacheDirectory, blobFilename));
    return blobFile.openWrite();
  }

  // Remove all the cached files.
  void remove() async {
    final File indexFile = File(path.join(cacheDirectory, hash));
    final File blobFile = File(path.join(cacheDirectory, blobFilename));

    await Future.wait([
      indexFile.delete(),
      blobFile.delete(),
    ]);
  }

  Map<String, String> _getResponseHeaders() {
    return {
      if (eTag != null) HttpHeaders.etagHeader: eTag!,
      if (expiredTime != null) HttpHeaders.expiresHeader: HttpDate.format(expiredTime!),
      if (contentLength != null) HttpHeaders.contentLengthHeader: contentLength.toString(),
      if (lastModified != null) HttpHeaders.lastModifiedHeader: HttpDate.format(lastModified!),
      // @TODO: for debug usage.
      "x-kraken-cache": "from disk cache",
    };
  }

  Future<HttpClientResponse?> toHttpClientResponse() async {
    final File indexFile = File(path.join(cacheDirectory, hash));
    final bool isIndexExist = await indexFile.exists();
    if (!isIndexExist) {
      return null;
    }

    final File blobFile = File(path.join(cacheDirectory, blobFilename));
    final bool isBlobExist = await blobFile.exists();
    if (!isBlobExist) {
      return null;
    }

    return HttpClientStreamResponse(
      blobFile.openRead(),
      statusCode: HttpStatus.ok,
      reasonPhrase: "From Cache",
      responseHeaders: _getResponseHeaders(),
    );
  }
}
