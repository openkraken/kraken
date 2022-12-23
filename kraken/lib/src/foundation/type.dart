/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

// Cast any input type to determined type.
T castToType<T>(value) {
  assert(value is T, '$value is not or not a subtype of $T');
  return value as T;
}
