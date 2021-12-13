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

  TextPainter get textPainter {
    double fontSize = renderStyle.fontSize.computedValue;

    TextStyle textStyle = TextStyle(
      fontFamilyFallback: renderStyle.fontFamily,
      fontSize: fontSize,
      textBaseline: CSSText.getTextBaseLine(),
      package: CSSText.getFontPackage(),
      locale: CSSText.getLocale(),
    );
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: ' ',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr
    );
    painter.layout();
    return painter;
  }

  // Height of BR element is only determined by its parents line-height.
  // @TODO add cache to avoid create TextPainter to measure size on every layout.
  double get lineHeight {
    CSSLengthValue lineHeight = renderStyle.parent!.lineHeight;
    if (lineHeight.type != CSSLengthType.NORMAL) {
      return lineHeight.computedValue;
    } else {
      return textPainter.size.height;
    }
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
  double computeDistanceToBaseline() {
    return textPainter.computeDistanceToActualBaseline(CSSText.getTextBaseLine());
  }
}
