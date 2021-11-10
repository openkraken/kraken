/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class RenderBr extends RenderIntrinsic {
  RenderBr(
    RenderStyle renderStyle,
  ) : super(
    renderStyle,
  );

  // Height of BR element is only determined by its parents line-height.
  double get height {
    RenderBoxModel parentBox = parent as RenderBoxModel;
    final Size textSize = (TextPainter(
      text: CSSTextMixin.createTextSpan(' ', parentBox.renderStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr)
      ..layout())
      .size;
    return textSize.height;
  }

  @override
  void performLayout() {
    size = Size(0, constraints.maxHeight);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return size.height;
  }
}