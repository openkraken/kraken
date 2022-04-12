/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'dart:math';

import 'package:quiver/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/css.dart';

/// Only support Basic color keywords and Extended color keywords,
/// for CSS system colors is not recommended for use after CSS3
const Map<String, int> _namedColors = {
  'transparent': 0x00000000,
  'aliceblue': 0xFFF0F8FF,
  'antiquewhite': 0xFFFAEBD7,
  'aqua': 0xFF00FFFF,
  'aquamarine': 0xFF7FFFD4,
  'azure': 0xFFF0FFFF,
  'beige': 0xFFF5F5DC,
  'bisque': 0xFFFFE4C4,
  'black': 0xFF000000,
  'blanchedalmond': 0xFFFFEBCD,
  'blue': 0xFF0000FF,
  'blueviolet': 0xFF8A2BE2,
  'brown': 0xFFA52A2A,
  'burlywood': 0xFFDEB887,
  'cadetblue': 0xFF5F9EA0,
  'chartreuse': 0xFF7FFF00,
  'chocolate': 0xFFD2691E,
  'coral': 0xFFFF7F50,
  'cornflowerblue': 0xFF6495ED,
  'cornsilk': 0xFFFFF8DC,
  'crimson': 0xFFDC143C,
  'cyan': 0xFF00FFFF,
  'darkblue': 0xFF00008B,
  'darkcyan': 0xFF008B8B,
  'darkgoldenrod': 0xFFB8860B,
  'darkgray': 0xFFA9A9A9,
  'darkgreen': 0xFF006400,
  'darkgrey': 0xFFA9A9A9,
  'darkkhaki': 0xFFBDB76B,
  'darkmagenta': 0xFF8B008B,
  'darkolivegreen': 0xFF556B2F,
  'darkorange': 0xFFFF8C00,
  'darkorchid': 0xFF9932CC,
  'darkred': 0xFF8B0000,
  'darksalmon': 0xFFE9967A,
  'darkseagreen': 0xFF8FBC8F,
  'darkslateblue': 0xFF483D8B,
  'darkslategray': 0xFF2F4F4F,
  'darkslategrey': 0xFF2F4F4F,
  'darkturquoise': 0xFF00CED1,
  'darkviolet': 0xFF9400D3,
  'deeppink': 0xFFFF1493,
  'deepskyblue': 0xFF00BFFF,
  'dimgray': 0xFF696969,
  'dimgrey': 0xFF696969,
  'dodgerblue': 0xFF1E90FF,
  'firebrick': 0xFFB22222,
  'floralwhite': 0xFFFFFAF0,
  'forestgreen': 0xFF228B22,
  'fuchsia': 0xFFFF00FF,
  'gainsboro': 0xFFDCDCDC,
  'ghostwhite': 0xFFF8F8FF,
  'gold': 0xFFFFD700,
  'goldenrod': 0xFFDAA520,
  'gray': 0xFF808080,
  'green': 0xFF008000,
  'greenyellow': 0xFFADFF2F,
  'grey': 0xFF808080,
  'honeydew': 0xFFF0FFF0,
  'hotpink': 0xFFFF69B4,
  'indianred': 0xFFCD5C5C,
  'indigo': 0xFF4B0082,
  'ivory': 0xFFFFFFF0,
  'khaki': 0xFFF0E68C,
  'lavender': 0xFFE6E6FA,
  'lavenderblush': 0xFFFFF0F5,
  'lawngreen': 0xFF7CFC00,
  'lemonchiffon': 0xFFFFFACD,
  'lightblue': 0xFFADD8E6,
  'lightcoral': 0xFFF08080,
  'lightcyan': 0xFFE0FFFF,
  'lightgoldenrodyellow': 0xFFFAFAD2,
  'lightgray': 0xFFD3D3D3,
  'lightgreen': 0xFF90EE90,
  'lightgrey': 0xFFD3D3D3,
  'lightpink': 0xFFFFB6C1,
  'lightsalmon': 0xFFFFA07A,
  'lightseagreen': 0xFF20B2AA,
  'lightskyblue': 0xFF87CEFA,
  'lightslategray': 0xFF778899,
  'lightslategrey': 0xFF778899,
  'lightsteelblue': 0xFFB0C4DE,
  'lightyellow': 0xFFFFFFE0,
  'lime': 0xFF00FF00,
  'limegreen': 0xFF32CD32,
  'linen': 0xFFFAF0E6,
  'magenta': 0xFFFF00FF,
  'maroon': 0xFF800000,
  'mediumaquamarine': 0xFF66CDAA,
  'mediumblue': 0xFF0000CD,
  'mediumorchid': 0xFFBA55D3,
  'mediumpurple': 0xFF9370DB,
  'mediumseagreen': 0xFF3CB371,
  'mediumslateblue': 0xFF7B68EE,
  'mediumspringgreen': 0xFF00FA9A,
  'mediumturquoise': 0xFF48D1CC,
  'mediumvioletred': 0xFFC71585,
  'midnightblue': 0xFF191970,
  'mintcream': 0xFFF5FFFA,
  'mistyrose': 0xFFFFE4E1,
  'moccasin': 0xFFFFE4B5,
  'navajowhite': 0xFFFFDEAD,
  'navy': 0xFF000080,
  'oldlace': 0xFFFDF5E6,
  'olive': 0xFF808000,
  'olivedrab': 0xFF6B8E23,
  'orange': 0xFFFFA500,
  'orangered': 0xFFFF4500,
  'orchid': 0xFFDA70D6,
  'palegoldenrod': 0xFFEEE8AA,
  'palegreen': 0xFF98FB98,
  'paleturquoise': 0xFFAFEEEE,
  'palevioletred': 0xFFDB7093,
  'papayawhip': 0xFFFFEFD5,
  'peachpuff': 0xFFFFDAB9,
  'peru': 0xFFCD853F,
  'pink': 0xFFFFC0CB,
  'plum': 0xFFDDA0DD,
  'powderblue': 0xFFB0E0E6,
  'purple': 0xFF800080,
  'rebeccapurple': 0xFF663399,
  'red': 0xFFFF0000,
  'rosybrown': 0xFFBC8F8F,
  'royalblue': 0xFF4169E1,
  'saddlebrown': 0xFF8B4513,
  'salmon': 0xFFFA8072,
  'sandybrown': 0xFFF4A460,
  'seagreen': 0xFF2E8B57,
  'seashell': 0xFFFFF5EE,
  'sienna': 0xFFA0522D,
  'silver': 0xFFC0C0C0,
  'skyblue': 0xFF87CEEB,
  'slateblue': 0xFF6A5ACD,
  'slategray': 0xFF708090,
  'slategrey': 0xFF708090,
  'snow': 0xFFFFFAFA,
  'springgreen': 0xFF00FF7F,
  'steelblue': 0xFF4682B4,
  'tan': 0xFFD2B48C,
  'teal': 0xFF008080,
  'thistle': 0xFFD8BFD8,
  'tomato': 0xFFFF6347,
  'turquoise': 0xFF40E0D0,
  'violet': 0xFFEE82EE,
  'wheat': 0xFFF5DEB3,
  'white': 0xFFFFFFFF,
  'whitesmoke': 0xFFF5F5F5,
  'yellow': 0xFFFFFF00,
  'yellowgreen': 0xFF9ACD32,
};

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#colors
// CSS Color: https://drafts.csswg.org/css-color-4/
// ignore: public_member_api_docs
final _colorHexRegExp = RegExp(r'^#([a-f0-9]{3,8})$', caseSensitive: false);
final _colorHslRegExp =
    RegExp(r'^(hsla?)\(([0-9.-]+)(deg|rad|grad|turn)?[,\s]+([0-9.]+%)[,\s]+([0-9.]+%)([,\s/]+([0-9.]+%?))?\s*\)$');
