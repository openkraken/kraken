/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

import 'dart:ui';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class BoxFitImageKey {
  const BoxFitImageKey({
    required this.descriptor,
    this.scale = 1.0,
    this.configuration,
  });

  final ImageDescriptor descriptor;
  final double scale;
  final ImageConfiguration? configuration;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is BoxFitImageKey
        && other.descriptor == descriptor
        && other.configuration == configuration;
  }

  @override
  int get hashCode => hashValues(configuration, descriptor);
}

class BoxFitImage extends ImageProvider<BoxFitImageKey> {
  const BoxFitImage({
    required this.descriptor,
    required this.boxFit,
  });

  final ImageDescriptor descriptor;
  final BoxFit boxFit;

  @override
  Future<BoxFitImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BoxFitImageKey>(BoxFitImageKey(
      descriptor: descriptor,
      configuration: configuration,
    ));
  }

  @override
  ImageStreamCompleter load(BoxFitImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _instantiateImageCodec(key.descriptor,
        boxFit: boxFit,
        preferredWidth: key.configuration?.size?.width.toInt(),
        preferredHeight: key.configuration?.size?.height.toInt(),
      ),
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<BoxFitImageKey>('Image key', key),
        ];
      },
    );
  }

  static Future<Codec> _instantiateImageCodec(ImageDescriptor descriptor, {
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
