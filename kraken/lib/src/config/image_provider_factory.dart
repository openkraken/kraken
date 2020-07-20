/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:kraken/element.dart';
import 'package:kraken/src/painting/cached_network_image.dart';
import 'dart:io';

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
/// | type [cacheNetImage]    | startsWith '//' ,'http://'，'https://' | cacheNetImage [param]may has cache store、auto
/// | type [noCacheNetImage]  |                                        | [param]may has cache
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
  cacheNetImage,
  noCacheNetImage,
  fileImage,
  dataImage,
  blobImage,
  fallbackImage
}

///
/// create image from data
///
/// [uriDataPath] startsWith 'data://''
/// desc:
/// * Data URL:  https://tools.ietf.org/html/rfc2397
/// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
///
ImageProvider defaultCachedNetImageProviderFactory(String url, [dynamic param]) {
  return CachedNetworkImage(url);
}

ImageProvider defaultNoCachedNetworkImageProviderFactory(String url, [dynamic param]) {
  return NetworkImage(url);
}

///
/// create image from network
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
/// create image from data
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
/// create image from network
///
/// [blobPath] @TODO
///
ImageProvider defaultBlobImageProvider(String blobPath, [dynamic param]) {
  // @TODO: support blob file url
  return null;
}

///
/// create image Fallback to image
/// maybe assetimage
/// [url] image from JSRuntime
///
ImageProvider defaultFallbackImageProvider(String rawUrl, [dynamic param]) {
  return AssetImage(rawUrl);
}
