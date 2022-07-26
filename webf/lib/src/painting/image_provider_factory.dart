/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/src/module/navigator.dart';

/// This class allows user to customize Kraken's image loading.

class ImageProviderParams {
  int? cachedWidth;
  int? cachedHeight;
  BoxFit objectFit = BoxFit.fill;

  ImageProviderParams({this.cachedWidth, this.cachedHeight, required this.objectFit});
}

class CachedNetworkImageProviderParams extends ImageProviderParams {
  int? contextId;

  CachedNetworkImageProviderParams(this.contextId,
      {int? cachedWidth, int? cachedHeight, BoxFit objectFit = BoxFit.fill})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit);
}

class FileImageProviderParams extends ImageProviderParams {
  File file;

  FileImageProviderParams(this.file,
      {int? cachedWidth, int? cachedHeight, BoxFit objectFit = BoxFit.fill})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit);
}

class DataUrlImageProviderParams extends ImageProviderParams {
  Uint8List bytes;

  DataUrlImageProviderParams(this.bytes,
      {int? cachedWidth, int? cachedHeight, BoxFit objectFit = BoxFit.fill})
      : super(cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit);
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

ImageType parseImageUrl(Uri resolvedUri, {String cache = 'auto'}) {
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
  } else if (resolvedUri.isScheme('ASSETS')) {
    return ImageType.assets;
  } else {
    throw FlutterError('Uri must have it\'s scheme. $resolvedUri');
  }
}

