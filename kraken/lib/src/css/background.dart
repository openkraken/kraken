

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/launcher.dart';

// CSS Backgrounds: https://drafts.csswg.org/css-backgrounds/
// CSS Images: https://drafts.csswg.org/css-images-3/

/// The [CSSBackgroundMixin] mixin used to handle background shorthand and compute
/// to single value of background
///

final RegExp _splitRegExp = RegExp(r'\s+');

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

class CSSColorStop {
  Color? color;
  double? stop;
  CSSColorStop(this.color, this.stop);
}

class CSSBackgroundImage {
  Gradient? gradient;
  DecorationImage? image;
  CSSBackgroundImage(this.image, this.gradient);
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
  CSSLengthValue? width;
  CSSLengthValue? height;

  @override
  String toString() => 'CSSBackgroundSize(fit: $fit, width: $width, height: $height)';
}

class CSSBackground {
  static bool isValidBackgroundRepeatValue(String value) {
    return value == REPEAT || value == NO_REPEAT || value == REPEAT_X || value == REPEAT_Y;
  }

  static bool isValidBackgroundSizeValue(String value) {
    return value == AUTO ||
        value == CONTAIN ||
        value == COVER ||
        value == FIT_WIDTH ||
        value == FIT_HEIGTH ||
        value == SCALE_DOWN ||
        value == FILL ||
        CSSLength.isLength(value) ||
        CSSPercentage.isPercentage(value);
  }

  static bool isValidBackgroundAttachmentValue(String value) {
    return value == SCROLL || value == LOCAL;
  }

  static bool isValidBackgroundImageValue(String value) {
    return (value.lastIndexOf(')') == value.length - 1) &&
        (value.startsWith('url(') ||
        value.startsWith('linear-gradient(') ||
        value.startsWith('repeating-linear-gradient(') ||
        value.startsWith('radial-gradient(') ||
        value.startsWith('repeating-radial-gradient(') ||
        value.startsWith('conic-gradient('));
  }

  static bool isValidBackgroundPositionValue(String value) {
    return value == CSSPosition.CENTER ||
        value == CSSPosition.LEFT ||
        value == CSSPosition.RIGHT ||
        value == CSSPosition.TOP ||
        value == CSSPosition.BOTTOM ||
        CSSLength.isLength(value) ||
        CSSPercentage.isPercentage(value);
  }

  static resolveBackgroundAttachment(String value) {
    switch (value) {
      case LOCAL:
        return CSSBackgroundAttachmentType.local;
      case FIXED:
        return CSSBackgroundAttachmentType.fixed;
      case SCROLL:
      default:
        return CSSBackgroundAttachmentType.scroll;
    }
  }

