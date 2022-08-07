/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibilityMixin on RenderBoxModelBase {
  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset? position}) {
    ContentVisibility? _contentVisibility = renderStyle.contentVisibility;
    return _contentVisibility != ContentVisibility.hidden;
  }

  void paintContentVisibility(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    ContentVisibility? _contentVisibility = renderStyle.contentVisibility;
    if (_contentVisibility == ContentVisibility.hidden) {
      return;
    }
    callback(context, offset);
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<ContentVisibility>('contentVisibility', renderStyle.contentVisibility));
  }
}
