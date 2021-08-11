/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import 'http_client_response.dart';

class HttpCacheObject {
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
  final String hash;

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
  }) : _file = File(path.join(cacheDirectory, hash)),
        _blob = HttpCacheObjectBlob(path.join(cacheDirectory, '$hash-blob'));

  factory HttpCacheObject.fromResponse(String url, HttpClientResponse response, String cacheDirectory) {
    DateTime expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
    String? eTag = response.headers.value(HttpHeaders.etagHeader);
    int contentLength = response.headers.contentLength;
    String? lastModifiedValue = response.headers.value(HttpHeaders.lastModifiedHeader);
    DateTime? lastModified = lastModifiedValue != null
        ? DateTime.tryParse(lastModifiedValue)
        : null;

    // Since md5 is more efficient among other hashing algorithms.
    final String hash = md5.convert(utf8.encode(url)).toString();

    return HttpCacheObject(url, cacheDirectory,
      eTag: eTag,
      expiredTime: expiredTime,
      contentLength: contentLength,
      hash: hash,
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

  static List<int> fromBytes(List<int> list, int size) {
    if (list.length % size != 0) {
      throw ArgumentError('Wrong size');
    }

    final result = <int>[];
    for (var i = 0; i < list.length; i += size) {
      var value = 0;
      for (var j = 0; j < size; j++) {
        var byte = list[i + j];
        final val = (byte & 0xff) << (j * 8);
        value |= val;
      }

      result.add(value);
    }

    return result;
  }

  bool isDateTimeValid() => expiredTime != null && expiredTime!.isAfter(DateTime.now());

  /**
   * Read the index file.
   */
  Future<void> read() async {
    final bool isIndexFileExist = await _file.exists();
    if (!isIndexFileExist) {
      // Index file not exist, dispose.
      return;
    }

    try {
      Uint8List bytes = await _file.readAsBytes();
      int index = 0;

      // Resverd units.
      index += 4;

      // Read expiredTime.
      Uint8List expiredTimestamp = bytes.sublist(index, index + 8);
      expiredTime = DateTime.fromMillisecondsSinceEpoch(fromBytes(expiredTimestamp, 8).single);
      index += 8;

      // Read lastUsed.
      Uint8List lastUsedTimestamp = bytes.sublist(index, index + 8);
      lastUsed = DateTime.fromMillisecondsSinceEpoch(fromBytes(lastUsedTimestamp, 8).single);
      index += 8;

      // Read lastModified.
      Uint8List lastModifiedTimestamp = bytes.sublist(index, index + 8);
      lastModified = DateTime.fromMillisecondsSinceEpoch(fromBytes(lastModifiedTimestamp, 8).single);
      index += 8;

      // Read contentLength.
      contentLength = fromBytes(bytes.sublist(index, index + 4), 4).single;
      index += 4;


      // Read url.
      Uint8List urlLengthValue = bytes.sublist(index, index + 4);
      int urlLength = fromBytes(urlLengthValue, 4).single;
      index += 4;

      Uint8List urlValue = bytes.sublist(index, index + urlLength);
      url = urlValue.toString();
      index += urlLength;

      // Read eTag.
      int eTagLength = fromBytes(bytes.sublist(index, index + 2), 2).single;
      index += 2;

      Uint8List eTagValue = bytes.sublist(index, index + eTagLength);
      eTag = eTagValue.toString();

      _valid = true;
    } catch (message, stackTrace) {
      print('Error while reading cache object for $url');
      print('\n$message');
      print('\n$stackTrace');
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
    // Store url length, 4B max respresents (0x)ffffffff -> 4294967295 (4GB)
    writeString(bytesBuilder, eTag ?? '', 2);

    // The index file will not be TOO LARGE,
    // so take bytes at one time.
    await _file.writeAsBytes(bytesBuilder.takeBytes());

    _valid = true;
  }

  EventSink<List<int>> openBlobWrite() {
    return _blob;
  }

  // Remove all the cached files.
  void remove() async {
    final File indexFile = File(path.join(cacheDirectory, hash));
    await Future.wait([
      indexFile.delete(),
      _blob.remove(),
    ]);
    _valid = false;
  }

  Map<String, String> _getResponseHeaders() {
    return {
      if (eTag != null) HttpHeaders.etagHeader: eTag!,
      if (expiredTime != null) HttpHeaders.expiresHeader: HttpDate.format(expiredTime!),
      if (contentLength != null) HttpHeaders.contentLengthHeader: contentLength.toString(),
      if (lastModified != null) HttpHeaders.lastModifiedHeader: HttpDate.format(lastModified!),
      // @TODO: for debug usage.
      "x-kraken-cache": "From http cache",
    };
  }

  Future<HttpClientResponse?> toHttpClientResponse() async {
    final bool isIndexExist = await _file.exists();
    if (!isIndexExist) {
      return null;
    }

    final bool isBlobExist = await _blob.exists();
    if (!isBlobExist) {
      return null;
    }

    return HttpClientStreamResponse(
      _blob.openRead(),
      statusCode: HttpStatus.ok,
      responseHeaders: _getResponseHeaders(),
    );
  }
}

class HttpCacheObjectBlob extends EventSink<List<int>> {
  final String path;
  final File _file;
  IOSink? _writer;

  HttpCacheObjectBlob(this.path) : _file = File(path);

  @override
  void add(List<int> data) {
    if (_writer == null) {
      _writer = _file.openWrite();
    }
    _writer!.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_writer != null) {
      _writer!.addError(error, stackTrace);
    }
    print('Error while writing to cache blob, $error');
    if (stackTrace != null) {
      print('\n$stackTrace');
    }
  }

  @override
  void close() {
    if (_writer != null) {
      _writer!.close();
    }
  }

  Future<bool> exists() {
    return _file.exists();
  }

  Stream<List<int>> openRead() {
    return _file.openRead();
  }

  Future<void> remove() async {
    await _file.delete();
  }
}
