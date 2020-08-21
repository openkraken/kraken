/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSOpacityMixin on Node {
  void updateRenderOpacity(RenderBoxModel renderBoxModel, Element element, String value) {
    double opacity = CSSStyleDeclaration.isNullOrEmptyValue(value) ? 1.0 : CSSLength.toDouble(value);
    renderBoxModel.opacity = opacity;
  }
}
