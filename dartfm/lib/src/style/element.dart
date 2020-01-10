import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Loop element tree to find nearest parent width
  // @TODO Support detecting node width in more complicated scene such as flex layout
  double getParentWidth(int childId) {
    var parentWidth;
    bool isParentWithWidth = false;
    var childNode = nodeMap[childId];

    while(isParentWithWidth == false) {
      if (childNode.parentNode != null) {
        childNode = childNode.parentNode;
      }
      if (childNode.properties != null) {
        var properties = childNode.properties;
        if (properties.containsKey('style')) {
          var style = properties['style'];
          if (style.containsKey('width')) {
            isParentWithWidth = true;
            parentWidth = style['width'];
          }
        }
      }
    }

    return Length(parentWidth).displayPortValue;
  }
}
