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

  // Try to parse CSSVariable.
  static CSSVariable? tryParse(RenderStyle renderStyle, String propertyName, String propertyValue) {
    // font-size: var(--x);
    // font-size: var(--x, 28px);
    if (CSSFunction.isFunction(propertyValue, functionName: VAR)) {
      List<CSSFunctionalNotation> fns = CSSFunction.parseFunction(propertyValue);
      if (fns.first.args.isNotEmpty) {
        if (fns.first.args.length > 1) {
          // Has default value for CSS Variable.
          return CSSVariable(fns.first.args.first, renderStyle,
              defaultValue: fns.first.args.last);
        } else {
          return CSSVariable(fns.first.args.first, renderStyle);
        }
      }
    }
  }

  final String identifier;
  final String? defaultValue;
  final RenderStyle _renderStyle;

  CSSVariable(this.identifier, this._renderStyle, { this.defaultValue });

  // Get the lazy calculated CSS resolved value.
  dynamic computedValue(String propertyName) {
    String? unsolvedValue = _renderStyle.getCSSVariable(identifier, propertyName) ?? defaultValue;
    if (unsolvedValue == null) {
      return null;
    }

    var resolved = _renderStyle.resolveValue(propertyName, unsolvedValue);
    if (resolved is CSSVariable) {
      return resolved.computedValue(propertyName);
    } else {
      return resolved;
    }
  }

  @override
  String toString() {
    return 'var($identifier${defaultValue != null ? ', $defaultValue': ''})';
  }
}
