import 'package:meta/meta.dart';
import 'package:flutter/rendering.dart';

/// [RenderPreferredSize] Render a box with preferred size,
/// if no child provided, size is exactly what preferred size
/// is, but it also obey parent constraints.
class RenderPreferredSize extends RenderProxyBox {
  RenderPreferredSize({
    @required Size preferredSize,
    RenderBox child = null,
  }) : assert(preferredSize != null),
        _preferredSize = preferredSize,
        super(child);

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    assert(value != null);
    if (preferredSize == value)
      return;

    _preferredSize = value;
    markNeedsLayout();
  }

  @override
  void performResize() {
    size = constraints.constrain(preferredSize);
    markNeedsSemanticsUpdate();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Size>('preferredSize', _preferredSize, missingIfNull: true));
  }
}
