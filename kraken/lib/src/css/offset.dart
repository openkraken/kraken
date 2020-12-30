/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

mixin CSSPositionMixin on RenderStyleBase {

  double _top;
  double get top {
    return _top;
  }
  set top(double value) {
    if (_top == value) return;
    _top = value;
    _markParentNeedsLayout();
  }

  double _bottom;
  double get bottom {
    return _bottom;
  }
  set bottom(double value) {
    if (_bottom == value) return;
    _bottom = value;
    _markParentNeedsLayout();
  }

  double _left;
  double get left {
    return _left;
  }
  set left(double value) {
    if (_left == value) return;
    _left = value;
    _markParentNeedsLayout();
  }

  double _right;
  double get right {
    return _right;
  }
  set right(double value) {
    if (_right == value) return;
    _right = value;
    _markParentNeedsLayout();
  }

  int _zIndex = 0;
  int get zIndex {
    return _zIndex;
  }
  set zIndex(int value) {
    if (_zIndex == value) return;
    _zIndex = value;
    _markParentNeedsLayout();
  }

  CSSPositionType _position = CSSPositionType.static;
  CSSPositionType get position {
    return _position;
  }
  set position(CSSPositionType value) {
    if (_position == value) return;
    _position = value;
    _markParentNeedsLayout();
  }

  void _markParentNeedsLayout() {
    if (renderBoxModel.parentData is RenderLayoutParentData) {
      RenderStyle renderStyle = renderBoxModel.renderStyle;
      if (renderStyle.position != CSSPositionType.static) {
        RenderBoxModel parent = renderBoxModel.parent;
        parent.markNeedsLayout();
      }
    }
  }

  void updateOffset(String property, String present) {
    double value = CSSLength.toDisplayPortValue(present, viewportSize);
    switch (property) {
      case TOP:
        top = value;
        break;
      case LEFT:
        left = value;
        break;
      case RIGHT:
        right = value;
        break;
      case BOTTOM:
        bottom = value;
        break;
    }
  }

  void updatePosition(String property, String present) {
    position = CSSPositionMixin.parsePositionType(style[POSITION]);
    zIndex = int.tryParse(present) ?? 0;
  }

  static CSSPositionType parsePositionType(String input) {
    switch (input) {
      case RELATIVE:
        return CSSPositionType.relative;
      case ABSOLUTE:
        return CSSPositionType.absolute;
      case FIXED:
        return CSSPositionType.fixed;
      case STICKY:
        return CSSPositionType.sticky;
    }
    return CSSPositionType.static;
  }

}
