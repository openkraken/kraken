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

typedef RenderStyleVisitor<T extends RenderStyle> = void Function(T renderStyle);

/// The abstract class for render-style, declare the
/// getter interface for all available CSS rule.
abstract class RenderStyle {
  // Common
  Element get target;
  RenderStyle? get parent;
  dynamic getProperty(String key);
  /// Resolve the style value.
  dynamic resolveValue(String property, String present);

  // CSSVariable
  String? getCSSVariable(String identifier, String propertyName);
  void setCSSVariable(String identifier, String value);

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
  double? get borderBoxConstraintsWidth;
  double? get borderBoxConstraintsHeight;
  double? get borderBoxWidth;
  double? get borderBoxHeight;
  double? get paddingBoxLogicalWidth;
  double? get paddingBoxLogicalHeight;
  double? get paddingBoxConstraintsWidth;
  double? get paddingBoxConstraintsHeight;
  double? get paddingBoxWidth;
  double? get paddingBoxHeight;
  double? get contentBoxLogicalWidth;
  double? get contentBoxLogicalHeight;
  double? get contentBoxConstraintsWidth;
  double? get contentBoxConstraintsHeight;
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
  double? get intrinsicRatio;
  double? get intrinsicWidth;
  double? get intrinsicHeight;

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
  bool get isHeightStretch;

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

  Size get viewportSize => target.ownerDocument.viewport.viewportSize;

  double get rootFontSize => target.ownerDocument.documentElement!.renderStyle.fontSize.computedValue;

