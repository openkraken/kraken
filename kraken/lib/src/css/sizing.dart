/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
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
  double _intrinsicWidth = 0;
  @override
  double get intrinsicWidth {
    return _intrinsicWidth;
  }
  set intrinsicWidth(double value) {
    if (_intrinsicWidth == value) return;
    _intrinsicWidth = value;
    _markSelfAndParentNeedsLayout();
  }

  // Intrinsic height of replaced element.
  double _intrinsicHeight = 0;
  @override
  double get intrinsicHeight {
    return _intrinsicHeight;
  }
  set intrinsicHeight(double value) {
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

      // For positioned element with no left&right or top&bottom, the offset of its positioned placeholder will change
      // when its size has changed in flex layout.
      //
      // Take following html for example, div of id=2 should reposition to align center in horizontal direction
      // when its width has changed.
      // <div style="display: flex; height: 100px; justify-content: center;">
      //   <div id=2 style="position: absolute; width: 50px; height: 50px;">
      //   </div>
      // </div>
      //
      // The renderBox of position element and its positioned placeholder will not always share the same parent,
      // so it needs to mark the positioned placeholder as needs layout additionally to mark sure the renderBox
      // of position element can get the updated offset of its positioned placeholder when it is layouted.
      RenderStyle renderStyle = boxModel.renderStyle;
      RenderLayoutParentData childParentData = boxModel.parentData as RenderLayoutParentData;

      RenderPositionPlaceholder? renderPositionPlaceholder = boxModel.renderPositionPlaceholder;
      if (renderPositionPlaceholder != null
        && renderPositionPlaceholder.parent is RenderFlexLayout
        && childParentData.isPositioned
        && ((renderStyle.left.isAuto && renderStyle.right.isAuto)
          || (renderStyle.top.isAuto && renderStyle.bottom.isAuto))
      ) {
        RenderLayoutBox? placeholderParent = renderPositionPlaceholder.parent as RenderLayoutBox;
        // Mark parent as _needsLayout directly as RenderPositionHolder has tight constraints which will
        // prevent the _needsLayout flag to bubble up the renderObject tree.
        placeholderParent.markNeedsLayout();
      }
    }
  }

}
