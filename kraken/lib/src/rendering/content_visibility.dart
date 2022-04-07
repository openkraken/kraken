/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibilityMixin on RenderBoxModelBase {
  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset? position}) {
    ContentVisibility? _contentVisibility = renderStyle.contentVisibility;
    return _contentVisibility != ContentVisibility.hidden;
  }

  void paintContentVisibility(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    ContentVisibility? _contentVisibility = renderStyle.contentVisibility;
    if (_contentVisibility == ContentVisibility.hidden) {
      return;
    }
    callback(context, offset);
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    ContentVisibility? contentVisibility = renderStyle.contentVisibility;
    if (contentVisibility != null)
      properties.add(DiagnosticsProperty<ContentVisibility>(
          'contentVisibility', contentVisibility));
  }
}
