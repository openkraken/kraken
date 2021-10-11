

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

// https://drafts.csswg.org/css-backgrounds/#typedef-attachment
enum CSSBackgroundAttachmentType {
  scroll,
  fixed,
  local,
}

enum CSSBackgroundRepeatType {
  repeat,
  repeatX,
  repeatY,
  noRepeat,
}

enum CSSBackgroundSizeType {
  auto,
  cover,
  contain,
}

enum CSSBackgroundPositionType {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum CSSBackgroundOriginType {
  borderBox,
  paddingBox,
  contentBox,
}

enum CSSBackgroundClipType {
  borderBox,
  paddingBox,
  contentBox,
}

enum CSSBackgroundImageType {
  none,
  gradient,
  image,
}

enum CSSBorderStyleType {
  none,
  hidden,
  dotted,
  dashed,
  solid,
  double,
  groove,
  ridge,
  inset,
  outset,
}

final RegExp _spaceRegExp = RegExp(r'\s+');

class CSSBackgroundImage {
  Gradient? gradient;
  DecorationImage? image;

  CSSBackgroundImage(this.image, this.gradient);

  static parseBackgroundImage(String present, RenderStyle renderStyle, String property, int? contextId) {
    Gradient? gradient;
    DecorationImage? image;
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(present);
    for (CSSFunctionalNotation method in methods) {
      if (method.name == 'url') {
        // image = CSSBackground.getDecorationImage(method, enderStyle, property, contextId: contextId);
      } else {
        // gradient = CSSBackground.getBackgroundGradient(method, renderStyle);
      }
    }

    return CSSBackgroundImage(image, gradient);
  }
}

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

  static CSSBackgroundPosition DEFAULT_BACKGROUND_POSITION = CSSBackgroundPosition(percentage: -1);
  static CSSBackgroundSize DEFAULT_BACKGROUND_SIZE = CSSBackgroundSize(fit: BoxFit.none);

  /// Background-clip
  BackgroundBoundary? get backgroundClip => _backgroundClip;
  BackgroundBoundary? _backgroundClip;
  set backgroundClip(BackgroundBoundary? value) {
    if (value == _backgroundClip) return;
    _backgroundClip = value;
  }

  /// Background-origin
  BackgroundBoundary? get backgroundOrigin => _backgroundOrigin;
  BackgroundBoundary? _backgroundOrigin;
  set backgroundOrigin(BackgroundBoundary? value) {
    if (value == _backgroundOrigin) return;
    _backgroundOrigin = value;
  }

  Color? get backgroundColor => _backgroundColor;
  Color? _backgroundColor;
  set backgroundColor(Color? value) {
    if (value == _backgroundColor) return;
    _backgroundColor = value;

    // If there has gradient, background color will not work
    if (backgroundImage?.gradient == null) {
      renderBoxModel!.markNeedsPaint();
    }
  }

  /// Background-image
  CSSBackgroundImage? get backgroundImage => _backgroundImage;
  CSSBackgroundImage? _backgroundImage;
  set backgroundImage(CSSBackgroundImage? value) {
    if (value == _backgroundImage) return;
    _backgroundImage = value;
  }

