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

/// - background
/// - border
mixin CSSDecoratedBoxMixin on CSSBackgroundMixin {
  RenderDecorateElementBox renderDecoratedBox;
  TransitionDecoration oldDecoration;
  CSSEdgeInsets oldBorderPadding;

  RenderObject initRenderDecoratedBox(RenderObject renderObject, CSSStyleDeclaration style, int targetId) {
    oldDecoration = getTransitionDecoration(style);
    EdgeInsets borderEdge = oldDecoration.getBorderEdgeInsets();

    return renderDecoratedBox = RenderDecorateElementBox(
      borderEdge: borderEdge,
      decoration: oldDecoration.toBoxDecoration(),
      child: renderObject,
    );
  }

  void updateRenderDecoratedBox(CSSStyleDeclaration style, Map<String, CSSTransition> transitionMap) {
    TransitionDecoration newDecoration = getTransitionDecoration(style);
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
        TransitionDecoration progressDecoration = oldDecoration.clone();
        TransitionDecoration baseDecoration = oldDecoration.clone();

        // background color transition
        addColorProcessListener(
          backgroundColorTransition,
          newDecoration.color,
          oldDecoration.color,
          progressDecoration.color,
          baseDecoration.color,
          progressDecoration
        );

        // side read inorder left top right bottom
        // radius read inorder topLeft topRight bottomLeft bottomRight
        for (int i = 0; i < 4; i++) {
          // add border color transition
          addColorProcessListener(
            borderColorTransitionsLTRB[i],
            newDecoration.borderSidesLTRB[i].color,
            oldDecoration.borderSidesLTRB[i].color,
            progressDecoration.borderSidesLTRB[i].color,
            baseDecoration.borderSidesLTRB[i].color,
            progressDecoration
          );

          addWidthAndRadiusProcessListener(borderWidthTransitionsLTRB[i], borderRadiusTransitionTLTRBLBR[i], i,
              newDecoration, oldDecoration, baseDecoration, progressDecoration);
        }
      } else {
        renderDecoratedBox.decoration = newDecoration.toBoxDecoration();
        _updateBorderInsets(newDecoration.getBorderEdgeInsets());
      }
    } else {
      renderDecoratedBox.decoration = newDecoration.toBoxDecoration();
      _updateBorderInsets(newDecoration.getBorderEdgeInsets());
    }
    oldDecoration = newDecoration;
  }

  // add color relate transition listener
  void addColorProcessListener(CSSTransition transition, Color newColor, Color oldColor,
      Color processColor, Color baseColor, TransitionDecoration processDecoration) {
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
          (greenDiff * progress).toInt() + baseColor.green
        );

        renderDecoratedBox.decoration = processDecoration.toBoxDecoration();
      });
    }
  }

  // add width and radius relate transition listener
  void addWidthAndRadiusProcessListener(
      CSSTransition widthTransition,
      CSSTransition radiusTransition,
      int index,
      TransitionDecoration newDecoration,
      TransitionDecoration oldDecoration,
      TransitionDecoration baseDecoration,
      TransitionDecoration processDecoration) {
    if (widthTransition != null) {
      double widthDiff = newDecoration.borderSidesLTRB[index].width - oldDecoration.borderSidesLTRB[index].width;
      widthTransition.addProgressListener((progress) {
        processDecoration.borderSidesLTRB[index] = processDecoration.borderSidesLTRB[index].copyWith(width: widthDiff * progress + baseDecoration.borderSidesLTRB[index].width);
        renderDecoratedBox.decoration = processDecoration.toBoxDecoration();
        _updateBorderInsets(processDecoration.getBorderEdgeInsets());
      });
    }

    if (radiusTransition != null) {
      double radiusDiff = newDecoration.borderRadiusTLTRBLBR[index] - oldDecoration.borderRadiusTLTRBLBR[index];
      radiusTransition.addProgressListener((progress) {
        processDecoration.borderRadiusTLTRBLBR[index] =
            radiusDiff * progress + baseDecoration.borderRadiusTLTRBLBR[index];
        renderDecoratedBox.decoration = processDecoration.toBoxDecoration();
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

  void _updateBorderInsets(EdgeInsets insets) {
    renderDecoratedBox.borderEdge = insets;
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>
  TransitionDecoration getTransitionDecoration(CSSStyleDeclaration style) {
    DecorationImage decorationImage;
    Gradient gradient;
    if (CSSBackground.hasScrollBackgroundImage(style)) {
      List<CSSFunctionalNotation> methods = CSSFunction(style[BACKGROUND_IMAGE]).computedValue;
      for (CSSFunctionalNotation method in methods) {
        if (method.name == 'url') {
          decorationImage = CSSBackground.getDecorationImage(style, method);
        } else {
          gradient = CSSBackground.getBackgroundGradient(method);
        }
      }
    }

    Color bgColor = CSSBackground.getBackgroundColor(style) ?? CSSColor.transparent;
    BorderSide leftSide = CSSBorder.getBorderSide(style, CSSBorder.LEFT);
    BorderSide topSide = CSSBorder.getBorderSide(style, CSSBorder.TOP);
    BorderSide rightSide = CSSBorder.getBorderSide(style, CSSBorder.RIGHT);
    BorderSide bottomSide = CSSBorder.getBorderSide(style, CSSBorder.BOTTOM);

    // border radius add inorder topLeft topRight bottomLeft bottomRight
    List<double> borderRadiusTLTRBLBR = [
      getBorderRadius(style, 'borderTopLeftRadius'),
      getBorderRadius(style, 'borderTopRightRadius'),
      getBorderRadius(style, 'borderBottomLeftRadius'),
      getBorderRadius(style, 'borderBottomRightRadius')
    ];

    return TransitionDecoration(bgColor, leftSide, topSide, rightSide,
        bottomSide, decorationImage, getBoxShadow(style), borderRadiusTLTRBLBR, gradient);
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

  double getBorderRadius(CSSStyleDeclaration style, String side) {
    if (style.contains(side)) {
      return CSSLength.toDisplayPortValue(style[side]) ?? 0;
    } else if (style.contains(BORDER_RADIUS)) {
      return CSSLength.toDisplayPortValue(style[BORDER_RADIUS]) ?? 0;
    }
    return 0.0;
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

    return EdgeInsets.fromLTRB(
      left,
      top,
      right,
      bottom
    );
  }

  static BorderSide _noneBorderSide = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide getBorderSide(CSSStyleDeclaration style, String side) {
    BorderStyle borderStyle = getBorderSideStyle(style, side);
    if (borderStyle == BorderStyle.none) {
      return _noneBorderSide;
    } else {
      return BorderSide(
        color: getBorderSideColor(style, side),
        width: getBorderSideWidth(style, side),
        style: borderStyle
      );
    }
  }
}

class TransitionDecoration {
  Color color;
  // radius inorder topLeft topRight bottomLeft bottomRight
  List<double> borderRadiusTLTRBLBR;
  // side inorder left top right bottom
  List<BorderSide> borderSidesLTRB;
  DecorationImage image;
  List<BoxShadow> boxShadow;
  Gradient gradient;

  TransitionDecoration(this.color, BorderSide borderLeftSide, BorderSide borderTopSide, BorderSide borderRightSide, BorderSide borderBottomSide,
      this.image, this.boxShadow, this.borderRadiusTLTRBLBR, this.gradient) {
    // side add inorder left top right bottom
    borderSidesLTRB = [
      borderLeftSide,
      borderTopSide,
      borderRightSide,
      borderBottomSide,
    ];
  }

  TransitionDecoration clone() {
    return TransitionDecoration(
        this.color,
        // side read inorder left top right bottom
        this.borderSidesLTRB[0].copyWith(),
        this.borderSidesLTRB[1].copyWith(),
        this.borderSidesLTRB[2].copyWith(),
        this.borderSidesLTRB[3].copyWith(),
        this.image,
        this.boxShadow,
        // radius read inorder topLeft topRight bottomLeft bottomRight
        List.of(this.borderRadiusTLTRBLBR),
        this.gradient);
  }

  BoxDecoration toBoxDecoration() {
    if (gradient != null) {
      color = null;
    }
    // side read inorder left top right bottom
    Border border = Border(
        left: borderSidesLTRB[0],
        top: borderSidesLTRB[1],
        right: borderSidesLTRB[2],
        bottom: borderSidesLTRB[3]);
    BorderRadius borderRadius;

    // flutter border limit, when border is not uniform, should set borderRadius
    if (border.isUniform) {
      // radius read inorder topLeft topRight bottomLeft bottomRight
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(borderRadiusTLTRBLBR[0]),
          topRight: Radius.circular(borderRadiusTLTRBLBR[1]),
          bottomLeft: Radius.circular(borderRadiusTLTRBLBR[2]),
          bottomRight: Radius.circular(borderRadiusTLTRBLBR[3]));
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
    return EdgeInsets.fromLTRB(borderSidesLTRB[0].width, borderSidesLTRB[1].width,
        borderSidesLTRB[2].width, borderSidesLTRB[3].width);
  }
}
