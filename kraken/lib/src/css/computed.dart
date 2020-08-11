import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'dart:math' as math;

mixin CSSComputedMixin on RenderBox {
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

  // Get element width according to element tree
  double getElementComputedWidth(int targetId, ElementManager elementManager) {
    double cropWidth = 0;
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = getElementRealDisplayValue(targetId, elementManager);

    double width = CSSLength.toDisplayPortValue(style[WIDTH]);
    double minWidth = CSSLength.toDisplayPortValue(style[MIN_WIDTH]);
    double maxWidth = CSSLength.toDisplayPortValue(style[MAX_WIDTH]);


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

    if (minWidth != null && (width == null || width < minWidth)) {
      width = minWidth;
    } else if (maxWidth != null && (width == null || width > maxWidth)) {
      width = maxWidth;
    }

    switch (display) {
      case BLOCK:
      case FLEX:
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains(WIDTH)) {
          width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
          cropPaddingBorder(child);
        } else {
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

              // Set width of element according to parent display
              if (display != INLINE) {
                // Skip to find upper parent
                if (style.contains(WIDTH)) {
                  // Use style width
                  width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
                  cropPaddingBorder(child);
                  break;
                } else if (display == INLINE_BLOCK || display == INLINE_FLEX) {
                  // Collapse width to children
                  width = null;
                  break;
                }
              }
            }
          }
        }
        break;
      case INLINE_BLOCK:
      case INLINE_FLEX:
        if (style.contains(WIDTH)) {
          width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
          cropPaddingBorder(child);
        } else {
          width = null;
        }
        break;
      case INLINE:
        width = null;
        break;
      default:
        break;
    }

    if (width != null) {
      return math.max(0, width - cropWidth);
    } else {
      return null;
    }
  }

  // Get element height according to element tree
  double getElementComputedHeight(int targetId, ElementManager elementManager) {
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = getElementRealDisplayValue(targetId, elementManager);
    double height = CSSLength.toDisplayPortValue(style[HEIGHT]);
    double minHeight = CSSLength.toDisplayPortValue(style[MIN_HEIGHT]);
    double maxHeight = CSSLength.toDisplayPortValue(style[MAX_HEIGHT]);
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      RenderBoxModel renderBoxModel = childNode.getRenderBoxModel();
      if (renderBoxModel.margin != null) {
        cropHeight += renderBoxModel.margin.vertical;
      }
    }

    void cropPaddingBorder(Element childNode) {
      RenderBoxModel renderBoxModel = childNode.getRenderBoxModel();
      if (renderBoxModel.borderEdge != null) {
        cropHeight += renderBoxModel.borderEdge.vertical;
      }
      if (renderBoxModel.padding != null) {
        cropHeight += renderBoxModel.padding.vertical;
      }
    }

    if (minHeight != null && (height == null || height < minHeight)) {
      height = minHeight;
    } else if (maxHeight != null && (height == null || height > maxHeight)) {
      height = maxHeight;
    }

    // inline element has no height
    if (display == INLINE) {
      return null;
    } else if (style.contains(HEIGHT)) {
      if (child is Element) {
        height = CSSLength.toDisplayPortValue(style[HEIGHT]) ?? 0;
        cropPaddingBorder(child);
      }
    } else {
      while (true) {
        Element current;
        if (child.parentNode != null) {
          cropMargin(child);
          cropPaddingBorder(child);
          current = child;
          child = child.parentNode;
        } else {
          break;
        }
        if (child is Element) {
          CSSStyleDeclaration style = child.style;
          if (_isStretchChildHeight(child, current)) {
            if (style.contains(HEIGHT)) {
              height = CSSLength.toDisplayPortValue(style[HEIGHT]) ?? 0;
              cropPaddingBorder(child);
              break;
            }
          } else {
            break;
          }
        }
      }
    }
    if (height != null) {
      return math.max(0, height - cropHeight);
    } else {
      return null;
    }
  }

  // Whether current node should stretch children's height
  static bool _isStretchChildHeight(Element current, Element child) {
    bool isStretch = false;
    CSSStyleDeclaration style = current.style;
    CSSStyleDeclaration childStyle = child.style;
    bool isFlex = style[DISPLAY].endsWith(FLEX);
    bool isHoriontalDirection = !style.contains(FLEX_DIRECTION) || style[FLEX_DIRECTION] == ROW;
    bool isAlignItemsStretch = !style.contains(ALIGN_ITEMS) || style[ALIGN_ITEMS] == STRETCH;
    bool isFlexNoWrap = style[FLEX_WRAP] != WRAP && style[FLEX_WRAP] != WRAP_REVERSE;
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
