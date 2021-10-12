

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

mixin RenderStyleBase {
  // Following properties used for exposing APIs
  // for class that extends [RenderStyleBase].
  late ElementDelegate elementDelegate;
  late CSSStyleDeclaration style;
  RenderBoxModel? get renderBoxModel => elementDelegate.getRenderBoxModel();
  Size get viewportSize => elementDelegate.getViewportSize();
  double get rootFontSize => style.target!.elementManager.getRootFontSize();
}

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
    CSSVisibilityMixin,
    CSSContentVisibilityMixin,
    CSSFlexboxMixin,
    CSSDisplayMixin,
    CSSInlineMixin,
    CSSObjectFitMixin,
    CSSObjectPositionMixin,
    CSSSliverMixin,
    CSSOverflowMixin,
    CSSFilterEffectsMixin,
    CSSOpacityMixin {

  @override
  CSSStyleDeclaration style;
  @override
  ElementDelegate elementDelegate;

  RenderStyle? parent;

  RenderStyle({
    required this.style,
    required this.elementDelegate,
  });

  // Content width of render box model calculated from style.
  double? getLogicalContentWidth() {
    RenderStyle renderStyle = this;
    double? intrinsicRatio = renderBoxModel!.intrinsicRatio;
    CSSDisplay? transformedDisplay = renderStyle.transformedDisplay;
    double? width = renderStyle.width?.computedValue;
    double? minWidth = renderStyle.minWidth?.computedValue;
    double? maxWidth = renderStyle.maxWidth?.computedValue;
    double cropWidth = 0;

    switch (transformedDisplay) {
      case CSSDisplay.block:
      case CSSDisplay.flex:
      case CSSDisplay.sliver:
      // Get own width if exists else get the width of nearest ancestor width width
        if (renderStyle.width != null) {
          cropWidth = _getCropWidthByPaddingBorder(renderStyle, cropWidth);
        } else {
          // @TODO: flexbox stretch alignment will stretch replaced element in the cross axis
          // Block level element will spread to its parent's width except for replaced element
          if (renderBoxModel is! RenderIntrinsic) {
            RenderStyle currentRenderStyle = renderStyle;

            while (true) {
              RenderStyle? parentRenderStyle = renderStyle.parent;

              if (parentRenderStyle != null) {
                cropWidth = _getCropWidthByMargin(currentRenderStyle, cropWidth);
                cropWidth = _getCropWidthByPaddingBorder(currentRenderStyle, cropWidth);
                parentRenderStyle = currentRenderStyle.parent;
              } else {
                break;
              }

              CSSDisplay? parentDisplay = parentRenderStyle!.transformedDisplay;
              RenderBoxModel parentRenderBoxModel = parentRenderStyle.renderBoxModel!;
              // Set width of element according to parent display
              if (parentDisplay != CSSDisplay.inline) {
                // Skip to find upper parent
                if (parentRenderStyle.width != null) {
                  // Use style width
                  width = parentRenderStyle.width?.computedValue;
                  cropWidth = _getCropWidthByPaddingBorder(parentRenderStyle, cropWidth);
                  break;
                } else if (parentRenderBoxModel.constraints.isTight) {
                  // Cases like flex item with flex-grow and no width in flex row direction.
                  width = parentRenderBoxModel.constraints.maxWidth;
                  cropWidth = _getCropWidthByPaddingBorder(parentRenderStyle, cropWidth);
                  break;
                } else if (parentDisplay == CSSDisplay.inlineBlock ||
                  parentDisplay == CSSDisplay.inlineFlex ||
                  parentDisplay == CSSDisplay.sliver) {
                  // Collapse width to children
                  width = null;
                  break;
                }
              }

              currentRenderStyle = parentRenderStyle;
            }
          }
        }
        break;
      case CSSDisplay.inlineBlock:
      case CSSDisplay.inlineFlex:
        if (renderStyle.width != null) {
          width = renderStyle.width?.computedValue;
          cropWidth = _getCropWidthByPaddingBorder(renderStyle, cropWidth);
        } else {
          width = null;
        }
        break;
      case CSSDisplay.inline:
        width = null;
        break;
      default:
        break;
    }
    // Get height by intrinsic ratio for replaced element if height is not defined
    if (width == null && intrinsicRatio != null) {
      width = renderStyle.getWidthByIntrinsicRatio() + cropWidth;
    }

    if (minWidth != null) {
      if (width != null && width < minWidth) {
        width = minWidth;
      }
    }
    if (maxWidth != null) {
      if (width != null && width > maxWidth) {
        width = maxWidth;
      }
    }

    if (width != null) {
      return math.max(0, width - cropWidth);
    } else {
      return null;
    }
  }

  // Content height of render box model calculated from style.
  double? getLogicalContentHeight() {
    RenderStyle renderStyle = this;
    CSSDisplay? display = renderStyle.transformedDisplay;
    double? height = renderStyle.height?.computedValue;
    double cropHeight = 0;
    double? maxHeight = renderStyle.maxHeight?.computedValue;
    double? minHeight = renderStyle.minHeight?.computedValue;
    double? intrinsicRatio = renderBoxModel!.intrinsicRatio;

    // Inline element has no height
    if (display == CSSDisplay.inline) {
      return null;
    } else if (height != null) {
      cropHeight = _getCropHeightByPaddingBorder(renderStyle, cropHeight);
    } else {
      RenderStyle currentRenderStyle = renderStyle;

      while (true) {
        RenderStyle? parentRenderStyle = currentRenderStyle.parent;

        if (parentRenderStyle != null) {
          cropHeight = _getCropHeightByMargin(currentRenderStyle, cropHeight);
          cropHeight = _getCropHeightByPaddingBorder(currentRenderStyle, cropHeight);
          parentRenderStyle = currentRenderStyle.parent;
        } else {
          break;
        }

        RenderBoxModel parentRenderBoxModel = parentRenderStyle!.renderBoxModel!;
        if (CSSSizingMixin.isStretchChildHeight(parentRenderStyle, currentRenderStyle)) {
          if (parentRenderStyle.height != null) {
            height = parentRenderStyle.height?.computedValue;
            cropHeight = _getCropHeightByPaddingBorder(parentRenderStyle, cropHeight);
            break;
          } else if (parentRenderBoxModel.constraints.isTight) {
            // Cases like flex item with flex-grow and no height in flex column direction.
            height = parentRenderBoxModel.constraints.maxHeight;
            cropHeight = _getCropHeightByPaddingBorder(parentRenderStyle, cropHeight);
            break;
          }
        } else {
          break;
        }

        currentRenderStyle = parentRenderStyle;
      }
    }

    // Get height by intrinsic ratio for replaced element if height is not defined
    if (height == null && intrinsicRatio != null) {
      height = renderStyle.getHeightByIntrinsicRatio() + cropHeight;
    }

    if (minHeight != null) {
      if (height != null && height < minHeight) {
        height = minHeight;
      }
    }
    if (maxHeight != null) {
      if (height != null && height > maxHeight) {
        height = maxHeight;
      }
    }

    if (height != null) {
      return math.max(0, height - cropHeight);
    } else {
      return null;
    }
  }

  /// Get max constraint width from style, use width or max-width exists if exists,
  /// otherwise calculated from its ancestors
  double getMaxConstraintWidth() {
    double maxConstraintWidth = double.infinity;
    double cropWidth = 0;

    RenderStyle currentRenderStyle = this;

    // Get the nearest width of ancestor with width
    while (true) {
      RenderStyle? parentRenderStyle = currentRenderStyle.parent;

      CSSDisplay? transformedDisplay = currentRenderStyle.transformedDisplay;

      // Flex item with flex-shrink 0 and no width/max-width will have infinity constraints
      // even if parents have width
      if (parentRenderStyle != null && (parentRenderStyle.display == CSSDisplay.flex ||
        parentRenderStyle.display == CSSDisplay.inlineFlex)
      ) {
        if (currentRenderStyle.flexShrink == 0 &&
          currentRenderStyle.width == null &&
          currentRenderStyle.maxWidth == null) {
          break;
        }
      }

      // Get width if width exists and element is not inline
      if (transformedDisplay != CSSDisplay.inline &&
        (currentRenderStyle.width != null || currentRenderStyle.maxWidth != null)) {
        // Get the min width between width and max-width
        maxConstraintWidth = math.min(currentRenderStyle.width?.computedValue ?? double.infinity,
          currentRenderStyle.maxWidth?.computedValue ?? double.infinity);
        cropWidth = _getCropWidthByPaddingBorder(currentRenderStyle, cropWidth);
        break;
      }

      if (parentRenderStyle != null) {
        cropWidth = _getCropHeightByMargin(currentRenderStyle, cropWidth);
        cropWidth = _getCropHeightByPaddingBorder(currentRenderStyle, cropWidth);
        currentRenderStyle = parentRenderStyle;
      } else {
        break;
      }
    }

    if (maxConstraintWidth != double.infinity) {
      maxConstraintWidth = maxConstraintWidth - cropWidth;
    }

    return maxConstraintWidth;
  }

  // Max constraints width calculated from renderStyle tree.
  double get maxConstraintsWidth {
    // @TODO: add cache to avoid recalculate every time.
    return getMaxConstraintWidth();
  }

  // Content width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  double? get contentBoxLogicalWidth {
    // @TODO: add cache to avoid recalculate every time.
    return getLogicalContentWidth();
  }

  // Content height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  double? get contentBoxLogicalHeight {
    // @TODO: add cache to avoid recalculate every time.
    return getLogicalContentHeight();
  }

  // Padding box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  double? get paddingBoxLogicalWidth {
    if (contentBoxLogicalWidth == null) {
      return null;
    }
    return contentBoxLogicalWidth! + paddingLeft.computedValue + paddingRight.computedValue;
  }

  // Padding box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  double? get paddingBoxLogicalHeight {
    if (contentBoxLogicalHeight == null) {
      return null;
    }
    return contentBoxLogicalHeight! + paddingTop.computedValue + paddingBottom.computedValue;
  }

  // Border box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxLogicalWidth {
    if (paddingBoxLogicalWidth == null) {
      return null;
    }
    return paddingBoxLogicalWidth! + borderLeftWidth.computedValue + borderRightWidth.computedValue;
  }

  // Border box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxLogicalHeight {
    if (paddingBoxLogicalHeight == null) {
      return null;
    }
    return paddingBoxLogicalHeight! + borderTopWidth.computedValue + borderBottomWidth.computedValue;
  }

  // Content box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  double? get contentBoxWidth {
    if (paddingBoxWidth == null) {
      return null;
    }
    return paddingBoxWidth! - paddingLeft.computedValue - paddingRight.computedValue;
  }

  // Content box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  double? get contentBoxHeight {
    if (paddingBoxHeight == null) {
      return null;
    }
    return paddingBoxHeight! - paddingTop.computedValue - paddingBottom.computedValue;
  }

  // Padding box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  double? get paddingBoxWidth {
    if (borderBoxWidth == null) {
      return null;
    }
    return borderBoxWidth! - borderLeftWidth.computedValue - borderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  double? get paddingBoxHeight {
    if (borderBoxHeight == null) {
      return null;
    }
    return borderBoxHeight! - borderTopWidth.computedValue - borderBottomWidth.computedValue;
  }

  // Border box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxWidth {
    Size? size = renderBoxModel!.boxSize;
    if (size == null) {
      return null;
    }
    return size.width;
  }

  // Border box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxHeight {
    Size? size = renderBoxModel!.boxSize;
    if (size == null) {
      return null;
    }
    return size.height;
  }

  /// Resolve percentage size to px base on size of its containing block
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing
  void resolveContainingBlock(RenderBoxModel parent) {
    if (!renderBoxModel!.hasSize || renderBoxModel!.parentData is! RenderLayoutParentData) {
      return;
    }

    final RenderLayoutParentData childParentData = renderBoxModel!.parentData as RenderLayoutParentData;
    double parentActualContentHeight = parent.size.height -
      parent.renderStyle.borderTopWidth.computedValue - parent.renderStyle.borderBottomWidth.computedValue -
      parent.renderStyle.paddingTop.computedValue - parent.renderStyle.paddingBottom.computedValue;
    double? parentLogicalContentHeight = parent.logicalContentHeight;

    // The percentage of height is calculated with respect to the height of the generated box's containing block.
    // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
    // and this element is not absolutely positioned, the value computes to 'auto'.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
    // Note: If the parent is flex item, percentage resloves againts the resolved height
    // no matter parent's height is set or not.
    double? parentContentHeight = childParentData.isPositioned || parent.parent is RenderFlexLayout ?
      parentActualContentHeight : parentLogicalContentHeight;

    RenderStyle parentRenderStyle = parent.renderStyle;
    Size parentSize = parent.size;
    Size? size = renderBoxModel!.boxSize;

    double parentHorizontalBorderWidth = parentRenderStyle.borderEdge != null ?
      parentRenderStyle.borderEdge.horizontal : 0;
    double parentVerticalBorderWidth = parentRenderStyle.borderEdge != null ?
      parentRenderStyle.borderEdge.vertical : 0;
    double parentHorizontalPaddingWidth = parentRenderStyle.padding.horizontal;
    double parentVerticalPaddingHeight = parentRenderStyle.padding.vertical;

    /// Width and height of parent padding box
    double parentPaddingBoxWidth = parentSize.width - parentHorizontalBorderWidth;
    double parentPaddingBoxHeight = parentSize.height - parentVerticalBorderWidth;
    /// Width and height of parent content box
    double parentContentBoxWidth = parentSize.width - parentHorizontalBorderWidth - parentHorizontalPaddingWidth;
    double parentContentBoxHeight = parentSize.height - parentVerticalBorderWidth - parentVerticalPaddingHeight;

    /// Percentage sizing, margin and padding starts from the edge of content box of containing block
    /// Update sizing
    double relativeParentWidth = childParentData.isPositioned ? parentPaddingBoxWidth : parentContentBoxWidth;

    // Compute all percentage sizes.
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-widths-heights
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-heights
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizes
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-width
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-height
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-size
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-containing-block
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-content-box
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-padding-box
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-border-box
    // https://www.w3.org/TR/CSS2/visudet.html#percentage-sizing-of-the-margin-box


    if (parentContentHeight != null) {
      double relativeParentHeight = childParentData.isPositioned ? parentPaddingBoxHeight : parentContentBoxHeight;
    }


    /// Percentage of padding and margin refer to the logical width of containing block
    /// Update padding
    /// https://www.w3.org/TR/css-box-3/#padding-physical

    /// Update margin
    /// https://www.w3.org/TR/css-box-3/#margin-physical


    /// Update offset
    /// Offset of positioned element starts from the edge of padding box of containing block
    ///
    /// parentPaddingBoxHeight
    /// parentPaddingBoxWidth

  }

  /// Resolve percentage size to px base on size of its own
  /// https://www.w3.org/TR/css-sizing-3/#percentage-sizing


  bool isPercentageOfSizingExist(RenderBoxModel parent) {
    if (renderBoxModel!.parentData is! RenderLayoutParentData) return false;

    final RenderLayoutParentData childParentData = renderBoxModel!.parentData as RenderLayoutParentData;
    double parentActualContentHeight = parent.size.height -
      parent.renderStyle.borderTopWidth.computedValue - parent.renderStyle.borderBottomWidth.computedValue -
      parent.renderStyle.paddingTop.computedValue - parent.renderStyle.paddingBottom.computedValue;
    double? parentLogicalContentHeight = parent.logicalContentHeight;

    // The percentage of height is calculated with respect to the height of the generated box's containing block.
    // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
    // and this element is not absolutely positioned, the value computes to 'auto'.
    // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
    // Note: If the parent is flex item, percentage resloves againts the resolved width
    // no matter parent's width is set or not.
    double? parentContentHeight = childParentData.isPositioned || parent.parent is RenderFlexLayout ?
      parentActualContentHeight : parentLogicalContentHeight;

    if (CSSLength.isPercentage(style[WIDTH]) ||
      CSSLength.isPercentage(style[MIN_WIDTH]) ||
      CSSLength.isPercentage(style[MAX_WIDTH])
    ) {
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

  /// Get height of replaced element by intrinsic ratio if height is not defined
  double getHeightByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double? intrinsicWidth = renderBoxModel!.intrinsicWidth;
    double intrinsicRatio = renderBoxModel!.intrinsicRatio!;
    double? realWidth = width?.computedValue ?? intrinsicWidth;
    if (minWidth != null && realWidth! < minWidth!.computedValue) {
      realWidth = minWidth!.computedValue;
    }
    if (maxWidth != null && realWidth! > maxWidth!.computedValue) {
      realWidth = maxWidth!.computedValue;
    }
    double realHeight = realWidth! * intrinsicRatio;
    return realHeight;
  }

  /// Get width of replaced element by intrinsic ratio if width is not defined
  double getWidthByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double? intrinsicHeight = renderBoxModel!.intrinsicHeight;
    double intrinsicRatio = renderBoxModel!.intrinsicRatio!;
    double? realHeight = height?.computedValue ?? intrinsicHeight;
    if (minHeight != null && realHeight! < minHeight!.computedValue) {
      realHeight = minHeight!.computedValue;
    }
    if (maxHeight != null && realHeight! > maxHeight!.computedValue) {
      realHeight = maxHeight!.computedValue;
    }
    double realWidth = realHeight! / intrinsicRatio;
    return realWidth;
  }
}

double _getCropWidthByMargin(RenderStyle renderStyle, double cropWidth) {
  cropWidth += renderStyle.margin.horizontal;
  return cropWidth;
}

double _getCropWidthByPaddingBorder(RenderStyle renderStyle, double cropWidth) {
  cropWidth += renderStyle.borderEdge.horizontal;
  cropWidth += renderStyle.padding.horizontal;
  return cropWidth;
}

double _getCropHeightByMargin(RenderStyle renderStyle, double cropHeight) {
  cropHeight += renderStyle.margin.vertical;
  return cropHeight;
}

double _getCropHeightByPaddingBorder(RenderStyle renderStyle, double cropHeight) {
  cropHeight += renderStyle.borderEdge.vertical;
  cropHeight += renderStyle.padding.vertical;
  return cropHeight;
}