  /// Background-position-x
  CSSBackgroundPosition get backgroundPositionX => _backgroundPositionX ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionX;
  set backgroundPositionX(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionX) return;
    _backgroundPositionX = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-position-y
  CSSBackgroundPosition get backgroundPositionY => _backgroundPositionY ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionY;
  set backgroundPositionY(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionY) return;
    _backgroundPositionY = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-size
  CSSBackgroundSize get backgroundSize => _backgroundSize ?? DEFAULT_BACKGROUND_SIZE;
  CSSBackgroundSize? _backgroundSize;
  set backgroundSize(CSSBackgroundSize? value) {
    if (value == _backgroundSize) return;
    _backgroundSize = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Background-attachment
  String? get backgroundAttachment => _backgroundAttachment;
  String? _backgroundAttachment;
  set backgroundAttachment(String? value) {
    if (value == _backgroundAttachment) return;
    _backgroundAttachment = value;
  }

  /// BorderSize to deflate.
  EdgeInsets get borderEdge {
    // If has border, render padding should subtracting the edge of the border
    return EdgeInsets.fromLTRB(
      borderLeftWidth.computedValue,
      borderTopWidth.computedValue,
      borderRightWidth.computedValue,
      borderBottomWidth.computedValue,
    );
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>

  /// Border-width
  CSSLengthValue? _borderTopWidth;
  set borderTopWidth(CSSLengthValue? value) {
    if (value == _borderTopWidth) return;
    _borderTopWidth = value;
    renderBoxModel!.markNeedsLayout();
  }
  CSSLengthValue get borderTopWidth => _borderTopWidth ?? CSSLengthValue.zero;

  CSSLengthValue? _borderRightWidth;
  set borderRightWidth(CSSLengthValue? value) {
    if (value == _borderRightWidth) return;
    _borderRightWidth = value;
    renderBoxModel!.markNeedsLayout();
  }
  CSSLengthValue get borderRightWidth => _borderRightWidth ?? CSSLengthValue.zero;

  CSSLengthValue? _borderBottomWidth;
  set borderBottomWidth(CSSLengthValue? value) {
    if (value == _borderBottomWidth) return;
    _borderBottomWidth = value;
    renderBoxModel!.markNeedsLayout();
  }
  CSSLengthValue get borderBottomWidth => _borderBottomWidth ?? CSSLengthValue.zero;

  CSSLengthValue? _borderLeftWidth;
  set borderLeftWidth(CSSLengthValue? value) {
    if (value == _borderLeftWidth) return;
    _borderLeftWidth = value;
    renderBoxModel!.markNeedsLayout();
  }
  CSSLengthValue get borderLeftWidth => _borderLeftWidth ?? CSSLengthValue.zero;

  /// Border-color
  Color? get borderTopColor => _borderTopColor;
  Color? _borderTopColor;
  set borderTopColor(Color? value) {
    if (value == _borderTopColor) return;
    _borderTopColor = value;
    renderBoxModel!.markNeedsPaint();
  }

  Color? get borderRightColor => _borderRightColor;
  Color? _borderRightColor;
  set borderRightColor(Color? value) {
    if (value == _borderRightColor) return;
    _borderRightColor = value;
    renderBoxModel!.markNeedsPaint();
  }

  Color? get borderBottomColor => _borderBottomColor;
  Color? _borderBottomColor;
  set borderBottomColor(Color? value) {
    if (value == _borderBottomColor) return;
    _borderBottomColor = value;
    renderBoxModel!.markNeedsPaint();
  }

  Color? get borderLeftColor => _borderLeftColor;
  Color? _borderLeftColor;
  set borderLeftColor(Color? value) {
    if (value == _borderLeftColor) return;
    _borderLeftColor = value;
    renderBoxModel!.markNeedsPaint();
  }

  /// Border-style
  BorderStyle? get borderTopStyle => _borderTopStyle;
  BorderStyle? _borderTopStyle;
  set borderTopStyle(BorderStyle? value) {
    if (value == _borderTopStyle) return;
    _borderTopStyle = value;
    renderBoxModel!.markNeedsPaint();
  }

  BorderStyle? get borderRightStyle => _borderRightStyle;
  BorderStyle? _borderRightStyle;
  set borderRightStyle(BorderStyle? value) {
    if (value == _borderRightStyle) return;
    _borderRightStyle = value;
    renderBoxModel!.markNeedsPaint();
  }

  BorderStyle? get borderBottomStyle => _borderBottomStyle;
  BorderStyle? _borderBottomStyle;
  set borderBottomStyle(BorderStyle? value) {
    if (value == _borderBottomStyle) return;
    _borderBottomStyle = value;
    renderBoxModel!.markNeedsPaint();
  }

  BorderStyle? get borderLeftStyle => _borderLeftStyle;
  BorderStyle? _borderLeftStyle;
  set borderLeftStyle(BorderStyle? value) {
    if (value == _borderLeftStyle) return;
    _borderLeftStyle = value;
    renderBoxModel!.markNeedsPaint();
  }

  CSSBorderRadius? _borderTopLeftRadius;
  set borderTopLeftRadius(CSSBorderRadius? value) {
    if (value == _borderTopLeftRadius) return;
    _borderTopLeftRadius = value;
    renderBoxModel!.markNeedsPaint();
  }
  CSSBorderRadius get borderTopLeftRadius => _borderTopLeftRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderTopRightRadius;
  set borderTopRightRadius(CSSBorderRadius? value) {
    if (value == _borderTopRightRadius) return;
    _borderTopRightRadius = value;
    renderBoxModel!.markNeedsPaint();
  }
  CSSBorderRadius get borderTopRightRadius => _borderTopRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomRightRadius;
  set borderBottomRightRadius(CSSBorderRadius? value) {
    if (value == _borderBottomRightRadius) return;
    _borderBottomRightRadius = value;
    renderBoxModel!.markNeedsPaint();
  }
  CSSBorderRadius get borderBottomRightRadius => _borderBottomRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomLeftRadius;
  set borderBottomLeftRadius(CSSBorderRadius? value) {
    if (value == _borderBottomLeftRadius) return;
    _borderBottomLeftRadius = value;
    renderBoxModel!.markNeedsPaint();
  }
  CSSBorderRadius get borderBottomLeftRadius => _borderBottomLeftRadius ?? CSSBorderRadius.zero;

  List<CSSBoxShadow>? _boxShadow;
  set boxShadow(List<CSSBoxShadow>? value) {
    if (value == _boxShadow) return;
    _boxShadow = value;
    renderBoxModel!.markNeedsPaint();
  }
  List<CSSBoxShadow>? get boxShadow => _boxShadow;

  /// What decoration to paint, should get value after layout.
  CSSBoxDecoration? _cachedDecoration;
  CSSBoxDecoration? get decoration {

    if (_cachedDecoration != null) {
      return _cachedDecoration;
    }

    List<Radius>? radius = _getBorderRadius();
    List<BorderSide>? borderSides = _getBorderSides();
    List<KrakenBoxShadow>? boxShadow = _getBoxShadow();

    if (backgroundColor == null &&
        backgroundImage == null &&
        borderSides == null &&
        radius == null &&
        boxShadow == null) {
      return null;
    }

    Border? border;
    if (borderSides != null) {
      // Side read inorder left top right bottom.
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

    Color? color = backgroundColor;
    Gradient? gradient = backgroundImage?.gradient;
    if (gradient is BorderGradientMixin) {
      gradient.borderEdge = border!.dimensions as EdgeInsets;
    }

    return _cachedDecoration = CSSBoxDecoration(
      boxShadow: boxShadow,
      color: gradient != null ? null : color,
      image: backgroundImage?.image,
      border: border,
      borderRadius: borderRadius,
      gradient: gradient,
    );
  }

  DecorationPosition decorationPosition = DecorationPosition.background;

  ImageConfiguration imageConfiguration = ImageConfiguration.empty;

  Size wrapBorderSize(Size innerSize) {
    return Size(borderLeftWidth.computedValue + innerSize.width + borderRightWidth.computedValue,
      borderTopWidth.computedValue + innerSize.height + borderBottomWidth.computedValue);
  }

  BoxConstraints deflateBorderConstraints(BoxConstraints constraints) {
    return constraints.deflate(borderEdge);
  }

  List<BorderSide>? _getBorderSides() {
    RenderStyle renderStyle = this as RenderStyle;
    BorderSide? leftSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.LEFT);
    BorderSide? topSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.TOP);
    BorderSide? rightSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.RIGHT);
    BorderSide? bottomSide = CSSBorderSide.getBorderSide(renderStyle, CSSBorderSide.BOTTOM);

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
    CSSBorderRadius? topLeftRadius = renderStyle.borderTopLeftRadius;
    CSSBorderRadius? topRightRadius = renderStyle.borderTopRightRadius;
    CSSBorderRadius? bottomRightRadius = renderStyle.borderBottomRightRadius;
    CSSBorderRadius? bottomLeftRadius = renderStyle.borderBottomLeftRadius;

    bool hasBorderRadius = topLeftRadius != CSSBorderRadius.zero ||
        topRightRadius != CSSBorderRadius.zero ||
        bottomRightRadius != CSSBorderRadius.zero ||
        bottomLeftRadius != CSSBorderRadius.zero;

    return hasBorderRadius ? [
      topLeftRadius.computedRadius,
      topRightRadius.computedRadius,
      bottomRightRadius.computedRadius,
      bottomLeftRadius.computedRadius
    ] : null;
  }

