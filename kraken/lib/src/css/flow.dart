/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Alignment: https://drafts.csswg.org/css-align/

mixin CSSFlowMixin {
  static void decorateRenderFlow(RenderFlowLayout renderFlowLayout, CSSStyleDeclaration style) {
    Axis axis = Axis.horizontal;
    TextDirection textDirection = TextDirection.ltr;
    VerticalDirection verticalDirection = VerticalDirection.down;

    renderFlowLayout.verticalDirection = verticalDirection;
    renderFlowLayout.direction = axis;
    renderFlowLayout.textDirection = textDirection;
    renderFlowLayout.mainAxisAlignment = _getTextAlign(style);
  }
}

MainAxisAlignment _getTextAlign(CSSStyleDeclaration style) {
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;

  if (style.contains(TEXT_ALIGN)) {
    String textAlign = style[TEXT_ALIGN];
    switch (textAlign) {
      case 'start':
      case 'left':
      // Use default value: start
        break;
      case 'end':
      case 'right':
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case 'center':
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case 'justify-all':
        mainAxisAlignment = MainAxisAlignment.spaceBetween;
        break;
    // Like inherit, which is the same with parent element.
    // Not impl it due to performance consideration.
    // case 'match-parent':
    }
  }

  return mainAxisAlignment;
}
