/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/css.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';

// CSS Backgrounds: https://drafts.csswg.org/css-backgrounds/
// CSS Images: https://drafts.csswg.org/css-images-3/

final RegExp _splitRegExp = RegExp(r'\s+');
const String _singleQuote = '\'';
const String _doubleQuote = '"';

String _removeQuotationMark(String input) {
  if ((input.startsWith(_singleQuote) && input.endsWith(_singleQuote))
      || (input.startsWith(_doubleQuote) && input.endsWith(_doubleQuote))) {
    input = input.substring(1, input.length - 1);
  }
  return input;
}

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

/// The [CSSBackgroundMixin] mixin used to handle background shorthand and compute
/// to single value of background.
mixin CSSBackgroundMixin on RenderStyle {
  static CSSBackgroundPosition DEFAULT_BACKGROUND_POSITION = CSSBackgroundPosition(percentage: -1);
  static CSSBackgroundSize DEFAULT_BACKGROUND_SIZE = CSSBackgroundSize(fit: BoxFit.none);

  /// Background-clip
  BackgroundBoundary? get backgroundClip => _backgroundClip;
  BackgroundBoundary? _backgroundClip;
  set backgroundClip(BackgroundBoundary? value) {
    if (value == _backgroundClip) return;
    _backgroundClip = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-origin
  BackgroundBoundary? get backgroundOrigin => _backgroundOrigin;
  BackgroundBoundary? _backgroundOrigin;
  set backgroundOrigin(BackgroundBoundary? value) {
    if (value == _backgroundOrigin) return;
    _backgroundOrigin = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  Color? get backgroundColor => _backgroundColor;
  Color? _backgroundColor;
  set backgroundColor(Color? value) {
    if (value == _backgroundColor) return;
    _backgroundColor = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-image
  @override
  CSSBackgroundImage? get backgroundImage => _backgroundImage;
  CSSBackgroundImage? _backgroundImage;
  set backgroundImage(CSSBackgroundImage? value) {
    if (value == _backgroundImage) return;
    _backgroundImage = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-position-x
  @override
  CSSBackgroundPosition get backgroundPositionX => _backgroundPositionX ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionX;
  set backgroundPositionX(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionX) return;
    _backgroundPositionX = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-position-y
  @override
  CSSBackgroundPosition get backgroundPositionY => _backgroundPositionY ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionY;
  set backgroundPositionY(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionY) return;
    _backgroundPositionY = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-size
  CSSBackgroundSize get backgroundSize => _backgroundSize ?? DEFAULT_BACKGROUND_SIZE;
  CSSBackgroundSize? _backgroundSize;
  set backgroundSize(CSSBackgroundSize? value) {
    if (value == _backgroundSize) return;
    _backgroundSize = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-attachment
  CSSBackgroundAttachmentType? get backgroundAttachment => _backgroundAttachment;
  CSSBackgroundAttachmentType? _backgroundAttachment;
  set backgroundAttachment(CSSBackgroundAttachmentType? value) {
    if (value == _backgroundAttachment) return;
    _backgroundAttachment = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Background-repeat
  @override
  ImageRepeat get backgroundRepeat => _backgroundRepeat ?? ImageRepeat.repeat;
  ImageRepeat? _backgroundRepeat;
  set backgroundRepeat(ImageRepeat? value) {
    if (value == _backgroundRepeat) return;
    _backgroundRepeat = value;
    renderBoxModel?.markNeedsPaint();
  }
}

class CSSColorStop {
  Color? color;
  double? stop;
  CSSColorStop(this.color, this.stop);
}

class CSSBackgroundImage {
  List<CSSFunctionalNotation> functions;
  RenderStyle renderStyle;
  KrakenController controller;
  CSSBackgroundImage(this.functions, this.renderStyle, this.controller);

  ImageProvider? get image {
    for (CSSFunctionalNotation method in functions) {
      if (method.name == 'url') {
        String url = method.args.isNotEmpty ? method.args[0] : '';
        if (url.isEmpty) {
          continue;
        }
        // Method may contain quotation mark, like ['"assets/foo.png"']
        url = _removeQuotationMark(url);

        Uri uri = Uri.parse(url);
        if (url.isNotEmpty) {
          uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri);
          return getImageProvider(uri, contextId: controller.view.contextId);
        }
      }
    }
  }
  Gradient? get gradient {
    List<Color> colors = [];
    List<double> stops = [];
    int start = 0;
    for (CSSFunctionalNotation method in functions) {
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
                  gradientLength = renderStyle.paddingBoxWidth;
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
                  gradientLength = renderStyle.paddingBoxHeight;
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
                  gradientLength = renderStyle.paddingBoxWidth;
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
                  gradientLength = renderStyle.paddingBoxHeight;
                  break;
              }
            }
            linearAngle = null;
            start = 1;
          } else if (CSSAngle.isAngle(arg0)) {
            linearAngle = CSSAngle.parseAngle(arg0);
            start = 1;
          }
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE, gradientLength);
          if (colors.length >= 2) {
            return CSSLinearGradient(
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
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE);
          if (colors.length >= 2) {
            return CSSRadialGradient(
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
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE);
          if (colors.length >= 2) {
            return CSSConicGradient(
                center: FractionalOffset(atX!, atY!),
                colors: colors,
                stops: stops,
                transform: GradientRotation(-math.pi / 2 + from!));
          }
          break;
      }
    }
  }
}

class CSSBackgroundPosition {
  CSSBackgroundPosition({
    this.length,
    this.percentage,
  });
  /// Absolute position to image container when length type is set.
  CSSLengthValue? length;
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
        CSSLength.isNonNegativeLength(value) ||
        CSSPercentage.isNonNegativePercentage(value);
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
    return value == CENTER ||
        value == LEFT ||
        value == RIGHT ||
        value == TOP ||
        value == BOTTOM ||
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
        if (values.length == 1 && values[0].isNotEmpty) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
          return CSSBackgroundSize(
            fit: BoxFit.none,
            width: width,
          );
        } else if (values.length == 2) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
          CSSLengthValue height = CSSLength.parseLength(values[1], renderStyle, propertyName, Axis.vertical);
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

  static resolveBackgroundImage(String present, RenderStyle renderStyle, String property, KrakenController controller) {
    List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(present);
    return CSSBackgroundImage(functions, renderStyle, controller);
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
}

void _applyColorAndStops(int start, List<String> args, List<Color?> colors, List<double?> stops, RenderStyle renderStyle, String propertyName, [double? gradientLength]) {
  // colors should more than one, otherwise invalid
  if (args.length - start - 1 > 0) {
    double grow = 1.0 / (args.length - start - 1);
    for (int i = start; i < args.length; i++) {
      List<CSSColorStop> colorGradients = _parseColorAndStop(args[i].trim(), renderStyle, propertyName, (i - start) * grow, gradientLength);
      for (var colorStop in colorGradients) {
        colors.add(colorStop.color);
        stops.add(colorStop.stop);
      }
    }
  }
}

List<CSSColorStop> _parseColorAndStop(String src, RenderStyle renderStyle, String propertyName, [double? defaultStop, double? gradientLength]) {
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
        for (int i = 1; i < strings.length; i++) {
          if (CSSPercentage.isPercentage(strings[i])) {
            stop = CSSPercentage.parsePercentage(strings[i]);
            // Negative percentage is invalid in gradients which will defaults to 0.
            if (stop! < 0) stop = 0;
          } else if (CSSAngle.isAngle(strings[i])) {
            stop = CSSAngle.parseAngle(strings[i])! / (math.pi * 2);
          } else if (CSSLength.isLength(strings[i])) {
            if (gradientLength != null) {
              stop = CSSLength.parseLength(strings[i], renderStyle, propertyName).computedValue / gradientLength;
            }
          }
          Color? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
          colorGradients.add(CSSColorStop(color, stop));
        }
      } catch (e) {}
    } else {
      Color? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
      colorGradients.add(CSSColorStop(color, stop));
    }
  }
  return colorGradients;
}
