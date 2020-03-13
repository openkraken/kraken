/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

class TextParentData extends ContainerBoxParentData<RenderBox> {
}

class RenderTextBox extends RenderBox
  with
    ElementStyleMixin,
    TextStyleMixin,
    DimensionMixin,
    ContainerRenderObjectMixin<RenderBox, TextParentData>,
    RenderBoxContainerDefaultsMixin<RenderBox, TextParentData> {

  RenderTextBox({
    this.nodeId,
    this.style,
    this.text,
  }) : assert(text != null) {
    RenderParagraph paragraphNode = RenderParagraph(
      createTextSpanWithStyle(text, style),
      textAlign: getTextAlignFromStyle(style),
      textDirection: TextDirection.ltr,
    );
    add(paragraphNode);
  }

  int nodeId;
  String text;
  Style style;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox child = firstChild;

    // @TODO when in flex-grow or flex-shrink width needs to be recalulated
    double constraintWidth = getParentWidth(nodeId);
    if (child != null) {
      BoxConstraints additionalConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: constraintWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      );
      child.layout(additionalConstraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox child = firstChild;
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}

