/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/rendering.dart';

/// [RenderPreferredSize] Render a box with preferred size,
/// if no child provided, size is exactly what preferred size
/// is, but it also obey parent constraints.
class RenderPreferredSize extends RenderProxyBox {
  RenderPreferredSize({
    required Size preferredSize,
    RenderBox? child,
  })  : _preferredSize = preferredSize,
        super(child);

  Size _preferredSize;

  Size get preferredSize => _preferredSize;

  set preferredSize(Size value) {
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
class RenderPositionPlaceholder extends RenderPreferredSize {
  RenderPositionPlaceholder({
    required Size preferredSize,
    RenderBox? child,
  }) : super(preferredSize: preferredSize, child: child);

  // Real position of this renderBox.
  RenderBoxModel? positioned;

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return false;
  }

  // Get the layout offset of renderObject to its ancestor which does not include the paint offset
  // such as scroll or transform.
  Offset getOffsetToAncestor(Offset point, RenderObject ancestor, {bool excludeScrollOffset = false}) {
    return MatrixUtils.transformPoint(
        getLayoutTransformTo(this, ancestor, excludeScrollOffset: excludeScrollOffset), point);
  }
}

bool isPositionPlaceholder(RenderBox box) {
  return box is RenderPositionPlaceholder;
}
