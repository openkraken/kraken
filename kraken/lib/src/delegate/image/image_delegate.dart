import 'package:flutter/painting.dart';
import 'package:kraken/src/delegate/delegate_config.dart';
import 'package:kraken/src/painting/cached_network_image.dart';
import 'dart:io';

abstract class ImageProviderDelegate {
  ///
  /// create image from network
  ///
  /// [url] startsWith '//' ,'http://'，'https://'
  /// [cache] cache maybe store、auto
  ///
  ImageProvider createNetworkImage(String url, {String cache});

  ///
  /// create image from network
  ///
  /// [rawPath] startsWith 'file://''
  ///
  ImageProvider createFileImage(String rawPath);

  ///
  /// create image from data
  ///
  /// [uriDataPath] startsWith 'data://''
  /// desc:
  /// * Data URL:  https://tools.ietf.org/html/rfc2397
  /// * dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
  ///
  ImageProvider createMemoryImage(String uriDataPath);

  ///
  /// create image from network
  ///
  /// [blobPath] startsWith 'file://''
  ///
  ImageProvider createBlobImage(String blobPath);

  ///
  /// create image Fallback to image
  /// maybe assetimage
  /// [url] image from JSRuntime
  ///
  ImageProvider createFallbackImage(String url);
}

///
/// DefaultImageProvider
/// * can be replace in [DelegateConfig]
///
class DefaultImageProviderDelegate implements ImageProviderDelegate {
  @override
  ImageProvider createNetworkImage(String url, {String cache}) {
    // @TODO: caching also works after image downloaded
    ImageProvider _value;
    if (cache == 'store' || cache == 'auto') {
      _value = CachedNetworkImage(url);
    } else {
      _value = NetworkImage(url);
    }
    return _value;
  }

  @override
  ImageProvider createFileImage(String rawPath) {
    return FileImage(File.fromUri(Uri.parse(rawPath)));
  }

  @override
  ImageProvider createMemoryImage(String uriDataPath) {
    ImageProvider _value = null;
    UriData data = UriData.parse(uriDataPath);
    if (data.isBase64) {
      _value = MemoryImage(data.contentAsBytes());
    }
    return _value;
  }

  @override
  ImageProvider createBlobImage(String blobPath) {
    // @TODO: support blob file url
    return null;
  }

  @override
  ImageProvider createFallbackImage(String blo) {
    return AssetImage(blo);
  }
}
