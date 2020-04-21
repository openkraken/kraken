/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin SubtreeVisibilityStyleMixin on Node {
  RenderVisibility renderVisibility;
  bool _hasIntersectionObserver = false;

  RenderObject initRenderSubtreeVisibility(RenderObject renderObject, StyleDeclaration style) {
    String subtreeVisibility = style['subtreeVisibility'];
    if (subtreeVisibility == 'hidden' || subtreeVisibility == 'auto') {
      // @TODO:  containIntrinsicSize
      renderVisibility = RenderVisibility(
        hidden: true,
        maintainSize: false,
        child: renderObject
      );
      return renderVisibility;
    } else {
      return renderObject;
    }
  }

  void setSubtreeVisibilityIntersectionObserver(RenderIntersectionObserver renderIntersectionObserver, String subtreeVisibility) {
    if (subtreeVisibility == 'auto' && !_hasIntersectionObserver) {
      renderIntersectionObserver.addListener(_handleIntersectionChange);
      // Call needs paint make sure intersection observer works immediately
      renderIntersectionObserver.markNeedsPaint();
      _hasIntersectionObserver = true;
    }
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    renderVisibility.hidden = !entry.isIntersecting;
  }

  void updateRenderSubtreeVisibility(String subtreeVisibility, { RenderObjectWithChildMixin parentRenderObject, RenderIntersectionObserver renderIntersectionObserver }) {

    if (renderVisibility != null) {
      renderVisibility.hidden = (subtreeVisibility == 'hidden' || subtreeVisibility == 'auto');
      if (subtreeVisibility != 'auto' && _hasIntersectionObserver) {
        renderIntersectionObserver.removeListener(_handleIntersectionChange);
        _hasIntersectionObserver = false;
      }
    } else if (subtreeVisibility == 'hidden' || subtreeVisibility == 'auto') {
      RenderObject child = parentRenderObject.child;
      // Drop child by set null first.
      parentRenderObject.child = null;
      renderVisibility = RenderVisibility(
        hidden: true,
        maintainSize: false,
        child: child
      );
      parentRenderObject.child = renderVisibility;
    }

    setSubtreeVisibilityIntersectionObserver(renderIntersectionObserver, subtreeVisibility);
  }
}
