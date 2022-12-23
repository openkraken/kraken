/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

FutureOr<String> resolveStringFromData(final List<int> data, { Codec codec = utf8 }) async {
  if (codec == utf8) {
    return _resolveUtf8StringFromData(data);
  } else {
    return codec.decode(data);
  }
}

Future<String> _resolveUtf8StringFromData(final List<int> data) async {
  // reference: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/services/asset_bundle.dart#L71
  // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs
  // on a Pixel 4.
  if (data.length < 50 * 1024) {
    return utf8.decode(data);
  }
  // For strings larger than 50 KB, run the computation in an isolate to
  // avoid causing main thread jank.
  return compute(_utf8decode, data);
}

String _utf8decode(List<int> data) => utf8.decode(data);
