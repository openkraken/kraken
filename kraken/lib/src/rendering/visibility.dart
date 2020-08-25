import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin RenderVisibilityMixin on RenderBox {
  Visibility _visibility;
  get visibility => _visibility;
  set visibility(Visibility value) {
    if (value == null) return;
    if (value == _visibility) return;
    _visibility = value;
    markNeedsPaint();
  }

  bool visibilityHitTest(BoxHitTestResult result, {Offset position}) {
    return _visibility != Visibility.hidden;
  }

  void paintVisibility(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_visibility == Visibility.hidden) {
      return;
    }
    callback(context, offset);
  }
}
