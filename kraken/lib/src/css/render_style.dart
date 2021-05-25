/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

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
    CSSContentVisibilityMixin,
    CSSFlexboxMixin,
    CSSFlowMixin,
    CSSDisplayMixin,
    CSSInlineMixin,
    CSSObjectFitMixin,
    CSSObjectPositionMixin,
    CSSSliverMixin,
    CSSOverflowStyleMixin,
    CSSOpacityMixin {

  late RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size get viewportSize => renderBoxModel.elementManager.viewport.viewportSize;

  RenderStyle({ required this.style });

  /// Resolve percentage size to px base on size of its containing block
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  bool resolvePercentageToContainingBlock(RenderBoxModel parent, double? parentLogicalContentWidth, double? parentLogicalContentHeight) {
    if (!renderBoxModel.hasSize) {
      return false;
    }

    RenderStyle parentRenderStyle = parent.renderStyle;
    bool isPercentageExist = false;
    Size parentSize = parent.size;
    Size size = renderBoxModel.boxSize;

    EdgeInsets? parentBorderEdge = parentRenderStyle.borderEdge;
    EdgeInsets? parentPadding = parentRenderStyle.padding;

    double parentHorizontalBorderWidth = parentBorderEdge != null ? parentBorderEdge.horizontal : 0;
    double parentVerticalBorderWidth = parentBorderEdge != null ? parentBorderEdge.vertical : 0;
    double parentHorizontalPaddingWidth = parentPadding != null ? parentPadding.horizontal : 0;
    double parentVerticalPaddingHeight = parentPadding != null ? parentPadding.vertical : 0;

    /// Width and height of parent padding box
    double parentPaddingBoxWidth = parentSize.width - parentHorizontalBorderWidth;
    double parentPaddingBoxHeight = parentSize.height - parentVerticalBorderWidth;
    /// Width and height of parent content box
    double parentContentBoxWidth = parentSize.width - parentHorizontalBorderWidth - parentHorizontalPaddingWidth;
    double parentContentBoxHeight = parentSize.height - parentVerticalBorderWidth - parentVerticalPaddingHeight;

    /// Percentage sizing, margin and padding starts from the edge of content box of containing block
    /// Update sizing
    if (parentLogicalContentWidth != null) {
      double? _percentageWidth = CSSLength.parsePercentage(style[WIDTH]);
      if (_percentageWidth != null) {
        updateSizing(
          WIDTH,
          parentContentBoxWidth * _percentageWidth,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMinWidth = CSSLength.parsePercentage(style[MIN_WIDTH]);
      if (_percentageMinWidth != null) {
        updateSizing(
          MIN_WIDTH,
          parentContentBoxWidth * _percentageMinWidth,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMaxWidth = CSSLength.parsePercentage(style[MAX_WIDTH]);
      if (_percentageMaxWidth != null) {
        updateSizing(
          MAX_WIDTH,
          parentContentBoxWidth * _percentageMaxWidth,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    if (parentLogicalContentHeight != null) {
      double? _percentageHeight = CSSLength.parsePercentage(style[HEIGHT]);

      if (_percentageHeight != null) {
        updateSizing(
          HEIGHT,
          parentContentBoxHeight * _percentageHeight,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMinHeight = CSSLength.parsePercentage(style[MIN_HEIGHT]);
      if (_percentageMinHeight != null) {
        updateSizing(
          MIN_HEIGHT,
          parentContentBoxHeight * _percentageMinHeight,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMaxHeight = CSSLength.parsePercentage(style[MAX_HEIGHT]);
      if (_percentageMaxHeight != null) {
        updateSizing(
          MAX_HEIGHT,
          parentContentBoxHeight * _percentageMaxHeight,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    /// Percentage of padding and margin refer to the logical width of containing block
    if (parentLogicalContentWidth != null) {
      /// Update padding
      /// https://www.w3.org/TR/css-box-3/#padding-physical
      double? _percentagePaddingTop = CSSLength.parsePercentage(style[PADDING_TOP]);
      if (_percentagePaddingTop != null) {
        updatePadding(
          PADDING_TOP,
          parentContentBoxWidth * _percentagePaddingTop,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentagePaddingRight = CSSLength.parsePercentage(style[PADDING_RIGHT]);
      if (_percentagePaddingRight != null) {
        updatePadding(
          PADDING_RIGHT,
          parentContentBoxWidth * _percentagePaddingRight,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentagePaddingBottom = CSSLength.parsePercentage(style[PADDING_BOTTOM]);
      if (_percentagePaddingBottom != null) {
        updatePadding(
          PADDING_BOTTOM,
          parentContentBoxWidth * _percentagePaddingBottom,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentagePaddingLeft = CSSLength.parsePercentage(style[PADDING_LEFT]);
      if (_percentagePaddingLeft != null) {
        updatePadding(
          PADDING_LEFT,
          parentContentBoxWidth * _percentagePaddingLeft,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      /// Update margin
      /// https://www.w3.org/TR/css-box-3/#margin-physical
      double? _percentageMarginTop = CSSLength.parsePercentage(style[MARGIN_TOP]);
      if (_percentageMarginTop != null) {
        updateMargin(
          MARGIN_TOP,
          parentContentBoxWidth * _percentageMarginTop,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMarginRight = CSSLength.parsePercentage(style[MARGIN_RIGHT]);
      if (_percentageMarginRight != null) {
        updateMargin(
          MARGIN_RIGHT,
          parentContentBoxWidth * _percentageMarginRight,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMarginBottom = CSSLength.parsePercentage(style[MARGIN_BOTTOM]);
      if (_percentageMarginBottom != null) {
        updateMargin(
          MARGIN_BOTTOM,
          parentContentBoxWidth * _percentageMarginBottom,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      double? _percentageMarginLeft = CSSLength.parsePercentage(style[MARGIN_LEFT]);
      if (_percentageMarginLeft != null) {
        updateMargin(
          MARGIN_LEFT,
          parentContentBoxWidth * _percentageMarginLeft,
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    /// Update offset
    /// Offset of positioned element starts from the edge of padding box of containing block
    double? _percentageTop = CSSLength.parsePercentage(style[TOP]);
    if (_percentageTop != null) {
      updateOffset(
        TOP,
        parentPaddingBoxHeight * _percentageTop,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    double? _percentageRight = CSSLength.parsePercentage(style[RIGHT]);
    if (_percentageRight != null) {
      updateOffset(
        RIGHT,
        parentPaddingBoxWidth * _percentageRight,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    double? _percentageBottom = CSSLength.parsePercentage(style[BOTTOM]);
    if (_percentageBottom != null) {
      updateOffset(
        BOTTOM,
        parentPaddingBoxHeight * _percentageBottom,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    double? _percentageLeft = CSSLength.parsePercentage(style[LEFT]);
    if (_percentageLeft != null) {
      updateOffset(
        LEFT,
        parentPaddingBoxWidth * _percentageLeft,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    /// border-radius
    String? parsedTopLeftRadius = parsePercentageBorderRadius(style[BORDER_TOP_LEFT_RADIUS], size);
    if (parsedTopLeftRadius != null) {
      updateBorderRadius(
        BORDER_TOP_LEFT_RADIUS,
        parsedTopLeftRadius,
      );
      isPercentageExist = true;
    }

    String? parsedTopRightRadius = parsePercentageBorderRadius(style[BORDER_TOP_RIGHT_RADIUS], size);
    if (parsedTopRightRadius != null) {
      updateBorderRadius(
        BORDER_TOP_RIGHT_RADIUS,
        parsedTopRightRadius,
      );
      isPercentageExist = true;
    }

    String? parsedBottomLeftRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_LEFT_RADIUS], size);
    if (parsedBottomLeftRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_LEFT_RADIUS,
        parsedBottomLeftRadius,
      );
      isPercentageExist = true;
    }

    String? parsedBottomRightRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_RIGHT_RADIUS], size);
    if (parsedBottomRightRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_RIGHT_RADIUS,
        parsedBottomRightRadius,
      );
      isPercentageExist = true;
    }

    /// Transform translate
    Matrix4? transformValue = parsePercentageTransformTranslate(style[TRANSFORM], size, viewportSize);
    if (transformValue != null) {
      updateTransform(
        transformValue,
        shouldToggleRepaintBoundary: false,
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
    String? parsedTopLeftRadius = parsePercentageBorderRadius(style[BORDER_TOP_LEFT_RADIUS], size);

    if (parsedTopLeftRadius != null) {
      updateBorderRadius(
        BORDER_TOP_LEFT_RADIUS,
        parsedTopLeftRadius,
      );
      isPercentageExist = true;
    }

    String? parsedTopRightRadius = parsePercentageBorderRadius(style[BORDER_TOP_RIGHT_RADIUS], size);
    if (parsedTopRightRadius != null) {
      updateBorderRadius(
        BORDER_TOP_RIGHT_RADIUS,
        parsedTopRightRadius,
      );
      isPercentageExist = true;
    }

    String? parsedBottomLeftRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_LEFT_RADIUS], size);
    if (parsedBottomLeftRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_LEFT_RADIUS,
        parsedBottomLeftRadius,
      );
      isPercentageExist = true;
    }

    String? parsedBottomRightRadius = parsePercentageBorderRadius(style[BORDER_BOTTOM_RIGHT_RADIUS], size);
    if (parsedBottomRightRadius != null) {
      updateBorderRadius(
        BORDER_BOTTOM_RIGHT_RADIUS,
        parsedBottomRightRadius,
      );
      isPercentageExist = true;
    }

    /// Transform translate
    Matrix4? transformValue = parsePercentageTransformTranslate(style[TRANSFORM], size, viewportSize);
    if (transformValue != null) {
      updateTransform(
        transformValue,
        shouldToggleRepaintBoundary: false,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  bool isPercentageOfSizingExist(double parentLogicalContentWidth, double parentLogicalContentHeight) {
    if (
      CSSLength.isPercentage(style[WIDTH]) ||
      CSSLength.isPercentage(style[MIN_WIDTH]) ||
      CSSLength.isPercentage(style[MAX_WIDTH])
    ) {
      return true;
    }

    if (
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
  static String? parsePercentageBorderRadius(String radiusStr, Size size) {
    bool isPercentageExist = false;
    final RegExp _spaceRegExp = RegExp(r'\s+');
    List<String> values = radiusStr.split(_spaceRegExp);
    String parsedRadius = '';
    if (values.length == 1) {
      double? percentage = CSSLength.parsePercentage(values[0]);
      if (percentage != null) {
        parsedRadius += (size.width * percentage).toString() + 'px' + ' ' +
          (size.height * percentage).toString() + 'px';
        isPercentageExist = true;
      } else {
        parsedRadius += values[0];
      }
    } else if (values.length == 2) {
      double? p0 = CSSLength.parsePercentage(values[0]);
      double? p1 = CSSLength.parsePercentage(values[1]);
      if (p0 != null) {
        parsedRadius += (size.width * p0).toString() + 'px';
        isPercentageExist = true;
      } else {
        parsedRadius += values[0];
      }
      if (p1 != null) {
        parsedRadius += ' ' + (size.height * p1).toString() + 'px';
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
  static Matrix4? parsePercentageTransformTranslate(String transformStr, Size size, Size viewportSize) {
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(transformStr);
    final String TRANSLATE = 'translate';
    bool isPercentageExist = false;

    Matrix4? matrix4;
    for (CSSFunctionalNotation method in methods) {
      Matrix4? transform;
      if (method.name == TRANSLATE && method.args.length >= 1 && method.args.length <= 2) {
        double y;
        double x;
        if (method.args.length == 2) {
          String translateY = method.args[1].trim();
          if (CSSLength.isPercentage(translateY)) {
            double? percentage = CSSLength.parsePercentage(translateY);
            if (percentage != null) {
              translateY = (size.height * percentage).toString() + 'px';
              isPercentageExist = true;
            }
          }
          y = CSSLength.toDisplayPortValue(translateY, viewportSize) ?? 0;
        } else {
          y = 0;
        }
        String translateX = method.args[0].trim();
        if (CSSLength.isPercentage(translateX)) {
          double? percentage = CSSLength.parsePercentage(translateX);
          if (percentage != null) {
            translateX = (size.width * percentage).toString() + 'px';
            isPercentageExist = true;
          }
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

  /// Get height of replaced element by intrinsic ratio if height is not defined
  double getHeightByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double intrinsicWidth = renderBoxModel.intrinsicWidth;
    double intrinsicRatio = renderBoxModel.intrinsicRatio;
    double realWidth = width ?? intrinsicWidth;
    double? _minWidth = minWidth;
    double? _maxWidth = maxWidth;
    if (_minWidth != null && realWidth < _minWidth) {
      realWidth = _minWidth;
    }
    if (_maxWidth != null && realWidth > _maxWidth) {
      realWidth = _maxWidth;
    }
    double realHeight = realWidth * intrinsicRatio;
    return realHeight;
  }

  /// Get width of replaced element by intrinsic ratio if width is not defined
  double getWidthByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double intrinsicHeight = renderBoxModel.intrinsicHeight;
    double intrinsicRatio = renderBoxModel.intrinsicRatio;
    double realHeight = height ?? intrinsicHeight;
    double? _minWidth = minWidth;
    double? _maxWidth = maxWidth;
    if (_minWidth != null && realHeight < _minWidth) {
      realHeight = _minWidth;
    }
    if (_maxWidth != null && realHeight > _maxWidth) {
      realHeight = _maxWidth;
    }
    double realWidth = realHeight / intrinsicRatio;
    return realWidth;
  }
}

mixin RenderStyleBase {
  // Follwing properties used for exposing APIs
  // for class that extends [RenderStyleBase].
  late RenderBoxModel renderBoxModel;
  late CSSStyleDeclaration style;
  Size get viewportSize;
}

