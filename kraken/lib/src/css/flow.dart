/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Alignment: https://drafts.csswg.org/css-align/

mixin CSSFlowMixin on RenderStyleBase {

  TextAlign get textAlign => _textAlign;
  late TextAlign _textAlign;
  set textAlign(TextAlign value) {
    if (_textAlign == value) return;
    _textAlign = value;
    if (renderBoxModel is RenderFlowLayout) {
      renderBoxModel.markNeedsLayout();
    }
  }

  void updateFlow() {
    CSSStyleDeclaration style = this.style;
    textAlign = _getTextAlign(style);
  }

  TextAlign _getTextAlign(CSSStyleDeclaration style) {
    TextAlign alignment = TextAlign.start;

    if (style.contains(TEXT_ALIGN)) {
      switch (style[TEXT_ALIGN]) {
        case 'start':
        case 'left':
        // Use default value: start
          break;
        case 'end':
        case 'right':
          alignment = TextAlign.end;
          break;
        case 'center':
          alignment = TextAlign.center;
          break;
        case 'justify':
          alignment = TextAlign.justify;
          break;
      // Like inherit, which is the same with parent element.
      // Not impl it due to performance consideration.
      // case 'match-parent':
      }
    }

    return alignment;
  }
}

