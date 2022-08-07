/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

// CSS Content Visibility: https://www.w3.org/TR/css-contain-2/#content-visibility

enum ContentVisibility { auto, hidden, visible }

mixin CSSContentVisibilityMixin on RenderStyle {
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
  @override
  ContentVisibility get contentVisibility => _contentVisibility ?? ContentVisibility.visible;
  ContentVisibility? _contentVisibility;
  set contentVisibility(ContentVisibility? value) {
    if (value == _contentVisibility) return;
    _contentVisibility = value;
    renderBoxModel?.markNeedsPaint();
  }

  static ContentVisibility resolveContentVisibility(String value) {
    switch (value) {
      case HIDDEN:
        return ContentVisibility.hidden;
      case AUTO:
        return ContentVisibility.auto;
      case VISIBLE:
      default:
        return ContentVisibility.visible;
    }
  }
}
