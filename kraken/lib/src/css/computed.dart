import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

mixin CSSComputedMixin on RenderBox {
  // Get max width of element, use width if exist,
  // or find the width of the nearest ancestor with width
  static double getElementComputedMaxWidth(int targetId) {
    double width;
    double cropWidth = 0;
    Element child = getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = _getElementRealDisplayValue(targetId);

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += childNode.cropBorderWidth;
      cropWidth += childNode.cropPaddingWidth;
    }

    // Get width of element if it's not inline
    if (display != 'inline' && style.contains('width')) {
      width = CSSLength.toDisplayPortValue(style['width']);
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
          String display = _getElementRealDisplayValue(child.targetId);
          if (style.contains('width') && display != 'inline') {
            width = CSSLength.toDisplayPortValue(style['width']);
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
  double getElementComputedWidth(int targetId) {
    double width;
    double cropWidth = 0;
    Element child = getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = _getElementRealDisplayValue(targetId);

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += childNode.cropBorderWidth;
      cropWidth += childNode.cropPaddingWidth;
    }

    switch (display) {
      case 'block':
      case 'flex':
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains('width')) {
          width = CSSLength.toDisplayPortValue(style['width']);
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
              String display = _getElementRealDisplayValue(child.targetId);

              // Set width of element according to parent display
              if (display != 'inline') { // Skip to find upper parent
                if (style.contains('width')) { // Use style width
                  width = CSSLength.toDisplayPortValue(style['width']);
                  cropPaddingBorder(child);
                  break;
                } else if (display == 'inline-block' ||
                    display == 'inline-flex') { // Collapse width to children
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
          width = CSSLength.toDisplayPortValue(style['width']);
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
  double getElementComputedHeight(int targetId) {
    double height;
    Element child = getEventTargetByTargetId<Element>(targetId);
    CSSStyleDeclaration style = child.style;
    String display = _getElementRealDisplayValue(targetId);
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      cropHeight += childNode.cropMarginHeight;
    }

    void cropPaddingBorder(Element childNode) {
      cropHeight += childNode.cropBorderHeight;
      cropHeight += childNode.cropPaddingHeight;
    }

    // inline element has no height
    if (display == 'inline') {
      return null;
    } else if (style.contains('height')) {
      if (child is Element) {
        height = CSSLength.toDisplayPortValue(style['height']);
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
              height = CSSLength.toDisplayPortValue(style['height']);
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
      (!style.contains('alignItems') ||
        (style.contains('alignItems') && style['alignItems'] == 'stretch'))
    ) {
      isStretch = true;
    }

    return isStretch;
  }

  // Element tree hierarchy can cause element display behavior to change,
  // for example element which is flex-item can display like inline-block or block
  static String _getElementRealDisplayValue(int targetId) {
    Element element = getEventTargetByTargetId<Element>(targetId);
    Element parentNode = element.parentNode;
    String display = isEmptyStyleValue(element.style['display'])
        ? element.defaultDisplay
        : element.style['display'];
    String position = element.style['position'];

    // Display as inline-block when element is positioned
    if (position == 'absolute' ||
      position == 'fixed'
      ) {
      display = 'inline-block';
    } else if (parentNode != null) {
      CSSStyleDeclaration style = parentNode.style;

      if (style['display'].endsWith('flex')) {
        // Display as inline-block if parent node is flex
        display = 'inline-block';

        // Display as block if flex vertical layout children and stretch children
        if (style['flexDirection'] == 'column' &&
          (!style.contains('alignItems') ||
            (style.contains('alignItems') && style['alignItems'] == 'stretch'))
        ) {
          display = 'block';
        }
      }
    }

    return display;
  }
}
