import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
class RenderVisibility extends RenderProxyBox {
  /// Creates an render object.
  RenderVisibility({
    bool hidden = false,
    bool maintainSize = true,
    RenderBox child,
  }) : assert(hidden != null),
       _hidden = hidden,
       _maintainSize = maintainSize,
       super(child);

  /// Whether the child is hidden from the rest of the tree.
  ///
  /// If true, the child is laid out as if it was in the tree, but without
  /// painting anything, without making the child available for hit testing, and
  /// without taking any room in the parent.
  ///
  /// If false, the child is included in the tree as normal.
  bool _hidden;
  bool get hidden => _hidden;
  set hidden(bool value) {
    assert(value != null);
    if (value == _hidden)
      return;
    _hidden = value;
    
    if (_maintainSize) {
      markNeedsPaint();
    } else {
      markNeedsLayoutForSizedByParentChange();
    }
  }

  /// Whether to maintain space when hidden.
  bool _maintainSize;
  bool get maintainSize => _maintainSize;
  set maintainSize(bool value) {
    assert(value != null);
    if (value == _maintainSize)
      return;
    _maintainSize = value;
    
    if (_maintainSize) {
      markNeedsPaint();
    } else {
      markNeedsLayoutForSizedByParentChange();
    }
  }

  double _minIntrinsicWidth = 0.0;
  double _maxIntrinsicWidth = 0.0;
  double _minIntrinsicHeight = 0.0;
  double _maxIntrinsicHeight = 0.0;
  double _distanceToActualBaseline = null;

  @override
  double computeMinIntrinsicWidth(double height) {
    if (hidden && !_maintainSize)
      return _minIntrinsicWidth;
    return _minIntrinsicWidth = super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (hidden && !_maintainSize)
      return _maxIntrinsicWidth;
    return _maxIntrinsicWidth = super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (hidden && !_maintainSize)
      return _minIntrinsicHeight;
    return _minIntrinsicHeight = super.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (hidden && !_maintainSize)
      return _maxIntrinsicHeight;
    return _maxIntrinsicHeight = super.computeMaxIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    if (hidden && !_maintainSize)
      return _distanceToActualBaseline;

    return _distanceToActualBaseline = super.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool get sizedByParent => hidden && !_maintainSize;

  @override
  void performResize() {
    assert(hidden);
    if (hidden && !_maintainSize) {
      size = constraints.smallest;
    } else {
      super.performResize();
    }
  }

  @override
  void performLayout() {
    if (hidden && !_maintainSize) {
      child?.layout(constraints);
    } else {
      super.performLayout();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, { Offset position }) {
    return !hidden && super.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (hidden && !_maintainSize)
      return;

    if (child != null) {
      // No need to keep the layer. We'll create a new one if necessary.
      layer = null;

      if (!hidden) {
        context.paintChild(child, offset);
      }
      return;
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (hidden)
      return;
    super.visitChildrenForSemantics(visitor);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('hidden', hidden));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    if (child == null)
      return <DiagnosticsNode>[];
    return <DiagnosticsNode>[
      child.toDiagnosticsNode(
        name: 'child',
        style: hidden ? DiagnosticsTreeStyle.offstage : DiagnosticsTreeStyle.sparse,
      ),
    ];
  }
}