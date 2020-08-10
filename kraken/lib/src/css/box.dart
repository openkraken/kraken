/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Model: https://drafts.csswg.org/css-box-4/
// CSS Backgrounds and Borders: https://drafts.csswg.org/css-backgrounds/

final RegExp _spaceRegExp = RegExp(r'\s+');

/// - background
/// - border
mixin CSSDecoratedBoxMixin on CSSBackgroundMixin {
  void initRenderDecoratedBox(RenderBoxModel renderBoxModel, CSSStyleDeclaration style) {
    renderBoxModel.oldDecoration = getCSSBoxDecoration(style);
    renderBoxModel.borderEdge = renderBoxModel.oldDecoration.getBorderEdgeInsets();
    renderBoxModel.decoration = renderBoxModel.oldDecoration.toBoxDecoration();
  }

  void updateRenderDecoratedBox(RenderBoxModel renderBoxModel, CSSStyleDeclaration style, Map<String, CSSTransition> transitionMap) {
    CSSBoxDecoration newDecoration = getCSSBoxDecoration(style);
    CSSBoxDecoration oldDecoration = renderBoxModel.oldDecoration;

    if (transitionMap != null) {
      CSSTransition backgroundColorTransition = getTransition(transitionMap, BACKGROUND_COLOR);
      // border color and width transition add inorder left top right bottom
      List<CSSTransition> borderColorTransitionsLTRB = [
        getTransition(transitionMap, 'border-left-color', parentProperty: 'border-color'),
        getTransition(transitionMap, 'border-top-color', parentProperty: 'border-color'),
        getTransition(transitionMap, 'border-right-color', parentProperty: 'border-color'),
        getTransition(transitionMap, 'border-bottom-color', parentProperty: 'border-color')
      ];
      List<CSSTransition> borderWidthTransitionsLTRB = [
        getTransition(transitionMap, 'border-left-width', parentProperty: 'border-width'),
        getTransition(transitionMap, 'border-top-width', parentProperty: 'border-width'),
        getTransition(transitionMap, 'border-right-width', parentProperty: 'border-width'),
        getTransition(transitionMap, 'border-bottom-width', parentProperty: 'border-width')
      ];

      // border radius transition add inorder topLeft topRight bottomLeft
      // bottomRight
      List<CSSTransition> borderRadiusTransitionTLTRBLBR = [
        getTransition(transitionMap, 'border-top-left-radius', parentProperty: 'border-radius'),
        getTransition(transitionMap, 'border-top-right-radius', parentProperty: 'border-radius'),
        getTransition(transitionMap, 'border-bottom-left-radius', parentProperty: 'border-radius'),
        getTransition(transitionMap, 'border-bottom-right-radius', parentProperty: 'border-radius')
      ];
      if (backgroundColorTransition != null ||
          borderWidthTransitionsLTRB.isNotEmpty ||
          borderColorTransitionsLTRB.isNotEmpty ||
          borderRadiusTransitionTLTRBLBR.isNotEmpty) {
        CSSBoxDecoration progressDecoration = oldDecoration.clone();
        CSSBoxDecoration baseDecoration = oldDecoration.clone();

        // background color transition
        addColorProcessListener(
            renderBoxModel,
            backgroundColorTransition,
            newDecoration.color,
            oldDecoration.color,
            progressDecoration.color,
            baseDecoration.color,
            progressDecoration);

        // side read inorder left top right bottom
        // radius read inorder topLeft topRight bottomLeft bottomRight
        for (int i = 0; i < 4; i++) {
          // add border color transition
          addColorProcessListener(
              renderBoxModel,
              borderColorTransitionsLTRB[i],
              newDecoration.borderSides[i].color,
              oldDecoration.borderSides[i].color,
              progressDecoration.borderSides[i].color,
              baseDecoration.borderSides[i].color,
              progressDecoration);

          addWidthAndRadiusProcessListener(renderBoxModel, borderWidthTransitionsLTRB[i], borderRadiusTransitionTLTRBLBR[i], i,
              newDecoration, oldDecoration, baseDecoration, progressDecoration);
        }
      } else {
        renderBoxModel.decoration = newDecoration.toBoxDecoration();
        _updateBorderInsets(renderBoxModel, newDecoration.getBorderEdgeInsets());
      }
    } else {
      renderBoxModel.decoration = newDecoration.toBoxDecoration();
      _updateBorderInsets(renderBoxModel, newDecoration.getBorderEdgeInsets());
    }
    renderBoxModel.oldDecoration = newDecoration;
  }

  // add color relate transition listener
  void addColorProcessListener(RenderBoxModel renderBoxModel, CSSTransition transition, Color newColor, Color oldColor, Color processColor,
      Color baseColor, CSSBoxDecoration processDecoration) {
    if (transition != null) {
      int alphaDiff = newColor.alpha - oldColor.alpha;
      int redDiff = newColor.red - oldColor.red;
      int greenDiff = newColor.green - oldColor.green;
      int blueDiff = newColor.blue - oldColor.blue;

      transition.addProgressListener((progress) {
        processDecoration.color = Color.fromARGB(
            (alphaDiff * progress).toInt() + baseColor.alpha,
            (redDiff * progress).toInt() + baseColor.red,
            (blueDiff * progress).toInt() + baseColor.blue,
            (greenDiff * progress).toInt() + baseColor.green);

        renderBoxModel.decoration = processDecoration.toBoxDecoration();
      });
    }
  }

  // add width and radius relate transition listener
  void addWidthAndRadiusProcessListener(
      RenderBoxModel renderBoxModel,
      CSSTransition widthTransition,
      CSSTransition radiusTransition,
      int index,
      CSSBoxDecoration newDecoration,
      CSSBoxDecoration oldDecoration,
      CSSBoxDecoration baseDecoration,
      CSSBoxDecoration processDecoration) {
    if (widthTransition != null) {
      double widthDiff = newDecoration.borderSides[index].width - oldDecoration.borderSides[index].width;

      widthTransition.addProgressListener((progress) {
        processDecoration.borderSides[index] = processDecoration.borderSides[index]
            .copyWith(width: widthDiff * progress + baseDecoration.borderSides[index].width);
        renderBoxModel.decoration = processDecoration.toBoxDecoration();
        _updateBorderInsets(renderBoxModel, processDecoration.getBorderEdgeInsets());
      });
    }

    if (radiusTransition != null) {
      Radius newRadius = newDecoration.radius[index];
      Radius oldRadius = oldDecoration.radius[index];
      Radius baseRadius = baseDecoration.radius[index];
      double radiusDiffX = newRadius.x - oldRadius.x;
      double radiusDiffY = newRadius.y - oldRadius.y;

      radiusTransition.addProgressListener((progress) {
        processDecoration.radius[index] =
            Radius.elliptical(radiusDiffX * progress + baseRadius.x, radiusDiffY * progress + baseRadius.y);
        renderBoxModel.decoration = processDecoration.toBoxDecoration();
      });
    }
  }

  CSSTransition getTransition(Map<String, CSSTransition> transitionMap, String property, {String parentProperty}) {
    if (transitionMap.containsKey(property)) {
      return transitionMap[property];
    } else if (parentProperty?.isNotEmpty != null && transitionMap.containsKey(parentProperty)) {
      return transitionMap[parentProperty];
    } else if (transitionMap.containsKey('all')) {
      return transitionMap['all'];
    }
    return null;
  }

  void _updateBorderInsets(RenderBoxModel renderBoxModel, EdgeInsets insets) {
    renderBoxModel.borderEdge = insets;
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>
  CSSBoxDecoration getCSSBoxDecoration(CSSStyleDeclaration style) {
    DecorationImage decorationImage;
    Gradient gradient;
    
    List<CSSFunctionalNotation> methods = CSSFunction(style[BACKGROUND_IMAGE]).computedValue;
    for (CSSFunctionalNotation method in methods) {
      if (method.name == 'url') {
        decorationImage = CSSBackground.getDecorationImage(style, method);
      } else {
        gradient = CSSBackground.getBackgroundGradient(method);
      }
    }

    Color bgColor = CSSBackground.getBackgroundColor(style) ?? CSSColor.transparent;

    BorderSide leftSide = CSSBorder.getBorderSide(style, CSSBorder.LEFT);
    BorderSide topSide = CSSBorder.getBorderSide(style, CSSBorder.TOP);
    BorderSide rightSide = CSSBorder.getBorderSide(style, CSSBorder.RIGHT);
    BorderSide bottomSide = CSSBorder.getBorderSide(style, CSSBorder.BOTTOM);

    // border radius add inorder topLeft topRight bottomLeft bottomRight
    Radius topLeftRadius = CSSBorder.getRadius(style[BORDER_TOP_LEFT_RADIUS]);
    Radius topRightRadius = CSSBorder.getRadius(style[BORDER_TOP_RIGHT_RADIUS]);
    Radius bottomRightRadius = CSSBorder.getRadius(style[BORDER_BOTTOM_RIGHT_RADIUS]);
    Radius bottomLeftRadius = CSSBorder.getRadius(style[BORDER_BOTTOM_LEFT_RADIUS]);

    return CSSBoxDecoration(bgColor, decorationImage, gradient, [leftSide, topSide, rightSide, bottomSide],
        [topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius], getBoxShadow(style));
  }

  /// Tip: inset not supported.
  List<BoxShadow> getBoxShadow(CSSStyleDeclaration style) {
    List<BoxShadow> boxShadow = [];
    if (style.contains(BOX_SHADOW)) {
      var shadows = CSSStyleProperty.getShadowValues(style[BOX_SHADOW]);
      if (shadows != null) {
        shadows.forEach((shadowDefinitions) {
          // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
          Color color = CSSColor.parseColor(shadowDefinitions[0] ?? style[COLOR]);
          double offsetX = CSSLength.toDisplayPortValue(shadowDefinitions[1]) ?? 0;
          double offsetY = CSSLength.toDisplayPortValue(shadowDefinitions[2]) ?? 0;
          double blurRadius = CSSLength.toDisplayPortValue(shadowDefinitions[3]) ?? 0;
          double spreadRadius = CSSLength.toDisplayPortValue(shadowDefinitions[4]) ?? 0;

          if (color != null) {
            boxShadow.add(BoxShadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              color: color,
            ));
          }
        });
      }

      // Tips only debug.
      if (!PRODUCTION && boxShadow.isEmpty) {
        print('[Warning] Wrong style format with boxShadow: ${style[BOX_SHADOW]}');
        print('    Correct syntax: inset? && <length>{2,4} && <color>?');
      }
    }

    return boxShadow;
  }
}

