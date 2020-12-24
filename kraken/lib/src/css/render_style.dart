/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class RenderStyle
  with
    RenderStyleBase,
    CSSSizingMixin,
    CSSPaddingMixin,
    CSSMarginMixin,
    CSSBoxMixin,
    CSSTextMixin,
    CSSPositionMixin,
    CSSFlexboxMixin,
    CSSFlowMixin {

  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size viewportSize;

  RenderStyle(
    this.renderBoxModel,
    this.style,
    this.viewportSize,
  );
}

mixin RenderStyleBase {
  RenderBoxModel renderBoxModel;
  CSSStyleDeclaration style;
  Size viewportSize;
}

