/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:kraken/css.dart';

class RenderStyle
  with
    RenderStyleBase,
    CSSSizingMixin,
    CSSPaddingMixin,
    CSSMarginMixin {

CSSStyleDeclaration style;
  Size viewportSize;

  RenderStyle(
    this.style,
    this.viewportSize,
  );
}

mixin RenderStyleBase {
  CSSStyleDeclaration style;
  Size viewportSize;
}

