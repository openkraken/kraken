import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibility on RenderBox {
  /// Whether the child is hidden from the rest of the tree.
  ///
  /// If true, the child is laid out as if it was in the tree, but without
  /// painting anything, without making the child available for hit testing, and
  /// without taking any room in the parent.
  ///
  /// If false, the child is included in the tree as normal.
  ContentVisibility _contentVisibility;
  ContentVisibility get contentVisibility => _contentVisibility;
  set contentVisibility(ContentVisibility value) {
    if (value == null) return;
    if (value == _contentVisibility) return;
    _contentVisibility = value;
    markNeedsPaint();
  }

  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset position}) {
    if (_contentVisibility == ContentVisibility.hidden) {
      return false;
    }
    return true;
  }

  void paintContentVisibility(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_contentVisibility == ContentVisibility.hidden) {
      return;
    }
    callback(context, offset);
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ContentVisibility>('contentVisibility', contentVisibility));
  }
}
