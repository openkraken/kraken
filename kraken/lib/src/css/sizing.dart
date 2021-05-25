/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height

mixin CSSSizingMixin on RenderStyleBase {

  double? _width;
  double? get width {
    return _width;
  }
  set width(double? value) {
    if (_width == value) return;
    _width = value;
  }

  double? _height;
  double? get height {
    return _height;
  }
  set height(double? value) {
    if (_height == value) return;
    _height = value;
  }

  double? _minWidth;
  double? get minWidth {
    return _minWidth;
  }
  set minWidth(double? value) {
    if (_minWidth == value) return;
    _minWidth = value;
  }

  double? _maxWidth;
  double? get maxWidth {
    return _maxWidth;
  }
  set maxWidth(double? value) {
    if (_maxWidth == value) return;
    _maxWidth = value;
  }

  double? _minHeight;
  double? get minHeight {
    return _minHeight;
  }
  set minHeight(double? value) {
    if (_minHeight == value) return;
    _minHeight = value;
  }

  double? _maxHeight;
  double? get maxHeight {
    return _maxHeight;
  }
  set maxHeight(double? value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
  }

  void updateSizing(String property, double? value, {bool shouldMarkNeedsLayout = true}) {
    RenderStyle renderStyle = this as RenderStyle;
    switch (property) {
      case WIDTH:
        renderStyle.width = value != null && value >= 0 ? value.abs() : null;
        break;
      case HEIGHT:
        renderStyle.height = value != null && value >= 0 ? value.abs() : null;
        break;
      case MIN_HEIGHT:
        renderStyle.minHeight = getMinHeight(value);
        // max-height should not exceed min-height
        double? maxHeight = renderStyle.maxHeight;
        if (maxHeight != null) {
          renderStyle.maxHeight = getMaxHeight(maxHeight, value);
        }
        break;
      case MAX_HEIGHT:
        renderStyle.maxHeight = getMaxHeight(value, renderStyle.minHeight);
        break;
      case MIN_WIDTH:
        renderStyle.minWidth = getMinWidth(value);
        // max-width should not exceed min-midth
        double? maxWidth = renderStyle.maxWidth;
        if (maxWidth != null) {
          renderStyle.maxWidth = getMaxWidth(maxWidth, value);
        }
        break;
      case MAX_WIDTH:
        renderStyle.maxWidth = getMaxWidth(value, renderStyle.minWidth);
        break;
    }

    if (shouldMarkNeedsLayout) {
      renderBoxModel.markNeedsLayout();
      // Sizing may affect parent size, mark parent as needsLayout in case
      // renderBoxModel has tight constraints which will prevent parent from marking.
      if (renderBoxModel.parent is RenderBoxModel) {
        (renderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
    }
  }

  double? getMinWidth(double? minWidth) {
    if (minWidth == null || minWidth < 0)  {
      return null;
    }
    return minWidth;
  }

  double? getMaxWidth(double? maxWidth, double? minWidth) {
    if (maxWidth == null || maxWidth < 0) {
      return null;
    }
    // max-width is invalid if max-width is smaller than min-width
    if (minWidth != null && minWidth > maxWidth) {
      return null;
    }
    return maxWidth;
  }

  double? getMinHeight(double? minHeight) {
    if (minHeight == null || minHeight < 0)  {
      return null;
    }
    return minHeight;
  }

  double? getMaxHeight(double? maxHeight, double? minHeight) {
    if (maxHeight == null || maxHeight < 0) {
      return null;
    }
    // max-height is invalid if max-height is smaller than min-height
    if (minHeight != null && minHeight > maxHeight) {
      return null;
    }
    return maxHeight;
  }

  // Whether current node should stretch children's height
  static bool isStretchChildHeight(RenderBoxModel current, RenderBoxModel child) {
    bool isStretch = false;
    RenderStyle renderStyle = current.renderStyle;
    RenderStyle childRenderStyle = child.renderStyle;
    bool isFlex = current is RenderFlexLayout;
    bool isHorizontalDirection = false;
    bool isAlignItemsStretch = false;
    bool isFlexNoWrap = false;
    bool isChildAlignSelfStretch = false;
    bool isChildStretchSelf = false;
    if (isFlex) {
      isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(
        current.renderStyle.flexDirection
      );
      isAlignItemsStretch = renderStyle.alignItems == AlignItems.stretch;
      isFlexNoWrap = renderStyle.flexWrap != FlexWrap.wrap &&
        childRenderStyle.flexWrap != FlexWrap.wrapReverse;
      isChildAlignSelfStretch = childRenderStyle.alignSelf == AlignSelf.stretch;
      isChildStretchSelf = childRenderStyle.alignSelf != AlignSelf.auto ?
        isChildAlignSelfStretch : isAlignItemsStretch;
    }

    CSSMargin marginTop = childRenderStyle.marginTop;
    CSSMargin marginBottom = childRenderStyle.marginBottom;

    // Display as block if flex vertical layout children and stretch children
    if (!marginTop.isAuto && !marginBottom.isAuto &&
      isFlex && isHorizontalDirection && isFlexNoWrap && isChildStretchSelf) {
      isStretch = true;
    }

    return isStretch;
  }
}

class CSSEdgeInsets {
  double left;
  double top;
  double right;
  double bottom;

  CSSEdgeInsets(this.top, this.right, this.bottom, this.left);

  EdgeInsets toEdgeInsets() {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