ImageProvider? getImageProvider(Uri resolvedUri,
    {int? contextId, cache = 'auto', BoxFit objectFit = BoxFit.fill, int? cachedWidth, int? cachedHeight}) {
  ImageType imageType = parseImageUrl(resolvedUri, cache: cache);
  ImageProviderFactory factory = _getImageProviderFactory(imageType);

  switch (imageType) {
    case ImageType.cached:
      return factory(
          resolvedUri,
          CachedNetworkImageProviderParams(contextId,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit));
    case ImageType.network:
      return factory(
          resolvedUri,
          CachedNetworkImageProviderParams(contextId,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit));
    case ImageType.file:
      File file = File.fromUri(resolvedUri);
      return factory(
          resolvedUri,
          FileImageProviderParams(file,
              cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit));
    case ImageType.dataUrl:
      // Data URL:  https://tools.ietf.org/html/rfc2397
      // dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
      UriData data = UriData.fromUri(resolvedUri);
      if (data.isBase64) {
        return factory(
            resolvedUri,
            DataUrlImageProviderParams(data.contentAsBytes(),
                cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit));
      }
      return null;
    case ImageType.blob:
      // TODO: support blob data type
      return null;
    case ImageType.assets:
      return factory(
          resolvedUri,
          ImageProviderParams(
              cachedWidth: cachedWidth, cachedHeight: cachedHeight, objectFit: objectFit));
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

class KrakenResizeImage extends ResizeImage {
  KrakenResizeImage(
    ImageProvider<Object> imageProvider, {
    int? width,
    int? height,
    this.objectFit,
  }) : super(imageProvider, width: width, height: height);

  BoxFit? objectFit;

  static ImageProvider<Object> resizeIfNeeded(
      int? cacheWidth, int? cacheHeight, BoxFit? objectFit, ImageProvider provider) {
    if (cacheWidth != null || cacheHeight != null) {
      return KrakenResizeImage(provider,
          width: cacheWidth, height: cacheHeight, objectFit: objectFit);
    }
    return provider;
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, key, ImageErrorListener handleError) {
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

    double naturalWidth = descriptor.width.toDouble();
    double naturalHeight = descriptor.height.toDouble();

    int? targetWidth;
    int? targetHeight;

    // Image will be resized according to its aspect radio if object-fit is not fill.
    // https://www.w3.org/TR/css-images-3/#propdef-object-fit
    if (cacheWidth != null && cacheHeight != null) {
      // When targetWidth or targetHeight is not set at the same time,
      // image will be resized according to its aspect radio.
      // https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/box_fit.dart#L152
      if (objectFit == BoxFit.contain) {
        if (cacheWidth / cacheHeight > naturalWidth / naturalHeight) {
          targetHeight = cacheHeight;
        } else {
          targetWidth = cacheWidth;
        }

      // Resized image should maintain its intrinsic aspect radio event if object-fit is fill
      // which behaves just like object-fit cover otherwise the cached resized image with
      // distorted aspect ratio will not work when object-fit changes to not fill.
      } else if (objectFit == BoxFit.fill || objectFit == BoxFit.cover) {
        if (cacheWidth / cacheHeight > naturalWidth / naturalHeight) {
          targetWidth = cacheWidth;
        } else {
          targetHeight = cacheHeight;
        }

      // Image should maintain its aspect radio and not resized if object-fit is none.
      } else if (objectFit == BoxFit.none) {
        targetWidth = descriptor.width;
        targetHeight = descriptor.height;

      // If image size is smaller than its natural size when object-fit is contain,
      // scale-down is parsed as none, otherwise parsed as contain.
      } else if (objectFit == BoxFit.scaleDown) {
        if (cacheWidth / cacheHeight > naturalWidth / naturalHeight) {
          if (cacheHeight > descriptor.height * window.devicePixelRatio) {
            targetWidth = descriptor.width;
            targetHeight = descriptor.height;
          } else {
            targetHeight = cacheHeight;
          }
        } else {
          if (cacheWidth > descriptor.width * window.devicePixelRatio) {
            targetWidth = descriptor.width;
            targetHeight = descriptor.height;
          } else {
            targetWidth = cacheWidth;
          }
        }
      }
    } else {
      targetWidth = cacheWidth;
      targetHeight = cacheHeight;
    }

    // Resize image size should not be larger than its natural size.
    if (!allowUpscaling) {
      if (targetWidth != null && targetWidth > descriptor.width * window.devicePixelRatio) {
        targetWidth = descriptor.width;
      }
      if (targetHeight != null && targetHeight > descriptor.height * window.devicePixelRatio) {
        targetHeight = descriptor.height;
      }
    }

    return descriptor.instantiateCodec(
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }
}

/// default ImageProviderFactory implementation of [ImageType.cached]
ImageProvider defaultCachedProviderFactory(
    Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
    params.cachedWidth,
    params.cachedHeight,
    params.objectFit,
    CachedNetworkImage(uri.toString(),
        contextId: (params as CachedNetworkImageProviderParams).contextId)
  );
}

/// default ImageProviderFactory implementation of [ImageType.network]
ImageProvider defaultNetworkProviderFactory(
    Uri uri, ImageProviderParams params) {
  NetworkImage networkImage = NetworkImage(uri.toString(), headers: {
    HttpHeaders.userAgentHeader: NavigatorModule.getUserAgent(),
    HttpHeaderContext:
        (params as CachedNetworkImageProviderParams).contextId.toString(),
  });
  return KrakenResizeImage.resizeIfNeeded(
    params.cachedWidth,
    params.cachedHeight,
    params.objectFit,
    networkImage
  );
}

/// default ImageProviderFactory implementation of [ImageType.file]
ImageProvider? defaultFileProviderFactory(Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
    params.cachedWidth,
    params.cachedHeight,
    params.objectFit,
    FileImage((params as FileImageProviderParams).file)
  );
}

/// default ImageProviderFactory implementation of [ImageType.dataUrl].
ImageProvider? defaultDataUrlProviderFactory(
    Uri uri, ImageProviderParams params) {
  return KrakenResizeImage.resizeIfNeeded(
    params.cachedWidth,
    params.cachedHeight,
    params.objectFit,
    MemoryImage((params as DataUrlImageProviderParams).bytes)
  );
}

/// default ImageProviderFactory implementation of [ImageType.blob].
ImageProvider? defaultBlobProviderFactory(Uri uri, ImageProviderParams params) {
  // @TODO: support blob file url
  return null;
}

/// default ImageProviderFactory implementation of [ImageType.assets].
ImageProvider defaultAssetsProvider(Uri uri, ImageProviderParams params) {
  final String assetName = AssetsBundle.getAssetName(uri);
  return KrakenResizeImage.resizeIfNeeded(
    params.cachedWidth,
    params.cachedHeight,
    params.objectFit,
    AssetImage(assetName)
  );
}
