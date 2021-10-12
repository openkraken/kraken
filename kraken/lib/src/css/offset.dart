

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

class CSSOffset {
  CSSOffset({
    this.length,
    this.isAuto,
  });
  /// length if margin value is length type
  double? length;
  /// Whether value is auto
  bool? isAuto;
}

mixin CSSPositionMixin on RenderStyleBase {

  CSSOffset? _top;
  CSSOffset? get top {
    return _top;
  }
  set top(CSSOffset? value) {
    if (_top == value) return;
    _top = value;
  }

  CSSOffset? _bottom;
  CSSOffset? get bottom {
    return _bottom;
  }
  set bottom(CSSOffset? value) {
    if (_bottom == value) return;
    _bottom = value;
  }

  CSSOffset? _left;
  CSSOffset? get left {
    return _left;
  }
  set left(CSSOffset? value) {
    if (_left == value) return;
    _left = value;
  }

  CSSOffset? _right;
  CSSOffset? get right {
    return _right;
  }
  set right(CSSOffset? value) {
    if (_right == value) return;
    _right = value;
  }

  int? _zIndex;
  int? get zIndex {
    return _zIndex;
  }
  set zIndex(int? value) {
    if (_zIndex == value) return;
    _zIndex = value;
    _markParentNeedsLayout();
    // Needs to sort children when parent paint children
    if (renderBoxModel!.parentData is RenderLayoutParentData) {
      RenderLayoutBox parent = renderBoxModel!.parent as RenderLayoutBox;
      final RenderLayoutParentData parentData = renderBoxModel!.parentData as RenderLayoutParentData;
      RenderBox? nextSibling = parentData.nextSibling;

      parent.sortedChildren.remove(renderBoxModel);
      parent.insertChildIntoSortedChildren(renderBoxModel!, after: nextSibling);
    }
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
    // Should mark positioned element's containing block needs layout directly
    // cause RelayoutBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    if (renderBoxModel!.parentData is RenderLayoutParentData) {
      RenderStyle renderStyle = renderBoxModel!.renderStyle;
      if (renderStyle.position != CSSPositionType.static) {
        RenderBoxModel parent = renderBoxModel!.parent as RenderBoxModel;
        parent.markNeedsLayout();
      }
    }
  }

  void updateOffset(String property, double value, {bool shouldMarkNeedsLayout = true}) {
    switch (property) {
      case TOP:
        top = CSSOffset(length: value, isAuto: style[TOP] == AUTO);
        break;
      case LEFT:
        left = CSSOffset(length: value, isAuto: style[LEFT] == AUTO);
        break;
      case RIGHT:
        right = CSSOffset(length: value, isAuto: style[RIGHT] == AUTO);
        break;
      case BOTTOM:
        bottom = CSSOffset(length: value, isAuto: style[BOTTOM] == AUTO);
        break;
    }
    /// Should mark parent needsLayout directly cause positioned element is rendered as relayoutBoundary
    /// the parent will not be marked as markNeedsLayout
    if (shouldMarkNeedsLayout) {
      _markParentNeedsLayout();
    }
  }

  void updatePosition(String property, String present) {
    RenderStyle renderStyle = this as RenderStyle;
    position = parsePositionType(style[POSITION]);
    // Position change may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations
    renderStyle.transformedDisplay = renderStyle.getTransformedDisplay();
  }

  void updateZIndex(String property, String present) {
    zIndex = int.tryParse(present);
  }

  static CSSPositionType parsePositionType(String? input) {
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
