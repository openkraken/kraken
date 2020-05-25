/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

const String INITIAL = 'initial';

abstract class CSSValue<ComputedType> {
  /// https://drafts.csswg.org/cssom/#parsing-css-values
  void parse();

  /// The parsed value.
  ComputedType get computedValue;

  /// https://drafts.csswg.org/cssom/#serializing-css-values
  String get serializedValue;
}
