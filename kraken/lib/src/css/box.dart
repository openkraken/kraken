

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:core';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Model: https://drafts.csswg.org/css-box-4/
// CSS Backgrounds and Borders: https://drafts.csswg.org/css-backgrounds/

final RegExp _spaceRegExp = RegExp(r'\s+');

class CSSBackgroundPosition {
  CSSBackgroundPosition({
    this.length,
    this.percentage,
  });
  /// Absolute position to image container when length type is set.
  double? length;
  /// Relative position to image container when keyword or percentage type is set.
  double? percentage;
}

class CSSBackgroundSize {
  CSSBackgroundSize({
    required this.fit,
    this.width,
    this.height,
  });

  // Keyword value (contain/cover/auto)
  BoxFit fit = BoxFit.none;

  // Length/percentage value
  dynamic width;
  dynamic height;

  static const String CONTAIN = 'contain';
  static const String COVER = 'cover';
  static const String AUTO = 'auto';

  static dynamic _parseLengthPercentageValue(String value, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    if (CSSLength.isLength(value)) {
      double? length = CSSLength.toDisplayPortValue(
        value,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      );
      // Negative value is invalid.
      return length != null && length >=0 ? length : null;
    } else if (CSSLength.isPercentage(value) || value == AUTO) {
      // Percentage value should be parsed on the paint phase cause
      // it depends on the final layouted size of background's container.
      return value;
    }
    return null;
  }

  static CSSBackgroundSize _parseSizeValue(String value, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    List<String> values = value.split(_spaceRegExp);
    if (values.length == 1) {
      dynamic parsedValue = _parseLengthPercentageValue(value,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize,
      );
      if (parsedValue != null) {
        return CSSBackgroundSize(
          fit: BoxFit.none,
          width: parsedValue,
        );
      }
    } else if (values.length == 2) {
      dynamic parsedWidth = _parseLengthPercentageValue(values[0],
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize,
      );
      dynamic parsedHeight = _parseLengthPercentageValue(values[1],
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize,
      );

      // Value which is neither length/percentage/auto is considered to be invalid.
      if (parsedWidth != null && parsedHeight != null) {
        return CSSBackgroundSize(
          fit: BoxFit.none,
          width: parsedWidth,
          height: parsedHeight,
        );
      }
    }

    return CSSBackgroundSize(
      fit: BoxFit.none
    );
  }

  static CSSBackgroundSize parseValue(String value, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    switch (value) {
      case CONTAIN:
        return CSSBackgroundSize(
          fit: BoxFit.contain
        );
      case COVER:
        return CSSBackgroundSize(
          fit: BoxFit.cover
        );
      case AUTO:
        return CSSBackgroundSize(
          fit: BoxFit.none
        );
      default:
        return _parseSizeValue(value,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize,
        );
    }
  }

  @override
  String toString() => 'CSSBackgroundSize(fit: $fit, width: $width, height: $height)';
}

