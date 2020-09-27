/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' show ImageFilter;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

const String GRAYSCALE = 'grayscale';
const String SEPIA = 'sepia';
const String BLUR = 'blur';

// Calc 5x5 matrix multiplcation.
List<double> _multiplyMatrix5(List<double> a, List<double> b) {
  if (a == null || b == null) {
    return a ?? b;
  }

  if (a.length != b.length) {
    throw new FlutterError('Matrix length should be same.');
  }

  if (a.length != 25) {
    throw new FlutterError('Matrix5 size is not correct.');
  }

  var a00 = a[0];
  var a01 = a[1];
  var a02 = a[2];
  var a03 = a[3];
  var a04 = a[4];
  var a10 = a[5];
  var a11 = a[6];
  var a12 = a[7];
  var a13 = a[8];
  var a14 = a[9];
  var a20 = a[10];
  var a21 = a[11];
  var a22 = a[12];
  var a23 = a[13];
  var a24 = a[14];
  var a30 = a[15];
  var a31 = a[16];
  var a32 = a[17];
  var a33 = a[18];
  var a34 = a[19];
  var a40 = a[20];
  var a41 = a[21];
  var a42 = a[22];
  var a43 = a[23];
  var a44 = a[24];

  var b00 = b[0];
  var b01 = b[1];
  var b02 = b[2];
  var b03 = b[3];
  var b04 = b[4];
  var b10 = b[5];
  var b11 = b[6];
  var b12 = b[7];
  var b13 = b[8];
  var b14 = b[9];
  var b20 = b[10];
  var b21 = b[11];
  var b22 = b[12];
  var b23 = b[13];
  var b24 = b[14];
  var b30 = b[15];
  var b31 = b[16];
  var b32 = b[17];
  var b33 = b[18];
  var b34 = b[19];
  var b40 = b[20];
  var b41 = b[21];
  var b42 = b[22];
  var b43 = b[23];
  var b44 = b[24];

  return [
    a00*b00 + a00*b01 + a00*b02 + a00*b03 + a00*b04, a01*b00 + a01*b01 + a01*b02 + a01*b03 + a01*b04, a02*b00 + a02*b01 + a02*b02 + a02*b03 + a02*b04, a03*b00 + a03*b01 + a03*b02 + a03*b03 + a03*b04, a04*b00 + a04*b01 + a04*b02 + a04*b03 + a04*b04,
    a10*b00 + a10*b01 + a10*b02 + a10*b03 + a10*b04, a11*b00 + a11*b01 + a11*b02 + a11*b03 + a11*b04, a12*b00 + a12*b01 + a12*b02 + a12*b03 + a12*b04, a13*b00 + a13*b01 + a13*b02 + a13*b03 + a13*b04, a14*b00 + a14*b01 + a14*b02 + a14*b03 + a14*b04,
    a20*b00 + a20*b01 + a20*b02 + a20*b03 + a20*b04, a21*b00 + a21*b01 + a21*b02 + a21*b03 + a21*b04, a22*b00 + a22*b01 + a22*b02 + a22*b03 + a22*b04, a23*b00 + a23*b01 + a23*b02 + a23*b03 + a23*b04, a24*b00 + a24*b01 + a24*b02 + a24*b03 + a24*b04,
    a30*b00 + a30*b01 + a30*b02 + a30*b03 + a30*b04, a31*b00 + a31*b01 + a31*b02 + a31*b03 + a31*b04, a32*b00 + a32*b01 + a32*b02 + a32*b03 + a32*b04, a33*b00 + a33*b01 + a33*b02 + a33*b03 + a33*b04, a34*b00 + a34*b01 + a34*b02 + a34*b03 + a34*b04,
    a40*b00 + a40*b01 + a40*b02 + a40*b03 + a40*b04, a41*b00 + a41*b01 + a41*b02 + a41*b03 + a41*b04, a42*b00 + a42*b01 + a42*b02 + a42*b03 + a42*b04, a43*b00 + a43*b01 + a43*b02 + a43*b03 + a43*b04, a44*b00 + a44*b01 + a44*b02 + a44*b03 + a44*b04,
  ];
}

