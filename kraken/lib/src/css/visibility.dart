/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSVisibilityMixin on Node {
  RenderVisibility renderVisibility;

  void updateRenderVisibility(String visibility, {RenderObjectWithChildMixin parentRenderObject}) {
    bool hidden = visibility == HIDDEN;
    if (renderVisibility != null) {
      renderVisibility.hidden = hidden;
    } else if (hidden) {
      RenderObject child = parentRenderObject.child;
      // Drop child by set null first.
      parentRenderObject.child = null;
      renderVisibility = RenderVisibility(
        hidden: hidden,
        child: child,
      );
      parentRenderObject.child = renderVisibility;
    }
  }
}
