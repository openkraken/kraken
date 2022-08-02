/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:webf/foundation.dart';

class BoxFitImageKey {
  const BoxFitImageKey({
    required this.url,
    this.configuration,
  });

  final Uri url;
  final ImageConfiguration? configuration;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is BoxFitImageKey && other.url == url && other.configuration == configuration;
  }

  @override
  int get hashCode => hashValues(configuration, url);

  @override
  String toString() => 'BoxFitImageKey($url, $configuration)';
}

typedef LoadImage = Future<Uint8List> Function(Uri url);
typedef OnImageLoad = void Function(int naturalWidth, int naturalHeight);

class BoxFitImage extends ImageProvider<BoxFitImageKey> {
  BoxFitImage({
    required this.loadImage,
    required this.url,
    required this.boxFit,
    this.onImageLoad,
  });

  final LoadImage loadImage;
  final Uri url;
  final BoxFit boxFit;
  final OnImageLoad? onImageLoad;

  @override
  Future<BoxFitImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BoxFitImageKey>(BoxFitImageKey(
      url: url,
      configuration: configuration,
    ));
  }

  Future<Codec> _loadAsync(BoxFitImageKey key) async {
    Uint8List bytes = await loadImage(url);
    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(bytes);
    final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
    final Codec codec = await _instantiateImageCodec(
      descriptor,
      boxFit: boxFit,
      preferredWidth: key.configuration?.size?.width.toInt(),
      preferredHeight: key.configuration?.size?.height.toInt(),
    );

    // Fire image on load after codec created.
    scheduleMicrotask(() {
      if (onImageLoad != null) {
        onImageLoad!(descriptor.width, descriptor.height);
      }
      _imageStreamCompleter!.setDimension(Dimension(descriptor.width, descriptor.height));
    });
    return codec;
  }

  DimensionedMultiFrameImageStreamCompleter? _imageStreamCompleter;

  @override
  ImageStreamCompleter load(BoxFitImageKey key, DecoderCallback decode) {
    return _imageStreamCompleter = DimensionedMultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<BoxFitImageKey>('Image key', key),
        ];
      },
    );
  }

  @override
  void resolveStreamForKey(
      ImageConfiguration configuration, ImageStream stream, BoxFitImageKey key, ImageErrorListener handleError) {
    if (stream.completer != null) {
      final ImageStreamCompleter? completer = PaintingBinding.instance.imageCache.putIfAbsent(
        key,
        () => stream.completer!,
        onError: handleError,
      );
      assert(identical(completer, stream.completer));
      return;
    }
    final ImageStreamCompleter? completer = PaintingBinding.instance.imageCache.putIfAbsent(
      key,
      () => load(key, PaintingBinding.instance.instantiateImageCodec),
      onError: handleError,
    );
    if (_imageStreamCompleter == null &&
        completer is DimensionedMultiFrameImageStreamCompleter &&
        onImageLoad != null) {
      completer.dimension.then((Dimension dimension) {
        onImageLoad!(dimension.width, dimension.height);
      });
    }
    if (completer != null) {
      stream.setCompleter(completer);
    }
  }

  static Future<Codec> _instantiateImageCodec(
    ImageDescriptor descriptor, {
    BoxFit? boxFit = BoxFit.none,
    int? preferredWidth,
    int? preferredHeight,
  }) async {
    assert(boxFit != null);

    final int naturalWidth = descriptor.width;
    final int naturalHeight = descriptor.height;

    int? targetWidth;
    int? targetHeight;

    // Image will be resized according to its aspect radio if object-fit is not fill.
    // https://www.w3.org/TR/css-images-3/#propdef-object-fit
    if (preferredWidth != null && preferredHeight != null) {
      // When targetWidth or targetHeight is not set at the same time,
      // image will be resized according to its aspect radio.
      // https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/box_fit.dart#L152
      if (boxFit == BoxFit.contain) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          targetHeight = preferredHeight;
        } else {
          targetWidth = preferredWidth;
        }

        // Resized image should maintain its intrinsic aspect radio event if object-fit is fill
        // which behaves just like object-fit cover otherwise the cached resized image with
        // distorted aspect ratio will not work when object-fit changes to not fill.
      } else if (boxFit == BoxFit.fill || boxFit == BoxFit.cover) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          targetWidth = preferredWidth;
        } else {
          targetHeight = preferredHeight;
        }

        // Image should maintain its aspect radio and not resized if object-fit is none.
      } else if (boxFit == BoxFit.none) {
        targetWidth = naturalWidth;
        targetHeight = naturalHeight;

        // If image size is smaller than its natural size when object-fit is contain,
        // scale-down is parsed as none, otherwise parsed as contain.
      } else if (boxFit == BoxFit.scaleDown) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          if (preferredHeight > naturalHeight) {
            targetWidth = naturalWidth;
            targetHeight = naturalHeight;
          } else {
            targetHeight = preferredHeight;
          }
        } else {
          if (preferredWidth > naturalWidth) {
            targetWidth = naturalWidth;
            targetHeight = naturalHeight;
          } else {
            targetWidth = preferredWidth;
          }
        }
      }
    } else {
      targetWidth = preferredWidth;
      targetHeight = preferredHeight;
    }

    // Resize image size should not be larger than its natural size.
    if (targetWidth != null && targetWidth > naturalWidth) {
      targetWidth = naturalWidth;
    }
    if (targetHeight != null && targetHeight > naturalHeight) {
      targetHeight = naturalHeight;
    }

    return descriptor.instantiateCodec(
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }
}

// The [MultiFrameImageStreamCompleter] that saved the natural dimention of image.
class DimensionedMultiFrameImageStreamCompleter extends MultiFrameImageStreamCompleter {
  DimensionedMultiFrameImageStreamCompleter({
    required Future<Codec> codec,
    required double scale,
    String? debugLabel,
    Stream<ImageChunkEvent>? chunkEvents,
    InformationCollector? informationCollector,
  }) : super(
            codec: codec,
            scale: scale,
            debugLabel: debugLabel,
            chunkEvents: chunkEvents,
            informationCollector: informationCollector);

  final List<Completer<Dimension>> _dimensionCompleter = [];
  Dimension? _dimension;

  Future<Dimension> get dimension async {
    if (_dimension != null) {
      return _dimension!;
    } else {
      Completer<Dimension> completer = Completer<Dimension>();
      _dimensionCompleter.add(completer);
      return completer.future;
    }
  }

  void setDimension(Dimension dimension) {
    _dimension = dimension;
    if (_dimensionCompleter.isNotEmpty) {
      _dimensionCompleter.forEach((Completer<Dimension> completer) {
        completer.complete(dimension);
      });
      _dimensionCompleter.clear();
    }
  }
}