  void visitChildren<T extends RenderStyle>(RenderStyleVisitor<T> visitor);
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
    CSSTransitionMixin,
    CSSVariableMixin {
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

  @override
  dynamic resolveValue(String propertyName, String propertyValue) {
    RenderStyle renderStyle = this;

    // Process CSSVariable.
    dynamic value = CSSVariable.tryParse(renderStyle, propertyName, propertyValue);
    if (value != null) {
      return value;
    }

    switch (propertyName) {
      case DISPLAY:
        value = CSSDisplayMixin.resolveDisplay(propertyValue);
        break;
      case OVERFLOW_X:
      case OVERFLOW_Y:
        value = CSSOverflowMixin.resolveOverflowType(propertyValue);
        break;
      case POSITION:
        value = CSSPositionMixin.resolvePositionType(propertyValue);
        break;
      case Z_INDEX:
        value = int.tryParse(propertyValue);
        break;
      case TOP:
      case LEFT:
      case BOTTOM:
      case RIGHT:
      case FLEX_BASIS:
      case PADDING_TOP:
      case PADDING_RIGHT:
      case PADDING_BOTTOM:
      case PADDING_LEFT:
      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
      case MARGIN_LEFT:
      case MARGIN_TOP:
      case MARGIN_RIGHT:
      case MARGIN_BOTTOM:
      case FONT_SIZE:
        value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        break;
      case FLEX_DIRECTION:
        value = CSSFlexboxMixin.resolveFlexDirection(propertyValue);
        break;
      case FLEX_WRAP:
        value = CSSFlexboxMixin.resolveFlexWrap(propertyValue);
        break;
      case ALIGN_CONTENT:
        value = CSSFlexboxMixin.resolveAlignContent(propertyValue);
        break;
      case ALIGN_ITEMS:
        value = CSSFlexboxMixin.resolveAlignItems(propertyValue);
        break;
      case JUSTIFY_CONTENT:
        value = CSSFlexboxMixin.resolveJustifyContent(propertyValue);
        break;
      case ALIGN_SELF:
        value = CSSFlexboxMixin.resolveAlignSelf(propertyValue);
        break;
      case FLEX_GROW:
        value = CSSFlexboxMixin.resolveFlexGrow(propertyValue);
        break;
      case FLEX_SHRINK:
        value = CSSFlexboxMixin.resolveFlexShrink(propertyValue);
        break;
      case SLIVER_DIRECTION:
        value = CSSSliverMixin.resolveAxis(propertyValue);
        break;
      case TEXT_ALIGN:
        value = CSSTextMixin.resolveTextAlign(propertyValue);
        break;
      case BACKGROUND_ATTACHMENT:
        value = CSSBackground.resolveBackgroundAttachment(propertyValue);
        break;
      case BACKGROUND_IMAGE:
        value = CSSBackground.resolveBackgroundImage(propertyValue, renderStyle, propertyName, renderStyle.target.ownerDocument.controller);
        break;
      case BACKGROUND_REPEAT:
        value = CSSBackground.resolveBackgroundRepeat(propertyValue);
        break;
      case BACKGROUND_POSITION_X:
        value = CSSPosition.resolveBackgroundPosition(propertyValue, renderStyle, propertyName, true);
        break;
      case BACKGROUND_POSITION_Y:
        value = CSSPosition.resolveBackgroundPosition(propertyValue, renderStyle, propertyName, false);
        break;
      case BACKGROUND_SIZE:
        value = CSSBackground.resolveBackgroundSize(propertyValue, renderStyle, propertyName);
        break;
      case BACKGROUND_CLIP:
        value = CSSBackground.resolveBackgroundClip(propertyValue);
        break;
      case BACKGROUND_ORIGIN:
        value = CSSBackground.resolveBackgroundOrigin(propertyValue);
        break;
      case BORDER_LEFT_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case BORDER_BOTTOM_WIDTH:
        value = CSSBorderSide.resolveBorderWidth(propertyValue, renderStyle, propertyName);
        break;
      case BORDER_LEFT_STYLE:
      case BORDER_TOP_STYLE:
      case BORDER_RIGHT_STYLE:
      case BORDER_BOTTOM_STYLE:
        value = CSSBorderSide.resolveBorderStyle(propertyValue);
        break;
      case COLOR:
      case BACKGROUND_COLOR:
      case TEXT_DECORATION_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_BOTTOM_COLOR:
        value = CSSColor.resolveColor(propertyValue, renderStyle, propertyName);
        break;
      case BOX_SHADOW:
        value = CSSBoxShadow.parseBoxShadow(propertyValue, renderStyle, propertyName);
        break;
      case BORDER_TOP_LEFT_RADIUS:
      case BORDER_TOP_RIGHT_RADIUS:
      case BORDER_BOTTOM_LEFT_RADIUS:
      case BORDER_BOTTOM_RIGHT_RADIUS:
        value = CSSBorderRadius.parseBorderRadius(propertyValue, renderStyle, propertyName);
        break;
      case OPACITY:
        value = CSSOpacityMixin.resolveOpacity(propertyValue);
        break;
      case VISIBILITY:
        value = CSSVisibilityMixin.resolveVisibility(propertyValue);
        break;
      case CONTENT_VISIBILITY:
        value = CSSContentVisibilityMixin.resolveContentVisibility(propertyValue);
        break;
      case TRANSFORM:
        value = CSSTransformMixin.resolveTransform(propertyValue);
        break;
      case FILTER:
        value = CSSFunction.parseFunction(propertyValue);
        break;
      case TRANSFORM_ORIGIN:
        value = CSSOrigin.parseOrigin(propertyValue, renderStyle, propertyName);
        break;
      case OBJECT_FIT:
        value = CSSObjectFitMixin.resolveBoxFit(propertyValue);
        break;
      case OBJECT_POSITION:
        value = CSSObjectPositionMixin.resolveObjectPosition(propertyValue);
        break;
      case TEXT_DECORATION_LINE:
        value = CSSText.resolveTextDecorationLine(propertyValue);
        break;
      case TEXT_DECORATION_STYLE:
        value = CSSText.resolveTextDecorationStyle(propertyValue);
        break;
      case FONT_WEIGHT:
        value = CSSText.resolveFontWeight(propertyValue);
        break;
      case FONT_STYLE:
        value = CSSText.resolveFontStyle(propertyValue);
        break;
      case FONT_FAMILY:
        value = CSSText.resolveFontFamilyFallback(propertyValue);
        break;
      case LINE_HEIGHT:
        value = CSSText.resolveLineHeight(propertyValue, renderStyle, propertyName);
        break;
      case LETTER_SPACING:
        value = CSSText.resolveSpacing(propertyValue, renderStyle, propertyName);
        break;
      case WORD_SPACING:
        value = CSSText.resolveSpacing(propertyValue, renderStyle, propertyName);
        break;
      case TEXT_SHADOW:
        value = CSSText.resolveTextShadow(propertyValue, renderStyle, propertyName);
        break;
      case WHITE_SPACE:
        value = CSSText.resolveWhiteSpace(propertyValue);
        break;
      case TEXT_OVERFLOW:
        // Overflow will affect text-overflow ellipsis taking effect
        value = CSSText.resolveTextOverflow(propertyValue);
        break;
      case LINE_CLAMP:
        value = CSSText.parseLineClamp(propertyValue);
        break;
      case VERTICAL_ALIGN:
        value = CSSInlineMixin.resolveVerticalAlign(propertyValue);
        break;
      // Transition
      case TRANSITION_DELAY:
      case TRANSITION_DURATION:
      case TRANSITION_TIMING_FUNCTION:
      case TRANSITION_PROPERTY:
        value = CSSStyleProperty.getMultipleValues(propertyValue);
        break;
    }

    // --x: foo;
    // Directly passing the value, not to resolve now.
    if (CSSVariable.isVariable(propertyName)) {
      return propertyValue;
    }

    return value;
  }


  // Compute the content box width from render style.
  void computeContentBoxLogicalWidth() {
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
        } else if (renderStyle.parent != null) {
          RenderStyle parentRenderStyle = renderStyle.parent!;
          RenderBoxModel parent = parentRenderStyle.renderBoxModel!;

          // Use parent's tight constraints if constraints is tight and width not exist.
          if (parent.hasSize && parent.constraints.hasTightWidth) {
            logicalWidth = parent.constraints.maxWidth;

          // Block element (except replaced element) will stretch to the content width of its parent in flow layout.
          // Replaced element also stretch in flex layout if align-items is stretch.
          } else if (current is! RenderIntrinsic || parent is RenderFlexLayout) {
            RenderStyle? ancestorRenderStyle = _findAncestorWithNoDisplayInline();
            // Should ignore renderStyle of display inline when searching for ancestors to stretch width.
            if (ancestorRenderStyle != null) {
              logicalWidth = ancestorRenderStyle.contentBoxLogicalWidth;
              // Should subtract horizontal margin of own from its parent content width.
              if (logicalWidth != null) {
                logicalWidth -= renderStyle.margin.horizontal;
              }
            }
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
      case CSSDisplay.none:
        break;
    }

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

    _contentBoxLogicalWidth = logicalContentWidth;
  }

  // Compute the content box height from render style.
  void computeContentBoxLogicalHeight() {
    RenderStyle renderStyle = this;
    double? logicalHeight;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;

    // Inline element has no height.
    if (effectiveDisplay != CSSDisplay.inline) {
      if (renderStyle.height.isNotAuto) {
        logicalHeight = renderStyle.height.computedValue;

      } else {
        if (renderStyle.parent != null) {
          RenderStyle parentRenderStyle = renderStyle.parent!;
          RenderBoxModel parent = parentRenderStyle.renderBoxModel!;

          if (renderStyle.isHeightStretch) {
            // Use parent's tight constraints if constraints is tight and height not exist.
            if (parent.hasSize && parent.constraints.hasTightHeight) {
              logicalHeight = parent.constraints.maxHeight;
            } else {
              logicalHeight = parentRenderStyle.contentBoxLogicalHeight;
              // Should subtract vertical margin of own from its parent content height.
              if (logicalHeight != null) {
                logicalHeight -= renderStyle.margin.vertical;
              }
            }
          }
        }
      }
    }

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

    _contentBoxLogicalHeight = logicalContentHeight;
  }

  // Whether height is stretched to fill its parent's content height.
  @override
  bool get isHeightStretch {
    RenderStyle renderStyle = this;
    if (renderStyle.parent == null) {
      return false;
    }
    bool isStretch = false;
    RenderStyle parentRenderStyle = renderStyle.parent!;

    bool isParentFlex = parentRenderStyle.display == CSSDisplay.flex ||
      parentRenderStyle.display == CSSDisplay.inlineFlex;
    bool isHorizontalDirection = false;
    bool isFlexNoWrap = false;
    bool isChildStretchSelf = false;
    if (isParentFlex) {
      isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(parentRenderStyle.flexDirection);
      isFlexNoWrap = parentRenderStyle.flexWrap != FlexWrap.wrap &&
        parentRenderStyle.flexWrap != FlexWrap.wrapReverse;
      isChildStretchSelf = renderStyle.alignSelf != AlignSelf.auto
        ? renderStyle.alignSelf == AlignSelf.stretch
        : parentRenderStyle.effectiveAlignItems == AlignItems.stretch;
    }

    CSSLengthValue marginTop = renderStyle.marginTop;
    CSSLengthValue marginBottom = renderStyle.marginBottom;

    // Display as block if flex vertical layout children and stretch children
    if (marginTop.isNotAuto && marginBottom.isNotAuto &&
      isParentFlex && isHorizontalDirection && isFlexNoWrap && isChildStretchSelf) {
      isStretch = true;
    }

    return isStretch;
  }


  // Max width to constrain its children, used in deciding the line wrapping timing of layout.
  @override
  double get contentMaxConstraintsWidth {
    // If renderBoxModel definite content constraints, use it as max constrains width of content.
    BoxConstraints? contentConstraints = renderBoxModel!.contentConstraints;
    if (contentConstraints != null && contentConstraints.maxWidth != double.infinity) {
      return contentConstraints.maxWidth;
    }

    double contentMaxConstraintsWidth = double.infinity;
    RenderStyle renderStyle = this;
    double? borderBoxLogicalWidth;
    RenderStyle? ancestorRenderStyle = _findAncestorWithContentBoxLogicalWidth();

    // If renderBoxModel has no logical width (eg. display is inline-block/inline-flex and
    // has no width), the child width is constrained by its closest ancestor who has definite logical content box width.
    if (ancestorRenderStyle != null) {
      borderBoxLogicalWidth = ancestorRenderStyle.contentBoxLogicalWidth;
    }

    if (borderBoxLogicalWidth != null) {
      contentMaxConstraintsWidth = borderBoxLogicalWidth -
        renderStyle.border.horizontal -
        renderStyle.padding.horizontal;
      // Logical width may be smaller than its border and padding width,
      // in this case, content width will be negative which is illegal.
      // <div style="width: 300px;">
      //   <div style="display: inline-block; padding: 0 200px;">
      //   </div>
      // </div>
      contentMaxConstraintsWidth = math.max(0, contentMaxConstraintsWidth);
    }

    return contentMaxConstraintsWidth;
  }

  // Content width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // Use double.infinity refers to the value is not computed yet.
  double? _contentBoxLogicalWidth = double.infinity;
  @override
  double? get contentBoxLogicalWidth {
    // If renderBox has tight width, its logical size equals max size.
    // Compute logical width directly in case as renderBoxModel is not layouted yet,
    // eg. compute percentage length before layout.
    if (_contentBoxLogicalWidth == double.infinity) {
      computeContentBoxLogicalWidth();
    }
    return _contentBoxLogicalWidth;
  }

  // Content height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // Use double.infinity refers to the value is not computed yet.
  double? _contentBoxLogicalHeight = double.infinity;
  @override
  double? get contentBoxLogicalHeight {
    // Compute logical height directly in case as renderBoxModel is not layouted yet,
    // eg. compute percentage length before layout.
    if (_contentBoxLogicalHeight == double.infinity) {
      computeContentBoxLogicalHeight();
    }
    return _contentBoxLogicalHeight;
  }

  // Padding box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalWidth {
    if (contentBoxLogicalWidth == null) {
      return null;
    }
    return contentBoxLogicalWidth!
      + paddingLeft.computedValue
      + paddingRight.computedValue;
  }

