import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Get constrain width of element
  static double getConstrainedWidth(int nodeId) {
    String width;
    double cropWidth = 0;
    Element child = nodeMap[nodeId];
    StyleDeclaration style = child.style;
    String display = getElementDisplay(nodeId);

    void cropMargin(Element childNode) {
      cropWidth += (childNode.cropMarginWidth ?? 0);
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += (childNode.cropBorderWidth ?? 0);
      cropWidth += (childNode.cropPaddingWidth ?? 0);
    }

    // Get width of element if it's not inline
    if (display != 'inline' && style.contains('width')) {
      width = style['width'];
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
          StyleDeclaration style = child.style;
          String display = getElementDisplay(child.nodeId);
          if (style.contains('width') && display != 'inline') {
            width = style['width'];
            cropPaddingBorder(child);
            break;
          }
        }
      }
    }

    if (width != null) {
      return Length.toDisplayPortValue(width) - cropWidth;
    } else {
      return null;
    }
  }

  // Get element width according to element tree
  double getElementWidth(int nodeId) {
    String width;
    double cropWidth = 0;
    Element child = nodeMap[nodeId];
    StyleDeclaration style = child.style;
    String display = getElementDisplay(nodeId);

    void cropMargin(Element childNode) {
      cropWidth += (childNode.cropMarginWidth ?? 0);
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += (childNode.cropBorderWidth ?? 0);
      cropWidth += (childNode.cropPaddingWidth ?? 0);
    }

    switch (display) {
      case 'block':
      case 'flex':
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains('width')) {
          width = style['width'];
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
              StyleDeclaration style = child.style;
              String display = getElementDisplay(child.nodeId);
              if (style.contains('width') && display != 'inline') {
                width = style['width'];
                cropPaddingBorder(child);
                break;
              }
            }
          }
        }
        break;
      case 'inline-block':
      case 'inline-flex':
        if (style.contains('width')) {
          width = style['width'];
          cropPaddingBorder(child);
        }
        break;
      case 'inline':
        width = null;
        break;
      default:
        break;
    }

    if (width != null) {
      return Length.toDisplayPortValue(width) - cropWidth;
    } else {
      return null;
    }
  }

  // Get element width according to element tree
  double getElementHeight(int nodeId) {
    String height;
    Element child = nodeMap[nodeId];
    StyleDeclaration style = child.style;
    String display = getElementDisplay(nodeId);
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      cropHeight += (childNode.cropMarginHeight ?? 0);
    }

    void cropPaddingBorder(Element childNode) {
      cropHeight += (childNode.cropBorderHeight ?? 0);
      cropHeight += (childNode.cropPaddingHeight ?? 0);
    }

    // inline element has no height
    if (display == 'inline') {
      return null;
    } else if (style.contains('height')) {
      if (child is Element) {
        height = style['height'];
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
          StyleDeclaration style = child.style;
          if (isStretchChildrenHeight(child)) {
            if (style.contains('height')) {
              height = style['height'];
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
      return Length.toDisplayPortValue(height) - cropHeight;
    } else {
      return null;
    }
  }

  // Whether current node should stretch children's height
  bool isStretchChildrenHeight(Element currentNode) {
    bool isStretch = false;
    StyleDeclaration style = currentNode.style;
    String display = getElementDisplay(currentNode.nodeId);
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

  // Get element display according to element hierarchy
  static String getElementDisplay(int nodeId) {
    Element element = nodeMap[nodeId];
    Element parentNode = element.parentNode;
    String display = isEmptyStyleValue(element.style['display'])
        ? element.defaultDisplay
        : element.style['display'];

    if (parentNode != null) {
      StyleDeclaration style = parentNode.style;

      // Display as inline-block if parent node is flex
      if (style['display'].endsWith('flex')) {
        display = 'inline-block';
      }

      // Display as block when following conditions met
      if (style['flexDirection'] == 'column' &&
        (!style.contains('alignItems') ||
          (style.contains('alignItems') && style['alignItems'] == 'stretch'))
      ) {
        display = 'block';
      }
    }

    return display;
  }
}
