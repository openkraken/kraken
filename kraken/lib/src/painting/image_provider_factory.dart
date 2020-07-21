/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:kraken/element.dart';
import 'package:kraken/painting.dart';


///
/// [ImageElement] allow change Default ImageProvider for
///
/// can be replace by call [ImageElement.setCustomImageProviderFactory]
///
/// [url] startsWith '//' ,'http://'，'https://'
/// [cache] cache maybe store、auto
///
/// only
///

typedef ImageProviderFactory = ImageProvider Function(String url, [dynamic param]);

///
/// create image from after JSRuntime Converted
///
/// [param] constains following types
///  params has [cache] maybe store、auto default is auto
///
/// [url] constains following types
/// ----------------------------------------------------------------------------------------------------
/// | type                    | example                                |
/// ----------------------------------------------------------------------------------------------------
/// | type [cacheNetworkImage]    | startsWith '//' ,'http://'，'https://' | cacheNetImage [param]may has cache store、auto
/// | type [nocacheNetworkImage]  |                                        | [param]may has cache
/// |                         |                                        | cache maybe store、auto; default is auto
/// ----------------------------------------------------------------------------------------------------
/// | type [fileImage]        | startsWith 'file://''                  | [param] file => [File]
/// ----------------------------------------------------------------------------------------------------
/// | type [dataImage]        | startsWith 'data://''                  | [param] => [Uint8List]
/// |                         |                                        | Data URL:  https://tools.ietf.org/html/rfc2397
/// |                         |                                        | dataurl := "data:" [ mediatype ] [ ";base64" ] "," data
/// ----------------------------------------------------------------------------------------------------
/// | type [fallbackImage]    | image from JSRuntime                   | maybe assetimage
/// ----------------------------------------------------------------------------------------------------
///
enum ImageType {
  cachedNetworkImage,
  uncachedNetworkImage,
  fileImage,
  dataImage,
  blobImage,
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

///
/// Create image from data
///
/// [uriDataPath] startsWith 'data://''
/// desc:
/// * Data URL:  https://tools.ietf.org/html/rfc2397
/// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
///
ImageProvider defaultCachedNetImageProviderFactory(String url, [dynamic param]) {
  return CachedNetworkImage(url);
}

ImageProvider defaultUncachedNetworkImageProviderFactory(String url, [dynamic param]) {
  return NetworkImage(url);
}

///
/// Create image from network
///
/// [rawPath] startsWith 'file://''
///
ImageProvider defaultFileImageProviderFactory(String rawPath, [dynamic param]) {
  ImageProvider _imageProvider = null;
  if(param is File){
    _imageProvider = FileImage(param);
  }
  return _imageProvider;
}

///
/// Create image from data
///
/// [uriDataPath] startsWith 'data://''
/// desc:
/// * Data URL:  https://tools.ietf.org/html/rfc2397
/// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
///
ImageProvider defaultDataImageProviderFactory(String uriDataPath, [dynamic param]) {
  ImageProvider _imageProvider = null;
  if (param is Uint8List) {
    _imageProvider = MemoryImage(param);
  }
  return _imageProvider;
}

///
/// Create image from network
///
/// [blobPath] @TODO
///
ImageProvider defaultBlobImageProviderFactory(String blobPath, [dynamic param]) {
  // @TODO: support blob file url
  return null;
}

///
/// create image Fallback to image
/// maybe asset image
/// [url] image from JSRuntime
///
ImageProvider defaultFallbackImageProvider(String rawUrl, [dynamic param]) {
  return AssetImage(rawUrl);
}
