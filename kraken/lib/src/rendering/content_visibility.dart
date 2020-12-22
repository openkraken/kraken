import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/module.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibility on RenderBox {
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
    markNeedsPaint();
  }

  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset position}) {
    return _contentVisibility != ContentVisibility.hidden;
  }

  void paintContentVisibility(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_contentVisibility == ContentVisibility.hidden) {
      return;
    }
    callback(context, offset);
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    if (contentVisibility != null) properties.add(DiagnosticsProperty<ContentVisibility>('contentVisibility', contentVisibility));
  }
}