  // Padding box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalHeight {
    if (contentBoxLogicalHeight == null) {
      return null;
    }
    return contentBoxLogicalHeight!
      + paddingTop.computedValue
      + paddingBottom.computedValue;
  }

  // Border box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalWidth {
    if (paddingBoxLogicalWidth == null) {
      return null;
    }
    return paddingBoxLogicalWidth!
      + effectiveBorderLeftWidth.computedValue
      + effectiveBorderRightWidth.computedValue;
  }

  // Border box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalHeight {
    if (paddingBoxLogicalHeight == null) {
      return null;
    }
    return paddingBoxLogicalHeight!
      + effectiveBorderTopWidth.computedValue
      + effectiveBorderBottomWidth.computedValue;
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

  // Padding box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxWidth {
    if (borderBoxWidth == null) {
      return null;
    }
    return borderBoxWidth!
      - effectiveBorderLeftWidth.computedValue
      - effectiveBorderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxHeight {
    if (borderBoxHeight == null) {
      return null;
    }
    return borderBoxHeight!
      - effectiveBorderTopWidth.computedValue
      - effectiveBorderBottomWidth.computedValue;
  }

  // Content box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxWidth {
    if (paddingBoxWidth == null) {
      return null;
    }
    return paddingBoxWidth!
      - paddingLeft.computedValue
      - paddingRight.computedValue;
  }

  // Content box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxHeight {
    if (paddingBoxHeight == null) {
      return null;
    }
    return paddingBoxHeight!
      - paddingTop.computedValue
      - paddingBottom.computedValue;
  }

  // Border box width of renderBoxModel calculated from tight width constraints.
  @override
  double? get borderBoxConstraintsWidth {
    if (renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.hasTightWidth
    ) {
      return renderBoxModel!.constraints.maxWidth;
    }
    return null;
  }

  // Border box height of renderBoxModel calculated from tight height constraints.
  @override
  double? get borderBoxConstraintsHeight {
    if (renderBoxModel!.hasSize &&
      renderBoxModel!.constraints.hasTightHeight
    ) {
      return renderBoxModel!.constraints.maxHeight;
    }
    return null;
  }

  // Padding box width of renderBoxModel calculated from tight width constraints.
  @override
  double? get paddingBoxConstraintsWidth {
    if (borderBoxConstraintsWidth == null) {
      return null;
    }
    return borderBoxConstraintsWidth!
      - effectiveBorderLeftWidth.computedValue
      - effectiveBorderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel calculated from tight height constraints.
  @override
  double? get paddingBoxConstraintsHeight {
    if (borderBoxConstraintsHeight == null) {
      return null;
    }
    return borderBoxConstraintsHeight!
      - effectiveBorderTopWidth.computedValue
      - effectiveBorderBottomWidth.computedValue;
  }

  // Content box width of renderBoxModel calculated from tight width constraints.
  @override
  double? get contentBoxConstraintsWidth {
    if (paddingBoxConstraintsWidth == null) {
      return null;
    }
    return paddingBoxConstraintsWidth!
      - paddingLeft.computedValue
      - paddingRight.computedValue;
  }

  // Content box height of renderBoxModel calculated from tight height constraints.
  @override
  double? get contentBoxConstraintsHeight {
    if (paddingBoxConstraintsHeight == null) {
      return null;
    }
    return paddingBoxConstraintsHeight!
      - paddingTop.computedValue
      - paddingBottom.computedValue;
  }

  // Get height of replaced element by intrinsic ratio if height is not defined
  @override
  double getHeightByIntrinsicRatio() {
    double? realWidth = width.isAuto ? intrinsicWidth : width.computedValue;
    if (minWidth.isNotAuto && realWidth! < minWidth.computedValue) {
      realWidth = minWidth.computedValue;
    }
    if (maxWidth.isNotNone && realWidth! > maxWidth.computedValue) {
      realWidth = maxWidth.computedValue;
    }
    double realHeight = realWidth! * intrinsicRatio!;
    return realHeight;
  }

  // Get width of replaced element by intrinsic ratio if width is not defined
  @override
  double getWidthByIntrinsicRatio() {
    double? realHeight = height.isAuto ? intrinsicHeight : height.computedValue;
    if (!minHeight.isAuto && realHeight! < minHeight.computedValue) {
      realHeight = minHeight.computedValue;
    }
    if (!maxHeight.isNone && realHeight! > maxHeight.computedValue) {
      realHeight = maxHeight.computedValue;
    }
    double realWidth = realHeight! / intrinsicRatio!;
    return realWidth;
  }


  @override
  void visitChildren<T extends RenderStyle>(RenderStyleVisitor<T> visitor) {
    target.children.forEach((Element childElement) {
      visitor(childElement.renderStyle as T);
    });
  }

  // Mark this node as detached.
  void detach() {
    // Clear reference to it's parent.
    parent = null;
  }

  // Find ancestor render style with display of not inline.
  RenderStyle? _findAncestorWithNoDisplayInline() {
    RenderStyle renderStyle = this;
    RenderStyle? parentRenderStyle = renderStyle.parent;
    while(parentRenderStyle != null) {
      if (parentRenderStyle.effectiveDisplay != CSSDisplay.inline) {
        break;
      }
      parentRenderStyle = parentRenderStyle.parent;
    }
    return parentRenderStyle;
  }

  // Find ancestor render style with definite content box logical width.
  RenderStyle? _findAncestorWithContentBoxLogicalWidth() {
    RenderStyle renderStyle = this;
    RenderStyle? parentRenderStyle = renderStyle.parent;

    while(parentRenderStyle != null) {
      RenderStyle? grandParentRenderStyle = parentRenderStyle.parent;
      // Flex item with flex-shrink 0 and no width/max-width will have infinity constraints
      // even if parents have width.
      if (grandParentRenderStyle != null) {
        bool isGrandParentFlex = grandParentRenderStyle.display == CSSDisplay.flex ||
          grandParentRenderStyle.display == CSSDisplay.inlineFlex;
        if (isGrandParentFlex && parentRenderStyle.flexShrink == 0) {
          return null;
        }
      }

      if (parentRenderStyle.contentBoxLogicalWidth != null) {
        break;
      }

      parentRenderStyle = grandParentRenderStyle;
    }
    return parentRenderStyle;
  }

  // Whether current renderStyle is ancestor for child renderStyle in the renderStyle tree.
  bool isAncestorOf(RenderStyle childRenderStyle) {
    RenderStyle? parentRenderStyle = childRenderStyle.parent;
    while(parentRenderStyle != null) {
      if (parentRenderStyle == this) {
        return true;
      }
      parentRenderStyle = parentRenderStyle.parent;
    }
    return false;
  }
}

