/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/painting.dart';

/// This class allows user to customize Kraken's image loading.

/// A factory function allow user to build an customized ImageProvider class.
typedef ImageProviderFactory = ImageProvider Function(String url, [dynamic param]);

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

ImageProviderFactory getImageProviderFactory(ImageType imageType) {
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

void setCustomImageProviderFactory(ImageType imageType, ImageProviderFactory customImageProviderFactory) {
  if (customImageProviderFactory != null) {
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
}

/// default ImageProviderFactory implementation of [ImageType.cached]
ImageProvider defaultCachedProviderFactory(String url, [dynamic param]) {
  return CachedNetworkImage(url);
}

/// default ImageProviderFactory implementation of [ImageType.network]
ImageProvider defaultNetworkProviderFactory(String url, [dynamic param]) {
  String contextId;
  if (param is List) contextId = param[0]?.toString();
  NetworkImage networkImage = NetworkImage(url, headers: {
    HttpHeaders.userAgentHeader: getKrakenInfo().userAgent,
    HttpHeaderContextID: contextId,
  });
  return networkImage;
}

/// default ImageProviderFactory implementation of [ImageType.file]
ImageProvider defaultFileProviderFactory(String rawPath, [dynamic param]) {
  ImageProvider _imageProvider;
  if (param is File) {
    _imageProvider = FileImage(param);
  }
  return _imageProvider;
}

/// default ImageProviderFactory implementation of [ImageType.dataUrl].
ImageProvider defaultDataUrlProviderFactory(String uriDataPath, [dynamic param]) {
  ImageProvider _imageProvider;
  if (param is Uint8List) {
    _imageProvider = MemoryImage(param);
  }
  return _imageProvider;
}

/// default ImageProviderFactory implementation of [ImageType.blob].
ImageProvider defaultBlobProviderFactory(String blobPath, [dynamic param]) {
  // @TODO: support blob file url
  return null;
}

/// default ImageProviderFactory implementation of [ImageType.assets].
ImageProvider defaultAssetsProvider(String rawUrl, [dynamic param]) {
  return AssetImage(rawUrl);
}
