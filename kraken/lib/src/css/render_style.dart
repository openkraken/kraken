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

  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size get viewportSize => renderBoxModel.elementManager.viewport.viewportSize;

  RenderStyle({ this.renderBoxModel, this.style });

  /// Resolve percentage size to px base on size of its containing block
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  bool resolvePercentageToContainingBlock(RenderBoxModel parent) {
    if (!renderBoxModel.hasSize) {
      return false;
    }

    final RenderLayoutParentData childParentData = renderBoxModel.parentData;
    double parentActualContentWidth = parent.size.width -
      parent.renderStyle.borderLeft - parent.renderStyle.borderRight -
      parent.renderStyle.paddingLeft - parent.renderStyle.paddingRight;
    double parentActualContentHeight = parent.size.height -
      parent.renderStyle.borderTop - parent.renderStyle.borderBottom -
      parent.renderStyle.paddingTop - parent.renderStyle.paddingBottom;
    double parentLogicalContentHeight = parent.logicalContentHeight;

    // The percentage of width is calculated with respect to the width of the generated box's containing block.
    // If the containing block's width depends on this element's width, then the resulting layout is undefined in CSS 2.1.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-width
    // @FIXME: The undefined layout of parent's width which depends on child's width may differ from browser.
    double parentContentWidth = parentActualContentWidth;
    // The percentage of height is calculated with respect to the height of the generated box's containing block.
    // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
    // and this element is not absolutely positioned, the value computes to 'auto'.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
    // Note: If the parent is flex item, percentage resloves againts the resolved height
    // no matter parent's height is set or not.
    double parentContentHeight = childParentData.isPositioned || parent.parent is RenderFlexLayout ?
      parentActualContentHeight : parentLogicalContentHeight;

    RenderStyle parentRenderStyle = parent.renderStyle;
    bool isPercentageExist = false;
    Size parentSize = parent.size;
    Size size = renderBoxModel.boxSize;

    double parentHorizontalBorderWidth = parentRenderStyle.borderEdge != null ?
      parentRenderStyle.borderEdge.horizontal : 0;
    double parentVerticalBorderWidth = parentRenderStyle.borderEdge != null ?
      parentRenderStyle.borderEdge.vertical : 0;
    double parentHorizontalPaddingWidth = parentRenderStyle.padding != null ?
      parentRenderStyle.padding.horizontal : 0;
    double parentVerticalPaddingHeight = parentRenderStyle.padding != null ?
      parentRenderStyle.padding.vertical : 0;

    /// Width and height of parent padding box
    double parentPaddingBoxWidth = parentSize.width - parentHorizontalBorderWidth;
    double parentPaddingBoxHeight = parentSize.height - parentVerticalBorderWidth;
    /// Width and height of parent content box
    double parentContentBoxWidth = parentSize.width - parentHorizontalBorderWidth - parentHorizontalPaddingWidth;
    double parentContentBoxHeight = parentSize.height - parentVerticalBorderWidth - parentVerticalPaddingHeight;

    /// Percentage sizing, margin and padding starts from the edge of content box of containing block
    /// Update sizing
    if (parentContentWidth != null) {
      double relativeParentWidth = childParentData.isPositioned ? parentPaddingBoxWidth : parentContentBoxWidth;

      if (CSSLength.isPercentage(style[WIDTH])) {
        updateSizing(
          WIDTH,
          relativeParentWidth * CSSLength.parsePercentage(style[WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MIN_WIDTH])) {
        updateSizing(
          MIN_WIDTH,
          relativeParentWidth * CSSLength.parsePercentage(style[MIN_WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MAX_WIDTH])) {
        updateSizing(
          MAX_WIDTH,
          relativeParentWidth * CSSLength.parsePercentage(style[MAX_WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    if (parentContentHeight != null) {
      double relativeParentHeight = childParentData.isPositioned ? parentPaddingBoxHeight : parentContentBoxHeight;

      if (CSSLength.isPercentage(style[HEIGHT])) {
        updateSizing(
          HEIGHT,
          relativeParentHeight * CSSLength.parsePercentage(style[HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MIN_HEIGHT])) {
        updateSizing(
          MIN_HEIGHT,
          relativeParentHeight * CSSLength.parsePercentage(style[MIN_HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MAX_HEIGHT])) {
        updateSizing(
          MAX_HEIGHT,
          relativeParentHeight * CSSLength.parsePercentage(style[MAX_HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    /// Percentage of padding and margin refer to the logical width of containing block
    if (parentContentWidth != null) {
      /// Update padding
      /// https://www.w3.org/TR/css-box-3/#padding-physical
      double relativeParentWidth = childParentData.isPositioned ? parentPaddingBoxWidth : parentContentBoxWidth;
      if (CSSLength.isPercentage(style[PADDING_TOP])) {
        updatePadding(
          PADDING_TOP,
          relativeParentWidth * CSSLength.parsePercentage(style[PADDING_TOP]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_RIGHT])) {
        updatePadding(
          PADDING_RIGHT,
          relativeParentWidth * CSSLength.parsePercentage(style[PADDING_RIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_BOTTOM])) {
        updatePadding(
          PADDING_BOTTOM,
          relativeParentWidth * CSSLength.parsePercentage(style[PADDING_BOTTOM]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_LEFT])) {
        updatePadding(
          PADDING_LEFT,
          relativeParentWidth * CSSLength.parsePercentage(style[PADDING_LEFT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      /// Update margin
      /// https://www.w3.org/TR/css-box-3/#margin-physical
      if (CSSLength.isPercentage(style[MARGIN_TOP])) {
        updateMargin(
          MARGIN_TOP,
          relativeParentWidth * CSSLength.parsePercentage(style[MARGIN_TOP]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_RIGHT])) {
        updateMargin(
          MARGIN_RIGHT,
          relativeParentWidth * CSSLength.parsePercentage(style[MARGIN_RIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_BOTTOM])) {
        updateMargin(
          MARGIN_BOTTOM,
          relativeParentWidth * CSSLength.parsePercentage(style[MARGIN_BOTTOM]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_LEFT])) {
        updateMargin(
          MARGIN_LEFT,
          relativeParentWidth * CSSLength.parsePercentage(style[MARGIN_LEFT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    /// Update offset
    /// Offset of positioned element starts from the edge of padding box of containing block
    if (CSSLength.isPercentage(style[TOP])) {
      updateOffset(
        TOP,
        parentPaddingBoxHeight * CSSLength.parsePercentage(style[TOP]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[RIGHT])) {
      updateOffset(
        RIGHT,
        parentPaddingBoxWidth * CSSLength.parsePercentage(style[RIGHT]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[BOTTOM])) {
      updateOffset(
        BOTTOM,
        parentPaddingBoxHeight * CSSLength.parsePercentage(style[BOTTOM]),
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    if (CSSLength.isPercentage(style[LEFT])) {
      updateOffset(
        LEFT,
        parentPaddingBoxWidth * CSSLength.parsePercentage(style[LEFT]),
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
        shouldToggleRepaintBoundary: false,
        shouldMarkNeedsLayout: false
      );
      isPercentageExist = true;
    }

    return isPercentageExist;
  }

  bool isPercentageOfSizingExist(RenderBoxModel parent) {
    final RenderLayoutParentData childParentData = renderBoxModel.parentData;
    double parentActualContentWidth = parent.size.width -
      parent.renderStyle.borderLeft - parent.renderStyle.borderRight -
      parent.renderStyle.paddingLeft - parent.renderStyle.paddingRight;
    double parentActualContentHeight = parent.size.height -
      parent.renderStyle.borderTop - parent.renderStyle.borderBottom -
      parent.renderStyle.paddingTop - parent.renderStyle.paddingBottom;
    double parentLogicalContentHeight = parent.logicalContentHeight;

    // The percentage of width is calculated with respect to the width of the generated box's containing block.
    // If the containing block's width depends on this element's width, then the resulting layout is undefined in CSS 2.1.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-width
    // @FIXME: The undefined layout of parent's width which depends on child's width may differ from browser.
    double parentContentWidth = parentActualContentWidth;
    // The percentage of height is calculated with respect to the height of the generated box's containing block.
    // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
    // and this element is not absolutely positioned, the value computes to 'auto'.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
    // Note: If the parent is flex item, percentage resloves againts the resolved width
    // no matter parent's width is set or not.
    double parentContentHeight = childParentData.isPositioned || parent.parent is RenderFlexLayout ?
      parentActualContentHeight : parentLogicalContentHeight;

    if (parentContentWidth != null && (
      CSSLength.isPercentage(style[WIDTH]) ||
      CSSLength.isPercentage(style[MIN_WIDTH]) ||
      CSSLength.isPercentage(style[MAX_WIDTH])
    )) {
      return true;
    }

    if (parentContentHeight != null && (
      CSSLength.isPercentage(style[HEIGHT]) ||
      CSSLength.isPercentage(style[MIN_HEIGHT]) ||
      CSSLength.isPercentage(style[MAX_HEIGHT])
    )) {
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

  /// Get height of replaced element by intrinsic ratio if height is not defined
  double getHeightByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double intrinsicWidth = renderBoxModel.intrinsicWidth;
    double intrinsicRatio = renderBoxModel.intrinsicRatio;
    double realWidth = width ?? intrinsicWidth;
    if (minWidth != null && realWidth < minWidth) {
      realWidth = minWidth;
    }
    if (maxWidth != null && realWidth > maxWidth) {
      realWidth = maxWidth;
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
    if (minHeight != null && realHeight < minHeight) {
      realHeight = minHeight;
    }
    if (maxHeight != null && realHeight > maxHeight) {
      realHeight = maxHeight;
    }
    double realWidth = realHeight / intrinsicRatio;
    return realWidth;
  }
}

mixin RenderStyleBase {
  // Follwing properties used for exposing APIs
  // for class that extends [RenderStyleBase].
  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size get viewportSize;
}