  List<KrakenBoxShadow>? _getBoxShadow() {
    if (boxShadow == null) {
      return null;
    }
    List<KrakenBoxShadow> result = [];
    for (CSSBoxShadow shadow in boxShadow!) {
      result.add(shadow.computedBoxShdow);
    }
    return result;
  }

  static resolveBackgroundAttachment() {
    // TODO
  }

  static BackgroundBoundary resolveBackgroundClip(String value) {
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

  static BackgroundBoundary resolveBackgroundOrigin(String value) {
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
  static const String LEFT = 'Left';
  static const String RIGHT = 'Right';
  static const String TOP = 'Top';
  static const String BOTTOM = 'Bottom';

  static BorderStyle resolveBorderStyle(String input) {
    BorderStyle borderStyle;
    switch (input) {
      case SOLID:
        borderStyle = BorderStyle.solid;
        break;
      case NONE:
      default:
        borderStyle = BorderStyle.none;
        break;
    }
    return borderStyle;
  }

  static double? getBorderWidth(String input, RenderStyle renderStyle) {
    Size viewportSize = renderStyle.viewportSize;
    RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
    double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
    double fontSize = renderStyle.fontSize.computedValue;

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

  static BorderSide none = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide? getBorderSide(RenderStyle renderStyle, String side) {
    BorderStyle? borderStyle;
    CSSLengthValue? borderWidth;
    Color? borderColor;
    switch (side) {
      case LEFT:
        borderStyle = renderStyle.borderLeftStyle;
        borderWidth = renderStyle.borderLeftWidth;
        borderColor = renderStyle.borderLeftColor;
        break;
      case RIGHT:
        borderStyle = renderStyle.borderRightStyle;
        borderWidth = renderStyle.borderRightWidth;
        borderColor = renderStyle.borderRightColor;
        break;
      case TOP:
        borderStyle = renderStyle.borderTopStyle;
        borderWidth = renderStyle.borderTopWidth;
        borderColor = renderStyle.borderTopColor;
        break;
      case BOTTOM:
        borderStyle = renderStyle.borderBottomStyle;
        borderWidth = renderStyle.borderBottomWidth;
        borderColor = renderStyle.borderBottomColor;
        break;
    }
    // Flutter will print border event if width is 0.0. So we needs to set borderStyle to none to prevent this.
    if (borderStyle == BorderStyle.none || borderWidth!.isZero) {
      return null;
    } else if (borderColor == null) {
      return BorderSide(
        width: borderWidth.computedValue,
        style: borderStyle!
      );
    } else {
      return BorderSide(
        width: borderWidth.computedValue,
        style: borderStyle!,
        color: borderColor
      );
    }
  }
}

class CSSBorderRadius {
  final CSSLengthValue x;
  final CSSLengthValue y;
  const CSSBorderRadius(this.x, this.y);
  static CSSBorderRadius zero = CSSBorderRadius(CSSLengthValue.zero, CSSLengthValue.zero);
  static CSSBorderRadius? parseBorderRadius(String radius, RenderStyle renderStyle, String propertyName) {
    if (radius.isNotEmpty) {
      // border-top-left-radius: horizontal vertical
      List<String> values = radius.split(_spaceRegExp);
      if (values.length == 1) {
        CSSLengthValue circular = CSSLength.parseLength(values[0], renderStyle, propertyName);
        return CSSBorderRadius(circular, circular);
      } else if (values.length == 2) {
        CSSLengthValue x = CSSLength.parseLength(values[0], renderStyle, propertyName, true, false);
        CSSLengthValue y = CSSLength.parseLength(values[1], renderStyle, propertyName, false, true);
        return CSSBorderRadius(x, y);
      }
    }
    return null;
  }

  Radius get computedRadius {
    return Radius.elliptical(x.computedValue, y.computedValue);
  }
}

class KrakenBoxShadow extends BoxShadow {
  /// Creates a box shadow.
  ///
  /// By default, the shadow is solid black with zero [offset], [blurRadius],
  /// and [spreadRadius].
  const KrakenBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    this.inset = false,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  final bool inset;
}

// ignore: must_be_immutable
class CSSBoxShadow {
  CSSBoxShadow({
    this.color,
    this.offsetX,
    this.offsetY,
    this.blurRadius,
    this.spreadRadius,
    this.inset = false,
  });

  bool inset = false;
  Color? color;
  CSSLengthValue? offsetX;
  CSSLengthValue? offsetY;
  CSSLengthValue? blurRadius;
  CSSLengthValue? spreadRadius;

  KrakenBoxShadow get computedBoxShdow {
    color ??= const Color(0xFF000000);
    offsetX ??= CSSLengthValue.zero;
    offsetY ??= CSSLengthValue.zero;
    blurRadius ??= CSSLengthValue.zero;
    spreadRadius ??= CSSLengthValue.zero;
    return KrakenBoxShadow(
      color: color!,
      offset: Offset(offsetX!.computedValue, offsetY!.computedValue),
      blurRadius: blurRadius!.computedValue,
      spreadRadius: spreadRadius!.computedValue,
      inset: inset,
    );
  }

  static List<CSSBoxShadow>? parseBoxShadow(String present, RenderStyle renderStyle, String propertyName) {

    var shadows = CSSStyleProperty.getShadowValues(present);
    if (shadows != null) {
      List<CSSBoxShadow>? boxShadow = [];
      for (var shadowDefinitions in shadows) {
        // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
        String? colorDefinition = shadowDefinitions[0];
        Color? color;
        if (colorDefinition == CURRENT_COLOR || colorDefinition == null) {
          color = renderStyle.color;
        } else {
          color = CSSColor.parseColor(colorDefinition);
        }
        CSSLengthValue? offsetX;
        if (shadowDefinitions[1] != null) {
          offsetX = CSSLength.parseLength(shadowDefinitions[1]!, renderStyle, propertyName);
        }

        CSSLengthValue? offsetY;
        if (shadowDefinitions[2] != null) {
          offsetY = CSSLength.parseLength(shadowDefinitions[2]!, renderStyle, propertyName);
        }

        CSSLengthValue? blurRadius;
        if (shadowDefinitions[3] != null) {
          blurRadius = CSSLength.parseLength(shadowDefinitions[3]!, renderStyle, propertyName);
        }

        CSSLengthValue? spreadRadius;
        if (shadowDefinitions[4] != null) {
          spreadRadius = CSSLength.parseLength(shadowDefinitions[4]!, renderStyle, propertyName);
        }

        bool inset = shadowDefinitions[5] == INSET;

        if (color != null) {
          boxShadow.add(CSSBoxShadow(
            offsetX: offsetX,
            offsetY: offsetY,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            color: color,
            inset: inset,
          ));
        }
      }
      return boxShadow;
    }

    return null;
  }
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
  final List<KrakenBoxShadow>? boxShadow;

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
    List<KrakenBoxShadow>? boxShadow,
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

