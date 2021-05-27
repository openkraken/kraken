import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin RenderVisibilityMixin on RenderBox {
  Visibility? _visibility;
  Visibility? get visibility => _visibility;
  set visibility(Visibility? value) {
    if (value == null) return;
    if (value == _visibility) return;
    _visibility = value;
    markNeedsPaint();
  }

  bool visibilityHitTest(BoxHitTestResult result, {required Offset position}) {
    return _visibility != Visibility.hidden;
  }

  bool get isCSSVisibilityHidden {
    return _visibility != null && _visibility == Visibility.hidden;
  }
}
