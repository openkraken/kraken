/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/painting.dart';


/// This class allows user to override default implement of image loading,
///
/// [ImageProviderFactory] define the interface, will be used by [CSSUrl] create
/// ImageProvider, which used by [ImageElement] to render image.
/// [ImageType] defines the types of different image source.
/// use [setCustomImageProviderFactory] override default ImageProviderFactory
///
/// The ImageProviderFactory uses to render image by following steps:
/// 1. ImageElement creates CSSUrl.
/// 2. CSSUrl parses url & get corresponding ImageProviderFactory of ImageType.
/// 3. CSSUrl creates ImageProvider by corresponding ImageProviderFactory with url & param.
/// 4. ImageElement uses created ImageProvider to render Image.

typedef ImageProviderFactory = ImageProvider Function(String url, [dynamic param]);

/// defines the types of supported image source.
/// [ImageType] is used to map url to corresponding ImageProviderFactory
enum ImageType {
  /// Indicate image source is network and require implement can auto cache to storage.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [defaultCachedNetImageProviderFactory].
  /// will be called when [url] startsWith '//' ,'http://'，'https://'.
  /// [param] will be [bool], the value is true.
  cachedNetworkImage,

  /// Indicate another image source is network, require to get image immediately from network without cache.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [defaultUncachedNetworkImageProviderFactory]
  /// will be called when [url] startsWith '//' ,'http://'，'https://'
  /// [param] will be [bool], the value is false.
  uncachedNetworkImage,

  /// Indicate image source is file path
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [defaultFileImageProviderFactory]
  /// will be called when [url] startsWith 'file://'
  /// [param] will be type [File]
  fileImage,

  /// Indicate image source is raw data.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [defaultDataImageProviderFactory]
  /// will be called when [url] startsWith 'data://'
  /// [param]  will be [Uint8List], value is the content part of the data URI as bytes,
  /// which is converted by [UriData.contentAsBytes].
  dataImage,

  /// Indicate image source is blob path.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation is [defaultBlobImageProviderFactory]
  /// [blobPath] @TODO
  blobImage,

  /// Indicate image source is not any of below.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation is [defaultFallbackImageProvider]
  /// Current, this type only has asset image source, [fallbackImage] should treat as asset image.
  fallbackImage
}

ImageProviderFactory _cachedNetworkImageProviderFactory = defaultCachedNetImageProviderFactory;
ImageProviderFactory _uncachedNetworkImageProviderFactory = defaultUncachedNetworkImageProviderFactory;
ImageProviderFactory _fileImageProviderFactory = defaultFileImageProviderFactory;
ImageProviderFactory _dataImageProviderFactory = defaultDataImageProviderFactory;
ImageProviderFactory _blobImageProviderFactory = defaultBlobImageProviderFactory;
ImageProviderFactory _fallbackImageProviderFactory = defaultFallbackImageProvider;

ImageProviderFactory getImageProviderFactory(ImageType imageType) {
  switch (imageType) {
    case ImageType.cachedNetworkImage:
      return _cachedNetworkImageProviderFactory;
    case ImageType.uncachedNetworkImage:
      return _uncachedNetworkImageProviderFactory;
    case ImageType.fileImage:
      return _fileImageProviderFactory;
    case ImageType.dataImage:
      return _dataImageProviderFactory;
    case ImageType.blobImage:
      return _blobImageProviderFactory;
    case ImageType.fallbackImage:
    default:
      return _fallbackImageProviderFactory;
  }
}

void setCustomImageProviderFactory(ImageType imageType, ImageProviderFactory customImageProviderFactory) {
  if (customImageProviderFactory != null) {
    switch (imageType) {
      case ImageType.cachedNetworkImage:
        _cachedNetworkImageProviderFactory = customImageProviderFactory;
        break;
      case ImageType.uncachedNetworkImage:
        _uncachedNetworkImageProviderFactory = customImageProviderFactory;
        break;
      case ImageType.fileImage:
        _fileImageProviderFactory = customImageProviderFactory;
        break;
      case ImageType.dataImage:
        _dataImageProviderFactory = customImageProviderFactory;
        break;
      case ImageType.blobImage:
        _blobImageProviderFactory = customImageProviderFactory;
        break;
      case ImageType.fallbackImage:
      default:
        _fallbackImageProviderFactory = customImageProviderFactory;
        break;
    }
  }
}

/// default ImageProviderFactory implementation of [ImageType.cachedNetworkImage]
ImageProvider defaultCachedNetImageProviderFactory(String url, [dynamic param]) {
  return CachedNetworkImage(url);
}

/// default ImageProviderFactory implementation of [ImageType.uncachedNetworkImage]
ImageProvider defaultUncachedNetworkImageProviderFactory(String url, [dynamic param]) {
  return NetworkImage(url);
}

/// default ImageProviderFactory implementation of [ImageType.fileImage]
ImageProvider defaultFileImageProviderFactory(String rawPath, [dynamic param]) {
  ImageProvider _imageProvider = null;
  if(param is File){
    _imageProvider = FileImage(param);
  }
  return _imageProvider;
}

/// default ImageProviderFactory implementation of [ImageType.dataImage].
ImageProvider defaultDataImageProviderFactory(String uriDataPath, [dynamic param]) {
  ImageProvider _imageProvider = null;
  if (param is Uint8List) {
    _imageProvider = MemoryImage(param);
  }
  return _imageProvider;
}

/// default ImageProviderFactory implementation of [ImageType.blobImage].
ImageProvider defaultBlobImageProviderFactory(String blobPath, [dynamic param]) {
  // @TODO: support blob file url
  return null;
}

/// default ImageProviderFactory implementation of [ImageType.fallbackImage].
ImageProvider defaultFallbackImageProvider(String rawUrl, [dynamic param]) {
  return AssetImage(rawUrl);
}
