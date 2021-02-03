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
    CSSDisplayMixin,
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
  bool resolvePercentageToContainingBlock() {
    if (!renderBoxModel.hasSize) {
      return false;
    }
    RenderBoxModel parent = renderBoxModel.parent;
    bool isPercentageExist = false;
    Size parentSize = parent.size;
    Size size = renderBoxModel.boxSize;

    /// Update sizing
    if (CSSLength.isPercentage(style[WIDTH])) {
      updateSizing(
        WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[WIDTH]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MIN_WIDTH])) {
      updateSizing(
        MIN_WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[MIN_WIDTH]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MAX_WIDTH])) {
      updateSizing(
        MAX_WIDTH,
        parentSize.width * CSSLength.parsePercentage(style[MAX_WIDTH]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[HEIGHT])) {
      updateSizing(
        HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[HEIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MIN_HEIGHT])) {
      updateSizing(
        MIN_HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[MIN_HEIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MAX_HEIGHT])) {
      updateSizing(
        MAX_HEIGHT,
        parentSize.height * CSSLength.parsePercentage(style[MAX_HEIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// Update padding
    if (CSSLength.isPercentage(style[PADDING_TOP])) {
      updatePadding(
        PADDING_TOP,
        parentSize.height * CSSLength.parsePercentage(style[PADDING_TOP]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_RIGHT])) {
      updatePadding(
        PADDING_RIGHT,
        parentSize.width * CSSLength.parsePercentage(style[PADDING_RIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_BOTTOM])) {
      updatePadding(
        PADDING_BOTTOM,
        parentSize.height * CSSLength.parsePercentage(style[PADDING_BOTTOM]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[PADDING_LEFT])) {
      updatePadding(
        PADDING_LEFT,
        parentSize.width * CSSLength.parsePercentage(style[PADDING_LEFT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// Update margin
    if (CSSLength.isPercentage(style[MARGIN_TOP])) {
      updateMargin(
        MARGIN_TOP,
        parentSize.height * CSSLength.parsePercentage(style[MARGIN_TOP]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_RIGHT])) {
      updateMargin(
        MARGIN_RIGHT,
        parentSize.width * CSSLength.parsePercentage(style[MARGIN_RIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_BOTTOM])) {
      updateMargin(
        MARGIN_BOTTOM,
        parentSize.height * CSSLength.parsePercentage(style[MARGIN_BOTTOM]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[MARGIN_LEFT])) {
      updateMargin(
        MARGIN_LEFT,
        parentSize.width * CSSLength.parsePercentage(style[MARGIN_LEFT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// Update offset

    /// Offset of positioned element starts from content other than border,
    /// it needs to substract border width
    double parentHorizontalBorderWidth = parent.renderStyle.borderEdge != null ?
      parent.renderStyle.borderEdge.horizontal : 0;
    double parentVerticalBorderWidth = parent.renderStyle.borderEdge != null ?
      parent.renderStyle.borderEdge.vertical : 0;
    double parentContentWidth = parentSize.width - parentHorizontalBorderWidth;
    double parentContentHeight = parentSize.height - parentVerticalBorderWidth;

    if (CSSLength.isPercentage(style[TOP])) {
      updateOffset(
        TOP,
        parentContentHeight * CSSLength.parsePercentage(style[TOP]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[RIGHT])) {
      updateOffset(
        RIGHT,
        parentContentWidth * CSSLength.parsePercentage(style[RIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[BOTTOM])) {
      updateOffset(
        BOTTOM,
        parentContentHeight * CSSLength.parsePercentage(style[BOTTOM]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[LEFT])) {
      updateOffset(
        LEFT,
        parentContentWidth * CSSLength.parsePercentage(style[LEFT]),
        shouldMarkNeedsLayout: false
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

    /// Transform translate
    Matrix4 transformValue = parsePercentageTransformTranslate(style[TRANSFORM], size, viewportSize);
    if (transformValue != null) {
      updateTransform(
        transformValue,
        shouldConvertToRepaintBoundary: false,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  /// Resolve percentage size to px base on size of its own
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  bool resolvePercentageToOwn() {
    if (!renderBoxModel.hasSize) {
      return false;
    }
    bool isPercentageExist = false;
    Size size = renderBoxModel.boxSize;

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

    /// Transform translate
    Matrix4 transformValue = parsePercentageTransformTranslate(style[TRANSFORM], size, viewportSize);
    if (transformValue != null) {
      updateTransform(
        transformValue,
        shouldConvertToRepaintBoundary: false,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  bool isPercentageOfSizingExist() {
    if (CSSLength.isPercentage(style[WIDTH]) ||
      CSSLength.isPercentage(style[MIN_WIDTH]) ||
      CSSLength.isPercentage(style[MAX_WIDTH]) ||
      CSSLength.isPercentage(style[HEIGHT]) ||
      CSSLength.isPercentage(style[MIN_HEIGHT]) ||
      CSSLength.isPercentage(style[MAX_HEIGHT])
    ) {
      return true;
    }
    return false;
  }

  bool isPercentageToOwnExist() {
    if (isBorderRadiusPercentage(style[BORDER_TOP_LEFT_RADIUS]) ||
      isBorderRadiusPercentage(style[BORDER_TOP_RIGHT_RADIUS]) ||
      isBorderRadiusPercentage(style[BORDER_BOTTOM_LEFT_RADIUS]) ||
      isBorderRadiusPercentage(style[BORDER_BOTTOM_RIGHT_RADIUS]) ||
      isTransformTranslatePercentage(style[TRANSFORM])
    ) {
      return true;
    }
    return false;
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
    bool isPercentageExist = false;

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
            isPercentageExist = true;
          }
          y = CSSLength.toDisplayPortValue(translateY, viewportSize) ?? 0;
        } else {
          y = 0;
        }
        String translateX = method.args[0].trim();
        if (CSSLength.isPercentage(translateX)) {
          double percentage = CSSLength.parsePercentage(translateX);
          translateX = (size.width * percentage).toString() + 'px';
          isPercentageExist = true;
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
    return isPercentageExist ? matrix4 : null;
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
    CSSDisplay transformedDisplay = renderBoxModel.renderStyle.transformedDisplay;
    bool isInline = transformedDisplay == CSSDisplay.inline;
    bool isInlineBlock = transformedDisplay == CSSDisplay.inlineBlock;

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

