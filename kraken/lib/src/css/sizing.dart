/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height

mixin CSSSizingMixin on RenderStyle {

  // https://drafts.csswg.org/css-sizing-3/#preferred-size-properties
  // Name: width, height
  // Value: auto | <length-percentage> | min-content | max-content | fit-content(<length-percentage>)
  // Initial: auto
  // Applies to: all elements except non-replaced inlines
  // Inherited: no
  // Percentages: relative to width/height of containing block
  // Computed value: as specified, with <length-percentage> values computed
  // Canonical order: per grammar
  // Animation type: by computed value type, recursing into fit-content()
  CSSLengthValue? _width;

  @override
  CSSLengthValue get width =>  _width ?? CSSLengthValue.auto;

  set width(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || width == value) {
      return;
    }
    _width = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _height;

  @override
  CSSLengthValue get height => _height ?? CSSLengthValue.auto;

  set height(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || height == value) {
      return;
    }
    _height = value;
    _markSelfAndParentNeedsLayout();
  }

  // https://drafts.csswg.org/css-sizing-3/#min-size-properties
  // Name: min-width, min-height
  // Value: auto | <length-percentage> | min-content | max-content | fit-content(<length-percentage>)
  // Initial: auto
  // Applies to: all elements that accept width or height
  // Inherited: no
  // Percentages: relative to width/height of containing block
  // Computed value: as specified, with <length-percentage> values computed
  // Canonical order: per grammar
  // Animatable: by computed value, recursing into fit-content()
  CSSLengthValue? _minWidth;

  @override
  CSSLengthValue get minWidth =>  _minWidth ?? CSSLengthValue.auto;

  set minWidth(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || minWidth == value) {
      return;
    }
    _minWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _minHeight;

  @override
  CSSLengthValue get minHeight => _minHeight ?? CSSLengthValue.auto;

  set minHeight(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || minHeight == value) {
      return;
    }
    _minHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  // https://drafts.csswg.org/css-sizing-3/#max-size-properties
  // Name: max-width, max-height
  // Value: none | <length-percentage> | min-content | max-content | fit-content(<length-percentage>)
  // Initial: none
  // Applies to: all elements that accept width or height
  // Inherited: no
  // Percentages: relative to width/height of containing block
  // Computed value: as specified, with <length-percentage> values computed
  // Canonical order: per grammar
  // Animatable: by computed value, recursing into fit-content()
  CSSLengthValue? _maxWidth;

  @override
  CSSLengthValue get maxWidth => _maxWidth ?? CSSLengthValue.none;

  set maxWidth(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || maxWidth == value) {
      return;
    }
    _maxWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _maxHeight;

  @override
  CSSLengthValue get maxHeight {
    return _maxHeight ?? CSSLengthValue.none;
  }

  set maxHeight(CSSLengthValue? value) {
    // Negative value is invalid, auto value is parsed at layout stage.
    if ((value != null && value.value != null && value.value! < 0) || maxHeight == value) {
      return;
    }
    _maxHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  void _markSelfAndParentNeedsLayout() {
    if (renderBoxModel == null) return;
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
      isAlignItemsStretch = renderStyle.effectiveAlignItems == AlignItems.stretch;
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
