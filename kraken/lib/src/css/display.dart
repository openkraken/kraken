/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

enum CSSDisplay {
  inline,
  block,
  inlineBlock,

  flex,
  inlineFlex,

  sliver, // @TODO temp name.

  none
}

mixin CSSDisplayMixin on RenderStyleBase {

  CSSDisplay _display;
  CSSDisplay get display => _display;
  set display(CSSDisplay value) {
    if (value == null) return;
    if (_display != value) {
      renderBoxModel.markNeedsLayout();
      _display = value;
    }
  }
  /// Some layout effects require blockification or inlinification of the box type
  /// https://www.w3.org/TR/css-display-3/#transformations
  CSSDisplay transformedDisplay;

  void updateDisplay(String value, Element element) {
    CSSDisplay originalDisplay = display;
    CSSDisplay presentDisplay = getDisplay(
      CSSStyleDeclaration.isNullOrEmptyValue(value) ? element.defaultDisplay : value
    );
    display = presentDisplay;
    transformedDisplay = getTransformedDisplay(element);
    if (originalDisplay != presentDisplay && renderBoxModel is RenderLayoutBox) {
      RenderLayoutBox prevRenderLayoutBox = renderBoxModel;
      renderBoxModel = element.createRenderLayout(element, prevRenderLayoutBox: prevRenderLayoutBox, repaintSelf: element.repaintSelf);
      bool shouldReattach = element.isRendererAttached && element.parent != null && prevRenderLayoutBox != renderBoxModel;

      if (shouldReattach) {
        RenderLayoutBox parentRenderObject = element.parent.renderBoxModel;
        Element previousSibling = element.previousSibling;
        RenderObject previous = previousSibling != null ? previousSibling.renderer : null;

        parentRenderObject.remove(prevRenderLayoutBox);
        parentRenderObject.insert(renderBoxModel, after: previous);
      } else {
        renderBoxModel.markNeedsLayout();
      }
    }
  }

  static CSSDisplay getDisplay(String displayString) {
    switch (displayString) {
      case 'none':
        return CSSDisplay.none;
      case 'sliver':
        return CSSDisplay.sliver;
      case 'block':
        return CSSDisplay.block;
      case 'inline-block':
        return CSSDisplay.inlineBlock;
      case 'flex':
        return CSSDisplay.flex;
      case 'inline-flex':
        return CSSDisplay.inlineFlex;
      case 'inline':
      default:
        return CSSDisplay.inline;
    }
  }

  /// Element tree hierarchy can cause element display behavior to change,
  /// for example element which is flex-item can display like inline-block or block
  /// https://www.w3.org/TR/css-display-3/#transformations
  static CSSDisplay getTransformedDisplay(Element element) {
    Element parentNode = element.parentNode;
    CSSDisplay display = element.renderBoxModel.renderStyle.display;

    CSSPositionType position = element.renderBoxModel.renderStyle.position;

    // Display as inline-block when element is positioned
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      display = CSSDisplay.inlineBlock;
    } else if (parentNode != null) {
      CSSStyleDeclaration style = parentNode.style;

      if (style[DISPLAY].endsWith(FLEX)) {
        // Display as inline-block if parent node is flex
        display = CSSDisplay.inlineBlock;

        String marginLeft = element.style[MARGIN_LEFT];
        String marginRight = element.style[MARGIN_RIGHT];

        bool isVerticalDirection = style[FLEX_DIRECTION] == COLUMN || style[FLEX_DIRECTION] == COLUMN_REVERSE;
        // Flex item will not stretch in stretch alignment when flex wrap is set to wrap or wrap-reverse
        bool isFlexNoWrap = !style.contains(FLEX_WRAP) || (style.contains(FLEX_WRAP) && style[FLEX_WRAP] == NO_WRAP);
        // Display as block if flex vertical layout children and stretch children
        if (marginLeft != AUTO && marginRight != AUTO && isVerticalDirection && isFlexNoWrap &&
          (!style.contains(ALIGN_ITEMS) || (style.contains(ALIGN_ITEMS) && style[ALIGN_ITEMS] == STRETCH))) {
          display = CSSDisplay.block;
        }
      }
    }

    return display;
  }
}
