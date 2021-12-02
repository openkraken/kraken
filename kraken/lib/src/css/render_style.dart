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

/// The abstract class for render-style, declare the
/// getter interface for all available CSS rule.
abstract class RenderStyle {
  // Common
  Element get target;
  RenderStyle? get parent;
  getProperty(String key);

  // Geometry
  CSSLengthValue get top;
  CSSLengthValue get right;
  CSSLengthValue get bottom;
  CSSLengthValue get left;
  int? get zIndex;
  CSSLengthValue get width;
  CSSLengthValue get height;
  CSSLengthValue get minWidth;
  CSSLengthValue get minHeight;
  CSSLengthValue get maxWidth;
  CSSLengthValue get maxHeight;
  EdgeInsets get margin;
  CSSLengthValue get marginLeft;
  CSSLengthValue get marginRight;
  CSSLengthValue get marginTop;
  CSSLengthValue get marginBottom;
  EdgeInsets get padding;
  CSSLengthValue get paddingLeft;
  CSSLengthValue get paddingRight;
  CSSLengthValue get paddingBottom;
  CSSLengthValue get paddingTop;

  // Border
  EdgeInsets get border;
  CSSLengthValue? get borderTopWidth;
  CSSLengthValue? get borderRightWidth;
  CSSLengthValue? get borderBottomWidth;
  CSSLengthValue? get borderLeftWidth;
  BorderStyle get borderLeftStyle;
  BorderStyle get borderRightStyle;
  BorderStyle get borderTopStyle;
  BorderStyle get borderBottomStyle;
  CSSLengthValue get effectiveBorderLeftWidth;
  CSSLengthValue get effectiveBorderRightWidth;
  CSSLengthValue get effectiveBorderTopWidth;
  CSSLengthValue get effectiveBorderBottomWidth;
  double? get logicalContentWidth;
  double? get logicalContentHeight;
  double get contentMaxConstraintsWidth;
  Color get borderLeftColor;
  Color get borderRightColor;
  Color get borderTopColor;
  Color get borderBottomColor;
  List<Radius>? get borderRadius;
  CSSBorderRadius get borderTopLeftRadius;
  CSSBorderRadius get borderTopRightRadius;
  CSSBorderRadius get borderBottomRightRadius;
  CSSBorderRadius get borderBottomLeftRadius;
  List<BorderSide>? get borderSides;
  List<KrakenBoxShadow>? get shadows;

  // Decorations
  Color? get backgroundColor;
  CSSBackgroundImage? get backgroundImage;
  ImageRepeat get backgroundRepeat;
  CSSBackgroundPosition get backgroundPositionX;
  CSSBackgroundPosition get backgroundPositionY;

  // Text
  CSSLengthValue get fontSize;
  FontWeight get fontWeight;
  FontStyle get fontStyle;
  List<String>? get fontFamily;
  List<Shadow>? get textShadow;
  WhiteSpace get whiteSpace;
  TextOverflow get textOverflow;
  TextAlign get textAlign;
  int? get lineClamp;
  CSSLengthValue get lineHeight;
  CSSLengthValue? get letterSpacing;
  CSSLengthValue? get wordSpacing;

  // BoxModel
  double? get borderBoxLogicalWidth;
  double? get borderBoxLogicalHeight;
  double? get borderBoxWidth;
  double? get borderBoxHeight;
  double? get paddingBoxLogicalWidth;
  double? get paddingBoxLogicalHeight;
  double? get paddingBoxWidth;
  double? get paddingBoxHeight;
  double? get contentBoxLogicalWidth;
  double? get contentBoxLogicalHeight;
  double? get contentBoxWidth;
  double? get contentBoxHeight;
  CSSPositionType get position;
  CSSDisplay get display;
  CSSDisplay get effectiveDisplay;
  Alignment get objectPosition;
  CSSOverflowType get overflowX;
  CSSOverflowType get overflowY;
  CSSOverflowType get effectiveOverflowX;
  CSSOverflowType get effectiveOverflowY;

  // Flex
  FlexDirection get flexDirection;
  FlexWrap get flexWrap;
  JustifyContent get justifyContent;
  AlignItems get alignItems;
  AlignItems get effectiveAlignItems;
  AlignContent get alignContent;
  AlignSelf get alignSelf;
  CSSLengthValue? get flexBasis;
  double get flexGrow;
  double get flexShrink;

  // Color
  Color get color;
  Color get currentColor;

  // Filter
  ColorFilter? get colorFilter;
  ImageFilter? get imageFilter;
  List<CSSFunctionalNotation>? get filter;

