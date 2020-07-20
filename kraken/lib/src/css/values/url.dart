/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';

import 'value.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#urls
class CSSUrl implements CSSValue<ImageProvider> {
  String cache;
  ImageProvider _value;
  String _url;
  String _rawInput;
  CSSUrl(this._rawInput, {this.cache = 'auto'}) {
    parse();
  }

  @override
  ImageProvider get computedValue => _value;

  @override
  void parse() {
    // support input string enclosed in quotation marks
    if ((_rawInput.startsWith('\'') && _rawInput.endsWith('\'')) ||
        (_rawInput.startsWith('\"') && _rawInput.endsWith('\"'))) {
      _rawInput = _rawInput.substring(1, _rawInput.length - 1);
    }

    // Default is raw value
    if (_rawInput.startsWith('//') || _rawInput.startsWith('http://') || _rawInput.startsWith('https://')) {
      _url = _rawInput.startsWith('//') ? 'https:' + _rawInput : _rawInput;
    }

    _value = ImageElement.getImageProviderAdapter().getImageProvider(_rawInput, {'cache': this.cache});
  }

  @override
  String get serializedValue => 'url($_url)';
}
