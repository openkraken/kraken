/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:math';
import 'dart:ui' show Color;
import 'value.dart';

/// A color in the CIELAB color space.
///
/// The CIELAB color space contains channels for lightness [l],
/// [a] (red and green opponent values), and [b] (blue and
/// yellow opponent values.)
class LabColor {
  /// Lightness represents the black to white value.
  ///
  /// The value ranges from black at `0` to white at `100`.
  final num l;
  /// The red to green opponent color value.
  ///
  /// Green is represented in the negative value range (`-128` to `0`)
  ///
  /// Red is represented in the positive value range (`0` to `127`)
  final num a;
  /// The yellow to blue opponent color value.
  ///
  /// Yellow is represented int he negative value range (`-128` to `0`)
  ///
  /// Blue is represented in the positive value range (`0` to `127`)
  final num b;

  /// A color in the CIELAB color space.
  ///
  /// [l] must be `>= 0` and `<= 100`.
  ///
  /// [a] and [b] must both be `>= -128` and `<= 127`.
  const LabColor(num this.l, num this.a, num this.b);

  num _toXyz(num value, num referenceWhiteValue) {
    num cube = pow(value, 3);
    if (cube > 0.008856) {
      value = cube;
    } else {
      value = (value - 16 / 116) / 7.787;
    }
    return value *= referenceWhiteValue;
  }

  num _toRgb(num value) {
    if (value > 0.0031308) {
      value = 1.055 * pow(value, 1 / 2.4) - 0.055;
    } else {
      value = value * 12.92;
    }
    return value *= 255;
  }

  RgbColor toRgbColor() {
    // To xyz color
    num x = _toXyz(a / 500 + (l + 16) / 116, 95.047) / 100;
    num y = _toXyz((l + 16) / 116, 100) / 100;
    num z = _toXyz((l + 16) / 116 - b / 200, 108.883) / 100;

    // To rgb color
    num rgbR = _toRgb(x * 3.2406 + y * -1.5372 + z * -0.4986);
    num rgbG = _toRgb(x * -0.9689 + y * 1.8758 + z * 0.0415);
    num rgbB = _toRgb(x * 0.0557 + y * -0.2040 + z * 1.0570);

    return RgbColor(rgbR, rgbG, rgbB);
  }
}

class RgbColor {
  final num r;
  final num g;
  final num b;

  /**
   * Creates a [Color] using a vector describing its red, green, and blue
   * values.
   *
   * The value for [r], [g], and [b] should be in the range between 0 and
   * 255 (inclusive).  Values above this range will be assumed to be a value
   * of 255, and values below this range will be assumed to be a value of 0.
   */
  const RgbColor(num this.r, num this.g, num this.b);

  num _toLab(num value, num referenceWhiteValue) {
    value /= referenceWhiteValue;
    if (value > 0.008856) {
      value = pow(value, 1 / 3);
    } else {
      value = (7.787 * value) + 16 / 116;
    }
    return value;
  }

  num _toXyz(num value) {
    if (value > 0.04045) {
      value = pow((value + 0.055) / 1.055, 2.4);
    } else {
      value = value / 12.92;
    }
    return value *= 100;
  }

  LabColor toLabColor() {
    // To xyz color
    num xyzR = _toXyz(r / 255);
    num xyzG = _toXyz(g / 255);
    num xyzB = _toXyz(b / 255);

    num x = xyzR * 0.4124 + xyzG * 0.3576 + xyzB * 0.1805;
    num y = xyzR * 0.2126 + xyzG * 0.7152 + xyzB * 0.0722;
    num z = xyzR * 0.0193 + xyzG * 0.1192 + xyzB * 0.9505;

    // To lab color
    num labX = _toLab(x, 95.047);
    num labY = _toLab(y, 100);
    num labZ = _toLab(z, 108.883);

    num labL = (116 * labY) - 16;
    num labA = 500 * (labX - labY);
    num labB = 200 * (labY - labZ);

    return LabColor(labL, labA, labB);
  }
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#colors
// CSS Color: https://drafts.csswg.org/css-color-4/
// ignore: public_member_api_docs
final RegExp rgbaRexExp = RegExp(
  r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,?(\s*\d*\.?\d+\s*)?\)',
  caseSensitive: false,
  multiLine: false,
);

