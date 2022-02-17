/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

const String _kAssetManifestFileName = 'AssetManifest.json';

/// A screen with a device-pixel ratio strictly less than this value is
/// considered a low-resolution screen (typically entry-level to mid-range
/// laptops, desktop screens up to QHD, low-end tablets such as Kindle Fire).
const double _kLowDprLimit = 2.0;

// Forked from Flutter [AssetBundleImageKey] Class, add objectFit key.
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_provider.dart#L594
class KrakenAssetBundleImageKey {
  /// Creates the key for an [KrakenAssetImage] or [KrakenAssetBundleImageProvider].
  ///
  /// The arguments must not be null.
  const KrakenAssetBundleImageKey({
    required this.bundle,
    required this.name,
    required this.scale,
    required this.objectFit,
  });

  /// The bundle from which the image will be obtained.
  ///
  /// The image is obtained by calling [AssetBundle.load] on the given [bundle]
  /// using the key given by [name].
  final AssetBundle bundle;

  /// The key to use to obtain the resource from the [bundle]. This is the
  /// argument passed to [AssetBundle.load].
  final String name;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  final BoxFit objectFit;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is KrakenAssetBundleImageKey
      && other.bundle == bundle
      && other.name == name
      && other.scale == scale
      && other.objectFit == objectFit;
  }

  @override
  int get hashCode => hashValues(bundle, name, scale, objectFit);
}

// Forked from Flutter [AssetBundleImageProvider] Class, add objectFit key.
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_provider.dart#L640
abstract class KrakenAssetBundleImageProvider extends ImageProvider<KrakenAssetBundleImageKey> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const KrakenAssetBundleImageProvider();

  /// Converts a key into an [ImageStreamCompleter], and begins fetching the
  /// image.
  @override
  ImageStreamCompleter load(KrakenAssetBundleImageKey key, DecoderCallback decode) {
    InformationCollector? collector;
    assert(() {
      collector = () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<KrakenAssetBundleImageKey>('Image key', key);
      };
      return true;
    }());
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.name,
      informationCollector: collector,
    );
  }

  /// Fetches the image from the asset bundle, decodes it, and returns a
  /// corresponding [ImageInfo] object.
  ///
  /// This function is used by [load].
  @protected
  Future<ui.Codec> _loadAsync(KrakenAssetBundleImageKey key, DecoderCallback decode) async {
    ByteData? data;
    // Hot reload/restart could change whether an asset bundle or key in a
    // bundle are available, or if it is a network backed bundle.
    try {
      data = await key.bundle.load(key.name);
    } on FlutterError {
      PaintingBinding.instance!.imageCache!.evict(key);
      rethrow;
    }
    // ignore: unnecessary_null_comparison
    if (data == null) {
      PaintingBinding.instance!.imageCache!.evict(key);
      throw StateError('Unable to read data');
    }
    return decode(data.buffer.asUint8List());
  }
}

// Forked from Flutter [AssetImage] Class, add objectFit key.
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_resolution.dart#L244
class KrakenAssetImage extends KrakenAssetBundleImageProvider {
  /// Creates an object that fetches an image from an asset bundle.
  ///
  /// The [assetName] argument must not be null. It should name the main asset
  /// from the set of images to choose from. The [package] argument must be
  /// non-null when fetching an asset that is included in package. See the
  /// documentation for the [AssetImage] class itself for details.
  const KrakenAssetImage(
      this.assetName, {
      this.bundle,
      this.package,
      this.objectFit = BoxFit.fill,
    });

  /// The name of the main asset from the set of images to choose from. See the
  /// documentation for the [AssetImage] class itself for details.
  final String assetName;

  /// The name used to generate the key to obtain the asset. For local assets
  /// this is [assetName], and for assets from packages the [assetName] is
  /// prefixed 'packages/<package_name>/'.
  String get keyName => package == null ? assetName : 'packages/$package/$assetName';

  /// The bundle from which the image will be obtained.
  ///
  /// If the provided [bundle] is null, the bundle provided in the
  /// [ImageConfiguration] passed to the [resolve] call will be used instead. If
  /// that is also null, the [rootBundle] is used.
  ///
  /// The image is obtained by calling [AssetBundle.load] on the given [bundle]
  /// using the key given by [keyName].
  final AssetBundle? bundle;

  /// The name of the package from which the image is included. See the
  /// documentation for the [AssetImage] class itself for details.
  final String? package;

  final BoxFit objectFit;

  // We assume the main asset is designed for a device pixel ratio of 1.0
  static const double _naturalResolution = 1.0;

  @override
  Future<KrakenAssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    // This function tries to return a SynchronousFuture if possible. We do this
    // because otherwise showing an image would always take at least one frame,
    // which would be sad. (This code is called from inside build/layout/paint,
    // which all happens in one call frame; using native Futures would guarantee
    // that we resolve each future in a new call frame, and thus not in this
    // build/layout/paint sequence.)
    final AssetBundle chosenBundle = bundle ?? configuration.bundle ?? rootBundle;
    Completer<KrakenAssetBundleImageKey>? completer;
    Future<KrakenAssetBundleImageKey>? result;

