import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/
final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');

class CSSOrigin {
  Offset offset;
  Alignment alignment;
  CSSOrigin(this.offset, this.alignment);

  static CSSOrigin? parseOrigin(String origin, [Size? viewportSize, double? rootFontSize, double? fontSize]) {
    if (origin.isNotEmpty) {
      List<String> originList = origin.trim().split(_spaceRegExp);
      String? x, y;

      if (originList.length == 1) {
        // default center
        x = originList[0];
        y = CSSPosition.CENTER;
        // flutter just support two value x y
        // FIXME when flutter support three value
      } else if (originList.length == 2 || originList.length == 3) {
        x = originList[0];
        y = originList[1];
      }
      // when origin property is not null, default is not center
      double offsetX = 0, offsetY = 0, alignX = -1, alignY = -1;
      // y just can be left right center when x is top bottom, otherwise illegal
      // switch to right place
      if ((x == CSSPosition.TOP || x == CSSPosition.BOTTOM) &&
          (y == CSSPosition.LEFT || y == CSSPosition.RIGHT || y == CSSPosition.CENTER)) {
        String? tmp = x;
        x = y;
        y = tmp;
      }

      // handle x
      if (CSSLength.isLength(x)) {
        offsetX = CSSLength.toDisplayPortValue(
          x,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        ) ?? offsetX;
      } else if (CSSPercentage.isPercentage(x)) {
        alignX = CSSPercentage.parsePercentage(x!)! * 2 - 1;
      } else if (x == CSSPosition.LEFT) {
        alignX = -1.0;
      } else if (x == CSSPosition.RIGHT) {
        alignX = 1.0;
      } else if (x == CSSPosition.CENTER) {
        alignX = 0.0;
      }

      // handle y
      if (CSSLength.isLength(y)) {
        offsetY = CSSLength.toDisplayPortValue(
          y,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        ) ?? offsetY;
      } else if (CSSPercentage.isPercentage(y)) {
        alignY = CSSPercentage.parsePercentage(y!)! * 2 - 1;
      } else if (y == CSSPosition.TOP) {
        alignY = -1.0;
      } else if (y == CSSPosition.BOTTOM) {
        alignY = 1.0;
      } else if (y == CSSPosition.CENTER) {
        alignY = 0.0;
      }
      return CSSOrigin(Offset(offsetX, offsetY), Alignment(alignX, alignY));
    }
    return null;
  }
}