/// #123
/// #123456
/// rgb(r,g,b)
/// rgba(r,g,b,a)
class CSSColor implements CSSValue<Color> {
  // Use a preprocessed color to cache.
  // Example:
  //   Input = '0 2rpx 4rpx 0 rgba(0,0,0,0.1), 0 25rpx 50rpx 0 rgba(0,0,0,0.15)'
  //   Output = '0 2rpx 4rpx 0 rgba0, 0 25rpx 50rpx 0 rgba1', with color cached:
  //     'rgba0' -> Color(0x19000000), 'rgba1' -> Color(0x26000000)
  // Cache will be terminated after used once.
  static final Map<String, Color> _cachedColor = {};
  static int _cacheCount = 0;

  // ignore: public_member_api_docs
  static String preprocessCSSPropertyWithRGBAColor(String input) {
    var ret = input;
    var match = rgbaRexExp.firstMatch(ret);
    while (match != null) {
      var cacheId = 'rgba$_cacheCount';
      _cachedColor[cacheId] =
          _generateColorFromRGBA(ret.substring(match.start, match.end));
      ret = ret.replaceRange(match.start, match.end, cacheId);
      _cacheCount++;

      match = rgbaRexExp.firstMatch(ret);
    }
    return ret;
  }

  static String convertToHex(Color color) {
    String red = color.red.toRadixString(16).padLeft(2);
    String green = color.green.toRadixString(16).padLeft(2);
    String blue = color.blue.toRadixString(16).padLeft(2);
    return '#${red}${green}${blue}';
  }

  static Color tranformToDarkColor(Color color) {
    // Convert to lab color
    LabColor lab = RgbColor(color.red, color.green, color.blue).toLabColor();
    num invertedL = min(110 - lab.l, 100);
    if (invertedL < lab.l) {
      RgbColor rgb = LabColor(invertedL, lab.a, lab.b).toRgbColor();
      return Color.fromARGB(color.alpha, rgb.r.toInt(), rgb.g.toInt(), rgb.b.toInt());
    } else {
      return color;
    }
  }

  static Color transformToLightColor(Color color) {
    // Convert to lab color
    LabColor lab = RgbColor(color.red, color.green, color.blue).toLabColor();
    num invertedL = min(110 - lab.l, 100);
    if (invertedL > lab.l) {
      RgbColor rgb = LabColor(invertedL, lab.a, lab.b).toRgbColor();
      return Color.fromARGB(color.alpha, rgb.r.toInt(), rgb.g.toInt(), rgb.b.toInt());
    } else {
      return color;
    }
  }

  static Color _generateColorFromRGBA(String input) {
    if (_cachedColor.containsKey(input)) {
      Color ret = _cachedColor[input];
      _cachedColor.remove(input);
      return ret;
    }

    int red = 0;
    int green = 0;
    int blue = 0;
    double alpha = 1.0;
    Iterable<RegExpMatch> matches = rgbaRexExp.allMatches(input);
    if (matches.length == 1) {
      RegExpMatch match = matches.first;
      red = int.tryParse(match[1]) ?? 0;
      green = int.tryParse(match[2]) ?? 0;
      blue = int.tryParse(match[3]) ?? 0;
      if (match[4] != null) {
        alpha = double.tryParse(match[4]) ?? 1.0;
        if (alpha > 1.0) alpha = 1.0;
        if (alpha < 0.0) alpha = 0.0;
      }
    }
    return Color.fromRGBO(red, green, blue, alpha);
  }

