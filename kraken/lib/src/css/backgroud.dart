/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Backgrounds: https://drafts.csswg.org/css-backgrounds/
// CSS Images: https://drafts.csswg.org/css-images-3/
typedef ConsumeProperty = bool Function(String src);

const String BACKGROUND_POSITION_AND_SIZE = 'backgroundPositionAndSize';

/// The [CSSBackgroundMixin] mixin used to handle background shorthand and compute
/// to single value of background
mixin CSSBackgroundMixin {
  // Default property.
  Map<String, String> background = {
    BACKGROUND_REPEAT: 'repeat',
    BACKGROUND_ATTACHMENT: 'scroll',
    BACKGROUND_POSITION: 'left top',
    BACKGROUND_IMAGE: '',
    BACKGROUND_SIZE: 'auto',
    BACKGROUND_COLOR: 'transparent'
  };

  RenderDecorateElementBox _renderDecorateElementBox;

  double linearAngle;

  void _parseBackground(CSSStyleDeclaration style) {
    if (style.contains(BACKGROUND)) {
      List<String> shorthand = style[BACKGROUND].split(' ');
      background = _consumeBackground(shorthand);
    }
    if (style.contains(BACKGROUND_ATTACHMENT)) {
      background[BACKGROUND_ATTACHMENT] = style[BACKGROUND_ATTACHMENT];
    }
    if (style.contains(BACKGROUND_REPEAT)) {
      background[BACKGROUND_REPEAT] = style[BACKGROUND_REPEAT];
    }
    if (style.contains(BACKGROUND_SIZE)) {
      background[BACKGROUND_SIZE] = style[BACKGROUND_SIZE];
    }
    if (style.contains(BACKGROUND_POSITION)) {
      background[BACKGROUND_POSITION] = style[BACKGROUND_POSITION];
    }
    if (style.contains(BACKGROUND_COLOR)) {
      background[BACKGROUND_COLOR] = style[BACKGROUND_COLOR];
    }
    if (style.contains(BACKGROUND_IMAGE)) {
      background[BACKGROUND_IMAGE] = style[BACKGROUND_IMAGE];
    }
  }

  void _setBackgroundProperty(String property, String value) {
    if (property == 'background') {
      List<String> shorthand = value.split(' ');
      background = _consumeBackground(shorthand);
    } else {
      background[property] = value;
    }
  }

  Map<String, String> _consumeBackground(List<String> shorthand) {
    int longhandCount = shorthand.length;
    Map<String, ConsumeProperty> propertyMap = {
      BACKGROUND_IMAGE: _consumeBackgroundImage,
      BACKGROUND_REPEAT: _consumeBackgroundRepeat,
      BACKGROUND_ATTACHMENT: _consumeBackgroundAttachment,
      BACKGROUND_POSITION_AND_SIZE: _consumeBackgroundPosition
    };
    // default property
    Map<String, String> background = {
      BACKGROUND_REPEAT: 'repeat',
      BACKGROUND_ATTACHMENT: 'scroll',
      BACKGROUND_POSITION: 'left top',
      BACKGROUND_IMAGE: '',
      BACKGROUND_SIZE: 'auto',
      BACKGROUND_COLOR: 'transparent'
    };
    bool broken = false;
    for (int i = 0; i < longhandCount; i++) {
      if (broken) {
        break;
      }
      String property = shorthand[i].trim();
      Iterable<String> keys = propertyMap.keys;
      // record the consumed property
      String consumedKey;
      for (String key in keys) {
        // The value of background image is function, may be contain space,
        // should begin with left parenthesis and end with right parenthesis.
        if (key == BACKGROUND_IMAGE && _consumeBackgroundImage(property)) {
          consumedKey = key;
          String backgroundImage = property;
          while (i + 1 < longhandCount &&
            !_consumeBackgroundImageEnd(shorthand[i + 1])) {
            backgroundImage = backgroundImage + ' ' + shorthand[++i];
          }
          if (i + 1 < longhandCount &&
            _consumeBackgroundImageEnd(shorthand[i + 1])) {
            backgroundImage =
              backgroundImage + ' ' + shorthand[++i];
          }
          background[BACKGROUND_IMAGE] = backgroundImage;

        // position may be more than one(at most four), should special handle
        // size is follow position and split by /
        } else if (key == BACKGROUND_POSITION_AND_SIZE) {
          if (property != '/' && property.contains('/')) {
            int index = property.indexOf('/');
            String position = property.substring(0, index);
            if (_consumeBackgroundPosition(position)) {
              background[BACKGROUND_POSITION] = position;
              String size = property.substring(index + 1);
              if (_consumeBackgroundSize(size)) {
                // size at most two value
                if (i + 1 < longhandCount &&
                    _consumeBackgroundSize(shorthand[i + 1].trim())) {
                  size = size + ' ' + shorthand[i + 1].trim();
                  i++;
                }
                background[BACKGROUND_SIZE] = size;
              } else {
                broken = true;
                break;
              }
              consumedKey = key;
            } else {
              broken = true;
              break;
            }
          } else if (_consumeBackgroundPosition(property)) {
            String position = property;
            String size;
            bool hasSize = false;
            // position at most four value
            for (int j = 1; j <= 4; j++) {
              if (i + j < longhandCount) {
                String temp = shorthand[i + j].trim();
                if (temp == '/') {
                  i = i + j;
                  hasSize = true;
                  break;
                } else if (temp.contains('/')) {
                  i = i + j;
                  hasSize = true;
                  int index = temp.indexOf('/');
                  String positionTemp = temp.substring(0, index);
                  if (_consumeBackgroundPosition(positionTemp)) {
                    background[BACKGROUND_POSITION] = position;
                    size = property.substring(index + 1);
                    if (!_consumeBackgroundSize(size)) {
                      broken = true;
                    }
                  } else {
                    broken = true;
                  }
                  break;
                } else if (_consumeBackgroundPosition(temp)) {
                  position = position + ' ' + temp;
                } else {
                  i = i + j - 1;
                  break;
                }
              } else {
                break;
              }
            }
            // handle size when / follow, at most two value
            if (hasSize) {
              if (i + 1 < longhandCount) {
                String nextSize = shorthand[i + 1].trim();
                if (size == null) {
                  size = nextSize;
                  if (_consumeBackgroundSize(size)) {
                    i++;
                    if (i + 1 < longhandCount) {
                      if (_consumeBackgroundSize(shorthand[i + 1].trim())) {
                        size = size + ' ' + shorthand[i + 1].trim();
                        i++;
                      }
                    }
                    background[BACKGROUND_SIZE] = size;
                  } else {
                    broken = true;
                    break;
                  }
                } else if (_consumeBackgroundSize(nextSize)) {
                  size = size + ' ' + nextSize;
                  background[BACKGROUND_SIZE] = size;
                } else {
                  broken = true;
                  break;
                }
              } else {
                broken = true;
                break;
              }
            }
            consumedKey = key;
            break;
          }
        } else if (propertyMap[key](property)) {
          background[key] = property;
          consumedKey = key;
          break;
        }
      }
      // consumed the property when find
      if (consumedKey != null) {
        propertyMap.remove(consumedKey);
      } else if (i == longhandCount - 1) {
        background[BACKGROUND_COLOR] = property;
      }
    }
    return background;
  }

  bool _consumeBackgroundRepeat(String src) {
    return 'repeat-x' == src ||
        'repeat-y' == src ||
        'repeat' == src ||
        'no-repeat' == src;
  }

  bool _consumeBackgroundAttachment(String src) {
    return 'fixed' == src || 'scroll' == src || 'local' == src;
  }

  bool _consumeBackgroundImage(String src) {
    return src.startsWith('url(') ||
        src.startsWith('linear-gradient(') ||
        src.startsWith('repeating-linear-gradient(') ||
        src.startsWith('radial-gradient(') ||
        src.startsWith('repeating-radial-gradient(') ||
        src.startsWith('conic-gradient(');
  }

  bool _consumeBackgroundImageEnd(String src) {
    return src.endsWith(')');
  }

  bool _consumeBackgroundPosition(String src) {
    return src == 'center' ||
        src == 'left' ||
        src == 'right' ||
        CSSLength.isLength(src) ||
        CSSPercentage.isPercentage(src) ||
        src == 'top' ||
        src == 'bottom';
  }

  bool _consumeBackgroundSize(String src) {
    return src == 'auto' ||
        src == 'contain' ||
        src == 'cover' ||
        src == 'fit-width' ||
        src == 'fit-height' ||
        src == 'scale-down' ||
        src == 'fill' ||
        CSSLength.isLength(src) ||
        CSSPercentage.isPercentage(src);
  }

  bool _shouldRenderBackgroundImage() {
    return background[BACKGROUND_ATTACHMENT] == 'local' &&
        background.containsKey(BACKGROUND_IMAGE);
  }

  RenderObject initBackground(
      RenderObject renderObject, CSSStyleDeclaration style, int targetId) {
    _parseBackground(style);
    if (!_shouldRenderBackgroundImage()) return renderObject;
    DecorationImage decorationImage;
    Gradient gradient;

    if (background.containsKey(BACKGROUND_IMAGE)) {
      List<CSSFunctionalNotation> methods =
          CSSFunction(background[BACKGROUND_IMAGE]).computedValue;
      // FIXME flutter just support one property
      for (CSSFunctionalNotation method in methods) {
        if (method.name == 'url') {
          String url = method.args.length > 0 ? method.args[0] : '';
          if (url != null && url.isNotEmpty) {
            decorationImage = getBackgroundImage(url);
            if (decorationImage != null) {
              return _renderDecorateElementBox = RenderDecorateElementBox(
                  targetId: targetId,
                  decoration:
                      BoxDecoration(image: decorationImage, gradient: gradient),
                  child: renderObject);
            }
          }
        } else {
          gradient = getBackgroundGradient(method);
          if (gradient != null) {
            return _renderDecorateElementBox = RenderDecorateElementBox(
                targetId: targetId,
                decoration:
                    BoxDecoration(image: decorationImage, gradient: gradient),
                child: renderObject);
          }
        }
      }
    }

    return renderObject;
  }

  void updateBackground(String property, String value,
      RenderObjectWithChildMixin parent, int targetId) {
    _setBackgroundProperty(property, value);
    if (!_shouldRenderBackgroundImage()) return;

    DecorationImage decorationImage;
    Gradient gradient;
    if (background.containsKey(BACKGROUND_IMAGE)) {
      List<CSSFunctionalNotation> methods =
          CSSFunction(background[BACKGROUND_IMAGE]).computedValue;
      //FIXME flutter just support one property
      for (CSSFunctionalNotation method in methods) {
        if (method.name == 'url') {
          String url = method.args.length > 0 ? method.args[0] : '';
          if (url != null && url.isNotEmpty) {
            decorationImage = getBackgroundImage(url);
            if (decorationImage != null) {
              _updateRenderGradient(
                  decorationImage, gradient, parent, targetId);
              return;
            }
          }
        } else {
          gradient = getBackgroundGradient(method);
          if (gradient != null) {
            _updateRenderGradient(decorationImage, gradient, parent, targetId);
            return;
          }
        }
      }
    }
  }

  void _updateRenderGradient(DecorationImage decorationImage, Gradient gradient,
      RenderObjectWithChildMixin parent, int targetId) {
    if (_renderDecorateElementBox != null) {
      _renderDecorateElementBox.decoration =
          BoxDecoration(image: decorationImage, gradient: gradient);
    } else {
      RenderObject child = parent.child;
      parent.child = null;
      _renderDecorateElementBox = RenderDecorateElementBox(
          targetId: targetId,
          decoration: BoxDecoration(image: decorationImage, gradient: gradient),
          child: child);
      parent.child = _renderDecorateElementBox;
    }
  }

  DecorationImage getBackgroundImage(String url) {
    DecorationImage backgroundImage = null;
    if (background.containsKey(BACKGROUND_REPEAT)) {
      // default repeat
      ImageRepeat imageRepeat = ImageRepeat.repeat;
      if (background.containsKey(BACKGROUND_REPEAT)) {
        switch (background[BACKGROUND_REPEAT]) {
          case 'repeat-x':
            imageRepeat = ImageRepeat.repeatX;
            break;
          case 'repeat-y':
            imageRepeat = ImageRepeat.repeatY;
            break;
          case 'no-repeat':
            imageRepeat = ImageRepeat.noRepeat;
            break;
        }
      }
      CSSPosition position = CSSPosition(background[BACKGROUND_POSITION]);
      // size default auto equals none
      BoxFit boxFit = BoxFit.none;
      if (background.containsKey(BACKGROUND_SIZE)) {
        switch (background[BACKGROUND_SIZE]) {
          case 'cover':
            boxFit = BoxFit.cover;
            break;
          case 'contain':
            boxFit = BoxFit.contain;
            break;
          case 'fill':
            boxFit = BoxFit.fill;
            break;
          case 'fit-width':
            boxFit = BoxFit.fitWidth;
            break;
          case 'fit-height':
            boxFit = BoxFit.fitHeight;
            break;
          case 'scale-down':
            boxFit = BoxFit.scaleDown;
            break;
        }
      }
      backgroundImage = DecorationImage(
          image: CSSUrl(url).computedValue,
          repeat: imageRepeat,
          alignment: position.computedValue,
          fit: boxFit);
    }
    return backgroundImage;
  }

  Gradient getBackgroundGradient(CSSFunctionalNotation method) {
    Gradient gradient;
    if (method.args.length > 1) {
      List<Color> colors = [];
      List<double> stops = [];
      int start = 0;
      switch (method.name) {
        case 'linear-gradient':
        case 'repeating-linear-gradient':
          Alignment begin = Alignment.topCenter, end = Alignment.bottomCenter;
          if (method.args[0].startsWith('to ')) {
            List<String> toString = method.args[0].trim().split(' ');
            if (toString.length >= 2) {
              switch (toString[1]) {
                case 'left':
                  if (toString.length == 3) {
                    if (toString[2] == 'top') {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (toString[2] == 'bottom') {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    }
                  } else {
                    begin = Alignment.centerRight;
                    end = Alignment.centerLeft;
                  }
                  break;
                case 'top':
                  if (toString.length == 3) {
                    if (toString[2] == 'left') {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (toString[2] == 'right') {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    }
                  } else {
                    begin = Alignment.bottomCenter;
                    end = Alignment.topCenter;
                  }
                  break;
                case 'right':
                  if (toString.length == 3) {
                    if (toString[2] == 'top') {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    } else if (toString[2] == 'bottom') {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.centerLeft;
                    end = Alignment.centerRight;
                  }
                  break;
                case 'bottom':
                  if (toString.length == 3) {
                    if (toString[2] == 'left') {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    } else if (toString[2] == 'right') {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.topCenter;
                    end = Alignment.bottomCenter;
                  }
                  break;
              }
            }
            start = 1;
          } else if (CSSAngle.isAngle(method.args[0])) {
            CSSAngle angle = CSSAngle(method.args[0]);
            linearAngle = angle.angleValue;
            start = 1;
          }
          applyColorAndStops(start, method.args, colors, stops);
          if (colors.length >= 2) {
            gradient = LinearGradient(
                begin: begin,
                end: end,
                colors: colors,
                stops: stops,
                tileMode: method.name == 'linear-gradient'
                    ? TileMode.clamp
                    : TileMode.repeated);
          }
          break;
        // @TODO just support circle radial
        case 'radial-gradient':
        case 'repeating-radial-gradient':
          double atX = 0.5;
          double atY = 0.5;
          double radius = 0.5;

          if (method.args[0].contains(PERCENTAGE)) {
            List<String> positionAndRadius = method.args[0].trim().split(' ');
            if (positionAndRadius.length >= 1) {
              if (CSSPercentage.isPercentage(positionAndRadius[0])) {
                radius = CSSPercentage(positionAndRadius[0]).toDouble() * 0.5;
                start = 1;
              }
              if (positionAndRadius.length > 2 &&
                  positionAndRadius[1] == 'at') {
                start = 1;
                if (CSSPercentage.isPercentage(positionAndRadius[2])) {
                  atX = CSSPercentage(positionAndRadius[2]).toDouble();
                }
                if (positionAndRadius.length == 4 &&
                    CSSPercentage.isPercentage(positionAndRadius[3])) {
                  atY = CSSPercentage(positionAndRadius[3]).toDouble();
                }
              }
            }
          }
          applyColorAndStops(start, method.args, colors, stops);
          if (colors.length >= 2) {
            gradient = RadialGradient(
              center: FractionalOffset(atX, atY),
              radius: radius,
              colors: colors,
              stops: stops,
              tileMode: method.name == 'radial-gradient'
                  ? TileMode.clamp
                  : TileMode.repeated,
            );
          }
          break;
        case 'conic-gradient':
          double from = 0.0;
          double atX = 0.5;
          double atY = 0.5;
          if (method.args[0].contains('from ') ||
              method.args[0].contains('at ')) {
            List<String> fromAt = method.args[0].trim().split(' ');
            int fromIndex = fromAt.indexOf('from');
            int atIndex = fromAt.indexOf('at');
            if (fromIndex != -1 && fromIndex + 1 < fromAt.length) {
              from = CSSAngle(fromAt[fromIndex + 1]).angleValue;
            }
            if (atIndex != -1) {
              if (atIndex + 1 < fromAt.length &&
                  CSSPercentage.isPercentage(fromAt[atIndex + 1])) {
                atX = CSSPercentage(fromAt[atIndex + 1]).toDouble();
              }
              if (atIndex + 2 < fromAt.length &&
                  CSSPercentage.isPercentage(fromAt[atIndex + 2])) {
                atY = CSSPercentage(fromAt[atIndex + 2]).toDouble();
              }
            }
            start = 1;
          }
          applyColorAndStops(start, method.args, colors, stops);
          if (colors.length >= 2) {
            gradient = SweepGradient(
                center: FractionalOffset(atX, atY),
                colors: colors,
                stops: stops,
                transform: GradientRotation(-math.pi / 2 + from));
          }
          break;
      }
    }

    return gradient;
  }

  Color getBackgroundColor(CSSStyleDeclaration style) {
    Color backgroundColor = CSSColor.transparent;
    if (background.containsKey(BACKGROUND_COLOR)) {
      backgroundColor = CSSColor.generate(background[BACKGROUND_COLOR]);
    }
    return backgroundColor;
  }

  void applyColorAndStops(
      int start, List<String> args, List<Color> colors, List<double> stops) {
    double grow = 1.0 / (args.length - 1);
    for (int i = start; i < args.length; i++) {
      CSSColorStop colorGradient = parseColorAndStop(args[i], i * grow);
      colors.add(colorGradient.color);
      stops.add(colorGradient.stop);
    }
  }

  CSSColorStop parseColorAndStop(String src, [double defaultStop]) {
    List<String> strings = src?.trim()?.split(" ");
    CSSColorStop colorGradient;
    if (strings != null && strings.length >= 1) {
      double stop = defaultStop;
      if (strings.length == 2) {
        try {
          if (CSSPercentage.isPercentage(strings[1])) {
            stop = CSSPercentage(strings[1]).toDouble();
          } else if (CSSAngle.isAngle(strings[1])) {
            stop = CSSAngle(strings[1]).angleValue / (math.pi * 2);
          }
        } catch (e) {}
      }
      colorGradient = CSSColorStop(CSSColor.generate(strings[0]), stop);
    }
    return colorGradient;
  }
}

class CSSColorStop {
  Color color;
  double stop;
  CSSColorStop(this.color, this.stop);
}
