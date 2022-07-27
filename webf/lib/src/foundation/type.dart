/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

// Cast any input type to determined type.
T castToType<T>(value) {
  assert(value is T, '$value is not or not a subtype of $T');
  return value as T;
}

class Dimension {
  const Dimension(this.width, this.height);

  final int width;
  final int height;

  @override
  bool operator ==(Object other) {
    return other is Dimension && other.width == width && other.height == height;
  }

  @override
  int get hashCode => hashValues(width, height);
}
