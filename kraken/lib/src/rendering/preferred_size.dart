import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/rendering.dart';

/// [RenderPreferredSize] Render a box with preferred size,
/// if no child provided, size is exactly what preferred size
/// is, but it also obey parent constraints.
class RenderPreferredSize extends RenderProxyBox {
  RenderPreferredSize({
    required Size preferredSize,
    RenderBox? child,
  })  : assert(preferredSize != null),
        _preferredSize = preferredSize,
        super(child);

  Size _preferredSize;

  Size get preferredSize => _preferredSize;

  set preferredSize(Size value) {
    assert(value != null);
    if (_preferredSize == value) return;

    _preferredSize = value;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
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
    properties.add(DiagnosticsProperty<Size>('preferredSize', _preferredSize,
        missingIfNull: true));
  }
}

/// A placeholder for positioned RenderBox
class RenderPositionHolder extends RenderPreferredSize {
  RenderPositionHolder({
    required Size preferredSize,
    RenderBox? child,
  }) : super(preferredSize: preferredSize, child: child);

  RenderBoxModel? realDisplayedBox;

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return false;
  }
}

bool isPositionHolder(RenderBox box) {
  return box is RenderPositionHolder;
}