final _colorRgbRegExp =
    RegExp(r'^(rgba?)\(([+-]?[0-9.]+%?)[,\s]+([+-]?[0-9.]+%?)[,\s]+([+-]?[0-9.]+%?)([,\s/]+([+-]?[0-9.]+%?))?\s*\)$');

final LinkedLruHashMap<String, Color> _cachedParsedColor = LinkedLruHashMap(maximumSize: 100);
/// #123
/// #123456
/// rgb(r,g,b)
/// rgba(r,g,b,a)
class CSSColor {
  static const Color transparent = Color(0x00000000);
  static const Color initial = Color(0xFF000000);
  static const String INITIAL_COLOR = 'black';
  static const String RGB = 'rgb';
  static const String HSL = 'hsl';

  // Use a preprocessed color to cache.
  // Example:
  //   Input = '0 2rpx 4rpx 0 rgba(0,0,0,0.1), 0 25rpx 50rpx 0 rgba(0,0,0,0.15)'
  //   Output = '0 2rpx 4rpx 0 rgba0, 0 25rpx 50rpx 0 rgba1', with color cached:
  //     'rgba0' -> Color(0x19000000), 'rgba1' -> Color(0x26000000)
  // Cache will be terminated after used once.


  static String convertToHex(Color color) {
    String red = color.red.toRadixString(16).padLeft(2);
    String green = color.green.toRadixString(16).padLeft(2);
    String blue = color.blue.toRadixString(16).padLeft(2);
    return '#$red$green$blue';
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

  static bool isColor(String color) {
    return color == CURRENT_COLOR || parseColor(color) != null;
  }

  static Color? resolveColor(String color, RenderStyle renderStyle, String propertyName) {
    if (color == CURRENT_COLOR) {
      if (propertyName == COLOR) {
        return null;
      }
      // Update property that deps current color.
      renderStyle.addColorRelativeProperty(propertyName);
      return renderStyle.color;
    }
    return parseColor(color);
  }

  static Color? parseColor(String color) {
    color = color.trim().toLowerCase();

    if (color == TRANSPARENT) {
      return CSSColor.transparent;
    } else if (_cachedParsedColor.containsKey(color)) {
      return _cachedParsedColor[color];
    }

    Color? parsed;
    if (color.startsWith('#')) {
      final hexMatch = _colorHexRegExp.firstMatch(color);
      if (hexMatch != null) {
        final hex = hexMatch[1]!.toUpperCase();
        // https://drafts.csswg.org/css-color-4/#hex-notation
        switch (hex.length) {
          case 3:
            parsed = Color(int.parse('0xFF${_x2(hex)}'));
            break;
          case 4:
            final alpha = hex[3];
            final rgb = hex.substring(0, 3);
            parsed = Color(int.parse('0x${_x2(alpha)}${_x2(rgb)}'));
            break;
          case 6:
            parsed = Color(int.parse('0xFF$hex'));
            break;
          case 8:
            final alpha = hex.substring(6, 8);
            final rgb = hex.substring(0, 6);
            parsed = Color(int.parse('0x$alpha$rgb'));
            break;
        }
      }
    } else if (color.startsWith(RGB)) {
      final rgbMatch = _colorRgbRegExp.firstMatch(color);
      if (rgbMatch != null) {
        final double? rgbR = _parseColorPart(rgbMatch[2]!, 0, 255);
        final double? rgbG = _parseColorPart(rgbMatch[3]!, 0, 255);
        final double? rgbB = _parseColorPart(rgbMatch[4]!, 0, 255);
        final double? rgbO = rgbMatch[6] != null ? _parseColorPart(rgbMatch[6]!, 0, 1) : 1;
        if (rgbR != null && rgbG != null && rgbB != null && rgbO != null) {
          parsed = Color.fromRGBO(rgbR.round(), rgbG.round(), rgbB.round(), rgbO);
        }
      }
    } else if (color.startsWith(HSL)) {
      final hslMatch = _colorHslRegExp.firstMatch(color);
      if (hslMatch != null) {
        final hslH = _parseColorHue(hslMatch[2]!, hslMatch[3]);
        final hslS = _parseColorPart(hslMatch[4]!, 0, 1);
        final hslL = _parseColorPart(hslMatch[5]!, 0, 1);
        final hslA = hslMatch[7] != null ? _parseColorPart(hslMatch[7]!, 0, 1) : 1;
        if (hslH != null && hslS != null && hslL != null && hslA != null) {
          parsed = HSLColor.fromAHSL(hslA as double, hslH, hslS, hslL).toColor();
        }
      }
    } else if (_namedColors.containsKey(color)) {
      parsed = Color(_namedColors[color]!);
    }

    if (parsed != null) {
      _cachedParsedColor[color] = parsed;
    }

    return parsed;
  }

  Color? value;
}

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
  const LabColor(this.l, this.a, this.b);

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

