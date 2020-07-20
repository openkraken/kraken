/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/custom_config.dart';
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
    _url = _rawInput;

    if (_rawInput.startsWith('//') || _rawInput.startsWith('http://') || _rawInput.startsWith('https://')) {
      var url = _rawInput.startsWith('//') ? 'https:' + _rawInput : _rawInput;
      _url = url;
      // @TODO: caching also works after image downloaded
      if (cache == 'store' || cache == 'auto') {
        _value = ImageElement.getImageProviderFactory(ImageType.cacheNetImage)(url);
      } else {
        _value = ImageElement.getImageProviderFactory(ImageType.noCacheNetImage)(url);
      }

    } else if (_rawInput.startsWith('file://')) {
      File file = File.fromUri(Uri.parse(_rawInput));
      _value = ImageElement.getImageProviderFactory(ImageType.fileImage)(_rawInput, file);
    } else if (_rawInput.startsWith('data:')) {
      // Data URL:  https://tools.ietf.org/html/rfc2397
      // dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data

      UriData data = UriData.parse(_rawInput);
      if (data.isBase64) {
        _value = ImageElement.getImageProviderFactory(ImageType.dataImage)(_rawInput, data.contentAsBytes());
      }

    } else if (_rawInput.startsWith('blob:')) {
      // @TODO: support blob file url
      _value = ImageElement.getImageProviderFactory(ImageType.blobImage)(_rawInput);
    } else {
      // Fallback to asset image
      _value = ImageElement.getImageProviderFactory(ImageType.fallbackImage)(_rawInput);
    }
  }

  @override
  String get serializedValue => 'url($_url)';
}