  static Color _generateColorFromHex(String hex) {
    int _r = 0;
    int _g = 0;
    int _b = 0;
    int _a = 0xFF;

    if (hex.length == 4) {
      String r = hex.substring(1, 2);
      String g = hex.substring(2, 3);
      String b = hex.substring(3, 4);

      _r = int.parse(r + r, radix: 16);
      _g = int.parse(g + g, radix: 16);
      _b = int.parse(b + b, radix: 16);
    } else if (hex.length == 7) {
      String r = hex.substring(1, 3);
      String g = hex.substring(3, 5);
      String b = hex.substring(5, 7);

      _r = int.parse(r, radix: 16);
      _g = int.parse(g, radix: 16);
      _b = int.parse(b, radix: 16);
    }
    //  255 r
    //  0 g
    //  0 b
    //  255 a
    //  ->
    //  0xFF FF 00 00
    return Color((_a << 24) + (_r << 16) + (_g << 8) + _b);
  }

  static Color generate(String color) {
    if (color == null) return CSSColor.transparent;
    color = color.trim();

    switch (color) {
      case 'black':
        return CSSColor.black;
      case 'silver':
        return CSSColor.silver;
      case 'gray':
        return CSSColor.gray;
      case 'white':
        return CSSColor.white;
      case 'maroon':
        return CSSColor.maroon;
      case 'red':
        return CSSColor.red;
      case 'purple':
        return CSSColor.purple;
      case 'fuchsia':
        return CSSColor.fuchsia;
      case 'green':
        return CSSColor.green;
      case 'lime':
        return CSSColor.lime;
      case 'olive':
        return CSSColor.olive;
      case 'yellow':
        return CSSColor.yellow;
      case 'navy':
        return CSSColor.navy;
      case 'blue':
        return CSSColor.blue;
      case 'teal':
        return CSSColor.teal;
      case 'aqua':
        return CSSColor.aqua;
      case 'aliceblue':
        return CSSColor.aliceblue;
      case 'antiquewhite':
        return CSSColor.antiquewhite;
      case 'aquamarine':
        return CSSColor.aquamarine;
      case 'azure':
        return CSSColor.azure;
      case 'beige':
        return CSSColor.beige;
      case 'bisque':
        return CSSColor.bisque;
      case 'blanchedalmond':
        return CSSColor.blanchedalmond;
      case 'blueviolet':
        return CSSColor.blueviolet;
      case 'brown':
        return CSSColor.brown;
      case 'burlywood':
        return CSSColor.burlywood;
      case 'cadetblue':
        return CSSColor.cadetblue;
      case 'chartreuse':
        return CSSColor.chartreuse;
      case 'chocolate':
        return CSSColor.chocolate;
      case 'coral':
        return CSSColor.coral;
      case 'cornflowerblue':
        return CSSColor.cornflowerblue;
      case 'cornsilk':
        return CSSColor.cornsilk;
      case 'crimson':
        return CSSColor.crimson;
      case 'cyan':
        return CSSColor.cyan;
      case 'darkblue':
        return CSSColor.darkblue;
      case 'darkcyan':
        return CSSColor.darkcyan;
      case 'darkgoldenrod':
        return CSSColor.darkgoldenrod;
      case 'darkgray':
        return CSSColor.darkgray;
      case 'darkgreen':
        return CSSColor.darkgreen;
      case 'darkgrey':
        return CSSColor.darkgrey;
      case 'darkkhaki':
        return CSSColor.darkkhaki;
      case 'darkmagenta':
        return CSSColor.darkmagenta;
      case 'darkolivegreen':
        return CSSColor.darkolivegreen;
      case 'darkorange':
        return CSSColor.darkorange;
      case 'darkorchid':
        return CSSColor.darkorchid;
      case 'darkred':
        return CSSColor.darkred;
      case 'darksalmon':
        return CSSColor.darksalmon;
      case 'darkseagreen':
        return CSSColor.darkseagreen;
      case 'darkslateblue':
        return CSSColor.darkslateblue;
      case 'darkslategray':
        return CSSColor.darkslategray;
      case 'darkslategrey':
        return CSSColor.darkslategrey;
      case 'darkturquoise':
        return CSSColor.darkturquoise;
      case 'darkviolet':
        return CSSColor.darkviolet;
      case 'deeppink':
        return CSSColor.deeppink;
      case 'deepskyblue':
        return CSSColor.deepskyblue;
      case 'dimgray':
        return CSSColor.dimgray;
      case 'dimgrey':
        return CSSColor.dimgrey;
      case 'dodgerblue':
        return CSSColor.dodgerblue;
      case 'firebrick':
        return CSSColor.firebrick;
      case 'floralwhite':
        return CSSColor.floralwhite;
      case 'forestgreen':
        return CSSColor.forestgreen;
      case 'gainsboro':
        return CSSColor.gainsboro;
      case 'ghostwhite':
        return CSSColor.ghostwhite;
      case 'gold':
        return CSSColor.gold;
      case 'goldenrod':
        return CSSColor.goldenrod;
      case 'greenyellow':
        return CSSColor.greenyellow;
      case 'grey':
        return CSSColor.grey;
      case 'honeydew':
        return CSSColor.honeydew;
      case 'hotpink':
        return CSSColor.hotpink;
      case 'indianred':
        return CSSColor.indianred;
      case 'indigo':
        return CSSColor.indigo;
      case 'ivory':
        return CSSColor.ivory;
      case 'khaki':
        return CSSColor.khaki;
      case 'lavender':
        return CSSColor.lavender;
      case 'lavenderblush':
        return CSSColor.lavenderblush;
      case 'lawngreen':
        return CSSColor.lawngreen;
      case 'lemonchiffon':
        return CSSColor.lemonchiffon;
      case 'lightblue':
        return CSSColor.lightblue;
      case 'lightcoral':
        return CSSColor.lightcoral;
      case 'lightcyan':
        return CSSColor.lightcyan;
      case 'lightgoldenrodyellow':
        return CSSColor.lightgoldenrodyellow;
      case 'lightgray':
        return CSSColor.lightgray;
      case 'lightgreen':
        return CSSColor.lightgreen;
      case 'lightgrey':
        return CSSColor.lightgrey;
      case 'lightpink':
        return CSSColor.lightpink;
      case 'lightsalmon':
        return CSSColor.lightsalmon;
      case 'lightseagreen':
        return CSSColor.lightseagreen;
      case 'lightskyblue':
        return CSSColor.lightskyblue;
      case 'lightslategray':
        return CSSColor.lightslategray;
      case 'lightslategrey':
        return CSSColor.lightslategrey;
      case 'lightsteelblue':
        return CSSColor.lightsteelblue;
      case 'lightyellow':
        return CSSColor.lightyellow;
      case 'limegreen':
        return CSSColor.limegreen;
      case 'linen':
        return CSSColor.linen;
      case 'magenta':
        return CSSColor.magenta;
      case 'mediumaquamarine':
        return CSSColor.mediumaquamarine;
      case 'mediumblue':
        return CSSColor.mediumblue;
      case 'mediumorchid':
        return CSSColor.mediumorchid;
      case 'mediumpurple':
        return CSSColor.mediumpurple;
      case 'mediumseagreen':
        return CSSColor.mediumseagreen;
      case 'mediumslateblue':
        return CSSColor.mediumslateblue;
      case 'mediumspringgreen':
        return CSSColor.mediumspringgreen;
      case 'mediumturquoise':
        return CSSColor.mediumturquoise;
      case 'mediumvioletred':
        return CSSColor.mediumvioletred;
      case 'midnightblue':
        return CSSColor.midnightblue;
      case 'mintcream':
        return CSSColor.mintcream;
      case 'mistyrose':
        return CSSColor.mistyrose;
      case 'moccasin':
        return CSSColor.moccasin;
      case 'navajowhite':
        return CSSColor.navajowhite;
      case 'oldlace':
        return CSSColor.oldlace;
      case 'olivedrab':
        return CSSColor.olivedrab;
      case 'orange':
        return CSSColor.orange;
      case 'orangered':
        return CSSColor.orangered;
      case 'orchid':
        return CSSColor.orchid;
      case 'palegoldenrod':
        return CSSColor.palegoldenrod;
      case 'palegreen':
        return CSSColor.palegreen;
      case 'paleturquoise':
        return CSSColor.paleturquoise;
      case 'palevioletred':
        return CSSColor.palevioletred;
      case 'papayawhip':
        return CSSColor.papayawhip;
      case 'peachpuff':
        return CSSColor.peachpuff;
      case 'peru':
        return CSSColor.peru;
      case 'pink':
        return CSSColor.pink;
      case 'plum':
        return CSSColor.plum;
      case 'powderblue':
        return CSSColor.powderblue;
      case 'rosybrown':
        return CSSColor.rosybrown;
      case 'royalblue':
        return CSSColor.royalblue;
      case 'saddlebrown':
        return CSSColor.saddlebrown;
      case 'salmon':
        return CSSColor.salmon;
      case 'sandybrown':
        return CSSColor.sandybrown;
      case 'seagreen':
        return CSSColor.seagreen;
      case 'seashell':
        return CSSColor.seashell;
      case 'sienna':
        return CSSColor.sienna;
      case 'skyblue':
        return CSSColor.skyblue;
      case 'slateblue':
        return CSSColor.slateblue;
      case 'slategray':
        return CSSColor.slategray;
      case 'slategrey':
        return CSSColor.slategrey;
      case 'snow':
        return CSSColor.snow;
      case 'springgreen':
        return CSSColor.springgreen;
      case 'steelblue':
        return CSSColor.steelblue;
      case 'tan':
        return CSSColor.tan;
      case 'thistle':
        return CSSColor.thistle;
      case 'tomato':
        return CSSColor.tomato;
      case 'turquoise':
        return CSSColor.turquoise;
      case 'violet':
        return CSSColor.violet;
      case 'wheat':
        return CSSColor.wheat;
      case 'whitesmoke':
        return CSSColor.whitesmoke;
      case 'yellowgreen':
        return CSSColor.yellowgreen;
      case 'transparent':
        return CSSColor.transparent;
    }

    if (color.startsWith('#')) {
      return _generateColorFromHex(color);
    } else if (color.startsWith('rgb')) {
      return _generateColorFromRGBA(color);
    } else {
      return CSSColor.transparent;
    }
  }