  /// Creates a [Color] using a vector describing its red, green, and blue
  /// values.
  ///
  /// The value for [r], [g], and [b] should be in the range between 0 and
  /// 255 (inclusive).  Values above this range will be assumed to be a value
  /// of 255, and values below this range will be assumed to be a value of 0.
  const RgbColor(this.r, this.g, this.b);

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

String _x2(String value) {
  final sb = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    sb.write(value[i] * 2);
  }
  return sb.toString();
}

double? _parseColorPart(String value, double min, double max) {
  double? v;

  if (value.endsWith('%')) {
    final p = double.tryParse(value.substring(0, value.length - 1));
    if (p == null) return null;
    v = p / 100.0 * max;
  }

  v ??= double.tryParse(value);

  return v! < min ? min : (v > max ? max : v);
}

double? _parseColorHue(String number, String? unit) {
  final v = double.tryParse(number);
  if (v == null) return null;

  double deg;
  switch (unit) {
    case 'rad':
      final rad = v;
      deg = rad * (180 / pi);
      break;
    case 'grad':
      final grad = v;
      deg = grad * 0.9;
      break;
    case 'turn':
      final turn = v;
      deg = turn * 360;
      break;
    default:
      deg = v;
  }

  while (deg < 0) {
    deg += 360;
  }

  return deg % 360;
}
