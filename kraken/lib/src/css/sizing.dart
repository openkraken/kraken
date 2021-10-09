/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
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

  CSSLengthValue? _width;
  CSSLengthValue? get width {
    return _width;
  }
  set width(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _width == value) return;
    _width = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _height;
  CSSLengthValue? get height {
    return _height;
  }
  set height(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _height == value) return;
    _height = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _minWidth;
  CSSLengthValue? get minWidth {
    return _minWidth;
  }
  set minWidth(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _minWidth == value) return;
    _minWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _maxWidth;
  CSSLengthValue? get maxWidth {
    return _maxWidth;
  }
  set maxWidth(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _maxWidth == value) return;
    _maxWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _minHeight;
  CSSLengthValue? get minHeight {
    return _minHeight;
  }
  set minHeight(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _minHeight == value) return;
    _minHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _maxHeight;
  CSSLengthValue? get maxHeight {
    return _maxHeight;
  }
  set maxHeight(CSSLengthValue? value) {
    if (value == null || value.value! < 0 || _maxHeight == value) return;
    _maxHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  void _markSelfAndParentNeedsLayout() {
    RenderBoxModel boxModel = renderBoxModel!;
    boxModel.markNeedsLayout();
    // Sizing may affect parent size, mark parent as needsLayout in case
    // renderBoxModel has tight constraints which will prevent parent from marking.
    if (boxModel.parent is RenderBoxModel) {
      (boxModel.parent as RenderBoxModel).markNeedsLayout();
    }
  }

  // Whether current node should stretch children's height
  static bool isStretchChildHeight(RenderStyle renderStyle, RenderStyle childRenderStyle) {
    bool isStretch = false;
    bool isFlex = renderStyle.renderBoxModel is RenderFlexLayout;
    bool isHorizontalDirection = false;
    bool isAlignItemsStretch = false;
    bool isFlexNoWrap = false;
    bool isChildAlignSelfStretch = false;
    bool isChildStretchSelf = false;
    if (isFlex) {
      isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection);
      isAlignItemsStretch = renderStyle.transformedAlignItems == AlignItems.stretch;
      isFlexNoWrap = renderStyle.flexWrap != FlexWrap.wrap &&
        childRenderStyle.flexWrap != FlexWrap.wrapReverse;
      isChildAlignSelfStretch = childRenderStyle.alignSelf == AlignSelf.stretch;
      isChildStretchSelf = childRenderStyle.alignSelf != AlignSelf.auto ?
        isChildAlignSelfStretch : isAlignItemsStretch;
    }

    CSSLengthValue marginTop = childRenderStyle.marginTop;
    CSSLengthValue marginBottom = childRenderStyle.marginBottom;

    // Display as block if flex vertical layout children and stretch children
    if (!marginTop.isAuto && !marginBottom.isAuto &&
      isFlex && isHorizontalDirection && isFlexNoWrap && isChildStretchSelf) {
      isStretch = true;
    }

    return isStretch;
  }
}
