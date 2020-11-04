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

mixin CSSSizingMixin {

  void updateRenderSizing(RenderBoxModel renderBoxModel, CSSStyleDeclaration style, String property, String present) {
    assert(renderBoxModel != null, 'RenderBoxModel should not be null');
    double value = CSSLength.toDisplayPortValue(present);

    switch (property) {
      case WIDTH:
        renderBoxModel.width = value;
        break;
      case HEIGHT:
        renderBoxModel.height = value;
        break;
      case MIN_HEIGHT:
        renderBoxModel.minHeight = getMinHeight(value);
        // max-height should not exceed min-height
        double maxHeight = renderBoxModel.maxHeight;
        if (maxHeight != null) {
          renderBoxModel.maxHeight = getMaxHeight(maxHeight, value);
        }
        break;
      case MAX_HEIGHT:
        renderBoxModel.maxHeight = getMaxHeight(value, renderBoxModel.minHeight);
        break;
      case MIN_WIDTH:
        renderBoxModel.minWidth = getMinWidth(value);
        // max-width should not exceed min-midth
        double maxWidth = renderBoxModel.maxWidth;
        if (maxWidth != null) {
          renderBoxModel.maxWidth = getMaxWidth(maxWidth, value);
        }
        break;
      case MAX_WIDTH:
        renderBoxModel.maxWidth = getMaxWidth(value, renderBoxModel.minWidth);
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

  static EdgeInsets _getMargin(CSSStyleDeclaration style) {
    double marginLeft;
    double marginTop;
    double marginRight;
    double marginBottom;

    if (style.contains(MARGIN_LEFT)) marginLeft = CSSLength.toDisplayPortValue(style[MARGIN_LEFT]);
    if (style.contains(MARGIN_TOP)) marginTop = CSSLength.toDisplayPortValue(style[MARGIN_TOP]);
    if (style.contains(MARGIN_RIGHT)) marginRight = CSSLength.toDisplayPortValue(style[MARGIN_RIGHT]);
    if (style.contains(MARGIN_BOTTOM)) marginBottom = CSSLength.toDisplayPortValue(style[MARGIN_BOTTOM]);

    return EdgeInsets.only(top: marginTop ?? 0.0, right: marginRight ?? 0.0, bottom: marginBottom ?? 0.0, left: marginLeft ?? 0.0);
  }

  void updateRenderMargin(RenderBoxModel renderBoxModel, CSSStyleDeclaration style, String property, String present) {
    EdgeInsets prevMargin = renderBoxModel.margin;

    if (prevMargin != null) {

      double left = prevMargin.left;
      double top = prevMargin.top;
      double right = prevMargin.right;
      double bottom = prevMargin.bottom;

      double presentValue = CSSLength.toDisplayPortValue(present) ?? 0;

      // Can not use [EdgeInsets.copyWith], for zero cannot be replaced to value.
      switch (property) {
        case MARGIN_LEFT:
          left = presentValue;
          break;
        case MARGIN_TOP:
          top = presentValue;
          break;
        case MARGIN_BOTTOM:
          bottom = presentValue;
          break;
        case MARGIN_RIGHT:
          right = presentValue;
          break;
      }

      renderBoxModel.margin = EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    } else {
      renderBoxModel.margin = _getMargin(style);
    }
  }

  static EdgeInsets _getPadding(CSSStyleDeclaration style) {
    double paddingTop;
    double paddingRight;
    double paddingBottom;
    double paddingLeft;

    if (style.contains(PADDING_TOP)) paddingTop = CSSLength.toDisplayPortValue(style[PADDING_TOP]);
    if (style.contains(PADDING_RIGHT)) paddingRight = CSSLength.toDisplayPortValue(style[PADDING_RIGHT]);
    if (style.contains(PADDING_BOTTOM)) paddingBottom = CSSLength.toDisplayPortValue(style[PADDING_BOTTOM]);
    if (style.contains(PADDING_LEFT)) paddingLeft = CSSLength.toDisplayPortValue(style[PADDING_LEFT]);

    return EdgeInsets.only(
      top: paddingTop ?? 0.0,
      right: paddingRight ?? 0.0,
      bottom: paddingBottom ?? 0.0,
      left: paddingLeft ?? 0.0
    );
  }

  void updateRenderPadding(RenderBoxModel renderBoxModel, CSSStyleDeclaration style, String property, String present) {
    EdgeInsets prevPadding = renderBoxModel.padding;

    if (prevPadding != null) {
      double left = prevPadding.left;
      double top = prevPadding.top;
      double right = prevPadding.right;
      double bottom = prevPadding.bottom;

      double presentValue = CSSLength.toDisplayPortValue(present) ?? 0;

      // Can not use [EdgeInsets.copyWith], for zero cannot be replaced to value.
      switch (property) {
        case PADDING_LEFT:
          left = presentValue;
          break;
        case PADDING_TOP:
          top = presentValue;
          break;
        case PADDING_BOTTOM:
          bottom = presentValue;
          break;
        case PADDING_RIGHT:
          right = presentValue;
          break;
      }

      renderBoxModel.padding = EdgeInsets.only(left: left, right: right, bottom: bottom, top: top);
    } else {
      renderBoxModel.padding = _getPadding(style);
    }
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
  // Get max width of element, use width if exist,
  // or find the width of the nearest ancestor with width
  static double getElementComputedMaxWidth(RenderBoxModel renderBoxModel, int targetId, ElementManager elementManager) {
    double width;
    double cropWidth = 0;
    CSSDisplay display = getElementRealDisplayValue(targetId, elementManager);

    void cropMargin(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.margin != null) {
        cropWidth += renderBoxModel.margin.horizontal;
      }
    }

    void cropPaddingBorder(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.borderEdge != null) {
        cropWidth += renderBoxModel.borderEdge.horizontal;
      }
      if (renderBoxModel.padding != null) {
        cropWidth += renderBoxModel.padding.horizontal;
      }
    }

    // Get width of element if it's not inline
    if (display != CSSDisplay.inline && renderBoxModel.width != null) {
      width = renderBoxModel.width;
      cropPaddingBorder(renderBoxModel);
    } else {
      // Get the nearest width of ancestor with width
      while (true) {
        if (renderBoxModel.parent != null && renderBoxModel.parent is RenderBoxModel) {
          cropMargin(renderBoxModel);
          cropPaddingBorder(renderBoxModel);
          renderBoxModel = renderBoxModel.parent;
        } else {
          break;
        }
        if (renderBoxModel is RenderBoxModel) {
          CSSDisplay display = getElementRealDisplayValue(renderBoxModel.targetId, elementManager);
          if (renderBoxModel.width != null && display != CSSDisplay.inline) {
            width = renderBoxModel.width;
            cropPaddingBorder(renderBoxModel);
            break;
          }
        }
      }
    }

    if (width != null) {
      return width - cropWidth;
    } else {
      return null;
    }
  }

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
        (current as RenderFlexLayout).flexDirection
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
    CSSPositionType position = CSSPositionedLayout.parsePositionType(element.style[POSITION]);

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
