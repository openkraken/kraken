// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

// CSS Content Visibility: https://www.w3.org/TR/css-contain-2/#content-visibility

enum ContentVisibility {
  auto,
  hidden,
  visible
}

mixin CSSContentVisibilityMixin on RenderStyleBase {

  /// Whether the child is hidden from the rest of the tree.
  ///
  /// If ContentVisibility.hidden, the child is laid out as if it was in the tree, but without
  /// painting anything, without making the child available for hit testing, and
  /// without taking any room in the parent.
  ///
  /// If ContentVisibility.visible, the child is included in the tree as normal.
  ///
  /// If ContentVisibility.auto, the framework will compute the intersection bounds and not to paint when child renderObject
  /// are no longer intersection with this renderObject.
  ContentVisibility _contentVisibility;
  ContentVisibility get contentVisibility => _contentVisibility;
  set contentVisibility(ContentVisibility value) {
    if (value == null) return;
    if (value == _contentVisibility) return;
    _contentVisibility = value;
    renderBoxModel.markNeedsPaint();
  }

  bool _hasIntersectionObserver = false;

  void setContentVisibilityIntersectionObserver(
    RenderBoxModel renderBoxModel, ContentVisibility contentVisibility) {
    if (contentVisibility == ContentVisibility.auto && !_hasIntersectionObserver) {
      renderBoxModel.addIntersectionChangeListener(_handleIntersectionChange);
      // Call needs paint make sure intersection observer works immediately
      renderBoxModel.markNeedsPaint();
      _hasIntersectionObserver = true;
    }
  }

  static ContentVisibility getContentVisibility(String value) {
    if (value == null) return ContentVisibility.visible;

    switch(value) {
      case HIDDEN:
        return ContentVisibility.hidden;
      case AUTO:
        return ContentVisibility.auto;
      case VISIBLE:
      default:
        return ContentVisibility.visible;
    }
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    assert(renderBoxModel != null);
    contentVisibility = entry.isIntersecting
        ? ContentVisibility.auto
        : ContentVisibility.hidden;
  }

  void updateRenderContentVisibility(String value) {
    if (renderBoxModel != null) {
      contentVisibility = CSSContentVisibilityMixin.getContentVisibility(value);
      if (contentVisibility != ContentVisibility.auto && _hasIntersectionObserver) {
        renderBoxModel.removeIntersectionChangeListener(_handleIntersectionChange);
        _hasIntersectionObserver = false;
      }
      setContentVisibilityIntersectionObserver(renderBoxModel, contentVisibility);
    }
  }
}