  final String rawInput;
  Color value;

  CSSColor(this.rawInput);

  /// Only support Basic color keywords and Extended color keywords,
  /// for CSS system colors is not recommended for use after CSS3
  /// https://www.w3.org/TR/css-color-3/#html4
  /// https://www.w3.org/TR/css-color-3/#css-system
  /// https://www.w3.org/TR/css-color-3/#svg-color

  // Basic color keywords
  static const Color black = Color(0xFF000000);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gray = Color(0xFF808080);
  static const Color white = Color(0xFFFFFFFF);
  static const Color maroon = Color(0xFF800000);
  static const Color red = Color(0xFFFF0000);
  static const Color purple = Color(0xFF800080);
  static const Color fuchsia = Color(0xFFFF00FF);
  static const Color green = Color(0xFF008000);
  static const Color lime = Color(0xFF00FF00);
  static const Color olive = Color(0xFF808000);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color navy = Color(0xFF000080);
  static const Color blue = Color(0xFF0000FF);
  static const Color teal = Color(0xFF008080);
  static const Color aqua = Color(0xFF00FFFF);

  // Extended color keywords
  static const Color aliceblue = Color(0xFFF0F8FF);
  static const Color antiquewhite = Color(0xFFFAEBD7);
  static const Color aquamarine = Color(0xFF7FFFD4);
  static const Color azure = Color(0xFFF0FFFF);
  static const Color beige = Color(0xFFF5F5DC);
  static const Color bisque = Color(0xFFFFE4C4);
  static const Color blanchedalmond = Color(0xFFFFEBCD);
  static const Color blueviolet = Color(0xFF8A2BE2);
  static const Color brown = Color(0xFFA52A2A);
  static const Color burlywood = Color(0xFFDEB887);
  static const Color cadetblue = Color(0xFF5F9EA0);
  static const Color chartreuse = Color(0xFF7FFF00);
  static const Color chocolate = Color(0xFFD2691E);
  static const Color coral = Color(0xFFFF7F50);
  static const Color cornflowerblue = Color(0xFF6495ED);
  static const Color cornsilk = Color(0xFFFFF8DC);
  static const Color crimson = Color(0xFFDC143C);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color darkblue = Color(0xFF00008B);
  static const Color darkcyan = Color(0xFF008B8B);
  static const Color darkgoldenrod = Color(0xFFB8860B);
  static const Color darkgray = Color(0xFFA9A9A9);
  static const Color darkgreen = Color(0xFF006400);
  static const Color darkgrey = Color(0xFFA9A9A9);
  static const Color darkkhaki = Color(0xFFBDB76B);
  static const Color darkmagenta = Color(0xFF8B008B);
  static const Color darkolivegreen = Color(0xFF556B2F);
  static const Color darkorange = Color(0xFFFF8C00);
  static const Color darkorchid = Color(0xFF9932CC);
  static const Color darkred = Color(0xFF8B0000);
  static const Color darksalmon = Color(0xFFE9967A);
  static const Color darkseagreen = Color(0xFF8FBC8F);
  static const Color darkslateblue = Color(0xFF483D8B);
  static const Color darkslategray = Color(0xFF2F4F4F);
  static const Color darkslategrey = Color(0xFF2F4F4F);
  static const Color darkturquoise = Color(0xFF00CED1);
  static const Color darkviolet = Color(0xFF9400D3);
  static const Color deeppink = Color(0xFFFF1493);
  static const Color deepskyblue = Color(0xFF00BFFF);
  static const Color dimgray = Color(0xFF696969);
  static const Color dimgrey = Color(0xFF696969);
  static const Color dodgerblue = Color(0xFF1E90FF);
  static const Color firebrick = Color(0xFFB22222);
  static const Color floralwhite = Color(0xFFFFFAF0);
  static const Color forestgreen = Color(0xFF228B22);
  static const Color gainsboro = Color(0xFFDCDCDC);
  static const Color ghostwhite = Color(0xFFF8F8FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldenrod = Color(0xFFDAA520);
  static const Color greenyellow = Color(0xFFADFF2F);
  static const Color grey = Color(0xFF808080);
  static const Color honeydew = Color(0xFFF0FFF0);
  static const Color hotpink = Color(0xFFFF69B4);
  static const Color indianred = Color(0xFFCD5C5C);
  static const Color indigo = Color(0xFF4B0082);
  static const Color ivory = Color(0xFFFFFFF0);
  static const Color khaki = Color(0xFFF0E68C);
  static const Color lavender = Color(0xFFE6E6FA);
  static const Color lavenderblush = Color(0xFFFFF0F5);
  static const Color lawngreen = Color(0xFF7CFC00);
  static const Color lemonchiffon = Color(0xFFFFFACD);
  static const Color lightblue = Color(0xFFADD8E6);
  static const Color lightcoral = Color(0xFFF08080);
  static const Color lightcyan = Color(0xFFE0FFFF);
  static const Color lightgoldenrodyellow = Color(0xFFFAFAD2);
  static const Color lightgray = Color(0xFFD3D3D3);
  static const Color lightgreen = Color(0xFF90EE90);
  static const Color lightgrey = Color(0xFFD3D3D3);
  static const Color lightpink = Color(0xFFFFB6C1);
  static const Color lightsalmon = Color(0xFFFFA07A);
  static const Color lightseagreen = Color(0xFF20B2AA);
  static const Color lightskyblue = Color(0xFF87CEFA);
  static const Color lightslategray = Color(0xFF778899);
  static const Color lightslategrey = Color(0xFF778899);
  static const Color lightsteelblue = Color(0xFFB0C4DE);
  static const Color lightyellow = Color(0xFFFFFFE0);
  static const Color limegreen = Color(0xFF32CD32);
  static const Color linen = Color(0xFFFAF0E6);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color mediumaquamarine = Color(0xFF66CDAA);
  static const Color mediumblue = Color(0xFF0000CD);
  static const Color mediumorchid = Color(0xFFBA55D3);
  static const Color mediumpurple = Color(0xFF9370DB);
  static const Color mediumseagreen = Color(0xFF3CB371);
  static const Color mediumslateblue = Color(0xFF7B68EE);
  static const Color mediumspringgreen = Color(0xFF00FA9A);
  static const Color mediumturquoise = Color(0xFF48D1CC);
  static const Color mediumvioletred = Color(0xFFC71585);
  static const Color midnightblue = Color(0xFF191970);
  static const Color mintcream = Color(0xFFF5FFFA);
  static const Color mistyrose = Color(0xFFFFE4E1);
  static const Color moccasin = Color(0xFFFFE4B5);
  static const Color navajowhite = Color(0xFFFFDEAD);
  static const Color oldlace = Color(0xFFFDF5E6);
  static const Color olivedrab = Color(0xFF6B8E23);
  static const Color orange = Color(0xFFFFA500);
  static const Color orangered = Color(0xFFFF4500);
  static const Color orchid = Color(0xFFDA70D6);
  static const Color palegoldenrod = Color(0xFFEEE8AA);
  static const Color palegreen = Color(0xFF98FB98);
  static const Color paleturquoise = Color(0xFFAFEEEE);
  static const Color palevioletred = Color(0xFFDB7093);
  static const Color papayawhip = Color(0xFFFFEFD5);
  static const Color peachpuff = Color(0xFFFFDAB9);
  static const Color peru = Color(0xFFCD853F);
  static const Color pink = Color(0xFFFFC0CB);
  static const Color plum = Color(0xFFDDA0DD);
  static const Color powderblue = Color(0xFFB0E0E6);
  static const Color rosybrown = Color(0xFFBC8F8F);
  static const Color royalblue = Color(0xFF4169E1);
  static const Color saddlebrown = Color(0xFF8B4513);
  static const Color salmon = Color(0xFFFA8072);
  static const Color sandybrown = Color(0xFFF4A460);
  static const Color seagreen = Color(0xFF2E8B57);
  static const Color seashell = Color(0xFFFFF5EE);
  static const Color sienna = Color(0xFFA0522D);
  static const Color skyblue = Color(0xFF87CEEB);
  static const Color slateblue = Color(0xFF6A5ACD);
  static const Color slategray = Color(0xFF708090);
  static const Color slategrey = Color(0xFF708090);
  static const Color snow = Color(0xFFFFFAFA);
  static const Color springgreen = Color(0xFF00FF7F);
  static const Color steelblue = Color(0xFF4682B4);
  static const Color tan = Color(0xFFD2B48C);
  static const Color thistle = Color(0xFFD8BFD8);
  static const Color tomato = Color(0xFFFF6347);
  static const Color turquoise = Color(0xFF40E0D0);
  static const Color violet = Color(0xFFEE82EE);
  static const Color wheat = Color(0xFFF5DEB3);
  static const Color whitesmoke = Color(0xFFF5F5F5);
  static const Color yellowgreen = Color(0xFF9ACD32);

  static const Color transparent = Color(0x00000000);

  bool _parsed = false;
  @override
  void parse() {
    if (!_parsed) value = CSSColor.generate(rawInput);
    _parsed = true;
  }

  @override
  Color get computedValue {
    // Lazy parse to get performance improved.
    parse();

    return value;
  }

  /// https://drafts.csswg.org/css-color-3/#valuea-def-color
  @override
  String get serializedValue {
    // Lazy parse to get performance improved.
    parse();

    var rgb = '${value.red}, ${value.green}, ${value.blue}';
    if (value.alpha == 255) {
      return 'rgb($rgb)';
    } else {
      return 'rgba($rgb, ${value.opacity})';
    }
  }
}
