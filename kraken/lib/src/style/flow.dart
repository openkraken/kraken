/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'style.dart';

mixin FlowMixin {
  static const String TEXT_ALIGN = 'textAlign';

  void decorateRenderFlow(ContainerRenderObjectMixin renderObject, Style style) {
    if (style != null) {
      (renderObject as RenderFlowLayout).mainAxisAlignment = _getTextAlign(style);
    }
  }

  MainAxisAlignment _getTextAlign(Style style) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;

    if (style.contains(TEXT_ALIGN)) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          mainAxisAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          mainAxisAlignment = MainAxisAlignment.center;
          break;
      }
    }

    return mainAxisAlignment;
  }
}

