/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui' show Color;
import 'package:meta/meta.dart';

final RegExp RGBARexExp = RegExp(
  r'rgba?\((\d+),(\d+),(\d+),?(\d*\.\d+)?\)',
  caseSensitive: false,
  multiLine: false,
);

/// #123
/// #123456
/// rgb(r,g,b)
/// rgba(r,g,b,a)
@immutable
class WebColor {
  // Use a preprocessed color to cache.
  // Eg: input = '0 2rpx 4rpx 0 rgba(0,0,0,0.1), 0 25rpx 50rpx 0 rgba(0,0,0,0.15)'
  // Output = '0 2rpx 4rpx 0 rgba0, 0 25rpx 50rpx 0 rgba1', with color cached:
  // 'rgba0' -> Color(0x19000000), 'rgba1' -> Color(0x26000000)
  // Cache will be terminated after used once.
  static Map<String, Color> _cachedColor = {};
  static int _cacheCount = 0;
  static String preprocessCSSPropertyWithRGBAColor(String input) {
    String ret = input;
    RegExpMatch match = RGBARexExp.firstMatch(ret);
    while (match != null) {
      String cacheId = 'rgba' + _cacheCount.toString();
      _cachedColor[cacheId] =
          generateRGBAColor(ret.substring(match.start, match.end));
      ret = ret.replaceRange(match.start, match.end, cacheId);
      _cacheCount++;

      match = RGBARexExp.firstMatch(ret);
    }
    return ret;
  }

  static String convertToHex(Color color) {
    String red = color.red.toRadixString(16).padLeft(2);
    String green = color.green.toRadixString(16).padLeft(2);
    String blue = color.blue.toRadixString(16).padLeft(2);
    return '#${red}${green}${blue}';
  }

  static Color generateRGBAColor(String input) {
    if (_cachedColor.containsKey(input)) {
      Color ret = _cachedColor[input];
      _cachedColor.remove(input);
      return ret;
    }

    int r = 0;
    int g = 0;
    int b = 0;
    double opacity = 1.0;
    Iterable<RegExpMatch> matches = RGBARexExp.allMatches(input);
    if (matches.length == 1) {
      RegExpMatch match = matches.first;
      r = int.parse(match[1]);
      g = int.parse(match[2]);
      b = int.parse(match[3]);
      if (match[4] != null) {
        opacity = double.parse(match[4]);
      }
    }
    return Color.fromRGBO(r, g, b, opacity);
  }