/// - background
/// - border
mixin CSSBoxMixin on RenderStyleBase {

  /// Background-clip
  BackgroundBoundary? get backgroundClip => _backgroundClip;
  BackgroundBoundary? _backgroundClip;
  set backgroundClip(BackgroundBoundary? value) {
    if (value == null) return;
    if (value == _backgroundClip) return;
    _backgroundClip = value;
  }

  /// Background-origin
  BackgroundBoundary? get backgroundOrigin => _backgroundOrigin;
  BackgroundBoundary? _backgroundOrigin;
  set backgroundOrigin(BackgroundBoundary? value) {
    if (value == null) return;
    if (value == _backgroundOrigin) return;
    _backgroundOrigin = value;
  }

  /// Background-image
  String? get backgroundImage => _backgroundImage;
  String? _backgroundImage;
  set backgroundImage(String? value) {
    if (value == null) return;
    if (value == _backgroundImage) return;
    _backgroundImage = value;
  }

  /// Background-position-x
  CSSBackgroundPosition get backgroundPositionX => _backgroundPositionX;
  CSSBackgroundPosition _backgroundPositionX = CSSBackgroundPosition(percentage: -1);
  set backgroundPositionX(CSSBackgroundPosition? value) {
    if (value == null) return;
    if (value == _backgroundPositionX) return;
    _backgroundPositionX = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-position-y
  CSSBackgroundPosition get backgroundPositionY => _backgroundPositionY;
  CSSBackgroundPosition _backgroundPositionY = CSSBackgroundPosition(percentage: -1);
  set backgroundPositionY(CSSBackgroundPosition? value) {
    if (value == null) return;
    if (value == _backgroundPositionY) return;
    _backgroundPositionY = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-size
  CSSBackgroundSize get backgroundSize => _backgroundSize;
  CSSBackgroundSize _backgroundSize = CSSBackgroundSize(fit: BoxFit.none);
  set backgroundSize(CSSBackgroundSize? value) {
    if (value == null) return;
    if (value == _backgroundSize) return;
    _backgroundSize = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-attachment
  String? get backgroundAttachment => _backgroundAttachment;
  String? _backgroundAttachment;
  set backgroundAttachment(String? value) {
    if (value == null) return;
    if (value == _backgroundAttachment) return;
    _backgroundAttachment = value;
  }

  /// BorderSize to deflate.
  EdgeInsets? _borderEdge;
  EdgeInsets? get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets? newValue) {
    _borderEdge = newValue;

    CSSBoxDecoration? decoration = renderBoxModel!.renderStyle.decoration;
    if (decoration != null && decoration is CSSBoxDecoration) {
      Gradient? gradient = decoration.gradient;
      if (gradient is BorderGradientMixin) {
        gradient.borderEdge = newValue;
      }
    }
    renderBoxModel!.markNeedsPaint();
  }

  double get borderTop {
    if (borderEdge == null) return 0.0;
    return borderEdge!.top;
  }

  double get borderBottom {
    if (borderEdge == null) return 0.0;
    return borderEdge!.bottom;
  }

  double get borderLeft {
    if (borderEdge == null) return 0.0;
    return borderEdge!.left;
  }

  double get borderRight {
    if (borderEdge == null) return 0.0;
    return borderEdge!.right;
  }

  /// What decoration to paint.
  ///
  /// Commonly a [CSSBoxDecoration].
  CSSBoxDecoration? get decoration => _decoration;
  CSSBoxDecoration? _decoration;
  set decoration(CSSBoxDecoration? value) {
    if (value == null) return;
    if (value == _decoration) return;

    renderBoxModel!.boxPainter?.dispose();
    renderBoxModel!.boxPainter = null;

    // Evict image cache.
    _decoration?.image?.image.evict();

    _decoration = value;
    // If has border, render padding should subtracting the edge of the border
    if (value.border != null) {
      Border border = value.border as Border;
      borderEdge = EdgeInsets.fromLTRB(
        border.left.width,
        border.top.width,
        border.right.width,
        border.bottom.width
      );
    }

    renderBoxModel!.markNeedsPaint();
  }

  DecorationPosition decorationPosition = DecorationPosition.background;

  ImageConfiguration imageConfiguration = ImageConfiguration.empty;

  Size wrapBorderSize(Size innerSize) {
    return Size(borderLeft + innerSize.width + borderRight,
      borderTop + innerSize.height + borderBottom);
  }

  BoxConstraints deflateBorderConstraints(BoxConstraints constraints) {
    if (borderEdge != null) {
      return constraints.deflate(borderEdge!);
    }
    return constraints;
  }

  void updateBox(String property, String present, int contextId, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    RenderStyle renderStyle = this as RenderStyle;

    if (property == BACKGROUND_IMAGE) {
      backgroundImage = present;
    } else if (property == BACKGROUND_ATTACHMENT) {
      backgroundAttachment = present;
    }

    if (decoration != null) {
      // Update by property
      if (property == BACKGROUND_CLIP) {
        renderStyle.backgroundClip = getBackgroundClip(present);
      } else if (property == BACKGROUND_ORIGIN) {
        renderStyle.backgroundOrigin = getBackgroundOrigin(present);
      } else if (property == BACKGROUND_COLOR) {
        updateBackgroundColor();
      } else if (property == BACKGROUND_POSITION_X) {
        backgroundPositionX = CSSPosition.parsePosition(present, renderStyle, true);
      } else if (property == BACKGROUND_POSITION_Y) {
        backgroundPositionY = CSSPosition.parsePosition(present, renderStyle, false);
      } else if (property == BACKGROUND_SIZE) {
        backgroundSize = CSSBackgroundSize.parseValue(
          present,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize,
        );
      } else if (property.startsWith(BACKGROUND)) {
        // Including BACKGROUND_REPEAT, BACKGROUND_IMAGE,
        //   BACKGROUND_SIZE, BACKGROUND_ORIGIN, BACKGROUND_CLIP.
        updateBackgroundImage(property, present, contextId);
      } else if (property.startsWith(BORDER)) {
        updateBorder(property);
      } else if (property == BOX_SHADOW) {
        updateBoxShadow(property);
      } else if (property == COLOR) {
       updateBackgroundColor();
       updateBorder(property);
       updateBoxShadow(property);
      }
    } else {
      CSSBoxDecoration? cssBoxDecoration = getCSSBoxDecoration();
      if (cssBoxDecoration == null) return;

      renderStyle.decoration = cssBoxDecoration;
      renderStyle.backgroundClip = getBackgroundClip(present);
      renderStyle.backgroundOrigin = getBackgroundOrigin(present);
    }
  }

  void updateBoxShadow(String property) {
    CSSBoxDecoration? prevBoxDecoration = decoration;

    if (prevBoxDecoration != null) {
      decoration = CSSBoxDecoration(
          // Only modify boxShadow.
          boxShadow: getBoxShadow(),
          color: prevBoxDecoration.color,
          image: prevBoxDecoration.image,
          border: prevBoxDecoration.border,
          borderRadius: prevBoxDecoration.borderRadius,
          gradient: prevBoxDecoration.gradient,
          backgroundBlendMode: prevBoxDecoration.backgroundBlendMode,
          shape: prevBoxDecoration.shape
      );
    } else {
      decoration = CSSBoxDecoration(boxShadow: getBoxShadow());
    }
  }

  void updateBackgroundColor([Color? color]) {
    Color? bgColor = color ?? CSSBackground.getBackgroundColor(style);

    decoration ??= getCSSBoxDecoration();

    CSSBoxDecoration? prevBoxDecoration = decoration;

    // If change bg color from some color to null, which must be explicitly transparent.
    if (bgColor != null) {
      // If there has gradient, background color will not work
      if (prevBoxDecoration!.gradient == null) {
        decoration = prevBoxDecoration.clone(color: bgColor);
      }
    } else {
      // Remove background color.
      //   [CSSBoxDecoration.copyWith] can not remove some value, so instantite a new [CSSBoxDecoration].
      decoration = CSSBoxDecoration(
        image: prevBoxDecoration!.image,
        border: prevBoxDecoration.border,
        borderRadius: prevBoxDecoration.borderRadius,
        boxShadow: prevBoxDecoration.boxShadow,
        gradient: prevBoxDecoration.gradient,
        backgroundBlendMode: prevBoxDecoration.backgroundBlendMode,
        shape: prevBoxDecoration.shape,
      );
    }
  }

  void updateBackgroundImage(String property, String present, int contextId) {
    CSSBoxDecoration prevBoxDecoration = decoration!;

    DecorationImage? decorationImage;
    Gradient? gradient;

    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(style[BACKGROUND_IMAGE]);
    for (CSSFunctionalNotation method in methods) {
      if (method.name == 'url') {
        decorationImage = CSSBackground.getDecorationImage(style, method, contextId: contextId);
      } else {
        gradient = CSSBackground.getBackgroundGradient(style, renderBoxModel!, method);
      }
    }

    CSSBoxDecoration updateBoxDecoration = CSSBoxDecoration(
      image: decorationImage,
      gradient: gradient,
      color: prevBoxDecoration.color,
      border: prevBoxDecoration.border,
      borderRadius: prevBoxDecoration.borderRadius,
      boxShadow: prevBoxDecoration.boxShadow,
      backgroundBlendMode: prevBoxDecoration.backgroundBlendMode,
      shape: prevBoxDecoration.shape,
    );

    if (CSSBackground.hasScrollBackgroundImage(style)) {
      decoration = updateBoxDecoration;
    } else if (CSSBackground.hasLocalBackgroundImage(style)) {
      // @FIXME: support local background image
      decoration = updateBoxDecoration;
    } else {
      decoration = updateBoxDecoration;
    }
  }

  static final Map _borderRadiusMapping = {
    BORDER_TOP_LEFT_RADIUS: 0,
    BORDER_TOP_RIGHT_RADIUS: 1,
    BORDER_BOTTOM_RIGHT_RADIUS: 2,
    BORDER_BOTTOM_LEFT_RADIUS: 3
  };

  // Add border radius transition listener
  void updateBorderRadius(String property, String present) {
    if (decoration == null) {
      CSSBoxDecoration? cssBoxDecoration = getCSSBoxDecoration();
      if (cssBoxDecoration == null) return;
      decoration = cssBoxDecoration;
    }
    if (decoration == null) return;

    // topLeft topRight bottomRight bottomLeft
    int? index = _borderRadiusMapping[property];
    RenderStyle renderStyle = this as RenderStyle;

    if (index != null) {
      Radius? newRadius = CSSBorderRadius.getRadius(present, renderStyle);
      BorderRadius? borderRadius = decoration!.borderRadius as BorderRadius?;
      decoration = decoration!.clone(borderRadius: BorderRadius.only(
        topLeft: index == 0 ? newRadius! : borderRadius?.topLeft ?? Radius.zero,
        topRight: index == 1 ? newRadius! : borderRadius?.topRight ?? Radius.zero,
        bottomRight: index == 2 ? newRadius! : borderRadius?.bottomRight ?? Radius.zero,
        bottomLeft: index == 3 ? newRadius! : borderRadius?.bottomLeft ?? Radius.zero,
      ));
    }
  }

  void updateBorder(String property, {Color? borderColor, double? borderWidth}) {
    Border? border = decoration!.border as Border?;
    RenderStyle renderStyle = this as RenderStyle;

    bool isBorderWidthChange = property == BORDER_TOP_WIDTH || property == BORDER_RIGHT_WIDTH ||
      property == BORDER_BOTTOM_WIDTH || property == BORDER_LEFT_WIDTH;

    // Only border width change will affect layout
    if (isBorderWidthChange) {
      renderBoxModel!.markNeedsLayout();
    }

    if (border != null) {
      BorderSide? left =  border.left;
      BorderSide? top =  border.top;
      BorderSide? right =  border.right;
      BorderSide? bottom =  border.bottom;
      bool updateAll = false;

      if (property.contains(BORDER_LEFT)) {
        left = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.LEFT, borderColor, borderWidth);
      } else if (property.contains(BORDER_TOP)) {
        top = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.TOP, borderColor, borderWidth);
      } else if (property.contains(BORDER_RIGHT)) {
        right = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.RIGHT, borderColor, borderWidth);
      } else if (property.contains(BORDER_BOTTOM)) {
        bottom = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.BOTTOM, borderColor, borderWidth);
      } else {
        updateAll = true;
      }

      if (!updateAll) {
        decoration = decoration!.clone(border: Border(
          left: left ?? BorderSide.none,
          top: top ?? BorderSide.none,
          right: right ?? BorderSide.none,
          bottom: bottom ?? BorderSide.none,
        ));
        return;
      }
    }
    // Update all border
    List<BorderSide>? borderSides = _getBorderSides(borderColor, borderWidth);

    if (borderSides != null) {
      decoration = decoration!.clone(border: Border(
        left: borderSides[0],
        top: borderSides[1],
        right: borderSides[2],
        bottom: borderSides[3],
      ));
    }
  }

  List<BorderSide>? _getBorderSides([Color? borderColor, double? borderWidth]) {
    RenderStyle renderStyle = this as RenderStyle;
    BorderSide? leftSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.LEFT, borderColor, borderWidth);
    BorderSide? topSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.TOP, borderColor, borderWidth);
    BorderSide? rightSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.RIGHT, borderColor, borderWidth);
    BorderSide? bottomSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.BOTTOM, borderColor, borderWidth);

    bool hasBorder = leftSide != null ||
        topSide != null ||
        rightSide != null ||
        bottomSide != null;

    return hasBorder ? [
      leftSide ?? CSSBorderSide.none,
      topSide ?? CSSBorderSide.none,
      rightSide ?? CSSBorderSide.none,
      bottomSide ?? CSSBorderSide.none] : null;
  }

  List<Radius>? _getBorderRadius() {
    RenderStyle renderStyle = this as RenderStyle;
    // border radius add border topLeft topRight bottomLeft bottomRight
    Radius? topLeftRadius = CSSBorderRadius.getRadius(style[BORDER_TOP_LEFT_RADIUS], renderStyle);
    Radius? topRightRadius = CSSBorderRadius.getRadius(style[BORDER_TOP_RIGHT_RADIUS], renderStyle);
    Radius? bottomRightRadius = CSSBorderRadius.getRadius(style[BORDER_BOTTOM_RIGHT_RADIUS], renderStyle);
    Radius? bottomLeftRadius = CSSBorderRadius.getRadius(style[BORDER_BOTTOM_LEFT_RADIUS], renderStyle);

    bool hasBorderRadius = topLeftRadius != null ||
        topRightRadius != null ||
        bottomRightRadius != null ||
        bottomLeftRadius != null;

    return hasBorderRadius ? [
      topLeftRadius ?? CSSBorderRadius.none,
      topRightRadius ?? CSSBorderRadius.none,
      bottomRightRadius ?? CSSBorderRadius.none,
      bottomLeftRadius ?? CSSBorderRadius.none
    ] : null;
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>
  CSSBoxDecoration? getCSSBoxDecoration() {
    // Backgroud color
    Color? bgColor = CSSBackground.getBackgroundColor(style);
    // Background image
    DecorationImage? decorationImage;
    Gradient? gradient;
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(style[BACKGROUND_IMAGE]);
    for (CSSFunctionalNotation method in methods) {
      if (method.name == 'url') {
        decorationImage = CSSBackground.getDecorationImage(style, method);
      } else {
        gradient = CSSBackground.getBackgroundGradient(style, renderBoxModel!, method);
      }
    }

    List<Radius>? radius = _getBorderRadius();
    List<CSSBoxShadow>? boxShadow = getBoxShadow();
    List<BorderSide>? borderSides = _getBorderSides();

    if (bgColor == null &&
        decorationImage == null &&
        gradient == null &&
        borderSides == null &&
        radius == null &&
        boxShadow == null) {
      return null;
    }

    if (gradient != null) {
      bgColor = null;
    }

    Border? border;
    if (borderSides != null) {
      // side read inorder left top right bottom
      border = Border(left: borderSides[0], top: borderSides[1], right: borderSides[2], bottom: borderSides[3]);
    }

    BorderRadius? borderRadius;
    // Flutter border radius only works when border is uniform.
    if (radius != null && (border == null || border.isUniform)) {
      borderRadius = BorderRadius.only(
        topLeft: radius[0],
        topRight: radius[1],
        bottomRight: radius[2],
        bottomLeft: radius[3],
      );
    }
    return CSSBoxDecoration(
        color: bgColor,
        image: decorationImage,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient
    );
  }

  List<CSSBoxShadow>? getBoxShadow() {
    List<CSSBoxShadow>? boxShadow;
    RenderStyle renderStyle = this as RenderStyle;
    CSSStyleDeclaration style = renderStyle.style;

    if (style.contains(BOX_SHADOW)) {
      boxShadow = [];
      var shadows = CSSStyleProperty.getShadowValues(style[BOX_SHADOW]);
      Size viewportSize = renderStyle.viewportSize;
      RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
      double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
      double fontSize = renderStyle.fontSize;

      if (shadows != null) {
        for (var shadowDefinitions in shadows) {
          // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
          String? colorDefinition = shadowDefinitions[0];
          if (colorDefinition == CURRENT_COLOR || colorDefinition == null) {
            colorDefinition = style.getCurrentColor();
          }
          Color? color = CSSColor.parseColor(colorDefinition);
          double offsetX = CSSLength.toDisplayPortValue(
            shadowDefinitions[1],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          double offsetY = CSSLength.toDisplayPortValue(
            shadowDefinitions[2],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          double blurRadius = CSSLength.toDisplayPortValue(
            shadowDefinitions[3],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          double spreadRadius = CSSLength.toDisplayPortValue(
            shadowDefinitions[4],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          bool inset = shadowDefinitions[5] == INSET;

          if (color != null) {
            boxShadow.add(CSSBoxShadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              color: color,
              inset: inset,
            ));
          }
        }
      }
    }
    return boxShadow;
  }

  BackgroundBoundary getBackgroundClip(String value) {
    switch (value) {
      case 'padding-box':
        return BackgroundBoundary.paddingBox;
      case 'content-box':
        return BackgroundBoundary.contentBox;
      case 'border-box':
      default:
        return BackgroundBoundary.borderBox;
    }
  }

  BackgroundBoundary getBackgroundOrigin(String value) {
    switch (value) {
      case 'border-box':
        return BackgroundBoundary.borderBox;
      case 'content-box':
        return BackgroundBoundary.contentBox;
      case 'padding-box':
      default:
        return BackgroundBoundary.paddingBox;
    }
  }
}

class CSSBorderSide {
  // border default width 3.0
  static double defaultBorderWidth = 3.0;
  static Color defaultBorderColor = CSSColor.initial;
  static String LEFT = 'Left';
  static String RIGHT = 'Right';
  static String TOP = 'Top';
  static String BOTTOM = 'Bottom';

  static double? getBorderWidth(String input, RenderStyle renderStyle) {
    Size viewportSize = renderStyle.viewportSize;
    RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
    double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
    double fontSize = renderStyle.fontSize;

    // https://drafts.csswg.org/css2/#border-width-properties
    // The interpretation of the first three values depends on the user agent.
    // The following relationships must hold, however:
    // thin ≤ medium ≤ thick.
    double? borderWidth;
    switch (input) {
      case THIN:
        borderWidth = 1;
        break;
      case MEDIUM:
        borderWidth = 3;
        break;
      case THICK:
        borderWidth = 5;
        break;
      default:
        borderWidth = CSSLength.toDisplayPortValue(
          input,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
    }
    return borderWidth;
  }

  static bool isValidBorderStyleValue(String value) {
    return value == SOLID || value == NONE;
  }

  static bool isValidBorderWidthValue(String value) {
    return CSSLength.isLength(value) || value == THIN || value == MEDIUM || value == THICK;
  }

  static double? getBorderSideWidth(RenderStyle renderStyle, String side) {
    CSSStyleDeclaration style = renderStyle.style;
    String property = 'border${side}Width';
    String value = style[property];
    return value.isEmpty ? defaultBorderWidth : getBorderWidth(value, renderStyle);
  }

  static Color? getBorderSideColor(CSSStyleDeclaration style, String side) {
    String property = 'border${side}Color';
    String value = style[property] ?? style[COLOR]; // Use current color first
    return value.isEmpty ? defaultBorderColor : CSSColor.parseColor(value);
  }

  static BorderSide none = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide? getBorderSide(RenderStyle renderStyle, String side, [Color? borderColor, double? borderWidth]) {
    CSSStyleDeclaration style = renderStyle.style;
    BorderStyle? borderStyle = CSSBorderStyle.getBorderSideStyle(style, side);
    double? width = borderWidth ?? getBorderSideWidth(renderStyle, side);
    Color? color = borderColor ?? getBorderSideColor(style, side);
    // Flutter will print border event if width is 0.0. So we needs to set borderStyle to none to prevent this.
    if (borderStyle == BorderStyle.none || width == 0.0) {
      return null;
    } else {
      return BorderSide(
        color: color!,
        width: width!,
        style: borderStyle!
      );
    }
  }
}

class CSSBorderRadius {
  static Radius none = Radius.zero;

  static Radius? getRadius(String radius, RenderStyle renderStyle) {
    Size viewportSize = renderStyle.viewportSize;
    RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
    double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
    double fontSize = renderStyle.fontSize;

    if (radius.isNotEmpty) {
      // border-top-left-radius: horizontal vertical
      List<String> values = radius.split(_spaceRegExp);
      if (values.length == 1) {
        double? circular = CSSLength.toDisplayPortValue(
          values[0],
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        if (circular != null) return Radius.circular(circular);
      } else if (values.length == 2) {
        double? x = CSSLength.toDisplayPortValue(
          values[0],
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        double? y = CSSLength.toDisplayPortValue(
          values[1],
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        if (x != null && y != null) return Radius.elliptical(x, y);
      }
    }

    return null;
  }
}

class CSSBorderStyle {
  static BorderStyle defaultBorderStyle = BorderStyle.none;
  static BorderStyle? getBorderSideStyle(CSSStyleDeclaration style, String side) {
    String property = 'border${side}Style';
    String value = style[property];
    return value.isEmpty ? defaultBorderStyle : getBorderStyle(value);
  }

  static BorderStyle? getBorderStyle(String input) {
    BorderStyle? borderStyle;
    switch (input) {
      case SOLID:
        borderStyle = BorderStyle.solid;
        break;
      case NONE:
        borderStyle = BorderStyle.none;
        break;
    }
    return borderStyle;
  }
}

// ignore: must_be_immutable
class CSSBoxShadow extends BoxShadow {
  CSSBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    bool inset = false,
  }) : super(color: color, offset: offset, blurRadius: blurRadius, spreadRadius: spreadRadius) {
    _inset = inset;
  }


  bool _inset = false;
  bool get inset {
    return _inset;
  }
  set inset(bool value) {
    if (_inset == value) return;
    _inset = value;
  }

  @override
  String toString() => 'BoxShadow($color, $offset, $blurRadius, $spreadRadius $inset)';
}

class CSSBoxDecoration extends BoxDecoration {
  CSSBoxDecoration({
    this.color,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
  }): super(color: color, image: image, border: border, borderRadius: borderRadius,
    gradient: gradient, backgroundBlendMode: backgroundBlendMode, shape: shape);

  @override
  final Color? color;

  @override
  final DecorationImage? image;

  @override
  final BoxBorder? border;

  @override
  final BorderRadiusGeometry? borderRadius;

  @override
  final List<CSSBoxShadow>? boxShadow;

  @override
  final Gradient? gradient;

  @override
  final BlendMode? backgroundBlendMode;

  @override
  final BoxShape shape;

  CSSBoxDecoration clone({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<CSSBoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
  }) {
    return CSSBoxDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      shape: shape ?? this.shape,
    );
  }
}

