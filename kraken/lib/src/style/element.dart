import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Loop element tree to find nearest parent width include self node
  // @TODO Support detecting node width in more complicated scene such as flex layout
  double getParentWidth(int childId) {
    String width;
    bool isParentWithWidth = false;
    var childNode = nodeMap[childId];
    double cropWidth = 0;
    while (!isParentWithWidth) {
      if (childNode is Element) {
        CSSStyleDeclaration style = childNode.style;
        if (style.contains('width')) {
          isParentWithWidth = true;
          width = style['width'];
          break;
        }
        // minus margin and border
        cropWidth +=
            ((childNode.cropWidth ?? 0) + (childNode.cropBorderWidth ?? 0));

        // minus padding
        Padding padding = baseGetPaddingFromStyle(childNode.style);
        cropWidth += padding.left + padding.right;
      }

      if (childNode.parentNode != null) {
        childNode = childNode.parentNode;
      }
    }

    double widthD = Length.toDisplayPortValue(width) - cropWidth;

    return widthD;
  }

  // Loop element tree to find nearest parent width include self node
  // @TODO Support detecting node width in more complicated scene such as flex layout
  double getParentHeight(int childId) {
    String height;
    bool isParentWithHeight = false;
    var childNode = nodeMap[childId];
    double cropHeight = 0;
    while (!isParentWithHeight) {
      if (childNode is Element) {
        CSSStyleDeclaration style = childNode.style;
        if (style.contains('height')) {
          isParentWithHeight = true;
          height = style['height'];
          break;
        }
        // minus margin and border
        cropHeight +=
        ((childNode.cropHeight ?? 0) + (childNode.cropBorderHeight ?? 0));

        // minus padding
        Padding padding = baseGetPaddingFromStyle(childNode.style);
        cropHeight += padding.top + padding.bottom;
      }

      if (childNode.parentNode != null) {
        childNode = childNode.parentNode;
      }
    }

    double heightD = Length.toDisplayPortValue(height) - cropHeight;

    return heightD;
  }

  // Get parent node height if parent is flex and stretch children height
  double getStretchParentHeight(int nodeId) {
    double parentHeight;
    Element currentNode = nodeMap[nodeId];
    Element parentNode = currentNode.parent;

    if (parentNode != null && parentNode.style != null) {
      CSSStyleDeclaration parentStyle = parentNode.style;
      CSSStyleDeclaration currentStyle = currentNode.style;

      String parentDisplay = parentStyle['display'];
      bool isParentFlex = parentDisplay == 'flex' || parentDisplay == 'inline-flex';

      if (isParentFlex &&
          parentStyle['flexDirection'] == 'row' &&
          currentStyle.contains('height') &&
          parentStyle.contains('height') &&
          (!parentStyle.contains('alignItems') ||
              (parentStyle.contains('alignItems') &&
                  parentStyle['alignItems'] == 'stretch'))) {
        parentHeight = Length.toDisplayPortValue(parentStyle['height']);
      }
    }
    return parentHeight;
  }

  // Get height of current node
  double getCurrentHeight(CSSStyleDeclaration style) {
    double height = Length.toDisplayPortValue(style['height']);
    // minus padding
    Padding padding = baseGetPaddingFromStyle(style);
    return height - padding.top - padding.bottom;
  }

  // Whether current node is inline
  bool isElementInline(String defaultDisplay, int nodeId) {
    var node = nodeMap[nodeId];
    var parentNode = node.parentNode;

    String display = defaultDisplay;

    // Display as inline if parent node is flex and with align-items not stretch
    if (parentNode != null) {
      CSSStyleDeclaration style = parentNode.style;

      bool isFlex = style['display'] == 'flex' || style['display'] == 'inline-flex';

      if (style.contains('display') && isFlex) {
        display = 'inline';

        if (style.contains('flexDirection') &&
            style['flexDirection'] == 'column' &&
            (!style.contains('alignItems') ||
                (style.contains('alignItems') &&
                    style['alignItems'] == 'stretch'))) {
          display = 'block';
        }
      }
    }

    return display == 'inline';
  }
}
