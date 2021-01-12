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
    if (!renderBoxModel.hasSize) {
      return false;
    }
    bool isPercentageExist = false;
    Size parentSize = parent.size;
    Size size = renderBoxModel.boxSize;

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

    /// Update offset
    if (CSSLength.isPercentage(style[TOP])) {
      updateOffset(
        TOP,
        parentSize.height * CSSLength.parsePercentage(style[TOP]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[RIGHT])) {
      updateOffset(
        RIGHT,
        parentSize.width * CSSLength.parsePercentage(style[RIGHT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[BOTTOM])) {
      updateOffset(
        BOTTOM,
        parentSize.height * CSSLength.parsePercentage(style[BOTTOM]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[LEFT])) {
      updateOffset(
        LEFT,
        parentSize.width * CSSLength.parsePercentage(style[LEFT]),
        markNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// border-radius
    String parsedTopLeftRadius = parsePercentageBorderRadius(style[BORDER_TOP_LEFT_RADIUS], size);

    if (parsedTopLeftRadius != null) {
      updateBorderRadius(
        BORDER_TOP_LEFT_RADIUS,
        parsedTopLeftRadius,
      );
      isPercentageExist = true;
    }

    String parsedTopRightRadius = parsePercentageBorderRadius(style[BORDER_TOP_RIGHT_RADIUS], size);
    if (parsedTopRightRadius != null) {
      updateBorderRadius(
        BORDER_TOP_RIGHT_RADIUS,
        parsedTopRightRadius,
      );
      isPercentageExist = true;
    }

    String parsedBottomLeftRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_LEFT_RADIUS], size);
    if (parsedBottomLeftRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_LEFT_RADIUS,
        parsedBottomLeftRadius,
      );
      isPercentageExist = true;
    }

    String parsedBottomRightRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_RIGHT_RADIUS], size);
    if (parsedBottomRightRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_RIGHT_RADIUS,
        parsedBottomRightRadius,
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  /// Parse percentage border radius
  /// Returns the parsed result if percentage found, otherwise returns null
  static String parsePercentageBorderRadius(String radiusStr, Size size) {
    bool isPercentageExist = false;
    final RegExp _spaceRegExp = RegExp(r'\s+');
    List<String> values = radiusStr.split(_spaceRegExp);
    String parsedRadius = '';
    if (values.length == 1) {
      if (CSSLength.isPercentage(values[0])) {
        double percentage = CSSLength.parsePercentage(values[0]);
        parsedRadius += (size.width * percentage).toString() + 'px' + ' ' +
          (size.height * percentage).toString() + 'px';
        isPercentageExist = true;
      } else {
        parsedRadius += values[0];
      }
    } else if (values.length == 2) {
      if (CSSLength.isPercentage(values[0])) {
        double percentage = CSSLength.parsePercentage(values[0]);
        parsedRadius += (size.width * percentage).toString() + 'px';
        isPercentageExist = true;
      } else {
        parsedRadius += values[0];
      }
      if (CSSLength.isPercentage(values[1])) {
        double percentage = CSSLength.parsePercentage(values[1]);
        parsedRadius += ' ' + (size.height * percentage).toString() + 'px';
        isPercentageExist = true;
      } else {
        parsedRadius += ' ' + values[1];
      }
    }

    return isPercentageExist ? parsedRadius : null;
  }

  /// Check whether percentage exist in border-radius
  static bool isBorderRadiusPercentage(String radiusStr) {
    bool isPercentageExist = false;
    final RegExp _spaceRegExp = RegExp(r'\s+');
    List<String> values = radiusStr.split(_spaceRegExp);
    if ((values.length == 1 && CSSLength.isPercentage(values[0])) ||
      (values.length == 2 && (CSSLength.isPercentage(values[0]) || CSSLength.isPercentage(values[1])))
    ) {
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  /// Parse percentage transform translate value
  /// Returns the parsed result if percentage found, otherwise returns null
  static Matrix4 parsePercentageTransformTranslate(String transformStr, Size size, Size viewportSize) {
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(transformStr);
    final String TRANSLATE = 'translate';

    Matrix4 matrix4;
    for (CSSFunctionalNotation method in methods) {
      Matrix4 transform;
      if (method.name == TRANSLATE && method.args.length >= 1 && method.args.length <= 2) {
        double y;
        double x;
        if (method.args.length == 2) {
          String translateY = method.args[1].trim();
          if (CSSLength.isPercentage(translateY)) {
            double percentage = CSSLength.parsePercentage(translateY);
            translateY = (size.height * percentage).toString() + 'px';
          }
          y = CSSLength.toDisplayPortValue(translateY, viewportSize) ?? 0;
        } else {
          y = 0;
        }
        String translateX = method.args[0].trim();
        if (CSSLength.isPercentage(translateX)) {
          double percentage = CSSLength.parsePercentage(translateX);
          translateX = (size.width * percentage).toString() + 'px';
        }
        x = CSSLength.toDisplayPortValue(translateX, viewportSize) ?? 0;
        transform = Matrix4.identity()..translate(x, y);
      }
      if (transform != null) {
        if (matrix4 == null) {
          matrix4 = transform;
        } else {
          matrix4.multiply(transform);
        }
      }
    }
    return matrix4;
  }

  /// Check whether percentage exist in transform translate
  static bool isTransformTranslatePercentage(String transformStr) {
    bool isPercentageExist = false;
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(transformStr);
    final String TRANSLATE = 'translate';
    for (CSSFunctionalNotation method in methods) {
      if (method.name == TRANSLATE && ((method.args.length == 1 && CSSLength.isPercentage(method.args[0])) ||
        (method.args.length == 2 && (CSSLength.isPercentage(method.args[0]) || CSSLength.isPercentage(method.args[1]))))
      ) {
        isPercentageExist = true;
      }
    }
    return isPercentageExist;
  }

  /// Calculate renderBoxModel constraints based on style
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