    chosenBundle.loadStructuredData<Map<String, List<String>>?>(_kAssetManifestFileName, _manifestParser).then<void>(
        (Map<String, List<String>>? manifest) {
        final String chosenName = _chooseVariant(
          keyName,
          configuration,
          manifest == null ? null : manifest[keyName],
        )!;
        final double chosenScale = _parseScale(chosenName);
        final KrakenAssetBundleImageKey key = KrakenAssetBundleImageKey(
          bundle: chosenBundle,
          name: chosenName,
          scale: chosenScale,
          objectFit: objectFit,
        );
        if (completer != null) {
          // We already returned from this function, which means we are in the
          // asynchronous mode. Pass the value to the completer. The completer's
          // future is what we returned.
          completer.complete(key);
        } else {
          // We haven't yet returned, so we must have been called synchronously
          // just after loadStructuredData returned (which means it provided us
          // with a SynchronousFuture). Let's return a SynchronousFuture
          // ourselves.
          result = SynchronousFuture<KrakenAssetBundleImageKey>(key);
        }
      },
    ).catchError((Object error, StackTrace stack) {
      // We had an error. (This guarantees we weren't called synchronously.)
      // Forward the error to the caller.
      assert(completer != null);
      assert(result == null);
      completer!.completeError(error, stack);
    });
    if (result != null) {
      // The code above ran synchronously, and came up with an answer.
      // Return the SynchronousFuture that we created above.
      return result!;
    }
    // The code above hasn't yet run its "then" handler yet. Let's prepare a
    // completer for it to use when it does run.
    completer = Completer<KrakenAssetBundleImageKey>();
    return completer.future;
  }

  static Future<Map<String, List<String>>?> _manifestParser(String? jsonData) {
    if (jsonData == null)
      return SynchronousFuture<Map<String, List<String>>?>(null);
    // TODO(ianh): JSON decoding really shouldn't be on the main thread.
    final Map<String, dynamic> parsedJson = json.decode(jsonData) as Map<String, dynamic>;
    final Iterable<String> keys = parsedJson.keys;
    final Map<String, List<String>> parsedManifest = <String, List<String>> {
      for (final String key in keys) key: List<String>.from(parsedJson[key] as List<dynamic>),
    };
    // TODO(ianh): convert that data structure to the right types.
    return SynchronousFuture<Map<String, List<String>>?>(parsedManifest);
  }

  String? _chooseVariant(String main, ImageConfiguration config, List<String>? candidates) {
    if (config.devicePixelRatio == null || candidates == null || candidates.isEmpty)
      return main;
    // TODO(ianh): Consider moving this parsing logic into _manifestParser.
    final SplayTreeMap<double, String> mapping = SplayTreeMap<double, String>();
    for (final String candidate in candidates)
      mapping[_parseScale(candidate)] = candidate;
    // TODO(ianh): implement support for config.locale, config.textDirection,
    // config.size, config.platform (then document this over in the Image.asset
    // docs)
    return _findBestVariant(mapping, config.devicePixelRatio!);
  }

  // Returns the "best" asset variant amongst the available `candidates`.
  //
  // The best variant is chosen as follows:
  // - Choose a variant whose key matches `value` exactly, if available.
  // - If `value` is less than the lowest key, choose the variant with the
  //   lowest key.
  // - If `value` is greater than the highest key, choose the variant with
  //   the highest key.
  // - If the screen has low device pixel ratio, choose the variant with the
  //   lowest key higher than `value`.
  // - If the screen has high device pixel ratio, choose the variant with the
  //   key nearest to `value`.
  String? _findBestVariant(SplayTreeMap<double, String> candidates, double value) {
    if (candidates.containsKey(value))
      return candidates[value]!;
    final double? lower = candidates.lastKeyBefore(value);
    final double? upper = candidates.firstKeyAfter(value);
    if (lower == null)
      return candidates[upper];
    if (upper == null)
      return candidates[lower];

    // On screens with low device-pixel ratios the artifacts from upscaling
    // images are more visible than on screens with a higher device-pixel
    // ratios because the physical pixels are larger. Choose the higher
    // resolution image in that case instead of the nearest one.
    if (value < _kLowDprLimit || value > (lower + upper) / 2)
      return candidates[upper];
    else
      return candidates[lower];
  }

  static final RegExp _extractRatioRegExp = RegExp(r'/?(\d+(\.\d*)?)x$');

  double _parseScale(String key) {
    if (key == assetName) {
      return _naturalResolution;
    }

    final Uri assetUri = Uri.parse(key);
    String directoryPath = '';
    if (assetUri.pathSegments.length > 1) {
      directoryPath = assetUri.pathSegments[assetUri.pathSegments.length - 2];
    }

    final Match? match = _extractRatioRegExp.firstMatch(directoryPath);
    if (match != null && match.groupCount > 0)
      return double.parse(match.group(1)!);
    return _naturalResolution; // i.e. default to 1.0x
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is AssetImage
      && other.keyName == keyName
      && other.bundle == bundle;
  }

  @override
  int get hashCode => hashValues(keyName, bundle);
}


