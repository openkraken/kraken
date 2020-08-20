/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

enum Display {
  inline,
  block,
  inlineBlock,
  flex,
  inlineFlex
}

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height

mixin CSSSizingMixin {

  void updateRenderSizing(RenderBoxModel renderBoxModel, CSSStyleDeclaration style, String property, String present) {
    double value = CSSLength.toDisplayPortValue(present) ?? 0;

    switch (property) {
      case WIDTH:
        renderBoxModel.width = value;
        break;
      case HEIGHT:
        renderBoxModel.height = value;
        break;
      case MIN_HEIGHT:
        renderBoxModel.minHeight = value;
        break;
      case MAX_HEIGHT:
        renderBoxModel.maxHeight = value;
        break;
      case MIN_WIDTH:
        renderBoxModel.minWidth = value;
        break;
      case MAX_WIDTH:
        renderBoxModel.maxWidth = value;
        break;
    }
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

    EdgeInsets margin = renderBoxModel.margin;

    if (margin != null) {
      switch (property) {
        case MARGIN_LEFT:
          margin = margin.copyWith(left: CSSLength.toDisplayPortValue(present));
          break;
        case MARGIN_TOP:
          margin = margin.copyWith(top: CSSLength.toDisplayPortValue(present));
          break;
        case MARGIN_BOTTOM:
          margin = margin.copyWith(bottom: CSSLength.toDisplayPortValue(present));
          break;
        case MARGIN_RIGHT:
          margin = margin.copyWith(right: CSSLength.toDisplayPortValue(present));
          break;
        case MARGIN:
          margin = _getMargin(style);
          break;
      }
  
      renderBoxModel.margin = margin;
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

    EdgeInsets padding = renderBoxModel.padding;

    if (padding != null) {
      switch (property) {
        case PADDING_LEFT:
          padding = padding.copyWith(left: CSSLength.toDisplayPortValue(present));
          break;
        case PADDING_TOP:
          padding = padding.copyWith(top: CSSLength.toDisplayPortValue(present));
          break;
        case PADDING_BOTTOM:
          padding = padding.copyWith(bottom: CSSLength.toDisplayPortValue(present));
          break;
        case PADDING_RIGHT:
          padding = padding.copyWith(right: CSSLength.toDisplayPortValue(present));
          break;
        case PADDING:
          padding = _getPadding(style);
          break;
      }
  
      renderBoxModel.padding = padding;
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
  static double getElementComputedMaxWidth(int targetId, ElementManager elementManager) {
    double width;
    double cropWidth = 0;
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = getElementRealDisplayValue(targetId, elementManager);

    void cropMargin(Element childNode) {
      RenderBoxModel renderBoxModel = childNode.getRenderBoxModel();
      if (renderBoxModel.margin != null) {
        cropWidth += renderBoxModel.margin.horizontal;
      }
    }

    void cropPaddingBorder(Element childNode) {
      RenderBoxModel renderBoxModel = childNode.getRenderBoxModel();
      if (renderBoxModel.borderEdge != null) {
        cropWidth += renderBoxModel.borderEdge.horizontal;
      }
      if (renderBoxModel.padding != null) {
        cropWidth += renderBoxModel.padding.horizontal;
      }
    }

    // Get width of element if it's not inline
    if (display != INLINE && style.contains(WIDTH)) {
      width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
      cropPaddingBorder(child);
    } else {
      // Get the nearest width of ancestor with width
      while (true) {
        if (child.parentNode != null) {
          cropMargin(child);
          cropPaddingBorder(child);
          child = child.parentNode;
        } else {
          break;
        }
        if (child is Element) {
          CSSStyleDeclaration style = child.style;
          String display = getElementRealDisplayValue(child.targetId, elementManager);
          if (style.contains(WIDTH) && display != INLINE) {
            width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
            cropPaddingBorder(child);
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
  static bool isStretchChildHeight(Element current, Element child) {
    bool isStretch = false;
    CSSStyleDeclaration style = current.style;
    CSSStyleDeclaration childStyle = child.style;
    bool isFlex = style[DISPLAY].endsWith(FLEX);
    bool isHoriontalDirection = !style.contains(FLEX_DIRECTION) ||
        style[FLEX_DIRECTION] == ROW;
    bool isAlignItemsStretch = !style.contains(ALIGN_ITEMS) ||
        style[ALIGN_ITEMS] == STRETCH;
    bool isFlexNoWrap = style[FLEX_WRAP] != WRAP &&
        style[FLEX_WRAP] != WRAP_REVERSE;
    bool isChildAlignSelfStretch = childStyle[ALIGN_SELF] == STRETCH;

    if (isFlex && isHoriontalDirection && isFlexNoWrap && (isAlignItemsStretch || isChildAlignSelfStretch)) {
      isStretch = true;
    }

    return isStretch;
  }

  // Element tree hierarchy can cause element display behavior to change,
  // for example element which is flex-item can display like inline-block or block
  static String getElementRealDisplayValue(int targetId, ElementManager elementManager) {
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
    Element parentNode = element.parentNode;
    String display = CSSStyleDeclaration.isNullOrEmptyValue(element.style[DISPLAY])
        ? element.defaultDisplay
        : element.style[DISPLAY];
    String position = element.style[POSITION];

    // Display as inline-block when element is positioned
    if (position == ABSOLUTE || position == FIXED) {
      display = INLINE_BLOCK;
    } else if (parentNode != null) {
      CSSStyleDeclaration style = parentNode.style;

      if (style[DISPLAY].endsWith(FLEX)) {
        // Display as inline-block if parent node is flex
        display = INLINE_BLOCK;

        // Display as block if flex vertical layout children and stretch children
        if (style[FLEX_DIRECTION] == COLUMN &&
            (!style.contains(ALIGN_ITEMS) || (style.contains(ALIGN_ITEMS) && style[ALIGN_ITEMS] == STRETCH))) {
          display = BLOCK;
        }
      }
    }

    return display;
  }

  static Display getDisplay(String displayString) {
    Display display = Display.inline;
    if (displayString == null) {
      return display;
    }

    switch(displayString) {
      case 'block':
        return Display.block;
      case 'inline-block':
        return Display.inlineBlock;
      case 'flex':
        return Display.flex;
      case 'inline-flex':
        return Display.inlineFlex;
      case 'inline':
      default:
        return Display.inline;
    }
  }
}
