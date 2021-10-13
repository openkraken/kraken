/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import 'http_client_response.dart';

class HttpCacheObject {
  static const _httpHeaderCacheHits = 'cache-hits';
  static const _httpCacheHit = 'HIT';

  // The cached url of resource.
  String url;

  // When the file is out-of-date
  DateTime? expiredTime;

  // The eTag provided by the server.
  String? eTag;

  // The length of content.
  int? contentLength;

  // When file was last used.
  DateTime? lastUsed;

  // When file was last modified.
  DateTime? lastModified;

  // The initial origin when caches.
  String? origin;

  // The directory to store cache file.
  final String cacheDirectory;

  // The storage filename.
  final int hash;

  // The index file.
  final File _file;

  // The blob.
  HttpCacheObjectBlob _blob;

  // Whether cache object is sync with file.
  bool _valid = false;
  bool get valid => _valid;

  HttpCacheObject(this.url, this.cacheDirectory, {
    this.expiredTime,
    this.eTag,
    this.contentLength,
    this.lastUsed,
    this.lastModified,
    this.origin,
    required this.hash,
  }) : _file = File(path.join(cacheDirectory, '$hash')),
        _blob = HttpCacheObjectBlob(path.join(cacheDirectory, '$hash-blob'));

  factory HttpCacheObject.fromResponse(String url, HttpClientResponse response, String cacheDirectory) {
    DateTime expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
    String? eTag = response.headers.value(HttpHeaders.etagHeader);
    int contentLength = response.headers.contentLength;
    String? lastModifiedValue = response.headers.value(HttpHeaders.lastModifiedHeader);
    DateTime? lastModified = lastModifiedValue != null
        ? DateTime.tryParse(lastModifiedValue)
        : null;

    return HttpCacheObject(url, cacheDirectory,
      eTag: eTag,
      expiredTime: expiredTime,
      contentLength: contentLength,
      hash: url.hashCode,
      lastModified: lastModified,
      lastUsed: DateTime.now(),
    );
  }

  static final DateTime alwaysExpired = DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime _getExpiredTimeFromResponseHeaders(HttpHeaders headers) {
    // CacheControl's multiple directives are comma-separated.
    List<String>? cacheControls = headers[HttpHeaders.cacheControlHeader];
    if (cacheControls != null) {
      for (String cacheControl in cacheControls) {
        cacheControl = cacheControl.toLowerCase();

        if (cacheControl.startsWith('no-store')) {
          // Will never save cache.
          return alwaysExpired;
        } else if (cacheControl.startsWith('no-cache')) {
          String? eTag = headers.value(HttpHeaders.etagHeader);
          if (eTag == null) {
            // Since no-cache is determined, eTag must be provided to compare.
            return alwaysExpired;
          }
        } else if (cacheControl.startsWith('max-age=')) {
          int maxAge = int.tryParse(cacheControl.substring(8)) ?? 0;
          return DateTime.now().add(Duration(seconds: maxAge));
        }
      }
    }

    return headers.expires ?? alwaysExpired;
  }

  static int NetworkType = 0x01;
  static int Reserved = 0x00;

  // This method write bytes in [Endian.little] order.
  // Reference: https://en.wikipedia.org/wiki/Endianness
  static void writeString(BytesBuilder bytesBuilder, String str, int size) {
    final int strLength = str.length;
    for (int i = 0; i < size; i++) {
      bytesBuilder.addByte(strLength >> (i * 8) & 0xff);
    }

    bytesBuilder.add(str.codeUnits);
  }

  static void writeInteger(BytesBuilder bytesBuilder, int data, int size) {
    for (int i = 0; i < size; i++) {
      bytesBuilder.addByte(data >> (i * 8) & 0xff);
    }
  }

  bool isDateTimeValid() => expiredTime != null && expiredTime!.isAfter(DateTime.now());

  // Validate the cache-control and expires.
  bool hitLocalCache(HttpClientRequest request) {
    return valid && isDateTimeValid();
  }

  /// Read the index file.
  Future<void> read() async {
    if (_valid) return;
    final bool isIndexFileExist = await _file.exists();
    if (!isIndexFileExist) {
      // Index file not exist, dispose.
      return;
    }

    try {
      Uint8List bytes = await _file.readAsBytes();
      ByteData byteData = bytes.buffer.asByteData();
      int index = 0;

      // Reserved units.
      index += 4;

      // Read expiredTime.
      expiredTime = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
      index += 8;

      // Read lastUsed.
      lastUsed = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
      index += 8;

      // Read lastModified.
      lastModified = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
      index += 8;

      // Read contentLength.
      contentLength = byteData.getUint32(index, Endian.little);
      index += 4;

      // Invalid cache blob size, mark as invalid.
      if (await _blob.length != contentLength) {
        _valid = false;
        return;
      }

      // Read url.
      int urlLength = byteData.getUint32(index, Endian.little);
      index += 4;

      Uint8List urlValue = bytes.sublist(index, index + urlLength);
      url = utf8.decode(urlValue);
      index += urlLength;

      // Read eTag.
      int eTagLength = byteData.getUint16(index, Endian.little);
      index += 2;

      Uint8List eTagValue = bytes.sublist(index, index + eTagLength);
      eTag = utf8.decode(eTagValue);

      _valid = true;
    } catch (message, stackTrace) {
      print('Error while reading cache object for $url');
      print('\n$message');
      print('\n$stackTrace');

      // Remove index file while invalid.
      await remove();
    }
  }

