/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

/// RenderDecoratedBox impls styles of
/// - background
/// - border
mixin RenderDecoratedBoxMixin on BackgroundImageMixin {
  RenderDecoratedBox renderDecoratedBox;
  RenderMargin renderBorderHolder;
  TransitionDecoration oldDecoration;
  Padding oldBorderPadding;

  RenderObject initRenderDecoratedBox(
      RenderObject renderObject, StyleDeclaration style, int nodeId) {
    oldDecoration = getTransitionDecoration(style);
    EdgeInsets margin = oldDecoration.getBorderEdgeInsets();
    // Flutter Border width is inside the element
    // but w3c border is outside the element
    // so use margin to fix it.
    renderBorderHolder = RenderMargin(
      margin: margin,
      child: renderObject,
    );
    return renderDecoratedBox = RenderGradient(
      nodeId: nodeId,
      decoration: oldDecoration.toBoxDecoration(),
      child: renderBorderHolder,
    );
  }

  void updateRenderDecoratedBox(
      StyleDeclaration style, Map<String, Transition> transitionMap) {
    TransitionDecoration newDecoration = getTransitionDecoration(style);
    if (transitionMap != null) {
      Transition allTransition = transitionMap['all'];
      Transition backgroundColorTransition = transitionMap['background-color'];
      Transition borderWidthTransition = transitionMap['border-width'];
      Transition borderColorTransition = transitionMap['border-color'];
      Transition borderLeftWidthTransition = transitionMap['border-left-width'];
      Transition borderLeftColorTransition = transitionMap['border-left-color'];
      Transition borderTopWidthTransition = transitionMap['border-top-width'];
      Transition borderTopColorTransition = transitionMap['border-top-color'];
      Transition borderRightWidthTransition =
          transitionMap['border-right-width'];
      Transition borderRightColorTransition =
          transitionMap['border-right-color'];
      Transition borderBottomWidthTransition =
          transitionMap['border-bottom-width'];
      Transition borderBottomColorTransition =
          transitionMap['border-bottom-color'];
      if (allTransition != null ||
          backgroundColorTransition != null ||
          borderWidthTransition != null ||
          borderColorTransition != null ||
          borderLeftWidthTransition != null ||
          borderLeftColorTransition != null ||
          borderTopColorTransition != null ||
          borderTopWidthTransition != null ||
          borderRightColorTransition != null ||
          borderRightWidthTransition != null ||
          borderBottomColorTransition != null ||
          borderBottomWidthTransition != null) {
        int alphaDiff = newDecoration.alpha - oldDecoration.alpha;
        int redDiff = newDecoration.red - oldDecoration.red;
        int greenDiff = newDecoration.green - oldDecoration.green;
        int blueDiff = newDecoration.blue - oldDecoration.blue;

        double borderLeftWidthDiff = newDecoration.borderLeftSide.borderWidth -
            oldDecoration.borderLeftSide.borderWidth;
        double borderTopWidthDiff = newDecoration.borderTopSide.borderWidth -
            oldDecoration.borderTopSide.borderWidth;
        double borderRightWidthDiff =
            newDecoration.borderRightSide.borderWidth -
                oldDecoration.borderRightSide.borderWidth;
        double borderBottomWidthDiff =
            newDecoration.borderBottomSide.borderWidth -
                oldDecoration.borderBottomSide.borderWidth;

        int borderLeftAlphaDiff = newDecoration.borderLeftSide.borderAlpha -
            oldDecoration.borderLeftSide.borderAlpha;
        int borderLeftRedDiff = newDecoration.borderLeftSide.borderRed -
            oldDecoration.borderLeftSide.borderRed;
        int borderLeftGreenDiff = newDecoration.borderLeftSide.borderGreen -
            oldDecoration.borderLeftSide.borderGreen;
        int borderLeftBlueDiff = newDecoration.borderLeftSide.borderBlue -
            oldDecoration.borderLeftSide.borderBlue;
        int borderTopAlphaDiff = newDecoration.borderTopSide.borderAlpha -
            oldDecoration.borderTopSide.borderAlpha;
        int borderTopRedDiff = newDecoration.borderTopSide.borderRed -
            oldDecoration.borderTopSide.borderRed;
        int borderTopGreenDiff = newDecoration.borderTopSide.borderGreen -
            oldDecoration.borderTopSide.borderGreen;
        int borderTopBlueDiff = newDecoration.borderTopSide.borderBlue -
            oldDecoration.borderTopSide.borderBlue;
        int borderRightAlphaDiff = newDecoration.borderRightSide.borderAlpha -
            oldDecoration.borderRightSide.borderAlpha;
        int borderRightRedDiff = newDecoration.borderRightSide.borderRed -
            oldDecoration.borderRightSide.borderRed;
        int borderRightGreenDiff = newDecoration.borderRightSide.borderGreen -
            oldDecoration.borderRightSide.borderGreen;
        int borderRightBlueDiff = newDecoration.borderRightSide.borderBlue -
            oldDecoration.borderRightSide.borderBlue;
        int borderBottomAlphaDiff = newDecoration.borderBottomSide.borderAlpha -
            oldDecoration.borderBottomSide.borderAlpha;
        int borderBottomRedDiff = newDecoration.borderBottomSide.borderRed -
            oldDecoration.borderBottomSide.borderRed;
        int borderBottomGreenDiff = newDecoration.borderBottomSide.borderGreen -
            oldDecoration.borderBottomSide.borderGreen;
        int borderBottomBlueDiff = newDecoration.borderBottomSide.borderBlue -
            oldDecoration.borderBottomSide.borderBlue;

        TransitionDecoration progressDecoration = oldDecoration.clone();
        TransitionDecoration baseDecoration = oldDecoration.clone();
        allTransition?.addProgressListener((progress) {
          if (backgroundColorTransition == null) {
            progressDecoration.alpha =
                (alphaDiff * progress).toInt() + baseDecoration.alpha;
            progressDecoration.red =
                (redDiff * progress).toInt() + baseDecoration.red;
            progressDecoration.green =
                (greenDiff * progress).toInt() + baseDecoration.green;
            progressDecoration.blue =
                (blueDiff * progress).toInt() + baseDecoration.blue;
          }
          if (borderWidthTransition == null) {
            if (borderLeftWidthTransition == null) {
              progressDecoration.borderLeftSide.borderWidth =
                  borderLeftWidthDiff * progress +
                      baseDecoration.borderLeftSide.borderWidth;
            }
            if (borderTopWidthTransition == null) {
              progressDecoration.borderTopSide.borderWidth =
                  borderTopWidthDiff * progress +
                      baseDecoration.borderTopSide.borderWidth;
            }
            if (borderRightWidthTransition == null) {
              progressDecoration.borderRightSide.borderWidth =
                  borderRightWidthDiff * progress +
                      baseDecoration.borderRightSide.borderWidth;
            }
            if (borderBottomWidthTransition == null) {
              progressDecoration.borderBottomSide.borderWidth =
                  borderBottomWidthDiff * progress +
                      baseDecoration.borderBottomSide.borderWidth;
            }
          }

          if (borderColorTransition == null) {
            if (borderLeftColorTransition == null) {
              progressDecoration.borderLeftSide.borderAlpha =
                  (borderLeftAlphaDiff * progress).toInt() +
                      baseDecoration.borderLeftSide.borderAlpha;
              progressDecoration.borderLeftSide.borderRed =
                  (borderLeftRedDiff * progress).toInt() +
                      baseDecoration.borderLeftSide.borderRed;
              progressDecoration.borderLeftSide.borderGreen =
                  (borderLeftGreenDiff * progress).toInt() +
                      baseDecoration.borderLeftSide.borderGreen;
              progressDecoration.borderLeftSide.borderBlue =
                  (borderLeftBlueDiff * progress).toInt() +
                      baseDecoration.borderLeftSide.borderBlue;
            }
            if (borderTopColorTransition == null) {
              progressDecoration.borderTopSide.borderAlpha =
                  (borderTopAlphaDiff * progress).toInt() +
                      baseDecoration.borderTopSide.borderAlpha;
              progressDecoration.borderTopSide.borderRed =
                  (borderTopRedDiff * progress).toInt() +
                      baseDecoration.borderTopSide.borderRed;
              progressDecoration.borderTopSide.borderGreen =
                  (borderTopGreenDiff * progress).toInt() +
                      baseDecoration.borderTopSide.borderGreen;
              progressDecoration.borderTopSide.borderBlue =
                  (borderTopBlueDiff * progress).toInt() +
                      baseDecoration.borderTopSide.borderBlue;
            }
            if (borderRightColorTransition == null) {
              progressDecoration.borderRightSide.borderAlpha =
                  (borderRightAlphaDiff * progress).toInt() +
                      baseDecoration.borderRightSide.borderAlpha;
              progressDecoration.borderRightSide.borderRed =
                  (borderRightRedDiff * progress).toInt() +
                      baseDecoration.borderRightSide.borderRed;
              progressDecoration.borderRightSide.borderGreen =
                  (borderRightGreenDiff * progress).toInt() +
                      baseDecoration.borderRightSide.borderGreen;
              progressDecoration.borderRightSide.borderBlue =
                  (borderRightBlueDiff * progress).toInt() +
                      baseDecoration.borderRightSide.borderBlue;
            }
            if (borderBottomColorTransition == null) {
              progressDecoration.borderBottomSide.borderAlpha =
                  (borderBottomAlphaDiff * progress).toInt() +
                      baseDecoration.borderBottomSide.borderAlpha;
              progressDecoration.borderBottomSide.borderRed =
                  (borderBottomRedDiff * progress).toInt() +
                      baseDecoration.borderBottomSide.borderRed;
              progressDecoration.borderBottomSide.borderGreen =
                  (borderBottomGreenDiff * progress).toInt() +
                      baseDecoration.borderBottomSide.borderGreen;
              progressDecoration.borderBottomSide.borderBlue =
                  (borderBottomBlueDiff * progress).toInt() +
                      baseDecoration.borderBottomSide.borderBlue;
            }
          }
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });
        backgroundColorTransition?.addProgressListener((progress) {
          progressDecoration.alpha =
              (alphaDiff * progress).toInt() + baseDecoration.alpha;
          progressDecoration.red =
              (redDiff * progress).toInt() + baseDecoration.red;
          progressDecoration.green =
              (greenDiff * progress).toInt() + baseDecoration.green;
          progressDecoration.blue =
              (blueDiff * progress).toInt() + baseDecoration.blue;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });

        borderWidthTransition?.addProgressListener((progress) {
          if (borderLeftWidthTransition == null) {
            progressDecoration.borderLeftSide.borderWidth =
                borderLeftWidthDiff * progress +
                    baseDecoration.borderLeftSide.borderWidth;
          }
          if (borderTopWidthTransition == null) {
            progressDecoration.borderTopSide.borderWidth =
                borderTopWidthDiff * progress +
                    baseDecoration.borderTopSide.borderWidth;
          }
          if (borderRightWidthTransition == null) {
            progressDecoration.borderRightSide.borderWidth =
                borderRightWidthDiff * progress +
                    baseDecoration.borderRightSide.borderWidth;
          }
          if (borderBottomWidthTransition == null) {
            progressDecoration.borderBottomSide.borderWidth =
                borderBottomWidthDiff * progress +
                    baseDecoration.borderBottomSide.borderWidth;
          }
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });

        borderLeftWidthTransition?.addProgressListener((progress) {
          progressDecoration.borderLeftSide.borderWidth =
              borderLeftWidthDiff * progress +
                  baseDecoration.borderLeftSide.borderWidth;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });
        borderTopWidthTransition?.addProgressListener((progress) {
          progressDecoration.borderTopSide.borderWidth =
              borderTopWidthDiff * progress +
                  baseDecoration.borderTopSide.borderWidth;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });
        borderRightWidthTransition?.addProgressListener((progress) {
          progressDecoration.borderRightSide.borderWidth =
              borderRightWidthDiff * progress +
                  baseDecoration.borderRightSide.borderWidth;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });
        borderBottomWidthTransition?.addProgressListener((progress) {
          progressDecoration.borderBottomSide.borderWidth =
              borderBottomWidthDiff * progress +
                  baseDecoration.borderBottomSide.borderWidth;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
          _updateBorderInsets(newDecoration.getBorderEdgeInsets());
        });

        borderColorTransition?.addProgressListener((progress) {
          if (borderLeftColorTransition == null) {
            progressDecoration.borderLeftSide.borderAlpha =
                (borderLeftAlphaDiff * progress).toInt() +
                    baseDecoration.borderLeftSide.borderAlpha;
            progressDecoration.borderLeftSide.borderRed =
                (borderLeftRedDiff * progress).toInt() +
                    baseDecoration.borderLeftSide.borderRed;
            progressDecoration.borderLeftSide.borderGreen =
                (borderLeftGreenDiff * progress).toInt() +
                    baseDecoration.borderLeftSide.borderGreen;
            progressDecoration.borderLeftSide.borderBlue =
                (borderLeftBlueDiff * progress).toInt() +
                    baseDecoration.borderLeftSide.borderBlue;
          }
          if (borderTopColorTransition == null) {
            progressDecoration.borderTopSide.borderAlpha =
                (borderTopAlphaDiff * progress).toInt() +
                    baseDecoration.borderTopSide.borderAlpha;
            progressDecoration.borderTopSide.borderRed =
                (borderTopRedDiff * progress).toInt() +
                    baseDecoration.borderTopSide.borderRed;
            progressDecoration.borderTopSide.borderGreen =
                (borderTopGreenDiff * progress).toInt() +
                    baseDecoration.borderTopSide.borderGreen;
            progressDecoration.borderTopSide.borderBlue =
                (borderTopBlueDiff * progress).toInt() +
                    baseDecoration.borderTopSide.borderBlue;
          }
          if (borderRightColorTransition == null) {
            progressDecoration.borderRightSide.borderAlpha =
                (borderRightAlphaDiff * progress).toInt() +
                    baseDecoration.borderRightSide.borderAlpha;
            progressDecoration.borderRightSide.borderRed =
                (borderRightRedDiff * progress).toInt() +
                    baseDecoration.borderRightSide.borderRed;
            progressDecoration.borderRightSide.borderGreen =
                (borderRightGreenDiff * progress).toInt() +
                    baseDecoration.borderRightSide.borderGreen;
            progressDecoration.borderRightSide.borderBlue =
                (borderRightBlueDiff * progress).toInt() +
                    baseDecoration.borderRightSide.borderBlue;
          }
          if (borderBottomColorTransition == null) {
            progressDecoration.borderBottomSide.borderAlpha =
                (borderBottomAlphaDiff * progress).toInt() +
                    baseDecoration.borderBottomSide.borderAlpha;
            progressDecoration.borderBottomSide.borderRed =
                (borderBottomRedDiff * progress).toInt() +
                    baseDecoration.borderBottomSide.borderRed;
            progressDecoration.borderBottomSide.borderGreen =
                (borderBottomGreenDiff * progress).toInt() +
                    baseDecoration.borderBottomSide.borderGreen;
            progressDecoration.borderBottomSide.borderBlue =
                (borderBottomBlueDiff * progress).toInt() +
                    baseDecoration.borderBottomSide.borderBlue;
          }
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });
        borderLeftColorTransition?.addProgressListener((progress) {
          progressDecoration.borderLeftSide.borderAlpha =
              (borderLeftAlphaDiff * progress).toInt() +
                  baseDecoration.borderLeftSide.borderAlpha;
          progressDecoration.borderLeftSide.borderRed =
              (borderLeftRedDiff * progress).toInt() +
                  baseDecoration.borderLeftSide.borderRed;
          progressDecoration.borderLeftSide.borderGreen =
              (borderLeftGreenDiff * progress).toInt() +
                  baseDecoration.borderLeftSide.borderGreen;
          progressDecoration.borderLeftSide.borderBlue =
              (borderLeftBlueDiff * progress).toInt() +
                  baseDecoration.borderLeftSide.borderBlue;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });
        borderTopColorTransition?.addProgressListener((progress) {
          progressDecoration.borderTopSide.borderAlpha =
              (borderTopAlphaDiff * progress).toInt() +
                  baseDecoration.borderTopSide.borderAlpha;
          progressDecoration.borderTopSide.borderRed =
              (borderTopRedDiff * progress).toInt() +
                  baseDecoration.borderTopSide.borderRed;
          progressDecoration.borderTopSide.borderGreen =
              (borderTopGreenDiff * progress).toInt() +
                  baseDecoration.borderTopSide.borderGreen;
          progressDecoration.borderTopSide.borderBlue =
              (borderTopBlueDiff * progress).toInt() +
                  baseDecoration.borderTopSide.borderBlue;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });
        borderRightColorTransition?.addProgressListener((progress) {
          progressDecoration.borderRightSide.borderAlpha =
              (borderRightAlphaDiff * progress).toInt() +
                  baseDecoration.borderRightSide.borderAlpha;
          progressDecoration.borderRightSide.borderRed =
              (borderRightRedDiff * progress).toInt() +
                  baseDecoration.borderRightSide.borderRed;
          progressDecoration.borderRightSide.borderGreen =
              (borderRightGreenDiff * progress).toInt() +
                  baseDecoration.borderRightSide.borderGreen;
          progressDecoration.borderRightSide.borderBlue =
              (borderRightBlueDiff * progress).toInt() +
                  baseDecoration.borderRightSide.borderBlue;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });
        borderBottomColorTransition?.addProgressListener((progress) {
          progressDecoration.borderBottomSide.borderAlpha =
              (borderBottomAlphaDiff * progress).toInt() +
                  baseDecoration.borderBottomSide.borderAlpha;
          progressDecoration.borderBottomSide.borderRed =
              (borderBottomRedDiff * progress).toInt() +
                  baseDecoration.borderBottomSide.borderRed;
          progressDecoration.borderBottomSide.borderGreen =
              (borderBottomGreenDiff * progress).toInt() +
                  baseDecoration.borderBottomSide.borderGreen;
          progressDecoration.borderBottomSide.borderBlue =
              (borderBottomBlueDiff * progress).toInt() +
                  baseDecoration.borderBottomSide.borderBlue;
          renderDecoratedBox.decoration = progressDecoration.toBoxDecoration();
        });
      } else {
        renderDecoratedBox.decoration = newDecoration.toBoxDecoration();
        _updateBorderInsets(newDecoration.getBorderEdgeInsets());
      }
    } else {
      renderDecoratedBox.decoration = newDecoration.toBoxDecoration();
      // Update can not trigger performlayout.
      // Gradient need trigger performlayout to recaculate the alignment
      // when linearAngle not null (other situation doesn't need).
      if (linearAngle != null) {
        renderDecoratedBox.markNeedsLayout();
      }
      _updateBorderInsets(newDecoration.getBorderEdgeInsets());
    }
    oldDecoration = newDecoration;
  }

  void _updateBorderInsets(EdgeInsets insets) {
    renderBorderHolder.margin = insets;
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>
  TransitionDecoration getTransitionDecoration(StyleDeclaration style) {
    BorderRadius borderRadius = getBorderRadius(style);
    DecorationImage decorationImage;
    Gradient gradient;
    if (style['backgroundAttachment'] == ''
        || style['backgroundAttachment'] == 'scroll'
            && style.contains('backgroundImage')) {
      List<Method> methods = Method.parseMethod(style['backgroundImage']);
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

    Color color = getBackgroundColor(style);
    TransitionBorderSide leftSide = getBorderSideByStyle(style, 'Left');
    TransitionBorderSide topSide = getBorderSideByStyle(style, 'Top');
    TransitionBorderSide rightSide = getBorderSideByStyle(style, 'Right');
    TransitionBorderSide bottomSide = getBorderSideByStyle(style, 'Bottom');

    return TransitionDecoration(
        color?.alpha,
        color?.red,
        color?.green,
        color?.blue,
        leftSide,
        topSide,
        rightSide,
        bottomSide,
        decorationImage,
        getBoxShadow(style),
        borderRadius,
        gradient);
  }

  /// Tip: inset not supported.
  static RegExp commaRegExp = RegExp(r',');
  List<BoxShadow> getBoxShadow(StyleDeclaration style) {
    List<BoxShadow> boxShadow = [];
    if (style.contains('boxShadow')) {
      String processedValue =
          WebColor.preprocessCSSPropertyWithRGBAColor(style['boxShadow']);
      List<String> rawShadows = processedValue.split(commaRegExp);
      for (String rawShadow in rawShadows) {
        List<String> shadowDefinitions = rawShadow.trim().split(spaceRegExp);
        if (shadowDefinitions.length > 2) {
          double offsetX = Length.toDisplayPortValue(shadowDefinitions[0]);
          double offsetY = Length.toDisplayPortValue(shadowDefinitions[1]);
          double blurRadius = shadowDefinitions.length > 3
              ? Length.toDisplayPortValue(shadowDefinitions[2])
              : 0.0;
          double spreadRadius = shadowDefinitions.length > 4
              ? Length.toDisplayPortValue(shadowDefinitions[3])
              : 0.0;

          Color color = WebColor.generate(shadowDefinitions.last);
          if (color != null) {
            boxShadow.add(BoxShadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              color: color,
            ));
          }
        }
      }

      // Tips only debug.
      if (!PRODUCTION && boxShadow.isEmpty) {
        print('[Warning] Wrong style format with boxShadow: ${style['boxShadow']}');
        print('    Correct syntax: inset? && <length>{2,4} && <color>?');
      }
    }
    return boxShadow;
  }

  static List<String> TLTRBLBR = [
    'TopLeft',
    'TopRight',
    'BottomLeft',
    'BottomRight'
  ];
  BorderRadiusGeometry getBorderRadius(StyleDeclaration style) {
    List<Radius> borderRadiusTLTRBLBR = [
      Radius.zero,
      Radius.zero,
      Radius.zero,
      Radius.zero,
    ];
    if (style.contains('borderRadius')) {
      double radius = Length.toDisplayPortValue(style['borderRadius']);
      borderRadiusTLTRBLBR[0] = borderRadiusTLTRBLBR[1] =
          borderRadiusTLTRBLBR[2] =
              borderRadiusTLTRBLBR[3] = Radius.circular(radius);
    } else {
      return null;
    }
    TLTRBLBR.forEach((String corner) {
      String key = 'borderRadius' + corner;
      if (style.contains(key)) {
        double radius = Length.toDisplayPortValue(style[key]);
        int index = TLTRBLBR.indexOf(corner);
        borderRadiusTLTRBLBR[index] = Radius.circular(radius);
      }
    });

    return BorderRadius.only(
      topLeft: borderRadiusTLTRBLBR[0],
      topRight: borderRadiusTLTRBLBR[1],
      bottomLeft: borderRadiusTLTRBLBR[2],
      bottomRight: borderRadiusTLTRBLBR[3],
    );
  }

  Color getBackgroundColor(StyleDeclaration style) {
    Color backgroundColor = WebColor.transparent;
    if (style.contains('backgroundColor')) {
      backgroundColor = WebColor.generate(style['backgroundColor']);
    }
    return backgroundColor;
  }

  static RegExp spaceRegExp = RegExp(r' ');
  List<String> getShorttedProperties(String input) {
    assert(input != null);
    return input.trim().split(spaceRegExp);
  }

  static double defaultBorderLineWidth = 0.0;
  static BorderStyle defaultBorderStyle = BorderStyle.solid;
  static Color defaultBorderColor = WebColor.transparent;

  BorderStyle getBorderStyle(String input) {
    BorderStyle borderStyle;
    switch (input) {
      case 'solid':
        borderStyle = BorderStyle.solid;
        break;
      default:
        borderStyle = BorderStyle.none;
        break;
    }
    return borderStyle;
  }
  // TODO: Shortted order in web not keep in same order
  Map _getShorttedInfoFromString(String input) {
    List<String> splittedBorder = getShorttedProperties(input);

    double width = splittedBorder.length > 0
      ? Length.toDisplayPortValue(splittedBorder[0])
      : null;

    BorderStyle style = splittedBorder.length > 1
      ? getBorderStyle(splittedBorder[1])
      : null;

    Color color = splittedBorder.length > 2
      ? WebColor.generate(splittedBorder[2])
      : null;

    return {
      'Color': color,
      'Style': style,
      'Width': width
    };
  }

  // TODO: shorthand format like `borderColor: 'red yellow green blue'` should full support
  TransitionBorderSide getBorderSideByStyle(StyleDeclaration style, String side) {
    TransitionBorderSide borderSide = TransitionBorderSide(0, 0, 0, 0, 0, defaultBorderStyle);
    final String borderName = 'border';
    final String borderSideName = borderName + side; // eg. borderLeft/borderRight
    // Same with the key in shortted info map
    final String widthName = 'Width';
    final String styleName = 'Style';
    final String colorName = 'Color';
    Map borderShorttedInfo;
    Map borderSideShorttedInfo;
    if (style.contains(borderName)){
      borderShorttedInfo = _getShorttedInfoFromString(style[borderName]);
    }

    if (style.contains(borderSideName)) {
      borderSideShorttedInfo = _getShorttedInfoFromString(style[borderSideName]);
    }

    // Set border width
    final String borderSideWidthName = borderSideName + widthName; // eg. borderLeftWidth/borderRightWidth
    final String borderWidthName = borderName + widthName; // borderWidth
    if (style.contains(borderSideWidthName) &&
      (style[borderSideWidthName] as String).isNotEmpty) {
      borderSide.borderWidth = Length.toDisplayPortValue(style[borderSideWidthName]);
    } else if (borderSideShorttedInfo != null && borderSideShorttedInfo[widthName] != null) { // eg. borderLeft: 'solid 1px black'
      borderSide.borderWidth = borderSideShorttedInfo[widthName];
    } else if (style.contains(borderWidthName)) {
      borderSide.borderWidth = Length.toDisplayPortValue(style[borderWidthName]);
    } else if (borderShorttedInfo != null && borderShorttedInfo[widthName] != null) { // eg. border: 'solid 2px red'
      borderSide.borderWidth = borderShorttedInfo[widthName];
    }

    // Set border style
    final String borderSideStyleName = borderSideName + styleName; // eg. borderLeftStyle/borderRightStyle
    final String borderStyleName = borderName + widthName; // borderStyle
    if (style.contains(borderSideStyleName)) {
      borderSide.borderStyle = getBorderStyle(style[borderSideStyleName]);
    } else if (borderSideShorttedInfo != null && borderSideShorttedInfo[styleName] != null) {
      borderSide.borderStyle = borderSideShorttedInfo[styleName];
    } else if (style.contains(borderStyleName)) {
      borderSide.borderStyle = getBorderStyle(style[borderStyleName]);
    } else if (borderShorttedInfo != null && borderShorttedInfo[styleName] != null) {
      borderSide.borderStyle = borderShorttedInfo[styleName];
    }

    // Set border color
    Color borderColor;
    final String borderSideColorName = borderSideName + colorName; // eg. borderLeftColor/borderRightColor
    final String borderColorName = borderName + colorName; // borderColor
    if (style.contains(borderSideColorName)) {
      borderColor = WebColor.generate(style[borderSideColorName]);
    } else if (borderSideShorttedInfo != null && borderSideShorttedInfo[colorName] != null) {
      borderColor = borderSideShorttedInfo[colorName];
    } else if (style.contains(borderColorName)) {
      borderColor = WebColor.generate(style[borderColorName]);
    } else if (borderShorttedInfo != null && borderShorttedInfo[colorName] != null) {
      borderColor = borderShorttedInfo[colorName];
    }

    if (borderColor != null) {
      borderSide.borderAlpha = borderColor.alpha;
      borderSide.borderRed = borderColor.red;
      borderSide.borderGreen = borderColor.green;
      borderSide.borderBlue = borderColor.blue;
    }

    return borderSide;
  }
}

class TransitionBorderSide {
  int borderAlpha, borderRed, borderGreen, borderBlue;
  double borderWidth;
  BorderStyle borderStyle;

  TransitionBorderSide(this.borderAlpha, this.borderRed, this.borderGreen,
      this.borderBlue, this.borderWidth, this.borderStyle);

  TransitionBorderSide clone() {
    return TransitionBorderSide(this.borderAlpha, this.borderRed,
        this.borderGreen, this.borderBlue, this.borderWidth, this.borderStyle);
  }

  BorderSide toBorderSide() {
    return BorderSide(
        color: Color.fromARGB(borderAlpha, borderRed, borderGreen, borderBlue),
        width: borderWidth,
        style: borderStyle);
  }
}

class TransitionDecoration {
  int alpha, red, green, blue;
  TransitionBorderSide borderLeftSide,
      borderTopSide,
      borderRightSide,
      borderBottomSide;
  DecorationImage image;
  List<BoxShadow> boxShadow;
  BorderRadiusGeometry borderRadius;
  Gradient gradient;

  TransitionDecoration(
      this.alpha,
      this.red,
      this.green,
      this.blue,
      this.borderLeftSide,
      this.borderTopSide,
      this.borderRightSide,
      this.borderBottomSide,
      this.image,
      this.boxShadow,
      this.borderRadius,
      this.gradient);

  TransitionDecoration clone() {
    return TransitionDecoration(
        this.alpha,
        this.red,
        this.green,
        this.blue,
        this.borderLeftSide.clone(),
        this.borderTopSide.clone(),
        this.borderRightSide.clone(),
        this.borderBottomSide.clone(),
        this.image,
        this.boxShadow,
        this.borderRadius,
        this.gradient);
  }

  BoxDecoration toBoxDecoration() {
    Color color = Color.fromARGB(alpha, red, green, blue);
    if (gradient != null) {
      color = null;
    }
    return BoxDecoration(
        color: color,
        image: image,
        border: Border(
            top: borderTopSide.toBorderSide(),
            right: borderRightSide.toBorderSide(),
            bottom: borderBottomSide.toBorderSide(),
            left: borderLeftSide.toBorderSide()),
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient);
  }

  EdgeInsets getBorderEdgeInsets() {
    return EdgeInsets.fromLTRB(
        borderLeftSide.borderWidth ?? 0,
        borderTopSide.borderWidth ?? 0,
        borderRightSide.borderWidth ?? 0,
        borderBottomSide.borderWidth ?? 0);
  }
}
