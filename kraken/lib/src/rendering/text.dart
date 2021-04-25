/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

class TextParentData extends ContainerBoxParentData<RenderBox> {}

enum WhiteSpace {
  normal,
  nowrap,
  pre,
  preWrap,
  preLine,
  breakSpaces
}

class RenderTextBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(InlineSpan text, {
    this.targetId,
    this.style,
    this.elementManager,
  }) : assert(text != null) {
    _renderParagraph = KrakenRenderParagraph(
      text,
      textDirection: TextDirection.ltr,
    );

    child = _renderParagraph;
  }

  KrakenRenderParagraph _renderParagraph;
  int targetId;
  CSSStyleDeclaration style;
  ElementManager elementManager;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  // Auto value for min-width
  double autoMinWidth = 0;
  // Auto value for min-height
  double autoMinHeight = 0;

  set text(TextSpan value) {
    assert(_renderParagraph != null);
    _renderParagraph.text = value;
  }

  set textAlign(TextAlign value) {
    assert(_renderParagraph != null);
    _renderParagraph.textAlign = value;
  }

  set overflow(TextOverflow value) {
    assert(_renderParagraph != null);
    _renderParagraph.overflow = value;
  }

  set maxLines(int value) {
    assert(_renderParagraph != null);
    // Forcing a break after a set number of lines
    // https://drafts.csswg.org/css-overflow-3/#max-lines
    _renderParagraph.maxLines = value;
  }

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size _boxSize;
  Size get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  WhiteSpace _whiteSpace;
  WhiteSpace get whiteSpace {
    return _whiteSpace;
  }
  set whiteSpace(WhiteSpace value) {
    if (value == whiteSpace) return;
    _whiteSpace = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  BoxConstraints getConstraints() {
    RenderBoxModel parentRenderBoxModel = parent;
    double maxConstraintWidth = RenderBoxModel.getMaxConstraintWidth(parentRenderBoxModel) ?? double.infinity;
    if (whiteSpace == WhiteSpace.nowrap && _renderParagraph.overflow != TextOverflow.ellipsis) {
      return BoxConstraints();
    }
    return BoxConstraints(
      minWidth: 0,
      maxWidth: maxConstraintWidth,
      minHeight: 0,
      maxHeight: double.infinity
    );
  }

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;

      // @FIXME: minimum size of text is wrong
      autoMinWidth = size.width;
      autoMinHeight = size.height;
    } else {
      performResize();
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  double computeDistanceToBaseline() {
    return parent is RenderFlowLayout ?
      _renderParagraph.computeDistanceToLastLineBaseline() :
      _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToFirstLineBaseline() {
    return _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToLastLineBaseline() {
    return _renderParagraph.computeDistanceToLastLineBaseline();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child, offset);
    }
  }

  // Text node need hittest self to trigger scroll
  @override
  bool hitTest(BoxHitTestResult result, { Offset position }) {
    return hasSize && size.contains(position);
  }
}
