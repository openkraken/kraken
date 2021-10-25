/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

enum Visibility {
  visible,
  hidden,
}

mixin CSSVisibilityMixin on ElementBase {
  static Visibility getVisibility(String value) {
    switch(value) {
      case HIDDEN:
        return Visibility.hidden;
      case VISIBLE:
      default:
        return Visibility.visible;
    }
  }

  void updateRenderVisibility(Visibility visibility) {
    renderBoxModel!.visibility = visibility;
  }
}
