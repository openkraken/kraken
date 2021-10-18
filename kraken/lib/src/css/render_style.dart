

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

  void setProperty(String name, dynamic value) {
    RenderStyle renderStyle = this;
    switch (name) {
      case DISPLAY:
        renderStyle.display = value;
        break;
      case Z_INDEX:
        renderStyle.zIndex = value;
        break;
      case OVERFLOW_X:
        renderStyle.overflowX = value;
        break;
      case OVERFLOW_Y:
        renderStyle.overflowY = value;
        break;
      case OPACITY:
        renderStyle.opacity = value;
        break;
      case VISIBILITY:
        renderStyle.visibility = value;
        break;
      case CONTENT_VISIBILITY:
        renderStyle.contentVisibility = value;
        break;
      case POSITION:
        renderStyle.position = value;
        break;
      case TOP:
        renderStyle.top = value;
        break;
      case LEFT:
        renderStyle.left = value;
        break;
      case BOTTOM:
        renderStyle.bottom = value;
        break;
      case RIGHT:
        renderStyle.right = value;
        break;
      // Size
      case WIDTH:
        renderStyle.width = value;
        break;
      case MIN_WIDTH:
        renderStyle.minWidth = value;
        break;
      case MAX_WIDTH:
        renderStyle.maxWidth = value;
        break;
      case HEIGHT:
        renderStyle.height = value;
        break;
      case MIN_HEIGHT:
        renderStyle.minHeight = value;
        break;
      case MAX_HEIGHT:
        renderStyle.maxHeight = value;
        break;
      // Flex
      case FLEX_DIRECTION:
        renderStyle.flexDirection = value;
        break;
      case FLEX_WRAP:
        renderStyle.flexWrap = value;
        break;
      case ALIGN_CONTENT:
        renderStyle.alignContent = value;
        break;
      case ALIGN_ITEMS:
        renderStyle.alignItems = value;
        break;
      case JUSTIFY_CONTENT:
        renderStyle.justifyContent = value;
        break;
      case ALIGN_SELF:
        renderStyle.alignSelf = value;
        break;
      case FLEX_GROW:
        renderStyle.flexGrow = value;
        break;
      case FLEX_SHRINK:
        renderStyle.flexShrink = value;
        break;
      case FLEX_BASIS:
        renderStyle.flexBasis = value;
        break;
      // Background
      case BACKGROUND_COLOR:
        renderStyle.backgroundColor = value;
        break;
      case BACKGROUND_ATTACHMENT:
        renderStyle.backgroundAttachment = value;
        break;
      case BACKGROUND_IMAGE:
        renderStyle.backgroundImage = value;
        break;
      case BACKGROUND_REPEAT:
        renderStyle.backgroundRepeat = value;
        break;
      case BACKGROUND_POSITION_X:
        renderStyle.backgroundPositionX = value;
        break;
      case BACKGROUND_POSITION_Y:
        renderStyle.backgroundPositionY = value;
        break;
      case BACKGROUND_SIZE:
        renderStyle.backgroundSize = value;
        break;
      case BACKGROUND_CLIP:
        renderStyle.backgroundClip = value;
        break;
      case BACKGROUND_ORIGIN:
        renderStyle.backgroundOrigin = value;
        break;
      // Padding
      case PADDING_TOP:
        renderStyle.paddingTop = value;
        break;
      case PADDING_RIGHT:
        renderStyle.paddingRight = value;
        break;
      case PADDING_BOTTOM:
        renderStyle.paddingBottom = value;
        break;
      case PADDING_LEFT:
        renderStyle.paddingLeft = value;
        break;
      // Border
      case BORDER_LEFT_WIDTH:
        renderStyle.borderLeftWidth = value;
        break;
      case BORDER_TOP_WIDTH:
        renderStyle.borderTopWidth = value;
        break;
      case BORDER_RIGHT_WIDTH:
        renderStyle.borderRightWidth = value;
        break;
      case BORDER_BOTTOM_WIDTH:
        renderStyle.borderBottomWidth = value;
        break;
      case BORDER_LEFT_STYLE:
        renderStyle.borderLeftStyle = value;
        break;
      case BORDER_TOP_STYLE:
        renderStyle.borderTopStyle = value;
        break;
      case BORDER_RIGHT_STYLE:
        renderStyle.borderRightStyle = value;
        break;
      case BORDER_BOTTOM_STYLE:
        renderStyle.borderBottomStyle = value;
        break;
      case BORDER_LEFT_COLOR:
        renderStyle.borderLeftColor = value;
        break;
      case BORDER_TOP_COLOR:
        renderStyle.borderTopColor = value;
        break;
      case BORDER_RIGHT_COLOR:
        renderStyle.borderRightColor = value;
        break;
      case BORDER_BOTTOM_COLOR:
        renderStyle.borderBottomColor = value;
        break;
      case BOX_SHADOW:
        renderStyle.boxShadow = value;
        break;
      case BORDER_TOP_LEFT_RADIUS:
        renderStyle.borderTopLeftRadius = value;
        break;
      case BORDER_TOP_RIGHT_RADIUS:
        renderStyle.borderTopRightRadius = value;
        break;
      case BORDER_BOTTOM_LEFT_RADIUS:
        renderStyle.borderBottomLeftRadius = value;
        break;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        renderStyle.borderBottomRightRadius = value;
        break;
      // Margin
      case MARGIN_LEFT:
        renderStyle.marginLeft = value;
        break;
      case MARGIN_TOP:
        renderStyle.marginTop = value;
        break;
      case MARGIN_RIGHT:
        renderStyle.marginRight = value;
        break;
      case MARGIN_BOTTOM:
        renderStyle.marginBottom = value;
        break;
      // Text
      case COLOR:
        // TODO: Color change should trigger currentColor update
        renderStyle.color = value;
        break;
      case TEXT_DECORATION_LINE:
        renderStyle.textDecorationLine = value;
        break;
      case TEXT_DECORATION_STYLE:
        renderStyle.textDecorationStyle = value;
        break;
      case TEXT_DECORATION_COLOR:
        renderStyle.textDecorationColor = value;
        break;
      case FONT_WEIGHT:
        renderStyle.fontWeight = value;
        break;
      case FONT_STYLE:
        renderStyle.fontStyle = value;
        break;
      case FONT_FAMILY:
        renderStyle.fontFamily = value;
        break;
      case FONT_SIZE:
        renderStyle.fontSize = value;
        break;
      case LINE_HEIGHT:
        renderStyle.lineHeight = value;
        break;
      case LETTER_SPACING:
        renderStyle.letterSpacing = value;
        break;
      case WORD_SPACING:
        renderStyle.wordSpacing = value;
        break;
      case TEXT_SHADOW:
        renderStyle.textShadow = value;
        break;
      case WHITE_SPACE:
        renderStyle.whiteSpace = value;
        break;
      case TEXT_OVERFLOW:
        // Overflow will affect text-overflow ellipsis taking effect
        renderStyle.textOverflow = value;
        break;
      case LINE_CLAMP:
        renderStyle.lineClamp = value;
        break;
      case VERTICAL_ALIGN:
        renderStyle.verticalAlign = value;
        break;
      case TEXT_ALIGN:
        renderStyle.textAlign = value;
        break;
      // Transfrom
      case TRANSFORM:
        renderStyle.transform = value;
        break;
      case TRANSFORM_ORIGIN:
        renderStyle.transformOrigin = value;
        break;
      // Others
      case OBJECT_FIT:
        renderStyle.objectFit = value;
        break;
      case OBJECT_POSITION:
        renderStyle.objectPosition = value;
        break;
      case FILTER:
        renderStyle.filter = value;
        break;
      case SLIVER_DIRECTION:
        renderStyle.sliverDirection = value;
          break;
    }
  }

  dynamic getProperty(String name) {
    RenderStyle renderStyle = this;
    switch (name) {
      case DISPLAY:
        return renderStyle.display;
      case Z_INDEX:
        return renderStyle.zIndex;
      case OVERFLOW_X:
        return renderStyle.overflowX;
      case OVERFLOW_Y:
        return renderStyle.overflowY;
      case OPACITY:
        return renderStyle.opacity;
      case VISIBILITY:
        return renderStyle.visibility;
      case CONTENT_VISIBILITY:
        return renderStyle.contentVisibility;
      case POSITION:
        return renderStyle.position;
      case TOP:
        return renderStyle.top;
      case LEFT:
        return renderStyle.left;
      case BOTTOM:
        return renderStyle.bottom;
      case RIGHT:
        return renderStyle.right;
      // Size
      case WIDTH:
        return renderStyle.width;
      case MIN_WIDTH:
        return renderStyle.minWidth;
      case MAX_WIDTH:
        return renderStyle.maxWidth;
      case HEIGHT:
        return renderStyle.height;
      case MIN_HEIGHT:
        return renderStyle.minHeight;
      case MAX_HEIGHT:
        return renderStyle.maxHeight;
      // Flex
      case FLEX_DIRECTION:
        return renderStyle.flexDirection;
      case FLEX_WRAP:
        return renderStyle.flexWrap;
      case ALIGN_CONTENT:
        return renderStyle.alignContent;
      case ALIGN_ITEMS:
        return renderStyle.alignItems;
      case JUSTIFY_CONTENT:
        return renderStyle.justifyContent;
      case ALIGN_SELF:
        return renderStyle.alignSelf;
      case FLEX_GROW:
        return renderStyle.flexGrow;
      case FLEX_SHRINK:
        return renderStyle.flexShrink;
      case FLEX_BASIS:
        return renderStyle.flexBasis;
      // Background
      case BACKGROUND_COLOR:
        return renderStyle.backgroundColor;
      case BACKGROUND_ATTACHMENT:
        return renderStyle.backgroundAttachment;
      case BACKGROUND_IMAGE:
        return renderStyle.backgroundImage;
      case BACKGROUND_REPEAT:
        return renderStyle.backgroundRepeat;
      case BACKGROUND_POSITION_X:
        return renderStyle.backgroundPositionX;
      case BACKGROUND_POSITION_Y:
        return renderStyle.backgroundPositionY;
      case BACKGROUND_SIZE:
        return renderStyle.backgroundSize;
      case BACKGROUND_CLIP:
        return renderStyle.backgroundClip;
      case BACKGROUND_ORIGIN:
        return renderStyle.backgroundOrigin;
      // Padding
      case PADDING_TOP:
        return renderStyle.paddingTop;
      case PADDING_RIGHT:
        return renderStyle.paddingRight;
      case PADDING_BOTTOM:
        return renderStyle.paddingBottom;
      case PADDING_LEFT:
        return renderStyle.paddingLeft;
      // Border
      case BORDER_LEFT_WIDTH:
        return renderStyle.borderLeftWidth;
      case BORDER_TOP_WIDTH:
        return renderStyle.borderTopWidth;
      case BORDER_RIGHT_WIDTH:
        return renderStyle.borderRightWidth;
      case BORDER_BOTTOM_WIDTH:
        return renderStyle.borderBottomWidth;
      case BORDER_LEFT_STYLE:
        return renderStyle.borderLeftStyle;
      case BORDER_TOP_STYLE:
        return renderStyle.borderTopStyle;
      case BORDER_RIGHT_STYLE:
        return renderStyle.borderRightStyle;
      case BORDER_BOTTOM_STYLE:
        return renderStyle.borderBottomStyle;
      case BORDER_LEFT_COLOR:
        return renderStyle.borderLeftColor;
      case BORDER_TOP_COLOR:
        return renderStyle.borderTopColor;
      case BORDER_RIGHT_COLOR:
        return renderStyle.borderRightColor;
      case BORDER_BOTTOM_COLOR:
        return renderStyle.borderBottomColor;
      case BOX_SHADOW:
        return renderStyle.boxShadow;
      case BORDER_TOP_LEFT_RADIUS:
        return renderStyle.borderTopLeftRadius;
      case BORDER_TOP_RIGHT_RADIUS:
        return renderStyle.borderTopRightRadius;
      case BORDER_BOTTOM_LEFT_RADIUS:
        return renderStyle.borderBottomLeftRadius;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        return renderStyle.borderBottomRightRadius;
      // Margin
      case MARGIN_LEFT:
        return renderStyle.marginLeft;
      case MARGIN_TOP:
        return renderStyle.marginTop;
      case MARGIN_RIGHT:
        return renderStyle.marginRight;
      case MARGIN_BOTTOM:
        return renderStyle.marginBottom;
      // Text
      case COLOR:
        return renderStyle.color;
      case TEXT_DECORATION_LINE:
        return renderStyle.textDecorationLine;
      case TEXT_DECORATION_STYLE:
        return renderStyle.textDecorationStyle;
      case TEXT_DECORATION_COLOR:
        return renderStyle.textDecorationColor;
      case FONT_WEIGHT:
        return renderStyle.fontWeight;
      case FONT_STYLE:
        return renderStyle.fontStyle;
      case FONT_FAMILY:
        return renderStyle.fontFamily;
      case FONT_SIZE:
        return renderStyle.fontSize;
      case LINE_HEIGHT:
        return renderStyle.lineHeight;
      case LETTER_SPACING:
        return renderStyle.letterSpacing;
      case WORD_SPACING:
        return renderStyle.wordSpacing;
      case TEXT_SHADOW:
        return renderStyle.textShadow;
      case WHITE_SPACE:
        return renderStyle.whiteSpace;
      case TEXT_OVERFLOW:
        return renderStyle.textOverflow;
      case LINE_CLAMP:
        return renderStyle.lineClamp;
      case VERTICAL_ALIGN:
        return renderStyle.verticalAlign;
      case TEXT_ALIGN:
        return renderStyle.textAlign;
      // Transform
      case TRANSFORM:
        return renderStyle.transform;
      case TRANSFORM_ORIGIN:
        return renderStyle.transformOrigin;
      case SLIVER_DIRECTION:
        return renderStyle.sliverDirection;
      case OBJECT_FIT:
        return renderStyle.objectFit;
      case OBJECT_POSITION:
        return renderStyle.objectPosition;
      case FILTER:
        return renderStyle.filter;
    }
  }

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
                cropWidth += currentRenderStyle.margin.horizontal;
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
          cropHeight += currentRenderStyle.margin.vertical;
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
        cropWidth += currentRenderStyle.margin.horizontal;
        cropWidth = _getCropWidthByPaddingBorder(currentRenderStyle, cropWidth);
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

double _getCropWidthByPaddingBorder(RenderStyle renderStyle, double cropWidth) {
  cropWidth += renderStyle.border.horizontal;
  cropWidth += renderStyle.padding.horizontal;
  return cropWidth;
}

double _getCropHeightByPaddingBorder(RenderStyle renderStyle, double cropHeight) {
  cropHeight += renderStyle.border.vertical;
  cropHeight += renderStyle.padding.vertical;
  return cropHeight;
}
