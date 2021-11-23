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
  late Element target;
  RenderBoxModel? get renderBoxModel => target.renderBoxModel;
  Size get viewportSize => target.elementManager.viewport.viewportSize;
  double get rootFontSize => target.elementManager.getRootFontSize();
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
    CSSOpacityMixin,
    CSSTransitionMixin {

  @override
  Element target;

  RenderStyle? parent;

  RenderStyle({
    required this.target,
  });

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

  double? computeLogicalContentWidth() {
    RenderBoxModel current = renderBoxModel!;
    RenderStyle renderStyle = this;
    double? logicalWidth;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    switch (effectiveDisplay) {
      case CSSDisplay.block:
      case CSSDisplay.flex:
      case CSSDisplay.sliver:
        //  Use width directly if defined.
        if (renderStyle.width.isNotAuto) {
          logicalWidth = renderStyle.width.computedValue;

        // Use tight constraints if constraints is tight and width not exist.
        } else if (current.hasSize && current.constraints.hasTightWidth) {
          logicalWidth = current.constraints.maxWidth;

        // Block element (except replaced element) will stretch to the content width of its parent.
        } else if (current is! RenderIntrinsic &&
          current.parent != null &&
          current.parent is RenderBoxModel
        ) {
          RenderBoxModel parent = current.parent as RenderBoxModel;
          logicalWidth = parent.logicalContentWidth;
          // Should subtract horizontal margin of own from its parent content width.
          if (logicalWidth != null) {
            logicalWidth -= renderStyle.margin.horizontal;
          }
        }
        break;
      case CSSDisplay.inlineBlock:
      case CSSDisplay.inlineFlex:
        if (renderStyle.width.isNotAuto) {
          logicalWidth = renderStyle.width.computedValue;
        } else if (current.hasSize && current.constraints.hasTightWidth) {
          logicalWidth = current.constraints.maxWidth;
        }
        break;
      case CSSDisplay.inline:
        break;
      default:
        break;
    }

    double? intrinsicRatio = current.intrinsicRatio;

    // Get width by intrinsic ratio for replaced element if width is auto.
    if (logicalWidth == null && intrinsicRatio != null) {
      logicalWidth = renderStyle.getWidthByIntrinsicRatio();
    }

    // Constrain width by min-width and max-width.
    if (renderStyle.minWidth.isNotAuto) {
      double minWidth = renderStyle.minWidth.computedValue;
      if (logicalWidth != null && logicalWidth < minWidth) {
        logicalWidth = minWidth;
      }
    }
    if (renderStyle.maxWidth.isNotNone) {
      double maxWidth = renderStyle.maxWidth.computedValue;
      if (logicalWidth != null && logicalWidth > maxWidth) {
        logicalWidth = maxWidth;
      }
    }

    double? logicalContentWidth;
    // Subtract padding and border width to get content width.
    if (logicalWidth != null) {
      logicalContentWidth = logicalWidth -
        renderStyle.border.horizontal -
        renderStyle.padding.horizontal;
      // Logical width may be smaller than its border and padding width,
      // in this case, content width will be negative which is illegal.
      logicalContentWidth = math.max(0, logicalContentWidth);
    }

    return logicalContentWidth;
  }

  // Content width of render box model calculated from style.
  double? getLogicalContentWidth() {
    RenderStyle renderStyle = this;
    double? intrinsicRatio = renderBoxModel!.intrinsicRatio;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double cropWidth = 0;

    switch (effectiveDisplay) {
      case CSSDisplay.block:
      case CSSDisplay.flex:
      case CSSDisplay.sliver:
      // Get own width if exists else get the width of nearest ancestor width width
        if (!renderStyle.width.isAuto) {
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
                if (parentRenderStyle.width.isNotAuto) {
                  // Use style width
                  width = parentRenderStyle.width.computedValue;
                  cropWidth = _getCropWidthByPaddingBorder(parentRenderStyle, cropWidth);
                  break;
                } else if (parentRenderBoxModel.hasSize && parentRenderBoxModel.constraints.hasTightWidth) {
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
        if (renderStyle.width.isNotAuto) {
          width = renderStyle.width.computedValue;
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

  double? computeLogicalContentHeight() {
    RenderBoxModel current = renderBoxModel!;
    RenderStyle renderStyle = this;
    double? logicalHeight;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;

    // Inline element has no height.
    if (effectiveDisplay != CSSDisplay.inline) {
      if (renderStyle.height.isNotAuto) {
        logicalHeight = renderStyle.height.computedValue;

      // Use tight constraints if constraints is tight and height not exist.
      } else if (current.hasSize && current.constraints.hasTightHeight) {
        logicalHeight = current.constraints.maxHeight;

      } else {
        if (current.parent != null && current.parent is RenderBoxModel) {
          RenderBoxModel parent = current.parent as RenderBoxModel;
          RenderStyle parentRenderStyle = parent.renderStyle;
          if (CSSSizingMixin.isStretchChildHeight(parentRenderStyle, renderStyle)) {
            logicalHeight = parent.logicalContentHeight;
            // Should subtract vertical margin of own from its parent content height.
            if (logicalHeight != null) {
              logicalHeight -= renderStyle.margin.vertical;
            }
          }
        }
      }
    }

    double? intrinsicRatio = current.intrinsicRatio;

    // Get height by intrinsic ratio for replaced element if height is auto.
    if (logicalHeight == null && intrinsicRatio != null) {
      logicalHeight = renderStyle.getHeightByIntrinsicRatio();
    }

    // Constrain height by min-height and max-height.
    if (renderStyle.minHeight.isNotAuto) {
      double minHeight = renderStyle.minHeight.computedValue;
      if (logicalHeight != null && logicalHeight < minHeight) {
        logicalHeight = minHeight;
      }
    }
    if (renderStyle.maxHeight.isNotNone) {
      double maxHeight = renderStyle.maxHeight.computedValue;
      if (logicalHeight != null && logicalHeight > maxHeight) {
        logicalHeight = maxHeight;
      }
    }

    double? logicalContentHeight;
    // Subtract padding and border width to get content width.
    if (logicalHeight != null) {
      logicalContentHeight = logicalHeight -
        renderStyle.border.vertical -
        renderStyle.padding.vertical;
      // Logical height may be smaller than its border and padding width,
      // in this case, content height will be negative which is illegal.
      logicalContentHeight = math.max(0, logicalContentHeight);
    }

    return logicalContentHeight;
  }

  // Content height of render box model calculated from style.
  double? getLogicalContentHeight() {
    RenderStyle renderStyle = this;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    double cropHeight = 0;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? intrinsicRatio = renderBoxModel!.intrinsicRatio;

    // Inline element has no height.
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
          if (parentRenderStyle.height.isNotAuto) {
            height = parentRenderStyle.height.computedValue;
            cropHeight = _getCropHeightByPaddingBorder(parentRenderStyle, cropHeight);
            break;
          } else if (parentRenderBoxModel.hasSize && parentRenderBoxModel.constraints.hasTightHeight) {
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

    // Get height by intrinsic ratio for replaced element if height is not defined.
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

  // Max constraints width of content, used in calculating the remaining space for line wrapping
  // in the stage of layout.
  double get contentMaxConstraintsWidth {
    // If renderBoxModel definite content constraints, use it as max constrains width of content.
    BoxConstraints? contentConstraints = renderBoxModel!.contentConstraints;
    if (contentConstraints != null && contentConstraints.maxWidth != double.infinity) {
      return contentConstraints.maxWidth;
    }

    // If renderBoxModel has no logical content width (eg display is inline-block/inline-flex and
    // has no width), find its ancestors with logical width set to calculate the remaining space.
    double contentMaxConstraintsWidth = double.infinity;
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
          currentRenderStyle.width.isAuto &&
          currentRenderStyle.maxWidth.isNone) {
          break;
        }
      }

      // Get width if width exists and element is not inline
      if (effectiveDisplay != CSSDisplay.inline &&
        (currentRenderStyle.width.isNotAuto || currentRenderStyle.maxWidth.isNotNone)) {
        // Get the min width between width and max-width
        contentMaxConstraintsWidth = math.min(
          (currentRenderStyle.width.isAuto ? null : currentRenderStyle.width.computedValue) ?? double.infinity,
          (currentRenderStyle.maxWidth.isNone ? null : currentRenderStyle.maxWidth.computedValue) ?? double.infinity
        );
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

    if (contentMaxConstraintsWidth != double.infinity) {
      contentMaxConstraintsWidth = contentMaxConstraintsWidth - cropWidth;
    }

    // Set contentMaxConstraintsWidth to 0 when it is negative in the case of
    // renderBoxModel's width exceeds its ancestors.
    // <div style="width: 300px;">
    //   <div style="display: inline-block; padding: 0 200px;">
    //   </div>
    // </div>
    if (contentMaxConstraintsWidth < 0) {
      contentMaxConstraintsWidth = 0;
    }

    return contentMaxConstraintsWidth;
  }

  // Content width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // @TODO: add cache to avoid recalculate every time.
  double? get contentBoxLogicalWidth {
    // If renderBox has tight width, its logical size equals max size.
    if (renderBoxModel != null &&
      renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.hasTightWidth
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
    // If renderBox has tight height, its logical size equals max size.
    if (renderBoxModel != null &&
      renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.hasTightHeight
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
    double? realWidth = width.isAuto ? intrinsicWidth : width.computedValue;
    if (minWidth.isNotAuto && realWidth! < minWidth.computedValue) {
      realWidth = minWidth.computedValue;
    }
    if (maxWidth.isNotNone && realWidth! > maxWidth.computedValue) {
      realWidth = maxWidth.computedValue;
    }
    double realHeight = realWidth! * intrinsicRatio;
    return realHeight;
  }

  /// Get width of replaced element by intrinsic ratio if width is not defined
  double getWidthByIntrinsicRatio() {
    // @TODO: move intrinsic width/height to renderStyle
    double? intrinsicHeight = renderBoxModel!.intrinsicHeight;
    double intrinsicRatio = renderBoxModel!.intrinsicRatio!;

    double? realHeight = height.isAuto ? intrinsicHeight : height.computedValue;
    if (!minHeight.isAuto && realHeight! < minHeight.computedValue) {
      realHeight = minHeight.computedValue;
    }
    if (!maxHeight.isNone && realHeight! > maxHeight.computedValue) {
      realHeight = maxHeight.computedValue;
    }
    double realWidth = realHeight! / intrinsicRatio;
    return realWidth;
  }

  // Mark this node as detached.
  void detach() {
    // Clear reference to it's parent.
    parent = null;
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
