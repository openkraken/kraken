/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/foundation.dart';

class CachedNetworkImageKey {
  const CachedNetworkImageKey({
    required this.url,
    required this.scale
  });

  final String url;

  final double scale;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is CachedNetworkImageKey
        && other.url == url
        && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(url, scale);
}

class CachedNetworkImage extends ImageProvider<CachedNetworkImageKey> {
  const CachedNetworkImage(this.url, {this.scale = 1.0, this.headers, this.contextId});

  final String url;

  final double scale;

  final int? contextId;

  final Map<String, String>? headers;

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-CSSLength` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) client = debugNetworkImageHttpClientProvider!();
      return true;
    }());
    return client;
  }

  Future<Uint8List> _getRawImageBytes(CachedNetworkImageKey key, StreamController<ImageChunkEvent> chunkEvents) async {
    HttpCacheController cacheController = HttpCacheController.instance(
        getOrigin(getEntrypointUri(contextId)));

    Uri uri = Uri.parse(url);
    Uint8List? bytes;

    if (HttpCacheController.mode != HttpCacheMode.NO_CACHE) {
      try {
        HttpCacheObject? cacheObject = await cacheController.getCacheObject(uri);
        bytes = await cacheObject.toBinaryContent();
      } catch (error, stackTrace) {
        print('Error while reading cache, $error\n$stackTrace');
      }
    }

    // Fallback to network
    bytes ??= await _fetchImageBytes(key, chunkEvents, cacheController);

    return bytes;
  }

  Future<Codec> _loadAsync(
      CachedNetworkImageKey key, DecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    Uint8List bytes = await _getRawImageBytes(key, chunkEvents);
    return decode(bytes);
  }

  Future<Uint8List> _fetchImageBytes(CachedNetworkImageKey key,
      StreamController<ImageChunkEvent> chunkEvents,
      HttpCacheController cacheController) async {
    try {
      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);

      HttpCacheObject cacheObject = HttpCacheObject.fromResponse(
          key.url,
          response,
          (await HttpCacheController.getCacheDirectory()).path);
      cacheController.putObject(resolved, cacheObject);

      HttpClientResponse _response = HttpClientCachedResponse(response, cacheObject);
      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        _response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      if (bytes.lengthInBytes == 0) throw Exception('Image from network is an empty file: $resolved');

      return bytes;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  Future<CachedNetworkImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedNetworkImageKey>(CachedNetworkImageKey(
      url: url,
      scale: scale
    ));
  }

  @override
  void resolveStreamForKey(
    ImageConfiguration configuration,
    ImageStream stream,
    CachedNetworkImageKey key,
    ImageErrorListener handleError,
  ) {
    // Something managed to complete the stream, or it's already in the image
    // cache. Notify the wrapped provider and expect it to behave by not
    // reloading the image since it's already resolved.
    // Do this even if the context has gone out of the tree, since it will
    // update LRU information about the cache. Even though we never showed the
    // image, it was still touched more recently.
    // Do this before checking scrolling, so that if the bytes are available we
    // render them even though we're scrolling fast - there's no additional
    // allocations to do for texture memory, it's already there.
    if (stream.completer != null || PaintingBinding.instance!.imageCache!.containsKey(key)) {
      super.resolveStreamForKey(configuration, stream, key, handleError);
      return;
    }
    // Something still wants this image, but check if the context is scrolling
    // too fast before scheduling work that might never show on screen.
    // Try to get to end of the frame callbacks of the next frame, and then
    // check again.
    if (_recommendDeferredLoading()) {
      // @TODO!
      count++;
      print('delay $count');
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        scheduleMicrotask(() => resolveStreamForKey(configuration, stream, key, handleError));
      });
      return;
    }
    // We are in the tree, we're not scrolling too fast, the cache doesn't
    // have our image, and no one has otherwise completed the stream.  Go.
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  // Return true if recommend deferred to load the file.
  bool _recommendDeferredLoading() {
    return false;
  }

  static int count = 0;

  @override
  ImageStreamCompleter load(CachedNetworkImageKey key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode, chunkEvents),
        chunkEvents: chunkEvents.stream,
        scale: key.scale,
        informationCollector: () {
          return <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<CachedNetworkImageKey>('Image key', key),
          ];
        });
  }
}
