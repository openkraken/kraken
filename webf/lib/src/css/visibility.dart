/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

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
    switch (value) {
      case HIDDEN:
        return Visibility.hidden;
      case VISIBLE:
      default:
        return Visibility.visible;
    }
  }
}
