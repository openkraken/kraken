/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin FlowMixin {
  static const String TEXT_ALIGN = 'textAlign';
  static const String JUSTIFY_CONTENT = 'justifyContent';

  void decorateRenderFlow(RenderFlowLayout renderFlowLayout, StyleDeclaration style) {
    bool isFlexDisplay = (style['display'] as String).endsWith('flex');

    renderFlowLayout.mainAxisAlignment = isFlexDisplay
        ? getRunAlignmentFromFlexProperty(style[JUSTIFY_CONTENT])
        : _getTextAlign(style[TEXT_ALIGN]);
  }

  MainAxisAlignment _getTextAlign(String textAlign) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;

    switch (textAlign) {
      case 'right':
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case 'center':
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }

    return mainAxisAlignment;
  }
}

