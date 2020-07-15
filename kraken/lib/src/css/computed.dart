import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

mixin CSSComputedMixin on RenderBox {
  // Get max width of element, use width if exist,
  // or find the width of the nearest ancestor with width
  static double getElementComputedMaxWidth(int targetId, ElementManager elementManager) {
    double width;
    double cropWidth = 0;
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = _getElementRealDisplayValue(targetId, elementManager);

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += childNode.cropBorderWidth;
      cropWidth += childNode.cropPaddingWidth;
    }

    // Get width of element if it's not inline
    if (display != 'inline' && style.contains('width')) {
      width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
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
          String display = _getElementRealDisplayValue(child.targetId, elementManager);
          if (style.contains('width') && display != 'inline') {
            width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
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
    String display = _getElementRealDisplayValue(targetId, elementManager);

    double width = CSSLength.toDisplayPortValue(style['width']);
    double minWidth = CSSLength.toDisplayPortValue(style['minWidth']);
    double maxWidth = CSSLength.toDisplayPortValue(style['maxWidth']);

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += childNode.cropBorderWidth;
      cropWidth += childNode.cropPaddingWidth;
    }

    if (minWidth != null && (width == null || width < minWidth)) {
      width = minWidth;
    } else if (maxWidth != null && (width == null || width > maxWidth)) {
      width = maxWidth;
    }

    switch (display) {
      case 'block':
      case 'flex':
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains('width')) {
          width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
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
              String display = _getElementRealDisplayValue(child.targetId, elementManager);

              // Set width of element according to parent display
              if (display != 'inline') {
                // Skip to find upper parent
                if (style.contains('width')) {
                  // Use style width
                  width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
                  cropPaddingBorder(child);
                  break;
                } else if (display == 'inline-block' || display == 'inline-flex') {
                  // Collapse width to children
                  width = null;
                  break;
                }
              }
            }
          }
        }
        break;
      case 'inline-block':
      case 'inline-flex':
        if (style.contains('width')) {
          width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
          cropPaddingBorder(child);
        } else {
          width = null;
        }
        break;
      case 'inline':
        width = null;
        break;
      default:
        break;
    }

    if (width != null) {
      return width - cropWidth;
    } else {
      return null;
    }
  }

  // Get element width according to element tree
  double getElementComputedHeight(int targetId, ElementManager elementManager) {
    Element child = elementManager.getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = _getElementRealDisplayValue(targetId, elementManager);
    double height = CSSLength.toDisplayPortValue(style['height']);
    double minHeight = CSSLength.toDisplayPortValue(style['minHeight']);
    double maxHeight = CSSLength.toDisplayPortValue(style['maxHeight']);
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      cropHeight += childNode.cropMarginHeight;
    }

    void cropPaddingBorder(Element childNode) {
      cropHeight += childNode.cropBorderHeight;
      cropHeight += childNode.cropPaddingHeight;
    }

    if (minHeight != null && (height == null || height < minHeight)) {
      height = minHeight;
    } else if (maxHeight != null && (height == null || height > maxHeight)) {
      height = maxHeight;
    }

    // inline element has no height
    if (display == 'inline') {
      return null;
    } else if (style.contains('height')) {
      if (child is Element) {
        height = CSSLength.toDisplayPortValue(style['height']) ?? 0;
        cropPaddingBorder(child);
      }
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
          if (_isStretchChildrenHeight(child)) {
            if (style.contains('height')) {
              height = CSSLength.toDisplayPortValue(style['height']) ?? 0;
              cropPaddingBorder(child);
              break;
            } else {
              if (child.renderPadding.hasSize) {
                height = child.renderPadding.size.height;
                cropPaddingBorder(child);
                break;
              }
            }
          } else {
            break;
          }
        }
      }
    }

    if (height != null) {
      return height - cropHeight;
    } else {
      return null;
    }
  }

  // Whether current node should stretch children's height
  static bool _isStretchChildrenHeight(Element element) {
    bool isStretch = false;
    CSSStyleDeclaration style = element.style;
    String display = style['display'];
    bool isFlex = display == 'flex' || display == 'inline-flex';
    if (isFlex &&
        style['flexDirection'] == 'row' &&
        (!style.contains('alignItems') || (style.contains('alignItems') && style['alignItems'] == 'stretch'))) {
      isStretch = true;
    }

    return isStretch;
  }

  // Element tree hierarchy can cause element display behavior to change,
  // for example element which is flex-item can display like inline-block or block
  static String _getElementRealDisplayValue(int targetId, ElementManager elementManager) {
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
    Element parentNode = element.parentNode;
    String display = CSSStyleDeclaration.isNullOrEmptyValue(element.style['display'])
        ? element.defaultDisplay
        : element.style['display'];
    String position = element.style['position'];

    // Display as inline-block when element is positioned
    if (position == 'absolute' || position == 'fixed') {
      display = 'inline-block';
    } else if (parentNode != null) {
      CSSStyleDeclaration style = parentNode.style;

      if (style['display'].endsWith('flex')) {
        // Display as inline-block if parent node is flex
        display = 'inline-block';

        // Display as block if flex vertical layout children and stretch children
        if (style['flexDirection'] == 'column' &&
            (!style.contains('alignItems') || (style.contains('alignItems') && style['alignItems'] == 'stretch'))) {
          display = 'block';
        }
      }
    }

    return display;
  }
}
