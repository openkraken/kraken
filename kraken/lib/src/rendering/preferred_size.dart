import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/rendering.dart';
import 'package:meta/meta.dart';

/// [RenderPreferredSize] Render a box with preferred size,
/// if no child provided, size is exactly what preferred size
/// is, but it also obey parent constraints.
class RenderPreferredSize extends RenderProxyBox {
  RenderPreferredSize({
    @required Size preferredSize,
    RenderBox child,
  })  : assert(preferredSize != null),
        _preferredSize = preferredSize,
        super(child);

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    assert(value != null);
    if (_preferredSize == value) return;

    _preferredSize = value;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      markNeedsLayout();
    });
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

/// A placeholder for positioned RenderBox
class RenderPositionHolder extends RenderPreferredSize {
  RenderPositionHolder({
    @required Size preferredSize,
    RenderBox child,
  }) : super(preferredSize: preferredSize, child: child);

  RenderBoxModel realDisplayedBox;
}

bool isPositionHolder(RenderBox box) {
  return box is RenderPositionHolder;
}
