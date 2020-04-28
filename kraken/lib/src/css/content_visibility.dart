/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Content Visibility: https://wicg.github.io/display-locking/

mixin CSSContentVisibilityMixin on Node {
  RenderVisibility renderVisibility;
  bool _hasIntersectionObserver = false;

  RenderObject initRenderContentVisibility(RenderObject renderObject, CSSStyleDeclaration style) {
    String contentVisibility = style['contentVisibility'];
    if (contentVisibility == 'hidden' || contentVisibility == 'auto') {
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

  void setContentVisibilityIntersectionObserver(RenderIntersectionObserver renderIntersectionObserver, String contentVisibility) {
    if (contentVisibility == 'auto' && !_hasIntersectionObserver) {
      renderIntersectionObserver.addListener(_handleIntersectionChange);
      // Call needs paint make sure intersection observer works immediately
      renderIntersectionObserver.markNeedsPaint();
      _hasIntersectionObserver = true;
    }
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    renderVisibility.hidden = !entry.isIntersecting;
  }

  void updateRenderContentVisibility(String contentVisibility, { RenderObjectWithChildMixin parentRenderObject, RenderIntersectionObserver renderIntersectionObserver }) {

    if (renderVisibility != null) {
      renderVisibility.hidden = (contentVisibility == 'hidden' || contentVisibility == 'auto');
      if (contentVisibility != 'auto' && _hasIntersectionObserver) {
        renderIntersectionObserver.removeListener(_handleIntersectionChange);
        _hasIntersectionObserver = false;
      }
    } else if (contentVisibility == 'hidden' || contentVisibility == 'auto') {
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

    setContentVisibilityIntersectionObserver(renderIntersectionObserver, contentVisibility);
  }
}
