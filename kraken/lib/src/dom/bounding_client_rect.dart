/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

class BoundingClientRect {
  final double x;
  final double y;
  final double width;
  final double height;
  final double top;
  final double left;
  final double right;
  final double bottom;

  const BoundingClientRect(
      {this.x = 0.0,
      this.y = 0.0,
      this.width = 0.0,
      this.height = 0.0,
      this.top = 0.0,
      this.left = 0.0,
      this.right = 0.0,
      this.bottom = 0.0});

  String toJSON() {
    return '{"x": $x, "y": $y, "width": $width, "height": $height, "top": $top, "left": $left, "right": $right, "bottom": $bottom}';
  }

  String toString() {
    return 'BoundingClientRect(${toJSON()})';
  }
}
