/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';

final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');

class CSSOrigin {
  final Offset offset;
  final Alignment alignment;
  const CSSOrigin(this.offset, this.alignment);

  static CSSOrigin? parseOrigin(String origin, RenderStyle renderStyle, String property) {
    if (origin.isNotEmpty) {
      List<String> originList = origin.trim().split(_spaceRegExp);
      String? x, y;

      if (originList.length == 1) {
        // Default is center.
        x = originList[0];
        y = CENTER;
        // Flutter just support two value: x/y.
        // FIXME: when flutter support three value
      } else if (originList.length == 2 || originList.length == 3) {
        x = originList[0];
        y = originList[1];
      }
      // When origin property is not null, default is not center.
      double offsetX = 0, offsetY = 0, alignX = -1, alignY = -1;
      // The y just can be left right center when x is top bottom, otherwise illegal
      // switch to right place.
      if ((x == TOP || x == BOTTOM) && (y == LEFT || y == RIGHT || y == CENTER)) {
        String? tmp = x;
        x = y;
        y = tmp;
      }

      // Handle x.
      if (CSSLength.isLength(x)) {
        offsetX = CSSLength.parseLength(x!, renderStyle, property).computedValue;
      } else if (CSSPercentage.isPercentage(x)) {
        alignX = CSSPercentage.parsePercentage(x!)! * 2 - 1;
      } else if (x == LEFT) {
        alignX = -1.0;
      } else if (x == RIGHT) {
        alignX = 1.0;
      } else if (x == CENTER) {
        alignX = 0.0;
      }

      // Handle y.
      if (CSSLength.isLength(y)) {
        offsetY = CSSLength.parseLength(y!, renderStyle, property).computedValue;
      } else if (CSSPercentage.isPercentage(y)) {
        alignY = CSSPercentage.parsePercentage(y!)! * 2 - 1;
      } else if (y == TOP) {
        alignY = -1.0;
      } else if (y == BOTTOM) {
        alignY = 1.0;
      } else if (y == CENTER) {
        alignY = 0.0;
      }
      return CSSOrigin(Offset(offsetX, offsetY), Alignment(alignX, alignY));
    }
    return null;
  }
}
