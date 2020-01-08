import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ElementStyleMixin on RenderBox {
  // Loop element tree to find nearest parent width include self node
  // @TODO Support detecting node width in more complicated scene such as flex layout
  double getParentsWidth(int childId) {
    var width;
    bool isParentWithWidth = false;
    var childNode = nodeMap[childId];

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
    }

    return Length(width).displayPortValue;
  }
}
