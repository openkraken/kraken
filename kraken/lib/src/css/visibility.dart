/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';

enum Visibility {
  visible,
  hidden,
}

mixin CSSVisibilityMixin on RenderStyle {
  Visibility? _visibility;

  set visibility(Visibility? value) {
    if (_visibility == value) return;
    _visibility = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  Visibility get visibility => _visibility ?? Visibility.visible;

  bool get isVisibilityHidden => _visibility == Visibility.hidden;

  static Visibility resolveVisibility(String value) {
    switch(value) {
      case HIDDEN:
        return Visibility.hidden;
      case VISIBLE:
      default:
        return Visibility.visible;
    }
  }
}
