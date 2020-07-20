import 'package:flutter/painting.dart';
import 'package:kraken/element.dart';
import 'package:kraken/src/painting/cached_network_image.dart';
import 'dart:io';

///
/// [ImageProviderAdapter] allow change Default ImageProvider for
///
/// can be replace by call [ImageElement.setCustomImageProviderAdapter]
///
/// [url] startsWith '//' ,'http://'，'https://'
/// [cache] cache maybe store、auto
///
abstract class ImageProviderAdapter {
  ///
  /// create image from after JSRuntime Converted
  ///
  /// [params] constains following types
  ///  params has [cache] maybe store、auto default is auto
  ///
  /// [url] constains following types
  /// ----------------------------------------------------------------------------------------------------
  /// | type                  | example                                |
  /// ----------------------------------------------------------------------------------------------------
  /// | type net              | startsWith '//' ,'http://'，'https://' | [params]may has cache
  /// |                       |                                        | cache maybe store、auto; default is auto
  /// ----------------------------------------------------------------------------------------------------
  /// | type rawPath          | startsWith 'file://''                  |
  /// ----------------------------------------------------------------------------------------------------
  /// | type uriDataPath      | startsWith 'data://''                  | Data URL:  https://tools.ietf.org/html/rfc2397
  /// |                       |                                        | dataurl := "data:" [ mediatype ] [ ";base64" ] "," data
  /// ----------------------------------------------------------------------------------------------------
  /// | type fallbackImage    | image from JSRuntime                   | maybe assetimage
  /// ----------------------------------------------------------------------------------------------------
  ///
  ///
  ///
  ImageProvider getImageProvider(String url, [dynamic params]);
}

///
/// DefaultImageProvider
///
class DefaultImageProviderAdapter implements ImageProviderAdapter {
  @override
  ImageProvider getImageProvider(String _rawInput, [dynamic params]) {
    ImageProvider _value;
    if (_rawInput.startsWith('//') || _rawInput.startsWith('http://') || _rawInput.startsWith('https://')) {
      var url = _rawInput.startsWith('//') ? 'https:' + _rawInput : _rawInput;
      String cache = params != null && params['cache'] != null ? params['cache'] ?? 'auto' : 'auto';
      _value = _createNetworkImage(url, cache: cache);
    } else if (_rawInput.startsWith('file://')) {
      _value = _createFileImage(_rawInput);
    } else if (_rawInput.startsWith('data:')) {
      _value = _createMemoryImage(_rawInput);
    } else if (_rawInput.startsWith('blob:')) {
      _value = _createBlobImage(_rawInput);
    } else {
      _value = _createFallbackImage(_rawInput);
    }
    return _value;
  }

  ///
  /// create image from data
  ///
  /// [uriDataPath] startsWith 'data://''
  /// desc:
  /// * Data URL:  https://tools.ietf.org/html/rfc2397
  /// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
  ///
  ImageProvider _createNetworkImage(String url, {String cache}) {
    // @TODO: caching also works after image downloaded
    ImageProvider _value;
    if (cache == 'store' || cache == 'auto') {
      _value = CachedNetworkImage(url);
    } else {
      _value = NetworkImage(url);
    }
    return _value;
  }

  ///
  /// create image from network
  ///
  /// [rawPath] startsWith 'file://''
  ///
  ImageProvider _createFileImage(String rawPath) {
    return FileImage(File.fromUri(Uri.parse(rawPath)));
  }

  ///
  /// create image from data
  ///
  /// [uriDataPath] startsWith 'data://''
  /// desc:
  /// * Data URL:  https://tools.ietf.org/html/rfc2397
  /// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
  ///
  ImageProvider _createMemoryImage(String uriDataPath) {
    ImageProvider _value = null;
    UriData data = UriData.parse(uriDataPath);
    if (data.isBase64) {
      _value = MemoryImage(data.contentAsBytes());
    }
    return _value;
  }

  ///
  /// create image from network
  ///
  /// [blobPath] @TODO
  ///
  ImageProvider _createBlobImage(String blobPath) {
    // @TODO: support blob file url
    return null;
  }

  ///
  /// create image Fallback to image
  /// maybe assetimage
  /// [url] image from JSRuntime
  ///
  ImageProvider _createFallbackImage(String rawUrl) {
    return AssetImage(rawUrl);
  }
}
