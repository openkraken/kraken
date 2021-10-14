

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
  Color get currentColor => (this as RenderStyle).color;
}

class RenderStyle
  with
    RenderStyleBase,
    CSSSizingMixin,
    CSSPaddingMixin,
    CSSBorderMixin,
    CSSBorderRadiusMixin,
    CSSMarginMixin,
    CSSBackgroundMixin,
    CSSBoxShadowMixin,
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
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    double? width = renderStyle.width?.computedValue;
    double? minWidth = renderStyle.minWidth?.computedValue;
    double? maxWidth = renderStyle.maxWidth?.computedValue;
    double cropWidth = 0;

    switch (effectiveDisplay) {
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

              CSSDisplay? parentEffectiveDisplay = parentRenderStyle!.effectiveDisplay;
              RenderBoxModel parentRenderBoxModel = parentRenderStyle.renderBoxModel!;
              // Set width of element according to parent display
              if (parentEffectiveDisplay != CSSDisplay.inline) {
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
                } else if (parentEffectiveDisplay == CSSDisplay.inlineBlock ||
                  parentEffectiveDisplay == CSSDisplay.inlineFlex ||
                  parentEffectiveDisplay == CSSDisplay.sliver) {
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
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    double? height = renderStyle.height?.computedValue;
    double cropHeight = 0;
    double? maxHeight = renderStyle.maxHeight?.computedValue;
    double? minHeight = renderStyle.minHeight?.computedValue;
    double? intrinsicRatio = renderBoxModel!.intrinsicRatio;

    // Inline element has no height
    if (effectiveDisplay == CSSDisplay.inline) {
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
      CSSDisplay? effectiveDisplay = currentRenderStyle.effectiveDisplay;

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
      if (effectiveDisplay != CSSDisplay.inline &&
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
  // @TODO: add cache to avoid recalculate every time.
  double get maxConstraintsWidth {
    return getMaxConstraintWidth();
  }

  // Content width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // @TODO: add cache to avoid recalculate every time.
  double? get contentBoxLogicalWidth {
    // If renderBox has tight constraints, its logical size equals max size.
    if (renderBoxModel != null &&
      renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.isTight
    ) {
      return renderBoxModel!.constraints.maxWidth -
        effectiveBorderLeftWidth.computedValue - effectiveBorderRightWidth.computedValue -
        paddingLeft.computedValue - paddingRight.computedValue;
    }
    return getLogicalContentWidth();
  }

  // Content height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // @TODO: add cache to avoid recalculate every time.
  double? get contentBoxLogicalHeight {
    // If renderBox has tight constraints, its logical size equals max size.
    if (renderBoxModel != null &&
      renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.isTight
    ) {
      return renderBoxModel!.constraints.maxHeight -
        effectiveBorderTopWidth.computedValue - effectiveBorderBottomWidth.computedValue -
        paddingTop.computedValue - paddingBottom.computedValue;
    }
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
    return paddingBoxLogicalWidth! + effectiveBorderLeftWidth.computedValue + effectiveBorderRightWidth.computedValue;
  }

  // Border box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxLogicalHeight {
    if (paddingBoxLogicalHeight == null) {
      return null;
    }
    return paddingBoxLogicalHeight! + effectiveBorderTopWidth.computedValue + effectiveBorderBottomWidth.computedValue;
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
    return borderBoxWidth! - effectiveBorderLeftWidth.computedValue - effectiveBorderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  double? get paddingBoxHeight {
    if (borderBoxHeight == null) {
      return null;
    }
    return borderBoxHeight! - effectiveBorderTopWidth.computedValue - effectiveBorderBottomWidth.computedValue;
  }

  // Border box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxWidth {
    if (renderBoxModel!.hasSize && renderBoxModel!.boxSize != null) {
      return renderBoxModel!.boxSize!.width;
    }
    return null;
  }

  // Border box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  double? get borderBoxHeight {
    if (renderBoxModel!.hasSize && renderBoxModel!.boxSize != null) {
      return renderBoxModel!.boxSize!.height;
    }
    return null;
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
  cropWidth += renderStyle.border.horizontal;
  cropWidth += renderStyle.padding.horizontal;
  return cropWidth;
}

double _getCropHeightByMargin(RenderStyle renderStyle, double cropHeight) {
  cropHeight += renderStyle.margin.vertical;
  return cropHeight;
}

double _getCropHeightByPaddingBorder(RenderStyle renderStyle, double cropHeight) {
  cropHeight += renderStyle.border.vertical;
  cropHeight += renderStyle.padding.vertical;
  return cropHeight;
}
