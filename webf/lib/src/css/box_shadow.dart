/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

mixin CSSBoxShadowMixin on RenderStyle {
  List<CSSBoxShadow>? _boxShadow;
  set boxShadow(List<CSSBoxShadow>? value) {
    if (value == _boxShadow) return;
    _boxShadow = value;
    renderBoxModel?.markNeedsPaint();
  }

  List<CSSBoxShadow>? get boxShadow => _boxShadow;

  @override
  List<WebFBoxShadow>? get shadows {
    if (boxShadow == null) {
      return null;
    }
    List<WebFBoxShadow> result = [];
    for (CSSBoxShadow shadow in boxShadow!) {
      result.add(shadow.computedBoxShadow);
    }
    return result;
  }
}
