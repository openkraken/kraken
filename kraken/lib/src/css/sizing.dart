/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

enum CSSDisplay {
  inline,
  block,
  inlineBlock,

  flex,
  inlineFlex,

  sliver, // @TODO temp name.

  none
}

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height

mixin CSSSizingMixin on RenderStyleBase {

  double _width;
  double get width {
    return _width;
  }
  set width(double value) {
    if (_width == value) return;
    _width = value;
    renderBoxModel.markNeedsLayout();
  }

  double _height;
  double get height {
    return _height;
  }
  set height(double value) {
    if (_height == value) return;
    _height = value;
    renderBoxModel.markNeedsLayout();
  }

  double _minWidth;
  double get minWidth {
    return _minWidth;
  }
  set minWidth(double value) {
    if (_minWidth == value) return;
    _minWidth = value;
    renderBoxModel.markNeedsLayout();
  }

  double _maxWidth;
  double get maxWidth {
    return _maxWidth;
  }
  set maxWidth(double value) {
    if (_maxWidth == value) return;
    _maxWidth = value;
    renderBoxModel.markNeedsLayout();
  }

  double _minHeight;
  double get minHeight {
    return _minHeight;
  }
  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    renderBoxModel.markNeedsLayout();
  }

  double _maxHeight;
  double get maxHeight {
    return _maxHeight;
  }
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    renderBoxModel.markNeedsLayout();
  }

  void updateSizing(String property, String present) {
    double value = CSSLength.toDisplayPortValue(present, viewportSize);
    RenderStyle renderStyle = this;
    switch (property) {
      case WIDTH:
        renderStyle.width = value;
        break;
      case HEIGHT:
        renderStyle.height = value;
        break;
      case MIN_HEIGHT:
        renderStyle.minHeight = getMinHeight(value);
        // max-height should not exceed min-height
        double maxHeight = renderStyle.maxHeight;
        if (maxHeight != null) {
          renderStyle.maxHeight = getMaxHeight(maxHeight, value);
        }
        break;
      case MAX_HEIGHT:
        renderStyle.maxHeight = getMaxHeight(value, renderStyle.minHeight);
        break;
      case MIN_WIDTH:
        renderStyle.minWidth = getMinWidth(value);
        // max-width should not exceed min-midth
        double maxWidth = renderStyle.maxWidth;
        if (maxWidth != null) {
          renderStyle.maxWidth = getMaxWidth(maxWidth, value);
        }
        break;
      case MAX_WIDTH:
        renderStyle.maxWidth = getMaxWidth(value, renderStyle.minWidth);
        break;
    }
  }

  double getMinWidth(double minWidth) {
    if (minWidth < 0)  {
      return null;
    }
    return minWidth;
  }

  double getMaxWidth(double maxWidth, double minWidth) {
    if (maxWidth < 0) {
      return null;
    }
    // max-width is invalid if max-width is smaller than min-width
    if (minWidth != null && minWidth > maxWidth) {
      return null;
    }
    return maxWidth;
  }

  double getMinHeight(double minHeight) {
    if (minHeight < 0)  {
      return null;
    }
    return minHeight;
  }

  double getMaxHeight(double maxHeight, double minHeight) {
    if (maxHeight < 0) {
      return null;
    }
    // max-height is invalid if max-height is smaller than min-height
    if (minHeight != null && minHeight > maxHeight) {
      return null;
    }
    return maxHeight;
  }
}

class CSSEdgeInsets {
  double left;
  double top;
  double right;
  double bottom;

  CSSEdgeInsets(this.top, this.right, this.bottom, this.left);

  EdgeInsets toEdgeInsets() {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

class CSSSizing {
  // Whether current node should stretch children's height
  static bool isStretchChildHeight(RenderBoxModel current, RenderBoxModel child) {
    bool isStretch = false;
    CSSStyleDeclaration style = current.style;
    CSSStyleDeclaration childStyle = child.style;
    bool isFlex = current is RenderFlexLayout;
    bool isHorizontalDirection = false;
    bool isAlignItemsStretch = false;
    bool isFlexNoWrap = false;
    bool isChildAlignSelfStretch = false;
    bool isChildStretchSelf = false;
    if (isFlex) {
      isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(
        (current as RenderFlexLayout).renderStyle.flexDirection
      );
      isAlignItemsStretch = !style.contains(ALIGN_ITEMS) ||
        style[ALIGN_ITEMS] == STRETCH;
      isFlexNoWrap = style[FLEX_WRAP] != WRAP &&
        style[FLEX_WRAP] != WRAP_REVERSE;
      isChildAlignSelfStretch = childStyle[ALIGN_SELF] == STRETCH;
      isChildStretchSelf = childStyle[ALIGN_SELF].isNotEmpty && childStyle[ALIGN_SELF] != AUTO ? isChildAlignSelfStretch : isAlignItemsStretch;
    }

    String marginTop = child.style[MARGIN_TOP];
    String marginBottom = child.style[MARGIN_BOTTOM];

    // Display as block if flex vertical layout children and stretch children
    if (marginTop != AUTO && marginBottom != AUTO &&
      isFlex && isHorizontalDirection && isFlexNoWrap && isChildStretchSelf) {
      isStretch = true;
    }

    return isStretch;
  }

  // Element tree hierarchy can cause element display behavior to change,
  // for example element which is flex-item can display like inline-block or block
  static CSSDisplay getElementRealDisplayValue(int targetId, ElementManager elementManager) {
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
    Element parentNode = element.parentNode;
    CSSDisplay display = CSSSizing.getDisplay(
        CSSStyleDeclaration.isNullOrEmptyValue(element.style[DISPLAY])
            ? element.defaultDisplay
            : element.style[DISPLAY]
    );

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
}
