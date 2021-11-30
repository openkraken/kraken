/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/painting.dart';

/// This class allows user to customize Kraken's image loading.

class ImageProviderParams {
  int? cachedWidth;
  int? cachedHeight;

  ImageProviderParams({this.cachedWidth, this.cachedHeight});
}

class CachedNetworkImageProviderParams extends ImageProviderParams {
  int? contextId;

  CachedNetworkImageProviderParams(this.contextId,
      {int? cachedWidth, int? cachedHeight})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight);
}

class FileImageProviderParams extends ImageProviderParams {
  File file;

  FileImageProviderParams(this.file, {int? cachedWidth, int? cachedHeight})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight);
}

class DataUrlImageProviderParams extends ImageProviderParams {
  Uint8List bytes;

  DataUrlImageProviderParams(this.bytes, {int? cachedWidth, int? cachedHeight})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight);
}

/// A factory function allow user to build an customized ImageProvider class.
typedef ImageProviderFactory = ImageProvider? Function(
    Uri uri, ImageProviderParams params);

/// defines the types of supported image source.
enum ImageType {
  /// Network image source with memory cache.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [CachedNetworkImage].
  /// will be called when [url] startsWith '//' ,'http://'，'https://'.
  /// [param] will be [bool], the value is true.
  cached,

  /// Network image source.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [NetworkImage]
  /// will be called when [url] startsWith '//' ,'http://'，'https://'
  /// [param] will be [bool], the value is false.
  network,

  /// File path image source
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [FileImage]
  /// will be called when [url] startsWith 'file://'
  /// [param] will be type [File]
  file,

  /// Raw image data source
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [MemoryImage]
  /// will be called when [url] startsWith 'data://'
  /// [param]  will be [Uint8List], value is the content part of the data URI as bytes,
  /// which is converted by [UriData.contentAsBytes].
  dataUrl,

  /// Blob image source which created by URL.createObjectURL()
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation is [defaultBlobProviderFactory]
  /// [blobPath] @TODO
  blob,

  /// Assets image source.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation is [defaultAssetsProvider]
  /// Current, this type only has asset image source, [assets] should treat as asset image.
  assets
}

ImageProviderFactory _cachedProviderFactory = defaultCachedProviderFactory;
ImageProviderFactory _networkProviderFactory = defaultNetworkProviderFactory;
ImageProviderFactory _fileProviderFactory = defaultFileProviderFactory;
ImageProviderFactory _dataUrlProviderFactory = defaultDataUrlProviderFactory;
ImageProviderFactory _blobProviderFactory = defaultBlobProviderFactory;
ImageProviderFactory _assetsProviderFactory = defaultAssetsProvider;

ImageType parseImageUrl(Uri resolvedUri, {cache = 'auto'}) {
  if (resolvedUri.isScheme('HTTP') || resolvedUri.isScheme('HTTPS')) {
    return (cache == 'store' || cache == 'auto')
        ? ImageType.cached
        : ImageType.network;
  } else if (resolvedUri.isScheme('FILE')) {
    return ImageType.file;
  } else if (resolvedUri.isScheme('DATA')) {
    return ImageType.dataUrl;
  } else if (resolvedUri.isScheme('BLOB')) {
    return ImageType.blob;
  } else {
    return ImageType.assets;
  }
}

ImageProvider? getImageProvider(Uri resolvedUri,
    {int? contextId, cache = 'auto', int? cachedWidth, int? cachedHeight}) {
  ImageType imageType = parseImageUrl(resolvedUri, cache: cache);
  ImageProviderFactory factory = _getImageProviderFactory(imageType);

  switch (imageType) {
    case ImageType.cached:
      return factory(
          resolvedUri,
          CachedNetworkImageProviderParams(contextId,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight));
    case ImageType.network:
      return factory(
          resolvedUri,
          CachedNetworkImageProviderParams(contextId,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight));
    case ImageType.file:
      File file = File.fromUri(resolvedUri);
      return factory(
          resolvedUri,
          FileImageProviderParams(file,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight));
    case ImageType.dataUrl:
      // Data URL:  https://tools.ietf.org/html/rfc2397
      // dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
      UriData data = UriData.fromUri(resolvedUri);
      if (data.isBase64) {
        return factory(
            resolvedUri,
            DataUrlImageProviderParams(data.contentAsBytes(),
                cachedWidth: cachedWidth, cachedHeight: cachedHeight));
      }
      return null;
    case ImageType.blob:
      // TODO: support blob data type
      return null;
    case ImageType.assets:
      return factory(
          resolvedUri,
          ImageProviderParams(
              cachedWidth: cachedWidth, cachedHeight: cachedHeight));
  }
}

