/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class RenderLineBreak extends RenderIntrinsic {
  RenderLineBreak(
    CSSRenderStyle renderStyle,
  ) : super(
    renderStyle,
  );

  // Height of BR element is only determined by its parents line-height.
  // @TODO add cache to avoid create TextPainter to measure size on every layout.
  double get lineHeight {
    final Size textSize = (TextPainter(
      text: CSSTextMixin.createTextSpan(' ', renderStyle.parent!),
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
  BoxConstraints getConstraints() {
    // BR element is a special element in HTML which accepts no style,
    // it dimension is only affected by the line-height of its parent.
    // https://www.w3.org/TR/CSS1/#br-elements
    double height = lineHeight;
    BoxConstraints constraints = BoxConstraints(
      minWidth: 0,
      maxWidth: 0,
      minHeight: height,
      maxHeight: height,
    );
    return constraints;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return size.height;
  }
}