class CSSBorder {
  // border default width 3.0
  static double defaultBorderWidth = 3.0;
  static BorderStyle defaultBorderStyle = BorderStyle.none;
  static Color defaultBorderColor = CSSColor.initial;
  static String LEFT = 'Left';
  static String RIGHT = 'Right';
  static String TOP = 'Top';
  static String BOTTOM = 'Bottom';

  static double getBorderWidth(String input) {
    // https://drafts.csswg.org/css2/#border-width-properties
    // The interpretation of the first three values depends on the user agent.
    // The following relationships must hold, however:
    // thin ≤ medium ≤ thick.
    double borderWidth;
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
        borderWidth = CSSLength.toDisplayPortValue(input);
    }
    return borderWidth;
  }

  static BorderStyle getBorderStyle(String input) {
    BorderStyle borderStyle;
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

  static bool isValidBorderStyleValue(String value) {
    return value == SOLID || value == NONE;
  }

  static bool isValidBorderWidthValue(String value) {
    return CSSLength.isLength(value) || value == THIN || value == MEDIUM || value == THICK;
  }

  static double getBorderSideWidth(CSSStyleDeclaration style, String side) {
    String property = 'border${side}Width';
    String value = style[property];
    return value.isEmpty ? defaultBorderWidth : getBorderWidth(value);
  }

  static Color getBorderSideColor(CSSStyleDeclaration style, String side) {
    String property = 'border${side}Color';
    String value = style[property];
    return value.isEmpty ? defaultBorderColor : CSSColor.parseColor(value);
  }

  static BorderStyle getBorderSideStyle(CSSStyleDeclaration style, String side) {
    String property = 'border${side}Style';
    String value = style[property];
    return value.isEmpty ? defaultBorderStyle : getBorderStyle(value);
  }

  static getBorderEdgeInsets(CSSStyleDeclaration style) {
    double left = 0.0;
    double top = 0.0;
    double bottom = 0.0;
    double right = 0.0;

    if (style[BORDER_LEFT_STYLE].isNotEmpty && style[BORDER_LEFT_STYLE] != NONE) {
      left = getBorderWidth(style[BORDER_LEFT_WIDTH]) ?? defaultBorderWidth;
    }

    if (style[BORDER_TOP_STYLE].isNotEmpty && style[BORDER_TOP_STYLE] != NONE) {
      top = getBorderWidth(style[BORDER_TOP_WIDTH]) ?? defaultBorderWidth;
    }

    if (style[BORDER_RIGHT_STYLE].isNotEmpty && style[BORDER_RIGHT_STYLE] != NONE) {
      right = getBorderWidth(style[BORDER_RIGHT_WIDTH]) ?? defaultBorderWidth;
    }

    if (style[BORDER_BOTTOM_STYLE].isNotEmpty && style[BORDER_BOTTOM_STYLE] != NONE) {
      bottom = getBorderWidth(style[BORDER_BOTTOM_WIDTH]) ?? defaultBorderWidth;
    }

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  static BorderSide _noneBorderSide = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide getBorderSide(CSSStyleDeclaration style, String side) {
    BorderStyle borderStyle = getBorderSideStyle(style, side);
    double width = getBorderSideWidth(style, side);
    // Flutter will print border event if width is 0.0. So we needs to set borderStyle to none to prevent this.
    if (borderStyle == BorderStyle.none || width == 0.0) {
      return _noneBorderSide;
    } else {
      return BorderSide(
          color: getBorderSideColor(style, side), width: getBorderSideWidth(style, side), style: borderStyle);
    }
  }

  static Radius getRadius(String radius) {
    if (radius.isNotEmpty) {
      // border-top-left-radius: horizontal vertical
      List<String> values = radius.split(_spaceRegExp);

      if (values.length == 1) {
        double circular = CSSLength.toDisplayPortValue(values[0]);
        if (circular != null) return Radius.circular(circular);
      } else if (values.length == 2) {
        double x = CSSLength.toDisplayPortValue(values[0]);
        double y = CSSLength.toDisplayPortValue(values[1]);
        if (x != null && y != null) return Radius.elliptical(x, y);
      }
    }

    return Radius.zero;
  }
}

class CSSBoxDecoration {
  Color color;
  DecorationImage image;
  Gradient gradient;
  // radius inorder topLeft topRight bottomLeft bottomRight
  List<Radius> radius;
  // side inorder left top right bottom
  List<BorderSide> borderSides;
  List<BoxShadow> boxShadow;

  CSSBoxDecoration(this.color, this.image, this.gradient, this.borderSides, this.radius, this.boxShadow);

  CSSBoxDecoration clone() {
    return CSSBoxDecoration(
        color,
        image,
        gradient,
        // side read inorder left top right bottom
        List.of(borderSides),
        // radius read inorder topLeft topRight bottomLeft bottomRight
        List.of(radius),
        List.of(boxShadow));
  }

  BoxDecoration toBoxDecoration() {
    if (gradient != null) {
      color = null;
    }
    // side read inorder left top right bottom
    Border border = Border(left: borderSides[0], top: borderSides[1], right: borderSides[2], bottom: borderSides[3]);

    BorderRadius borderRadius;
    // flutter border limit, when border is not uniform, should set borderRadius
    if (border.isUniform) {
      // radius read inorder topLeft topRight bottomLeft bottomRight
      borderRadius = BorderRadius.only(
        topLeft: radius[0],
        topRight: radius[1],
        bottomRight: radius[2],
        bottomLeft: radius[3],
      );
    }

    return BoxDecoration(
        color: color,
        image: image,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient);
  }

  EdgeInsets getBorderEdgeInsets() {
    // side read inorder left top right bottom
    return EdgeInsets.fromLTRB(borderSides[0].width, borderSides[1].width, borderSides[2].width, borderSides[3].width);
  }
}