  static Color generateHexColor(String hex) {
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
    if (color == null) return WebColor.transparent;
    color = color.trim();

    switch (color) {
      case 'black':
        return WebColor.black;
      case 'silver':
        return WebColor.silver;
      case 'gray':
        return WebColor.gray;
      case 'white':
        return WebColor.white;
      case 'maroon':
        return WebColor.maroon;
      case 'red':
        return WebColor.red;
      case 'purple':
        return WebColor.purple;
      case 'fuchsia':
        return WebColor.fuchsia;
      case 'green':
        return WebColor.green;
      case 'lime':
        return WebColor.lime;
      case 'olive':
        return WebColor.olive;
      case 'yellow':
        return WebColor.yellow;
      case 'navy':
        return WebColor.navy;
      case 'blue':
        return WebColor.blue;
      case 'teal':
        return WebColor.teal;
      case 'aqua':
        return WebColor.aqua;
      case 'aliceblue':
        return WebColor.aliceblue;
      case 'antiquewhite':
        return WebColor.antiquewhite;
      case 'aquamarine':
        return WebColor.aquamarine;
      case 'azure':
        return WebColor.azure;
      case 'beige':
        return WebColor.beige;
      case 'bisque':
        return WebColor.bisque;
      case 'blanchedalmond':
        return WebColor.blanchedalmond;
      case 'blueviolet':
        return WebColor.blueviolet;
      case 'brown':
        return WebColor.brown;
      case 'burlywood':
        return WebColor.burlywood;
      case 'cadetblue':
        return WebColor.cadetblue;
      case 'chartreuse':
        return WebColor.chartreuse;
      case 'chocolate':
        return WebColor.chocolate;
      case 'coral':
        return WebColor.coral;
      case 'cornflowerblue':
        return WebColor.cornflowerblue;
      case 'cornsilk':
        return WebColor.cornsilk;
      case 'crimson':
        return WebColor.crimson;
      case 'cyan':
        return WebColor.cyan;
      case 'darkblue':
        return WebColor.darkblue;
      case 'darkcyan':
        return WebColor.darkcyan;
      case 'darkgoldenrod':
        return WebColor.darkgoldenrod;
      case 'darkgray':
        return WebColor.darkgray;
      case 'darkgreen':
        return WebColor.darkgreen;
      case 'darkgrey':
        return WebColor.darkgrey;
      case 'darkkhaki':
        return WebColor.darkkhaki;
      case 'darkmagenta':
        return WebColor.darkmagenta;
      case 'darkolivegreen':
        return WebColor.darkolivegreen;
      case 'darkorange':
        return WebColor.darkorange;
      case 'darkorchid':
        return WebColor.darkorchid;
      case 'darkred':
        return WebColor.darkred;
      case 'darksalmon':
        return WebColor.darksalmon;
      case 'darkseagreen':
        return WebColor.darkseagreen;
      case 'darkslateblue':
        return WebColor.darkslateblue;
      case 'darkslategray':
        return WebColor.darkslategray;
      case 'darkslategrey':
        return WebColor.darkslategrey;
      case 'darkturquoise':
        return WebColor.darkturquoise;
      case 'darkviolet':
        return WebColor.darkviolet;
      case 'deeppink':
        return WebColor.deeppink;
      case 'deepskyblue':
        return WebColor.deepskyblue;
      case 'dimgray':
        return WebColor.dimgray;
      case 'dimgrey':
        return WebColor.dimgrey;
      case 'dodgerblue':
        return WebColor.dodgerblue;
      case 'firebrick':
        return WebColor.firebrick;
      case 'floralwhite':
        return WebColor.floralwhite;
      case 'forestgreen':
        return WebColor.forestgreen;
      case 'gainsboro':
        return WebColor.gainsboro;
      case 'ghostwhite':
        return WebColor.ghostwhite;
      case 'gold':
        return WebColor.gold;
      case 'goldenrod':
        return WebColor.goldenrod;
      case 'greenyellow':
        return WebColor.greenyellow;
      case 'grey':
        return WebColor.grey;
      case 'honeydew':
        return WebColor.honeydew;
      case 'hotpink':
        return WebColor.hotpink;
      case 'indianred':
        return WebColor.indianred;
      case 'indigo':
        return WebColor.indigo;
      case 'ivory':
        return WebColor.ivory;
      case 'khaki':
        return WebColor.khaki;
      case 'lavender':
        return WebColor.lavender;
      case 'lavenderblush':
        return WebColor.lavenderblush;
      case 'lawngreen':
        return WebColor.lawngreen;
      case 'lemonchiffon':
        return WebColor.lemonchiffon;
      case 'lightblue':
        return WebColor.lightblue;
      case 'lightcoral':
        return WebColor.lightcoral;
      case 'lightcyan':
        return WebColor.lightcyan;
      case 'lightgoldenrodyellow':
        return WebColor.lightgoldenrodyellow;
      case 'lightgray':
        return WebColor.lightgray;
      case 'lightgreen':
        return WebColor.lightgreen;
      case 'lightgrey':
        return WebColor.lightgrey;
      case 'lightpink':
        return WebColor.lightpink;
      case 'lightsalmon':
        return WebColor.lightsalmon;
      case 'lightseagreen':
        return WebColor.lightseagreen;
      case 'lightskyblue':
        return WebColor.lightskyblue;
      case 'lightslategray':
        return WebColor.lightslategray;
      case 'lightslategrey':
        return WebColor.lightslategrey;
      case 'lightsteelblue':
        return WebColor.lightsteelblue;
      case 'lightyellow':
        return WebColor.lightyellow;
      case 'limegreen':
        return WebColor.limegreen;
      case 'linen':
        return WebColor.linen;
      case 'magenta':
        return WebColor.magenta;
      case 'mediumaquamarine':
        return WebColor.mediumaquamarine;
      case 'mediumblue':
        return WebColor.mediumblue;
      case 'mediumorchid':
        return WebColor.mediumorchid;
      case 'mediumpurple':
        return WebColor.mediumpurple;
      case 'mediumseagreen':
        return WebColor.mediumseagreen;
      case 'mediumslateblue':
        return WebColor.mediumslateblue;
      case 'mediumspringgreen':
        return WebColor.mediumspringgreen;
      case 'mediumturquoise':
        return WebColor.mediumturquoise;
      case 'mediumvioletred':
        return WebColor.mediumvioletred;
      case 'midnightblue':
        return WebColor.midnightblue;
      case 'mintcream':
        return WebColor.mintcream;
      case 'mistyrose':
        return WebColor.mistyrose;
      case 'moccasin':
        return WebColor.moccasin;
      case 'navajowhite':
        return WebColor.navajowhite;
      case 'oldlace':
        return WebColor.oldlace;
      case 'olivedrab':
        return WebColor.olivedrab;
      case 'orange':
        return WebColor.orange;
      case 'orangered':
        return WebColor.orangered;
      case 'orchid':
        return WebColor.orchid;
      case 'palegoldenrod':
        return WebColor.palegoldenrod;
      case 'palegreen':
        return WebColor.palegreen;
      case 'paleturquoise':
        return WebColor.paleturquoise;
      case 'palevioletred':
        return WebColor.palevioletred;
      case 'papayawhip':
        return WebColor.papayawhip;
      case 'peachpuff':
        return WebColor.peachpuff;
      case 'peru':
        return WebColor.peru;
      case 'pink':
        return WebColor.pink;
      case 'plum':
        return WebColor.plum;
      case 'powderblue':
        return WebColor.powderblue;
      case 'rosybrown':
        return WebColor.rosybrown;
      case 'royalblue':
        return WebColor.royalblue;
      case 'saddlebrown':
        return WebColor.saddlebrown;
      case 'salmon':
        return WebColor.salmon;
      case 'sandybrown':
        return WebColor.sandybrown;
      case 'seagreen':
        return WebColor.seagreen;
      case 'seashell':
        return WebColor.seashell;
      case 'sienna':
        return WebColor.sienna;
      case 'skyblue':
        return WebColor.skyblue;
      case 'slateblue':
        return WebColor.slateblue;
      case 'slategray':
        return WebColor.slategray;
      case 'slategrey':
        return WebColor.slategrey;
      case 'snow':
        return WebColor.snow;
      case 'springgreen':
        return WebColor.springgreen;
      case 'steelblue':
        return WebColor.steelblue;
      case 'tan':
        return WebColor.tan;
      case 'thistle':
        return WebColor.thistle;
      case 'tomato':
        return WebColor.tomato;
      case 'turquoise':
        return WebColor.turquoise;
      case 'violet':
        return WebColor.violet;
      case 'wheat':
        return WebColor.wheat;
      case 'whitesmoke':
        return WebColor.whitesmoke;
      case 'yellowgreen':
        return WebColor.yellowgreen;
      case 'transparent':
        return WebColor.transparent;
    }

    if (color.startsWith('#')) {
      return generateHexColor(color);
    } else if (color.startsWith('rgb')) {
      return generateRGBAColor(color);
    } else {
      return WebColor.transparent;
    }
  }

  /// Only support Basic color keywords and Extended color keywords,
  /// for CSS system colors is not recommanded for use after CSS3
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
}
