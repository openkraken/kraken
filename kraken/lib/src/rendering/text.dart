/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';
import 'package:kraken/element.dart';

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
    String text,
    Style style,
  }) : assert(text != null) {
    _text = text;
    _style = style;

    _renderParagraph = RenderParagraph(
      createTextSpanWithStyle(text, style),
      textAlign: getTextAlignFromStyle(style),
      textDirection: TextDirection.ltr,
    );
    add(_renderParagraph);
  }

  void _rebuild() {
    _renderParagraph.text = createTextSpanWithStyle(text, style);
    _renderParagraph.textAlign = getTextAlignFromStyle(style);
    _renderParagraph.markNeedsLayout();
  }

  RenderParagraph _renderParagraph;
  int nodeId;
  String _text;
  String get text => _text;
  set text(String newText) {
    _text = newText;
    _rebuild();
  }

  Style _style;
  Style get style => _style;
  set style(Style newStyle) {
    _style = newStyle;
    _rebuild();
  }

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
    var currentNode = nodeMap[nodeId];
    var parentNode = currentNode.parentNode;
    double constraintWidth = getElementWidth(parentNode.nodeId);
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

