/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

/// All of these keywords are normatively defined in the Cascade module.
/// [CSS3CASCADE]
enum PreDefinedTextualKeywords {
  /// The initial keyword represents the value specified as the property’s
  /// initial value.
  initial,

  /// The inherit keyword represents the computed value of the property on
  /// the element’s parent.
  inherit,

  /// The unset keyword acts as either inherit or initial, depending on whether
  /// the property is inherited or not.
  unset,
}

class TextualString {
  String _value;

  TextualString(String value) {
    if (value != null) {
      _value = value;
    }
  }

  String valueOf() => _value;
}

class URL extends TextualString {
  URL(String value) : super(value);

  String valueOf() {
    return 'url(' + _value + ')';
  }
}
