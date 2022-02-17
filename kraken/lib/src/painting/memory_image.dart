/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class KrakenMemoryImageKey {
  KrakenMemoryImageKey({
    required this.bytes,
    required this.scale,
    required this.objectFit
  });

  final Uint8List bytes;

  final double scale;

  final BoxFit objectFit;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is KrakenMemoryImageKey
        && other.bytes == bytes
        && other.scale == scale
        && other.objectFit == objectFit;
  }

  @override
  int get hashCode => hashValues(bytes, scale, objectFit);
}

// Forked from Flutter [FileImage] Class, add objectFit key.
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_provider.dart#L856
class KrakenMemoryImage extends ImageProvider<KrakenMemoryImageKey> {

  /// Creates an object that decodes a [Uint8List] buffer as an image.
  ///
  /// The arguments must not be null.
  const KrakenMemoryImage(this.bytes, { this.scale = 1.0, this.objectFit = BoxFit.fill });

  /// The bytes to decode into an image.
  ///
  /// The bytes represent encoded image bytes and can be encoded in any of the
  /// following supported image formats: {@macro flutter.dart:ui.imageFormats}
  ///
  /// See also:
  ///
  ///  * [PaintingBinding.instantiateImageCodec]
  final Uint8List bytes;

  /// The scale to place in the [ImageInfo] object of the image.
  ///
  /// See also:
  ///
  ///  * [ImageInfo.scale], which gives more information on how this scale is
  ///    applied.
  final double scale;

  final BoxFit objectFit;

  @override
  Future<KrakenMemoryImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<KrakenMemoryImageKey>(KrakenMemoryImageKey(
      bytes: bytes,
      scale: scale,
      objectFit: objectFit,
    ));
  }

  @override
  ImageStreamCompleter load(KrakenMemoryImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: 'MemoryImage(${describeIdentity(key.bytes)})',
    );
  }

  Future<ui.Codec> _loadAsync(KrakenMemoryImageKey key, DecoderCallback decode) {
    assert(key == this);

    return decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is KrakenMemoryImage
      && other.bytes == bytes
      && other.scale == scale
      && other.objectFit == objectFit;
  }

  @override
  int get hashCode => hashValues(bytes.hashCode, scale, objectFit);

}
