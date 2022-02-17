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

class KrakenFileImageKey {
  KrakenFileImageKey({
    required this.file,
    required this.scale,
    required this.objectFit
  });

  final File file;

  final double scale;

  final BoxFit objectFit;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is KrakenFileImageKey
      && other.file.path == file.path
      && other.scale == scale
      && other.objectFit == objectFit;
  }

  @override
  int get hashCode => hashValues(file.path, scale, objectFit);
}

// Forked from Flutter [FileImage] Class, add objectFit key.
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_provider.dart#L856
class KrakenFileImage extends ImageProvider<KrakenFileImageKey> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  const KrakenFileImage(this.file, { this.scale = 1.0, this.objectFit = BoxFit.fill });

  /// The file to decode into an image.
  final File file;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  final BoxFit objectFit;

  @override
  Future<KrakenFileImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<KrakenFileImageKey>(KrakenFileImageKey(
      file: file,
      scale: scale,
      objectFit: objectFit,
    ));
  }

  @override
  ImageStreamCompleter load(KrakenFileImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () sync* {
        yield ErrorDescription('Path: ${file.path}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(KrakenFileImageKey key, DecoderCallback decode) async {
    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance!.imageCache!.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }

    return decode(bytes);
  }
}
