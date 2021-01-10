/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';

class RenderStyle
  with
    RenderStyleBase,
    CSSSizingMixin,
    CSSPaddingMixin,
    CSSMarginMixin,
    CSSBoxMixin,
    CSSTextMixin,
    CSSPositionMixin,
    CSSTransformMixin,
    CSSFlexboxMixin,
    CSSFlowMixin,
    CSSOpacityMixin {

  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size viewportSize;

  RenderStyle(
    this.renderBoxModel,
    this.style,
    this.viewportSize,
  );

  /// Resolve percentage size to px base on size of its containing block
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  bool resolvePercentageSize(RenderBoxModel parent) {
    bool isPercentageExist = false;
    Size parentSize = parent.size;

    /// Update sizing
    if (CSSLength.isPercentage(style[WIDTH])) {
      updateSizing(
        WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[WIDTH]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MIN_WIDTH])) {
      updateSizing(
        MIN_WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[MIN_WIDTH]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MAX_WIDTH])) {
      updateSizing(
        MAX_WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[MAX_WIDTH]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[HEIGHT])) {
      updateSizing(
        HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[HEIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MIN_HEIGHT])) {
      updateSizing(
        MIN_HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[MIN_HEIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MAX_HEIGHT])) {
      updateSizing(
        MAX_HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[MAX_HEIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// Update padding
    if (CSSLength.isPercentage(style[PADDING_TOP])) {
      updatePadding(
        PADDING_TOP,
        parentSize.height * CSSLength.parsePercentage(style[PADDING_TOP]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_RIGHT])) {
      updatePadding(
        PADDING_RIGHT,
        parentSize.width * CSSLength.parsePercentage(style[PADDING_RIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_BOTTOM])) {
      updatePadding(
        PADDING_BOTTOM,
        parentSize.height * CSSLength.parsePercentage(style[PADDING_BOTTOM]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_LEFT])) {
      updatePadding(
        PADDING_LEFT,
        parentSize.width * CSSLength.parsePercentage(style[PADDING_LEFT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// Update margin
    if (CSSLength.isPercentage(style[MARGIN_TOP])) {
      updateMargin(
        MARGIN_TOP,
        parentSize.height * CSSLength.parsePercentage(style[MARGIN_TOP]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_RIGHT])) {
      updateMargin(
        MARGIN_RIGHT,
        parentSize.width * CSSLength.parsePercentage(style[MARGIN_RIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_BOTTOM])) {
      updateMargin(
        MARGIN_BOTTOM,
        parentSize.height * CSSLength.parsePercentage(style[MARGIN_BOTTOM]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_LEFT])) {
      updateMargin(
        MARGIN_LEFT,
        parentSize.width * CSSLength.parsePercentage(style[MARGIN_LEFT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  BoxConstraints getConstraints() {
    double constraintWidth = width ?? double.infinity;
    double constraintHeight = height ?? double.infinity;
    int targetId = renderBoxModel.targetId;
    ElementManager elementManager = renderBoxModel.elementManager;
    CSSDisplay realDisplay = CSSSizing.getElementRealDisplayValue(targetId, elementManager);
    bool isInline = realDisplay == CSSDisplay.inline;
    bool isInlineBlock = realDisplay == CSSDisplay.inlineBlock;

    if (!isInline) {
      // Base width when width no exists, inline-block has width of 0
      double baseWidth = isInlineBlock ? 0 : constraintWidth;
      if (maxWidth != null && width == null) {
        constraintWidth = baseWidth > maxWidth ? maxWidth : baseWidth;
      } else if (minWidth != null && width == null) {
        constraintWidth = baseWidth < minWidth ? minWidth : baseWidth;
      }
      // Base height always equals to 0 no matter
      double baseHeight = 0;
      if (maxHeight != null && height == null) {
        constraintHeight = baseHeight > maxHeight ? maxHeight : baseHeight;
      } else if (minHeight != null && height == null) {
        constraintHeight = baseHeight < minHeight ? minHeight : baseHeight;
      }
    }
    return BoxConstraints(
      minWidth: 0,
      maxWidth: constraintWidth,
      minHeight: 0,
      maxHeight: constraintHeight,
    );
  }
}

mixin RenderStyleBase {
  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size viewportSize;
}

