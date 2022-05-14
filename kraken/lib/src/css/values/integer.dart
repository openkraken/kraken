/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#integers
class CSSInteger {

  static int? parseInteger(String value) {
    return int.tryParse(value);
  }

  static bool isInteger(String value){
    return int.tryParse(value) != null;
  }
}