  Future<void> writeIndex() async {
    final BytesBuilder bytesBuilder = BytesBuilder();

    // Index bytes format:
    // | Type x 1B | Reserved x 3B | ExpiredTimeStamp x 8B |
    bytesBuilder.add([
      NetworkType, Reserved, Reserved, Reserved,
    ]);

    // | ExpiredTimeStamp x 8 |
    final int expiredTimeStamp = (expiredTime ?? alwaysExpired).millisecondsSinceEpoch;
    writeInteger(bytesBuilder, expiredTimeStamp, 8);

    // | LastUsedTimeStamp x 8 |
    final int lastUsedTimeStamp = (lastUsed ?? DateTime.now()).millisecondsSinceEpoch;
    writeInteger(bytesBuilder, lastUsedTimeStamp, 8);

    // | LastModifiedTimeStamp x 8 |
    final int lastModifiedTimestamp = (lastModified ?? alwaysExpired).millisecondsSinceEpoch;
    writeInteger(bytesBuilder, lastModifiedTimestamp, 8);

    // | ContentLength x 4B |
    writeInteger(bytesBuilder, contentLength ?? 0, 4);

    // | Length of url x 4B | URL Payload x N |
    writeString(bytesBuilder, url, 4);

    // | Length of eTag x 2B | eTag payload x N |
    // Store url length, 4B max represents (0x)ffffffff -> 4294967295 (4GB)
    writeString(bytesBuilder, eTag ?? '', 2);

    // The index file will not be TOO LARGE,
    // so take bytes at one time.
    await _file.writeAsBytes(bytesBuilder.takeBytes(), flush: true);

    _valid = true;
  }

  EventSink<List<int>> openBlobWrite() {
    return _blob;
  }

  // Remove all the cached files.
  Future<void> remove() async {
    if (await _file.exists()) {
      await _file.delete();
    }
    await _blob.remove();

    _valid = false;
  }

  Map<String, String> _getResponseHeaders() {
    return {
      if (eTag != null) HttpHeaders.etagHeader: eTag!,
      if (expiredTime != null) HttpHeaders.expiresHeader: HttpDate.format(expiredTime!),
      if (contentLength != null) HttpHeaders.contentLengthHeader: contentLength.toString(),
      if (lastModified != null) HttpHeaders.lastModifiedHeader: HttpDate.format(lastModified!),
      _httpHeaderCacheHits: _httpCacheHit,
    };
  }

  Future<bool> get _exists async {
    final bool isIndexExist = await _file.exists();
    if (!isIndexExist) {
      return false;
    }

    return await _blob.exists();
  }

  Future<HttpClientResponse?> toHttpClientResponse() async {
    if (!await _exists) {
      return null;
    }

    return HttpClientStreamResponse(
      _blob.openRead(),
      statusCode: HttpStatus.ok,
      responseHeaders: _getResponseHeaders(),
    );
  }

  Future<Uint8List?> toBinaryContent() async {
    if (!await _exists) {
      return null;
    }

    // Open read.
    Stream<List<int>> blobStream = _blob.openRead();

    // Consume stream.
    Completer<Uint8List> completer = Completer<Uint8List>();
    ByteConversionSink sink = ByteConversionSink.withCallback(
            (bytes) => completer.complete(Uint8List.fromList(bytes)));
    blobStream.listen(
        sink.add,
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true);

    return completer.future;
  }

  Future<void> updateIndex(HttpClientResponse response) async {
    bool indexChanged = false;

    // Update eTag.
    String? remoteEtag = response.headers.value(HttpHeaders.etagHeader);
    if (remoteEtag != null && remoteEtag != eTag) {
      eTag = remoteEtag;
      indexChanged = true;
    }

    // Update lastModified
    String? remoteLastModifiedString = response.headers.value(HttpHeaders.lastModifiedHeader);
    if (remoteLastModifiedString != null) {
      DateTime? remoteLastModified = DateTime.tryParse(remoteLastModifiedString);
      if (remoteLastModified != null
          && (lastModified == null || !remoteLastModified.isAtSameMomentAs(lastModified!))) {
        lastModified = remoteLastModified;
        indexChanged = true;
      }
    }

    // Update expires.
    if (response.headers.expires != null) {
      expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
      indexChanged = true;
    }

    // Update content length.
    int contentLength = response.headers.contentLength;
    if (!contentLength.isNegative && contentLength != this.contentLength) {
      this.contentLength = contentLength;
      indexChanged = true;
    }

    // Update index.
    if (indexChanged) {
      await writeIndex();
    }
  }
}

class HttpCacheObjectBlob extends EventSink<List<int>> {
  final String path;
  final File _file;
  IOSink? _writer;

  HttpCacheObjectBlob(this.path) : _file = File(path);

  // The length of the file.
  Future<int> get length async {
    if (await exists()) {
      return await _file.length();
    } else {
      return 0;
    }
  }

  @override
  void add(List<int> data) {
    _writer ??= _file.openWrite();
    _writer!.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _writer?.addError(error, stackTrace);
    print('Error while writing to cache blob, $error');
    if (stackTrace != null) {
      print('\n$stackTrace');
    }
  }

  @override
  void close() async {
    // Ensure buffer has been written.
    await _writer?.flush();
    await _writer?.close();

    _writer = null;
  }

  Future<bool> exists() {
    return _file.exists();
  }

  Stream<List<int>> openRead() {
    return _file.openRead();
  }

  Future<void> remove() async {
    if (await _file.exists()) {
      await _file.delete();
    }
    close();
  }
}
