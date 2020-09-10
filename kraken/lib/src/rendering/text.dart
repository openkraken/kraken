/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
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
    _renderParagraph = RenderParagraph(
      text,
      textDirection: TextDirection.ltr,
    );

    child = _renderParagraph;
  }

  RenderParagraph _renderParagraph;
  int targetId;
  CSSStyleDeclaration style;
  ElementManager elementManager;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  set text(InlineSpan value) {
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

  WhiteSpace _whiteSpace;
  WhiteSpace get whiteSpace {
    return _whiteSpace;
  }
  set whiteSpace(WhiteSpace value) {
    if (value == whiteSpace) return;
    _whiteSpace = value;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints boxConstraints;
      Node hostTextNode = elementManager.getEventTargetByTargetId<EventTarget>(targetId);
      Element parentElement = hostTextNode.parent;
      final double contentWidth = parentElement.renderBoxModel.getContentWidth();

      if (parentElement.style[DISPLAY] == NONE) {
        boxConstraints = BoxConstraints(
          minWidth: 0,
          maxWidth: 0,
          minHeight: 0,
          maxHeight: 0,
        );
      } else if (contentWidth != null && (whiteSpace != WhiteSpace.nowrap || _renderParagraph.overflow == TextOverflow.ellipsis)) {
        boxConstraints = BoxConstraints(
          minWidth: 0,
          maxWidth: contentWidth,
          minHeight: 0,
          maxHeight: double.infinity
        );
      } else {
        boxConstraints = constraints;
      }
      child.layout(boxConstraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return _renderParagraph.computeDistanceToActualBaseline(TextBaseline.ideographic);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}