  static CSSBackgroundSize resolveBackgroundSize(String value, RenderStyle renderStyle, String propertyName) {
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
        List<String> values = value.split(_splitRegExp);
        if (values.length == 1) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName);
          return CSSBackgroundSize(
            fit: BoxFit.none,
            width: width,
          );
        } else if (values.length == 2) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName);
          CSSLengthValue height = CSSLength.parseLength(values[0], renderStyle, propertyName);
          // Value which is neither length/percentage/auto is considered to be invalid.
          return CSSBackgroundSize(
            fit: BoxFit.none,
            width: width,
            height: height,
          );
        }
        return CSSBackgroundSize(
          fit: BoxFit.none
        );
    }
  }

  static resolveBackgroundImage(String present, RenderStyle renderStyle, String property, int? contextId) {
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

  static ImageRepeat resolveBackgroundRepeat(String value) {
    switch (value) {
      case REPEAT_X:
        return ImageRepeat.repeatX;
      case REPEAT_Y:
        return ImageRepeat.repeatY;
      case NO_REPEAT:
        return ImageRepeat.noRepeat;
      case REPEAT:
      default:
        return ImageRepeat.repeat;
    }
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

  static bool hasLocalBackgroundImage(CSSStyleDeclaration style) {
    return style[BACKGROUND_IMAGE].isNotEmpty && style[BACKGROUND_ATTACHMENT] == LOCAL;
  }

  static bool hasScrollBackgroundImage(CSSStyleDeclaration style) {
    String attachment = style[BACKGROUND_ATTACHMENT];
    // Default is `scroll` attachment
    return style[BACKGROUND_IMAGE].isNotEmpty && (attachment.isEmpty || attachment == SCROLL);
  }

  static DecorationImage? getDecorationImage(CSSStyleDeclaration style, CSSFunctionalNotation method, { int? contextId }) {
    DecorationImage? backgroundImage;

    String url = method.args.isNotEmpty ? method.args[0] : '';
    if (url.isEmpty) {
      return null;
    }

    // Method may contain quotation mark, like ['"assets/foo.png"']
    url = _removeQuotationMark(url);

    Uri uri = Uri.parse(url);
    if (contextId != null && url.isNotEmpty) {
      KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
      if (controller != null) {
        uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri);
      }
    }

    ImageRepeat imageRepeat = ImageRepeat.repeat;
    if (style[BACKGROUND_REPEAT].isNotEmpty) {
      switch (style[BACKGROUND_REPEAT]) {
        case REPEAT_X:
          imageRepeat = ImageRepeat.repeatX;
          break;
        case REPEAT_Y:
          imageRepeat = ImageRepeat.repeatY;
          break;
        case NO_REPEAT:
          imageRepeat = ImageRepeat.noRepeat;
          break;
      }
    }

    backgroundImage = DecorationImage(
      image: CSSUrl.parseUrl(uri, contextId: contextId)!,
      repeat: imageRepeat,
    );

    return backgroundImage;
  }

  static Gradient? getBackgroundGradient(CSSStyleDeclaration? style, RenderBoxModel renderBoxModel, CSSFunctionalNotation method) {
    Gradient? gradient;

    if (method.args.length > 1) {
      List<Color> colors = [];
      List<double> stops = [];
      int start = 0;
      RenderStyle renderStyle = renderBoxModel.renderStyle;
      Size viewportSize = renderStyle.viewportSize;
      double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
      double fontSize = renderStyle.fontSize.computedValue;

      switch (method.name) {
        case 'linear-gradient':
        case 'repeating-linear-gradient':
          double? linearAngle;
          Alignment begin = Alignment.topCenter;
          Alignment end = Alignment.bottomCenter;
          String arg0 = method.args[0].trim();
          double? gradientLength;
          if (arg0.startsWith('to ')) {
            List<String> parts = arg0.split(_splitRegExp);
            if (parts.length >= 2) {
              switch (parts[1]) {
                case LEFT:
                  if (parts.length == 3) {
                    if (parts[2] == TOP) {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (parts[2] == BOTTOM) {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    }
                  } else {
                    begin = Alignment.centerRight;
                    end = Alignment.centerLeft;
                  }
                  if (style![WIDTH].isNotEmpty) {
                    gradientLength = CSSLength.toDisplayPortValue(
                      style[WIDTH],
                      viewportSize: viewportSize,
                      rootFontSize: rootFontSize,
                      fontSize: fontSize
                    );
                  } else if (renderBoxModel.attached) {
                    gradientLength = renderBoxModel.renderStyle.getLogicalContentWidth();
                  }
                  break;
                case TOP:
                  if (parts.length == 3) {
                    if (parts[2] == LEFT) {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (parts[2] == RIGHT) {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    }
                  } else {
                    begin = Alignment.bottomCenter;
                    end = Alignment.topCenter;
                  }
                  if (style![HEIGHT].isNotEmpty) {
                    gradientLength = CSSLength.toDisplayPortValue(
                      style[HEIGHT],
                      viewportSize: viewportSize,
                      rootFontSize: rootFontSize,
                      fontSize: fontSize
                    );
                  } else if (renderBoxModel.attached) {
                    gradientLength = renderBoxModel.renderStyle.getLogicalContentHeight();
                  }
                  break;
                case RIGHT:
                  if (parts.length == 3) {
                    if (parts[2] == TOP) {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    } else if (parts[2] == BOTTOM) {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.centerLeft;
                    end = Alignment.centerRight;
                  }

                  if (style![WIDTH].isNotEmpty) {
                    gradientLength = CSSLength.toDisplayPortValue(
                      style[WIDTH],
                      viewportSize: viewportSize,
                      rootFontSize: rootFontSize,
                      fontSize: fontSize
                    );
                  } else if (renderBoxModel.attached) {
                    gradientLength = renderBoxModel.renderStyle.getLogicalContentWidth();
                  }

                  break;
                case BOTTOM:
                  if (parts.length == 3) {
                    if (parts[2] == LEFT) {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    } else if (parts[2] == RIGHT) {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.topCenter;
                    end = Alignment.bottomCenter;
                  }
                  if (style![HEIGHT].isNotEmpty) {
                    gradientLength = CSSLength.toDisplayPortValue(
                      style[HEIGHT],
                      viewportSize: viewportSize,
                      rootFontSize: rootFontSize,
                      fontSize: fontSize
                    );
                  } else if (renderBoxModel.attached) {
                    gradientLength = renderBoxModel.renderStyle.getLogicalContentHeight();
                  }
                  break;
              }
            }
            linearAngle = null;
            start = 1;
          } else if (CSSAngle.isAngle(arg0)) {
            linearAngle = CSSAngle.parseAngle(arg0);
            start = 1;
          }
          _applyColorAndStops(renderBoxModel, start, method.args, colors, stops, gradientLength);
          if (colors.length >= 2) {
            gradient = CSSLinearGradient(
                begin: begin,
                end: end,
                angle: linearAngle,
                colors: colors,
                stops: stops,
                tileMode: method.name == 'linear-gradient' ? TileMode.clamp : TileMode.repeated);
          }
          break;
        // @TODO just support circle radial
        case 'radial-gradient':
        case 'repeating-radial-gradient':
          double? atX = 0.5;
          double? atY = 0.5;
          double radius = 0.5;

          if (method.args[0].contains(CSSPercentage.PERCENTAGE)) {
            List<String> positionAndRadius = method.args[0].trim().split(' ');
            if (positionAndRadius.isNotEmpty) {
              if (CSSPercentage.isPercentage(positionAndRadius[0])) {
                radius = CSSPercentage.parsePercentage(positionAndRadius[0])! * 0.5;
                start = 1;
              }
              if (positionAndRadius.length > 2 && positionAndRadius[1] == 'at') {
                start = 1;
                if (CSSPercentage.isPercentage(positionAndRadius[2])) {
                  atX = CSSPercentage.parsePercentage(positionAndRadius[2]);
                }
                if (positionAndRadius.length == 4 && CSSPercentage.isPercentage(positionAndRadius[3])) {
                  atY = CSSPercentage.parsePercentage(positionAndRadius[3]);
                }
              }
            }
          }
          _applyColorAndStops(renderBoxModel, start, method.args, colors, stops);
          if (colors.length >= 2) {
            gradient = CSSRadialGradient(
              center: FractionalOffset(atX!, atY!),
              radius: radius,
              colors: colors,
              stops: stops,
              tileMode: method.name == 'radial-gradient' ? TileMode.clamp : TileMode.repeated,
            );
          }
          break;
        case 'conic-gradient':
          double? from = 0.0;
          double? atX = 0.5;
          double? atY = 0.5;
          if (method.args[0].contains('from ') || method.args[0].contains('at ')) {
            List<String> fromAt = method.args[0].trim().split(' ');
            int fromIndex = fromAt.indexOf('from');
            int atIndex = fromAt.indexOf('at');
            if (fromIndex != -1 && fromIndex + 1 < fromAt.length) {
              from = CSSAngle.parseAngle(fromAt[fromIndex + 1]);
            }
            if (atIndex != -1) {
              if (atIndex + 1 < fromAt.length && CSSPercentage.isPercentage(fromAt[atIndex + 1])) {
                atX = CSSPercentage.parsePercentage(fromAt[atIndex + 1]);
              }
              if (atIndex + 2 < fromAt.length && CSSPercentage.isPercentage(fromAt[atIndex + 2])) {
                atY = CSSPercentage.parsePercentage(fromAt[atIndex + 2]);
              }
            }
            start = 1;
          }
          _applyColorAndStops(renderBoxModel, start, method.args, colors, stops);
          if (colors.length >= 2) {
            gradient = CSSConicGradient(
                center: FractionalOffset(atX!, atY!),
                colors: colors,
                stops: stops,
                transform: GradientRotation(-math.pi / 2 + from!));
          }
          break;
      }
    }

    return gradient;
  }

  static void _applyColorAndStops(RenderBoxModel renderBoxModel, int start, List<String> args, List<Color?> colors, List<double?> stops, [double? gradientLength]) {
    // colors should more than one, otherwise invalid
    if (args.length - start - 1 > 0) {
      double grow = 1.0 / (args.length - start - 1);
      for (int i = start; i < args.length; i++) {
        List<CSSColorStop> colorGradients = _parseColorAndStop(renderBoxModel, args[i].trim(), (i - start) * grow, gradientLength);
        for (var colorStop in colorGradients) {
          colors.add(colorStop.color);
          stops.add(colorStop.stop);
        }
      }
    }
  }

  static List<CSSColorStop> _parseColorAndStop(RenderBoxModel renderBoxModel, String src, [double? defaultStop, double? gradientLength]) {
    List<String> strings = [];
    List<CSSColorStop> colorGradients = [];
    // rgba may contain space, color should handle special
    if (src.startsWith('rgba(')) {
      int indexOfRgbaEnd = src.indexOf(')');
      if (indexOfRgbaEnd == -1) {
        // rgba parse error
        return colorGradients;
      }
      strings.add(src.substring(0, indexOfRgbaEnd + 1));
      if (indexOfRgbaEnd + 1 < src.length) {
        strings.addAll(src.substring(indexOfRgbaEnd + 1).trim().split(' '));
      }
    } else {
      strings = src.split(' ');
    }

    if (strings.isNotEmpty) {
      double? stop = defaultStop;
      if (strings.length >= 2) {
        try {
          RenderStyle renderStyle = renderBoxModel.renderStyle;
          Size viewportSize = renderStyle.viewportSize;
          double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
          double fontSize = renderStyle.fontSize.computedValue;

          for (int i = 1; i < strings.length; i++) {
            if (CSSPercentage.isPercentage(strings[i])) {
              stop = CSSPercentage.parsePercentage(strings[i]);
            } else if (CSSAngle.isAngle(strings[i])) {
              stop = CSSAngle.parseAngle(strings[i])! / (math.pi * 2);
            } else if (CSSLength.isLength(strings[i])) {
              if (gradientLength != null) {
                stop = CSSLength.toDisplayPortValue(
                  strings[i],
                  viewportSize: viewportSize,
                  rootFontSize: rootFontSize,
                  fontSize: fontSize
                )! / gradientLength;
              }
            }
            colorGradients.add(CSSColorStop(CSSColor.parseColor(strings[0]), stop));
          }
        } catch (e) {}
      } else {
        colorGradients.add(CSSColorStop(CSSColor.parseColor(strings[0]), stop));
      }
    }
    return colorGradients;
  }
}

const String _singleQuote = '\'';
const String _doubleQuote = '"';
String _removeQuotationMark(String input) {
  if ((input.startsWith(_singleQuote) && input.endsWith(_singleQuote))
      || (input.startsWith(_doubleQuote) && input.endsWith(_doubleQuote))) {
    input = input.substring(1, input.length - 1);
  }
  return input;
}
