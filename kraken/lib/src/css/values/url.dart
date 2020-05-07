/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';
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
    // support input with ' " cover
    if ((_rawInput.startsWith('\'') && _rawInput.endsWith('\'')) ||
      (_rawInput.startsWith('\"') && _rawInput.endsWith('\"'))) {
      _rawInput = _rawInput.substring(1, _rawInput.length - 1);
    }
    if (_rawInput.startsWith('//') ||
        _rawInput.startsWith('http://') ||
        _rawInput.startsWith('https://')) {
      var url = _rawInput.startsWith('//') ? 'https:' + _rawInput : _rawInput;
      _url = url;
      // @TODO: caching also works after image downloaded
      if (cache == 'store' || cache == 'auto') {
        _value = CachedNetworkImage(url);
      } else {
        _value = NetworkImage(url);
      }
    } else if (_rawInput.startsWith('file://')) {
      _value = FileImage(File.fromUri(Uri.parse(_rawInput)));
      _url = _rawInput;
    } else {
      // Fallback to asset image
      _value = AssetImage(_rawInput);
      _url = _rawInput;
    }
  }

  @override
  String get serializedValue => 'url($_url)';
}
