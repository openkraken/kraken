import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

mixin RenderSizingHelper on RenderBox {
  // Get max width of element, use width if exist,
  // or find the width of the nearest ancestor with width
  static double getElementComputedMaxWidth(int targetId, ElementManager elementManager) {
    double width;
    double cropWidth = 0;
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = getElementRealDisplayValue(targetId, elementManager);

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
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
}