  // Misc
  double get opacity;
  Visibility get visibility;
  ContentVisibility? get contentVisibility;
  VerticalAlign get verticalAlign;
  BoxFit get objectFit;

  // Transition
  List<String> get transitionProperty;
  List<String> get transitionDuration;
  List<String> get transitionTimingFunction;
  List<String> get transitionDelay;

  // Sliver
  Axis get sliverDirection;

  void addFontRelativeProperty(String propertyName);
  void addRootFontRelativeProperty(String propertyName);
  void addColorRelativeProperty(String propertyName);
  String? removeAnimationProperty(String propertyName);
  double getWidthByIntrinsicRatio();
  double getHeightByIntrinsicRatio();

  // Following properties used for exposing APIs
  // for class that extends [AbstractRenderStyle].
  RenderBoxModel? get renderBoxModel => target.renderBoxModel;

  Size get viewportSize => target.elementManager.viewport.viewportSize;

  double get rootFontSize => target.elementManager.getRootFontSize();
}

class CSSRenderStyle
  extends RenderStyle
  with
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
  CSSRenderStyle({ required this.target });

  @override
  Element target;

  @override
  CSSRenderStyle? parent;

  @override
  getProperty(String name) {
    switch (name) {
      case DISPLAY:
        return display;
      case Z_INDEX:
        return zIndex;
      case OVERFLOW_X:
        return overflowX;
      case OVERFLOW_Y:
        return overflowY;
      case OPACITY:
        return opacity;
      case VISIBILITY:
        return visibility;
      case CONTENT_VISIBILITY:
        return contentVisibility;
      case POSITION:
        return position;
      case TOP:
        return top;
      case LEFT:
        return left;
      case BOTTOM:
        return bottom;
      case RIGHT:
        return right;
      // Size
      case WIDTH:
        return width;
      case MIN_WIDTH:
        return minWidth;
      case MAX_WIDTH:
        return maxWidth;
      case HEIGHT:
        return height;
      case MIN_HEIGHT:
        return minHeight;
      case MAX_HEIGHT:
        return maxHeight;
      // Flex
      case FLEX_DIRECTION:
        return flexDirection;
      case FLEX_WRAP:
        return flexWrap;
      case ALIGN_CONTENT:
        return alignContent;
      case ALIGN_ITEMS:
        return alignItems;
      case JUSTIFY_CONTENT:
        return justifyContent;
      case ALIGN_SELF:
        return alignSelf;
      case FLEX_GROW:
        return flexGrow;
      case FLEX_SHRINK:
        return flexShrink;
      case FLEX_BASIS:
        return flexBasis;
      // Background
      case BACKGROUND_COLOR:
        return backgroundColor;
      case BACKGROUND_ATTACHMENT:
        return backgroundAttachment;
      case BACKGROUND_IMAGE:
        return backgroundImage;
      case BACKGROUND_REPEAT:
        return backgroundRepeat;
      case BACKGROUND_POSITION_X:
        return backgroundPositionX;
      case BACKGROUND_POSITION_Y:
        return backgroundPositionY;
      case BACKGROUND_SIZE:
        return backgroundSize;
      case BACKGROUND_CLIP:
        return backgroundClip;
      case BACKGROUND_ORIGIN:
        return backgroundOrigin;
      // Padding
      case PADDING_TOP:
        return paddingTop;
      case PADDING_RIGHT:
        return paddingRight;
      case PADDING_BOTTOM:
        return paddingBottom;
      case PADDING_LEFT:
        return paddingLeft;
      // Border
      case BORDER_LEFT_WIDTH:
        return borderLeftWidth;
      case BORDER_TOP_WIDTH:
        return borderTopWidth;
      case BORDER_RIGHT_WIDTH:
        return borderRightWidth;
      case BORDER_BOTTOM_WIDTH:
        return borderBottomWidth;
      case BORDER_LEFT_STYLE:
        return borderLeftStyle;
      case BORDER_TOP_STYLE:
        return borderTopStyle;
      case BORDER_RIGHT_STYLE:
        return borderRightStyle;
      case BORDER_BOTTOM_STYLE:
        return borderBottomStyle;
      case BORDER_LEFT_COLOR:
        return borderLeftColor;
      case BORDER_TOP_COLOR:
        return borderTopColor;
      case BORDER_RIGHT_COLOR:
        return borderRightColor;
      case BORDER_BOTTOM_COLOR:
        return borderBottomColor;
      case BOX_SHADOW:
        return boxShadow;
      case BORDER_TOP_LEFT_RADIUS:
        return borderTopLeftRadius;
      case BORDER_TOP_RIGHT_RADIUS:
        return borderTopRightRadius;
      case BORDER_BOTTOM_LEFT_RADIUS:
        return borderBottomLeftRadius;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        return borderBottomRightRadius;
      // Margin
      case MARGIN_LEFT:
        return marginLeft;
      case MARGIN_TOP:
        return marginTop;
      case MARGIN_RIGHT:
        return marginRight;
      case MARGIN_BOTTOM:
        return marginBottom;
      // Text
      case COLOR:
        return color;
      case TEXT_DECORATION_LINE:
        return textDecorationLine;
      case TEXT_DECORATION_STYLE:
        return textDecorationStyle;
      case TEXT_DECORATION_COLOR:
        return textDecorationColor;
      case FONT_WEIGHT:
        return fontWeight;
      case FONT_STYLE:
        return fontStyle;
      case FONT_FAMILY:
        return fontFamily;
      case FONT_SIZE:
        return fontSize;
      case LINE_HEIGHT:
        return lineHeight;
      case LETTER_SPACING:
        return letterSpacing;
      case WORD_SPACING:
        return wordSpacing;
      case TEXT_SHADOW:
        return textShadow;
      case WHITE_SPACE:
        return whiteSpace;
      case TEXT_OVERFLOW:
        return textOverflow;
      case LINE_CLAMP:
        return lineClamp;
      case VERTICAL_ALIGN:
        return verticalAlign;
      case TEXT_ALIGN:
        return textAlign;
      // Transform
      case TRANSFORM:
        return transform;
      case TRANSFORM_ORIGIN:
        return transformOrigin;
      case SLIVER_DIRECTION:
        return sliverDirection;
      case OBJECT_FIT:
        return objectFit;
      case OBJECT_POSITION:
        return objectPosition;
      case FILTER:
        return filter;
    }
  }

  // Content width of render box model calculated from style.
  @override
  double? get logicalContentWidth {
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

  // Content height of render box model calculated from style.
  @override
  double? get logicalContentHeight {
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
  @override
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
  @override
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
    return logicalContentWidth;
  }

  // Content height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // @TODO: add cache to avoid recalculate every time.
  @override
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
    return logicalContentHeight;
  }

  // Padding box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalWidth {
    if (contentBoxLogicalWidth == null) {
      return null;
    }
    return contentBoxLogicalWidth! + paddingLeft.computedValue + paddingRight.computedValue;
  }

  // Padding box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalHeight {
    if (contentBoxLogicalHeight == null) {
      return null;
    }
    return contentBoxLogicalHeight! + paddingTop.computedValue + paddingBottom.computedValue;
  }

  // Border box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalWidth {
    if (paddingBoxLogicalWidth == null) {
      return null;
    }
    return paddingBoxLogicalWidth! + effectiveBorderLeftWidth.computedValue + effectiveBorderRightWidth.computedValue;
  }

  // Border box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalHeight {
    if (paddingBoxLogicalHeight == null) {
      return null;
    }
    return paddingBoxLogicalHeight! + effectiveBorderTopWidth.computedValue + effectiveBorderBottomWidth.computedValue;
  }

  // Content box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxWidth {
    if (paddingBoxWidth == null) {
      return null;
    }
    return paddingBoxWidth! - paddingLeft.computedValue - paddingRight.computedValue;
  }

  // Content box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxHeight {
    if (paddingBoxHeight == null) {
      return null;
    }
    return paddingBoxHeight! - paddingTop.computedValue - paddingBottom.computedValue;
  }

  // Padding box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxWidth {
    if (borderBoxWidth == null) {
      return null;
    }
    return borderBoxWidth! - effectiveBorderLeftWidth.computedValue - effectiveBorderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxHeight {
    if (borderBoxHeight == null) {
      return null;
    }
    return borderBoxHeight! - effectiveBorderTopWidth.computedValue - effectiveBorderBottomWidth.computedValue;
  }

  // Border box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxWidth {
    if (renderBoxModel!.hasSize && renderBoxModel!.boxSize != null) {
      return renderBoxModel!.boxSize!.width;
    }
    return null;
  }

  // Border box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxHeight {
    if (renderBoxModel!.hasSize && renderBoxModel!.boxSize != null) {
      return renderBoxModel!.boxSize!.height;
    }
    return null;
  }

  /// Get height of replaced element by intrinsic ratio if height is not defined
  @override
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
  @override
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
