import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Get element width according to element tree
  double getElementWidth(int nodeId) {
    String width;
    double cropWidth = 0;
    bool isParentWithWidth = false;
    var childNode = nodeMap[nodeId];
    Style style = childNode.style;
    String display = getElementDisplay(nodeId);

    void calCropWidth(Element childNode) {
      // minus margin and border
      cropWidth +=
          ((childNode.cropWidth ?? 0) + (childNode.cropBorderWidth ?? 0));

      // minus padding
      Padding padding = baseGetPaddingFromStyle(childNode.style);
      cropWidth += padding.left + padding.right;
    }

    void cropMargin(Element childNode) {
      cropWidth += (childNode.cropWidth ?? 0);
    }

    void cropPaddingBorder(Element childNode) {
      // minus border
      cropWidth += (childNode.cropBorderWidth ?? 0);
      // minus padding
      Padding padding = baseGetPaddingFromStyle(childNode.style);
      cropWidth += padding.left + padding.right;
    }

    switch (display) {
      case 'block':
      case 'flex':
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains('width')) {
          width = style['width'];
          cropPaddingBorder(childNode);
        } else {
          while (true) {
            if (childNode.parentNode != null) {
              cropMargin(childNode);
              cropPaddingBorder(childNode);
              childNode = childNode.parentNode;
            } else {
              break;
            }
            if (childNode is Element) {
              Style style = childNode.style;
              String display = getElementDisplay(childNode.nodeId);
              if (style.contains('width') && display != 'inline') {
                width = style['width'];
                cropPaddingBorder(childNode);
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
          cropPaddingBorder(childNode);
          // calCropWidth(childNode);
        }
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
    var childNode = nodeMap[nodeId];
    Style style = childNode.style;
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      cropHeight += (childNode.cropHeight ?? 0);
    }

    void cropPaddingBorder(Element childNode) {
      // minus border
      cropHeight += (childNode.cropBorderHeight ?? 0);
      // minus padding
      Padding padding = baseGetPaddingFromStyle(childNode.style);
      cropHeight += padding.top + padding.bottom;
    }

    if (style.contains('height')) {
      if (childNode is Element) {
        height = style['height'];
        cropPaddingBorder(childNode);
      }
    } else {
      while (true) {
        if (childNode.parentNode != null) {
          cropMargin(childNode);
          cropPaddingBorder(childNode);
          childNode = childNode.parentNode;
        } else {
          break;
        }
        if (childNode is Element) {
          Style style = childNode.style;
          if (isStretchChildrenHeight(childNode)) {
            if (style.contains('height')) {
              height = style['height'];
              cropPaddingBorder(childNode);
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
    Style style = currentNode.style;
    String display = style.get('display');
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
  String getElementDisplay(int nodeId) {
    var currentNode = nodeMap[nodeId];
    var parentNode = currentNode.parentNode;
    String defaultDisplay = currentNode.style.get('display');
    String display = defaultDisplay;

    // Display as inline-block if parent node is flex
    if (parentNode != null) {
      Style style = parentNode.style;

      bool isParentFlex = style['display'] == 'flex' || style['display'] == 'inline-flex';

      if (isParentFlex) {
        display = 'inline-block';
      }
    }

    return display;
  }
}
