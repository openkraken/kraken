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

  // Intrinsic width of replaced element.
  double? _intrinsicWidth;
  @override
  double? get intrinsicWidth {
    return _intrinsicWidth;
  }
  set intrinsicWidth(double? value) {
    if (_intrinsicWidth == value) return;
    _intrinsicWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  // Intrinsic height of replaced element.
  double? _intrinsicHeight;
  @override
  double? get intrinsicHeight {
    return _intrinsicHeight;
  }
  set intrinsicHeight(double? value) {
    if (_intrinsicHeight == value) return;
    _intrinsicHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  // Aspect ratio of replaced element.
  double? _intrinsicRatio;
  @override
  double? get intrinsicRatio {
    return _intrinsicRatio;
  }
  set intrinsicRatio(double? value) {
    if (_intrinsicRatio == value) return;
    _intrinsicRatio = value;
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

}
