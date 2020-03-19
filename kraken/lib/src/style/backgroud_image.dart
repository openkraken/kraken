/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin BackgroundImageMixin on Node {

  double linearAngle;

  bool shouldInitBackgroundImage(StyleDeclaration style) {
    return style['backgroundAttachment'] == 'local' &&
        style.contains('backgroundImage');
  }

  RenderObject initBackgroundImage(
    RenderObject renderObject,
    StyleDeclaration style,
    int nodeId
  ) {
    DecorationImage decorationImage;
    Gradient gradient;

    if (style.contains('backgroundImage')) {
      List<Method> methods = Method.parseMethod(style['backgroundImage']);
      //FIXME flutter just support one property
      for (Method method in methods) {
        if (method.name == 'url') {
          String url = method.args.length > 0 ? method.args[0] : '';
          if (url != null && url.isNotEmpty) {
            decorationImage = getBackgroundImage(url, style);
          }
        } else {
          gradient = getBackgroundGradient(method, style);
        }
      }
    }

    return RenderGradient(
        nodeId: nodeId,
        decoration: BoxDecoration(image: decorationImage, gradient: gradient),
        child: renderObject);
  }

  DecorationImage getBackgroundImage(String url, StyleDeclaration style) {
    DecorationImage backgroundImage = null;
    if (style.contains('backgroundImage')) {
      ImageRepeat imageRepeat = ImageRepeat.noRepeat;
      if (style.contains('backgroundRepeat')) {
        switch (style['backgroundRepeat']) {
          case 'repeat-x':
            imageRepeat = ImageRepeat.repeatX;
            break;
          case 'repeat-y':
            imageRepeat = ImageRepeat.repeatY;
            break;
          case 'repeat':
            imageRepeat = ImageRepeat.repeat;
            break;
        }
      }
      Position position =
          Position(style['backgroundPosition'], window.physicalSize);
      BoxFit boxFit = BoxFit.none;
      if (style.contains('backgroundSize')) {
        switch (style['backgroundSize']) {
          case 'cover':
            boxFit = BoxFit.cover;
            break;
          case 'contain':
            boxFit = BoxFit.contain;
            break;
          case 'fill':
            boxFit = BoxFit.fill;
            break;
          case 'fitWidth':
            boxFit = BoxFit.fitWidth;
            break;
          case 'fitHeight':
            boxFit = BoxFit.fitHeight;
            break;
          case 'scaleDown':
            boxFit = BoxFit.scaleDown;
            break;
        }
      }
      backgroundImage = DecorationImage(
          image: NetworkImage(url),
          repeat: imageRepeat,
          alignment: position.alignment,
          fit: boxFit);
    }
    return backgroundImage;
  }

  Gradient getBackgroundGradient(Method method, StyleDeclaration style) {
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
          } else if (Angle.isAngle(method.args[0])) {
            Angle angle = Angle(method.args[0]);
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
        //TODO just support circle radial
        case 'radial-gradient':
        case 'repeating-radial-gradient':
          double atX = 0.5;
          double atY = 0.5;
          double radius = 0.5;

          if (method.args[0].contains(PERCENTAGE)) {
            List<String> positionAndRadius = method.args[0].trim().split(' ');
            if (positionAndRadius.length >= 1) {
              if (Percentage.isPercentage(positionAndRadius[0])) {
                radius = Percentage(positionAndRadius[0]).toDouble() * 0.5;
                start = 1;
              }
              if (positionAndRadius.length > 2 &&
                  positionAndRadius[1] == 'at') {
                start = 1;
                if (Percentage.isPercentage(positionAndRadius[2])) {
                  atX = Percentage(positionAndRadius[2]).toDouble();
                }
                if (positionAndRadius.length == 4 &&
                    Percentage.isPercentage(positionAndRadius[3])) {
                  atY = Percentage(positionAndRadius[3]).toDouble();
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
              from = Angle(fromAt[fromIndex + 1]).angleValue;
            }
            if (atIndex != -1) {
              if (atIndex + 1 < fromAt.length &&
                  Percentage.isPercentage(fromAt[atIndex + 1])) {
                atX = Percentage(fromAt[atIndex + 1]).toDouble();
              }
              if (atIndex + 2 < fromAt.length &&
                  Percentage.isPercentage(fromAt[atIndex + 2])) {
                atY = Percentage(fromAt[atIndex + 2]).toDouble();
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

  void applyColorAndStops(
      int start, List<String> args, List<Color> colors, List<double> stops) {
    double grow = 1.0 / (args.length - 1);
    for (int i = start; i < args.length; i++) {
      ColorGradient colorGradient = parseColorAndStop(args[i], i * grow);
      colors.add(colorGradient.color);
      stops.add(colorGradient.stop);
    }
  }

  ColorGradient parseColorAndStop(String src, [double defaultStop]) {
    List<String> strings = src?.trim()?.split(" ");
    ColorGradient colorGradient;
    if (strings != null && strings.length >= 1) {
      double stop = defaultStop;
      if (strings.length == 2) {
        try {
          if (Percentage.isPercentage(strings[1])) {
            stop = Percentage(strings[1]).toDouble();
          } else if (Angle.isAngle(strings[1])) {
            stop = Angle(strings[1]).angleValue / (math.pi * 2);
          }
        } catch (e) {}
      }
      colorGradient = ColorGradient(WebColor.generate(strings[0]), stop);
    }
    return colorGradient;
  }
}

class ColorGradient {
  Color color;
  double stop;
  ColorGradient(this.color, this.stop);
}
