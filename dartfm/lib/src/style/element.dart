import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Loop element tree to find nearest parent width include self node
  // @TODO Support detecting node width in more complicated scene such as flex layout
  double getParentWidth(int childId) {
    var width;
    bool isParentWithWidth = false;
    var childNode = nodeMap[childId];

    double cropWidth = 0;
    if (childNode is Element) {
      cropWidth += childNode.cropWidth ?? 0;
    }
    while(isParentWithWidth == false) {
      if (childNode.properties != null) {
        var properties = childNode.properties;
        if (properties.containsKey('style')) {
          var style = properties['style'];
          if (style.containsKey('width')) {
            isParentWithWidth = true;
            width = style['width'];
          }
        }
      }
      if (childNode.parentNode != null) {
        childNode = childNode.parentNode;
      }
      if (childNode is Element) {
        cropWidth += childNode.cropWidth ?? 0;
      }
    }

    double widthD = Length.toDisplayPortValue(width) - cropWidth;

    return widthD;
  }

  // Whether current node is inline
  bool isElementInline(String defaultDisplay, int nodeId) {
    var node = nodeMap[nodeId];
    var parentNode = node.parentNode;

    String display = defaultDisplay;

    // Display as inline-block if parent node is flex and with align-items not stretch
    if (parentNode != null) {
      Style style = parentNode.style;
      if (style.contains('display') &&
        style['display'] == 'flex' &&
        style.contains('flexDirection') &&
        style['flexDirection'] == 'column' &&
        style.contains('alignItems') &&
        style['alignItems'] != 'stretch'
      ) {
        display = 'inline-block';
      }
    }

    if (display == 'flex' ||
        display == 'block') {
      return false;
    }
    return true;
  }
}
