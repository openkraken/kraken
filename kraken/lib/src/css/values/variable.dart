/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';

const int _HYPHEN_CODE = 45; // -

// https://www.w3.org/TR/css-variables-1/#defining-variables
class CSSVariable {

  static bool isVariable(String? value) {
    if (value == null) {
      return false;
    }
    return value.length > 2 && value.codeUnitAt(0) == _HYPHEN_CODE && value.codeUnitAt(1) == _HYPHEN_CODE;
  }

  final String identifier;
  final dynamic defaultValue;
  final RenderStyle _renderStyle;

  CSSVariable(this.identifier, this._renderStyle, { this.defaultValue });

  // Get the lazy calculated CSS resolved value.
  dynamic computedValue(String propertyName) {
    dynamic value = _renderStyle.getCSSVariable(identifier, propertyName) ?? defaultValue;
    if (value != null) {
      value = _renderStyle.resolveValue(propertyName, value);
    }
    return value;
  }
}