/// Impl W3C Filter Effects Spec:
///   https://www.w3.org/TR/filter-effects-1/#definitions
mixin CSSFilterEffectsMixin {

  // Get the color filter.
  // eg: 'grayscale(1) grayscale(0.5)' -> matrix5(grayscale(1)) · matrix5(grayscale(0.5))
  static ColorFilter _parseColorFilters(List<CSSFunctionalNotation> functions) {
    List<double> matrix5 = null;
    if (functions != null && functions.length > 0) {
      for (int i = 0; i < functions.length; i ++) {
        CSSFunctionalNotation f = functions[i];
        double amount = double.tryParse(f.args.first) ?? 1;
        // amount should be range [0, 1]
        amount = amount > 1 ? 1 : (amount < 0 ? 0 : amount);

        switch (f.name.toLowerCase()) {
          case GRAYSCALE:
            // Formula from: https://www.w3.org/TR/filter-effects-1/#grayscaleEquivalent
            matrix5 = _multiplyMatrix5(matrix5, <double>[
              (0.2126 + 0.7874 * (1 - amount)), (0.7152 - 0.7152  * (1 - amount)), (0.0722 - 0.0722 * (1 - amount)), 0, 0,
              (0.2126 - 0.2126 * (1 - amount)), (0.7152 + 0.2848  * (1 - amount)), (0.0722 - 0.0722 * (1 - amount)), 0, 0,
              (0.2126 - 0.2126 * (1 - amount)), (0.7152 - 0.7152  * (1 - amount)), (0.0722 + 0.9278 * (1 - amount)), 0, 0,
              0, 0, 0, 1, 0,
              0, 0, 0, 0, 1
            ]);
            break;
          case SEPIA:
            // Formula from: https://www.w3.org/TR/filter-effects-1/#sepiaEquivalent
            matrix5 = _multiplyMatrix5(matrix5, <double>[
              (0.393 + 0.607 * (1 - amount)), (0.769 - 0.769 * (1 - amount)), (0.189 - 0.189 * (1 - amount)), 0, 0,
              (0.349 - 0.349 * (1 - amount)), (0.686 + 0.314 * (1 - amount)), (0.168 - 0.168 * (1 - amount)), 0, 0,
              (0.272 - 0.272 * (1 - amount)), (0.534 - 0.534 * (1 - amount)), (0.131 + 0.869 * (1 - amount)), 0, 0,
              0, 0, 0, 1, 0,
              0, 0, 0, 0, 1
            ]);
            break;
        }
      }
    }

    // Each line is R|G|B|A|1, the last line not works.
    // See https://www.w3.org/TR/filter-effects-1/#funcdef-filter-grayscale
    return matrix5 != null ? ColorFilter.matrix(matrix5.sublist(0, 20)) : null;
  }

  // Get the image filter.
  static ImageFilter _parseImageFilters(List<CSSFunctionalNotation> functions) {
    if (functions != null && functions.length > 0) {
      for (int i = 0; i < functions.length; i ++) {
        CSSFunctionalNotation f = functions[i];
        switch (f.name.toLowerCase()) {
          case BLUR:
            double amount = CSSLength.parseLength(f.args.first);
            return ImageFilter.blur(sigmaX: amount, sigmaY: amount);
        }
      }
    }
    return null;
  }

  void updateFilterEffects(RenderBoxModel renderBoxModel, String filter) {
    assert(renderBoxModel != null);
    List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(filter);
    ColorFilter colorFilter = _parseColorFilters(functions);
    if (colorFilter != null) {
      renderBoxModel.colorFilter = colorFilter;
    }

    ImageFilter imageFilter = _parseImageFilters(functions);
    if (imageFilter != null) {
      renderBoxModel.imageFilter = imageFilter;
    }

    if (!kReleaseMode) {
      if (colorFilter == null && imageFilter == null) {
        print('[WARNING] Parse CSS Filter failed or not supported: "$filter"');
        String supportedFilters = '$GRAYSCALE $SEPIA $BLUR';
        print('Kraken only support following filters: $supportedFilters');
      }
    }
  }
}
