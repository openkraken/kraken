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
  double get height {
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
    // HACK: current use block layout make text force line break
    // BR element is a special element in HTML which accepts no style,
    // it dimension is only affected by the line-height of its parent.
    // https://www.w3.org/TR/CSS1/#br-elements
    double height;
    final RenderLayoutParentData selfParentData = parentData as RenderLayoutParentData;
    final RenderBoxModel parentBox = parent as RenderBoxModel;
    RenderBox? previousSibling = selfParentData.previousSibling;
    // BR element has no height if it follows an inline-level element (including text node) in flow layout.
    if (parentBox is RenderFlowLayout &&
      (previousSibling is RenderTextBox ||
        (previousSibling is RenderBoxModel &&
          (previousSibling.renderStyle.display != CSSDisplay.block &&
            previousSibling.renderStyle.display != CSSDisplay.flex)))
    ) {
      height = 0;
    } else {
      height = this.height;
    }
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
