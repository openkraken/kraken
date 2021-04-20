/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

// Constraints of element whose display style is none
final _displayNoneConstraints = BoxConstraints(
  minWidth: 0,
  maxWidth: 0,
  minHeight: 0,
  maxHeight: 0
);

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
    CSSSliverMixin,
    CSSOpacityMixin {

  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size get viewportSize => renderBoxModel.elementManager.viewport.viewportSize;

  RenderStyle({ this.renderBoxModel, this.style });

  /// Resolve percentage size to px base on size of its containing block
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  bool resolvePercentageToContainingBlock(double parentLogicalContentWidth, double parentLogicalContentHeight) {
    if (!renderBoxModel.hasSize) {
      return false;
    }

    RenderBoxModel parent = renderBoxModel.parent;
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
    if (parentLogicalContentWidth != null) {
      if (CSSLength.isPercentage(style[WIDTH])) {
        updateSizing(
          WIDTH,
          parentContentBoxWidth * CSSLength.parsePercentage(style[WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MIN_WIDTH])) {
        updateSizing(
          MIN_WIDTH,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MIN_WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MAX_WIDTH])) {
        updateSizing(
          MAX_WIDTH,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MAX_WIDTH]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    if (parentLogicalContentHeight != null) {
      if (CSSLength.isPercentage(style[HEIGHT])) {
        updateSizing(
          HEIGHT,
          parentContentBoxHeight * CSSLength.parsePercentage(style[HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MIN_HEIGHT])) {
        updateSizing(
          MIN_HEIGHT,
          parentContentBoxHeight * CSSLength.parsePercentage(style[MIN_HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MAX_HEIGHT])) {
        updateSizing(
          MAX_HEIGHT,
          parentContentBoxHeight * CSSLength.parsePercentage(style[MAX_HEIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }
    }

    /// Percentage of padding and margin refer to the logical width of containing block
    if (parentLogicalContentWidth != null) {
      /// Update padding
      /// https://www.w3.org/TR/css-box-3/#padding-physical
      if (CSSLength.isPercentage(style[PADDING_TOP])) {
        updatePadding(
          PADDING_TOP,
          parentContentBoxWidth * CSSLength.parsePercentage(style[PADDING_TOP]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_RIGHT])) {
        updatePadding(
          PADDING_RIGHT,
          parentContentBoxWidth * CSSLength.parsePercentage(style[PADDING_RIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_BOTTOM])) {
        updatePadding(
          PADDING_BOTTOM,
          parentContentBoxWidth * CSSLength.parsePercentage(style[PADDING_BOTTOM]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[PADDING_LEFT])) {
        updatePadding(
          PADDING_LEFT,
          parentContentBoxWidth * CSSLength.parsePercentage(style[PADDING_LEFT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      /// Update margin
      /// https://www.w3.org/TR/css-box-3/#margin-physical
      if (CSSLength.isPercentage(style[MARGIN_TOP])) {
        updateMargin(
          MARGIN_TOP,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MARGIN_TOP]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_RIGHT])) {
        updateMargin(
          MARGIN_RIGHT,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MARGIN_RIGHT]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_BOTTOM])) {
        updateMargin(
          MARGIN_BOTTOM,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MARGIN_BOTTOM]),
          shouldMarkNeedsLayout: false
        );
        isPercentageExist = true;
      }

      if (CSSLength.isPercentage(style[MARGIN_LEFT])) {
        updateMargin(
          MARGIN_LEFT,
          parentContentBoxWidth * CSSLength.parsePercentage(style[MARGIN_LEFT]),
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

  bool isPercentageOfSizingExist(double parentLogicalContentWidth, double parentLogicalContentHeight) {
    if (parentLogicalContentWidth != null && (
      CSSLength.isPercentage(style[WIDTH]) ||
      CSSLength.isPercentage(style[MIN_WIDTH]) ||
      CSSLength.isPercentage(style[MAX_WIDTH])
    )) {
      return true;
    }

    if (parentLogicalContentHeight != null && (
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

  /// Calculate renderBoxModel constraints based on style
  BoxConstraints getConstraints() {
    bool isDisplayInline = transformedDisplay == CSSDisplay.inline;
    bool isDisplayNone = transformedDisplay == CSSDisplay.none;

    if (isDisplayNone) {
      return _displayNoneConstraints;
    }

    double minConstraintWidth = 0;
    double maxConstraintWidth = double.infinity;
    double minConstraintHeight = 0;
    double maxConstraintHeight = double.infinity;;

    if (!isDisplayInline) {
      double horizontalBorderWidth = borderEdge != null ? borderEdge.horizontal : 0;
      double verticalBorderWidth = borderEdge != null ? borderEdge.vertical : 0;
      double horizontalPaddingWidth = padding != null ? padding.horizontal : 0;
      double verticalPaddingWidth = padding != null ? padding.vertical : 0;

      double realWidth = width;
      double realHeight = height;

      if (renderBoxModel.parent is RenderFlexLayout) {
        RenderBoxModel parentRenderBoxModel = renderBoxModel.parent;
        // In flex layout, flex basis takes priority over width/height if set
        if (flexBasis != null) {
          if (CSSFlex.isHorizontalFlexDirection(parentRenderBoxModel.renderStyle.flexDirection)) {
            realWidth = flexBasis;
          } else {
            realHeight = flexBasis;
          }
        }
      }

      // Width cannot be smaller than its horizontal border and padding width
      if (realWidth != null) {
        realWidth = horizontalBorderWidth + horizontalPaddingWidth > realWidth ? horizontalBorderWidth + horizontalPaddingWidth : realWidth;
      }

      minConstraintWidth = realWidth ?? minConstraintWidth;
      if (minWidth != null) {
        minConstraintWidth = minConstraintWidth < minWidth ? minWidth : minConstraintWidth;
      }
      if (maxWidth != null) {
        maxConstraintWidth = maxWidth;
        if (maxConstraintWidth < minConstraintWidth) {
          minConstraintWidth = maxConstraintWidth;
        }
      }

      // Height cannot be smaller than its vertical border and padding width
      if (realHeight != null) {
        realHeight = verticalBorderWidth + verticalPaddingWidth > realHeight ? verticalBorderWidth + verticalPaddingWidth : realHeight;
      }

      minConstraintHeight = realHeight ?? minConstraintHeight;
      if (minHeight != null) {
        minConstraintHeight = minConstraintHeight < minHeight ? minHeight : minConstraintHeight;
      }
      if (maxHeight != null) {
        maxConstraintHeight = maxHeight;
        if (maxConstraintHeight < minConstraintHeight) {
          minConstraintHeight = maxConstraintHeight;
        }
      }
    }

    return BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: maxConstraintHeight,
    );
  }
}

mixin RenderStyleBase {
  // Follwing properties used for exposing APIs
  // for class that extends [RenderStyleBase].
  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size get viewportSize;
}

