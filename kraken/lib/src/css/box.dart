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
  CSSInset oldBorderPadding;

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
        addColorProcessListener(backgroundColorTransition, newDecoration, oldDecoration, progressDecoration,
            baseDecoration, progressDecoration);

        // side read inorder left top right bottom
        // radius read inorder topLeft topRight bottomLeft bottomRight
        for (int i = 0; i < 4; i++) {
          // add border color transition
          addColorProcessListener(
              borderColorTransitionsLTRB[i],
              newDecoration.borderSidesLTRB[i],
              oldDecoration.borderSidesLTRB[i],
              progressDecoration.borderSidesLTRB[i],
              baseDecoration.borderSidesLTRB[i],
              progressDecoration);

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
  void addColorProcessListener(CSSTransition transition, TransitionColorMixin newColor, TransitionColorMixin oldColor,
      TransitionColorMixin processColor, TransitionColorMixin baseColor, TransitionDecoration processDecoration) {
    if (transition != null) {
      int alphaDiff = newColor.color.alpha - oldColor.color.alpha;
      int redDiff = newColor.color.red - oldColor.color.red;
      int greenDiff = newColor.color.green - oldColor.color.green;
      int blueDiff = newColor.color.blue - oldColor.color.blue;
      transition.addProgressListener((progress) {
        processColor.color = processColor.color.withAlpha((alphaDiff * progress).toInt() + baseColor.color.alpha);
        processColor.color = processColor.color.withRed((redDiff * progress).toInt() + baseColor.color.red);
        processColor.color = processColor.color.withBlue((blueDiff * progress).toInt() + baseColor.color.blue);
        processColor.color = processColor.color.withGreen((greenDiff * progress).toInt() + baseColor.color.green);
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
      double widthDiff =
          newDecoration.borderSidesLTRB[index].borderWidth - oldDecoration.borderSidesLTRB[index].borderWidth;
      widthTransition.addProgressListener((progress) {
        processDecoration.borderSidesLTRB[index].borderWidth =
            widthDiff * progress + baseDecoration.borderSidesLTRB[index].borderWidth;
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
    if ((background[BACKGROUND_ATTACHMENT] == '' || background[BACKGROUND_ATTACHMENT] == 'scroll') &&
        background.containsKey(BACKGROUND_IMAGE)) {
      List<CSSFunctionalNotation> methods = CSSFunction(background[BACKGROUND_IMAGE]).computedValue;
      for (CSSFunctionalNotation method in methods) {
        if (method.name == 'url') {
          String url = method.args.length > 0 ? method.args[0] : '';
          if (url != null && url.isNotEmpty) {
            decorationImage = getBackgroundImage(url);
          }
        } else {
          gradient = getBackgroundGradient(method);
        }
      }
    }

    Color color = getBackgroundColor(style);
    TransitionBorderSide leftSide = getBorderSideByStyle(style, 'Left');
    TransitionBorderSide topSide = getBorderSideByStyle(style, 'Top');
    TransitionBorderSide rightSide = getBorderSideByStyle(style, 'Right');
    TransitionBorderSide bottomSide = getBorderSideByStyle(style, 'Bottom');

    // border radius add inorder topLeft topRight bottomLeft bottomRight
    List<double> borderRadiusTLTRBLBR = [
      getBorderRadius(style, 'borderTopLeftRadius'),
      getBorderRadius(style, 'borderTopRightRadius'),
      getBorderRadius(style, 'borderBottomLeftRadius'),
      getBorderRadius(style, 'borderBottomRightRadius')
    ];

    return TransitionDecoration(color?.alpha, color?.red, color?.green, color?.blue, leftSide, topSide, rightSide,
        bottomSide, decorationImage, getBoxShadow(style), borderRadiusTLTRBLBR, gradient);
  }

  /// Tip: inset not supported.
  List<BoxShadow> getBoxShadow(CSSStyleDeclaration style) {
    List<BoxShadow> boxShadow = [];
    if (style.contains(BOX_SHADOW)) {
      var shadows = CSSStyleProperty.getShadowValues(style[BOX_SHADOW]);
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

  // border default width 3.0
  static double defaultBorderWidth = 3.0;
  static BorderStyle defaultBorderStyle = BorderStyle.none;
  static Color defaultBorderColor = CSSColor.initial;

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

  static Map _getShorthandInfo(String input) {
    List<String> properties = CSSStyleProperty.getBorderValues(input);
    if (properties == null) return null;

    double width;
    if (properties[0] != null) {
      width = getBorderWidth(properties[0]);
    }

    BorderStyle style;
    if (properties[1] != null) {
      style = getBorderStyle(properties[1]);
    }

    Color color;
    if (properties[2] != null) {
      color = CSSColor.parseColor(properties[2]);
    }

    return {'Color': color ?? defaultBorderColor, 'Style': style ?? defaultBorderStyle, 'Width': width ?? defaultBorderWidth};
  }

  // TODO: shorthand format like `borderColor: 'red yellow green blue'` should full support
  static TransitionBorderSide getBorderSideByStyle(CSSStyleDeclaration style, String side) {
    TransitionBorderSide borderSide = TransitionBorderSide(0, 0, 0, 0, defaultBorderWidth, defaultBorderStyle);
    final String borderName = 'border';
    final String borderSideName = borderName + side; // eg. borderLeft/borderRight
    // Same with the key in shortted info map
    final String widthName = 'Width';
    final String styleName = 'Style';
    final String colorName = 'Color';
    Map borderShorthandInfo;
    Map borderSideShorthandInfo;
    if (style.contains(BORDER)) {
      borderShorthandInfo = _getShorthandInfo(style[BORDER]);
    }

    if (style.contains(borderSideName)) {
      borderSideShorthandInfo = _getShorthandInfo(style[borderSideName]);
    }

    // Set border style
    BorderStyle borderStyle;
    final String borderSideStyleName = borderSideName + styleName; // eg. borderLeftStyle/borderRightStyle
    final String borderStyleName = borderName + styleName; // borderStyle
    if (style.contains(borderSideStyleName)) {
      borderStyle = getBorderStyle(style[borderSideStyleName]);
    } else if (borderSideShorthandInfo != null && borderSideShorthandInfo[styleName] != null) {
      borderStyle = borderSideShorthandInfo[styleName];
    } else if (style.contains(borderStyleName)) {
      borderStyle = getBorderStyle(style[borderStyleName]);
    } else if (borderShorthandInfo != null && borderShorthandInfo[styleName] != null) {
      borderStyle = borderShorthandInfo[styleName];
    }

    borderSide.borderStyle = borderStyle ?? defaultBorderStyle;

    // Set border width
    double borderWidth;
    // border width should be zero when style is none
    if (borderSide.borderStyle == BorderStyle.none) {
      borderWidth = 0.0;
    } else {
      final String borderSideWidthName = borderSideName + widthName; // eg. borderLeftWidth/borderRightWidth
      final String borderWidthName = borderName + widthName; // borderWidth
      if (style.contains(borderSideWidthName) && (style[borderSideWidthName] as String).isNotEmpty) {
        borderWidth = getBorderWidth(style[borderSideWidthName]);
      } else if (borderSideShorthandInfo != null && borderSideShorthandInfo[widthName] != null) {
        // eg. borderLeft: 'solid 1px black'
        borderWidth = borderSideShorthandInfo[widthName];
      } else if (style.contains(borderWidthName)) {
        borderWidth = getBorderWidth(style[borderWidthName]);
      } else if (borderShorthandInfo != null && borderShorthandInfo[widthName] != null) {
        // eg. border: 'solid 2px red'
        borderWidth = borderShorthandInfo[widthName];
      }
    }

    borderSide.borderWidth = borderWidth ?? defaultBorderWidth;

    // Set border color
    Color borderColor;
    final String borderSideColorName = borderSideName + colorName; // eg. borderLeftColor/borderRightColor
    final String borderColorName = borderName + colorName; // borderColor
    if (style.contains(borderSideColorName)) {
      borderColor = CSSColor.parseColor(style[borderSideColorName]) ;
    } else if (borderSideShorthandInfo != null && borderSideShorthandInfo[colorName] != null) {
      borderColor = borderSideShorthandInfo[colorName];
    } else if (style.contains(borderColorName)) {
      borderColor = CSSColor.parseColor(style[borderColorName]);
    } else if (borderShorthandInfo != null && borderShorthandInfo[colorName] != null) {
      borderColor = borderShorthandInfo[colorName];
    }

    borderSide.color = borderColor ?? defaultBorderColor;

    return borderSide;
  }
}

mixin TransitionColorMixin {
  Color color;

  void initColor(Color color) {
    this.color = color;
  }
}

class TransitionBorderSide with TransitionColorMixin {
  double borderWidth;
  BorderStyle borderStyle;

  TransitionBorderSide(borderAlpha, borderRed, borderGreen, borderBlue, this.borderWidth, this.borderStyle) {
    initColor(Color.fromARGB(borderAlpha, borderRed, borderGreen, borderBlue));
  }

  TransitionBorderSide clone() {
    return TransitionBorderSide(color.alpha, color.red, color.green, color.blue, this.borderWidth, this.borderStyle);
  }

  BorderSide toBorderSide() {
    if (borderWidth == 0.0) {
      return BorderSide.none;
    }
    return BorderSide(color: color, width: borderWidth, style: borderStyle);
  }
}

class TransitionDecoration with TransitionColorMixin {
  // radius inorder topLeft topRight bottomLeft bottomRight
  List<double> borderRadiusTLTRBLBR;
  // side inorder left top right bottom
  List<TransitionBorderSide> borderSidesLTRB;
  DecorationImage image;
  List<BoxShadow> boxShadow;
  Gradient gradient;

  TransitionDecoration(alpha, red, green, blue, borderLeftSide, borderTopSide, borderRightSide, borderBottomSide,
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
        color.alpha,
        color.red,
        color.green,
        color.blue,
        // side read inorder left top right bottom
        this.borderSidesLTRB[0].clone(),
        this.borderSidesLTRB[1].clone(),
        this.borderSidesLTRB[2].clone(),
        this.borderSidesLTRB[3].clone(),
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
        left: borderSidesLTRB[0].toBorderSide(),
        top: borderSidesLTRB[1].toBorderSide(),
        right: borderSidesLTRB[2].toBorderSide(),
        bottom: borderSidesLTRB[3].toBorderSide());
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
    return EdgeInsets.fromLTRB(borderSidesLTRB[0].borderWidth, borderSidesLTRB[1].borderWidth,
        borderSidesLTRB[2].borderWidth, borderSidesLTRB[3].borderWidth);
  }
}
