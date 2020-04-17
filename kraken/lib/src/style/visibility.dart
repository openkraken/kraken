/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin VisibilityStyleMixin on Node {
  RenderVisibility renderVisibility;

  RenderObject initRenderVisibility(RenderObject renderObject, StyleDeclaration style) {
    bool hidden = style['visibility'] == 'hidden';
    if (hidden) {
      renderVisibility = RenderVisibility(
        hidden: true,
        child: renderObject
      );
      return renderVisibility;
    } else {
      return renderObject;
    }
  }

  void updateRenderVisibility(String visibility, { RenderObjectWithChildMixin parentRenderObject }) {
    bool hidden = visibility == 'hidden';
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
