/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
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
        : getRunAlignmentFromFlexProperty(style[TEXT_ALIGN]);
  }
}