ImageProviderFactory _getImageProviderFactory(ImageType imageType) {
  switch (imageType) {
    case ImageType.cached:
      return _cachedProviderFactory;
    case ImageType.network:
      return _networkProviderFactory;
    case ImageType.file:
      return _fileProviderFactory;
    case ImageType.dataUrl:
      return _dataUrlProviderFactory;
    case ImageType.blob:
      return _blobProviderFactory;
    case ImageType.assets:
    default:
      return _assetsProviderFactory;
  }
}

void setCustomImageProviderFactory(
    ImageType imageType, ImageProviderFactory customImageProviderFactory) {
  switch (imageType) {
    case ImageType.cached:
      _cachedProviderFactory = customImageProviderFactory;
      break;
    case ImageType.network:
      _networkProviderFactory = customImageProviderFactory;
      break;
    case ImageType.file:
      _fileProviderFactory = customImageProviderFactory;
      break;
    case ImageType.dataUrl:
      _dataUrlProviderFactory = customImageProviderFactory;
      break;
    case ImageType.blob:
      _blobProviderFactory = customImageProviderFactory;
      break;
    case ImageType.assets:
    default:
      _assetsProviderFactory = customImageProviderFactory;
      break;
  }
}

class KrakenResizeImage extends ResizeImage {
  KrakenResizeImage(
    ImageProvider<Object> imageProvider, {
    int? width,
    int? height,
  }) : super(imageProvider, width: width, height: height);

  static ImageProvider<Object> resizeIfNeeded(
      int? cacheWidth, int? cacheHeight, ImageProvider<Object> provider) {
    if (cacheWidth != null || cacheHeight != null) {
      return KrakenResizeImage(provider,
          width: cacheWidth, height: cacheHeight);
    }
    return provider;
  }

  int naturalWidth = 0;
  int naturalHeight = 0;

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream,
      key, ImageErrorListener handleError) {
    // This is an unusual edge case where someone has told us that they found
    // the image we want before getting to this method. We should avoid calling
    // load again, but still update the image cache with LRU information.
    if (stream.completer != null) {
      final ImageStreamCompleter? completer =
          PaintingBinding.instance!.imageCache!.putIfAbsent(
        key,
        () => stream.completer!,
        onError: handleError,
      );
      assert(identical(completer, stream.completer));
      return;
    }
    final ImageStreamCompleter? completer =
        PaintingBinding.instance!.imageCache!.putIfAbsent(
      key,
      () => load(key, instantiateImageCodec),
      onError: handleError,
    );
    if (completer != null) {
      stream.setCompleter(completer);
    }
  }

  Future<Codec> instantiateImageCodec(
    Uint8List bytes, {
    int? cacheWidth,
    int? cacheHeight,
    bool allowUpscaling = false,
  }) async {
    assert(cacheWidth == null || cacheWidth > 0);
    assert(cacheHeight == null || cacheHeight > 0);

    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(bytes);
    final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
    if (!allowUpscaling) {
      if (cacheWidth != null && cacheWidth > descriptor.width) {
        cacheWidth = descriptor.width;
      }
      if (cacheHeight != null && cacheHeight > descriptor.height) {
        cacheHeight = descriptor.height;
      }
    }

    naturalWidth = descriptor.width;
    naturalHeight = descriptor.height;

    return descriptor.instantiateCodec(
      targetWidth: cacheWidth,
      targetHeight: cacheHeight,
    );
  }
}

/// default ImageProviderFactory implementation of [ImageType.cached]
ImageProvider defaultCachedProviderFactory(
    Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
      params.cachedWidth,
      params.cachedHeight,
      CachedNetworkImage(uri.toString(),
          contextId: (params as CachedNetworkImageProviderParams).contextId));
}

/// default ImageProviderFactory implementation of [ImageType.network]
ImageProvider defaultNetworkProviderFactory(
    Uri uri, ImageProviderParams params) {
  NetworkImage networkImage = NetworkImage(uri.toString(), headers: {
    HttpHeaders.userAgentHeader: getKrakenInfo().userAgent,
    HttpHeaderContext:
        (params as CachedNetworkImageProviderParams).contextId.toString(),
  });
  return KrakenResizeImage.resizeIfNeeded(
      params.cachedWidth, params.cachedHeight, networkImage);
}

/// default ImageProviderFactory implementation of [ImageType.file]
ImageProvider? defaultFileProviderFactory(Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(params.cachedWidth,
      params.cachedHeight, FileImage((params as FileImageProviderParams).file));
}

/// default ImageProviderFactory implementation of [ImageType.dataUrl].
ImageProvider? defaultDataUrlProviderFactory(
    Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
      params.cachedWidth,
      params.cachedHeight,
      MemoryImage((params as DataUrlImageProviderParams).bytes));
}

/// default ImageProviderFactory implementation of [ImageType.blob].
ImageProvider? defaultBlobProviderFactory(Uri uri, ImageProviderParams params) {
  // @TODO: support blob file url
  return null;
}

/// default ImageProviderFactory implementation of [ImageType.assets].
ImageProvider defaultAssetsProvider(Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
      params.cachedWidth, params.cachedHeight, AssetImage(uri.toString()));
}
