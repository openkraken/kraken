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

  /// Whether to maintain space when hidden.
  final bool _maintainSize;

  /// Whether the child is hidden from the rest of the tree.
  ///
  /// If true, the child is laid out as if it was in the tree, but without
  /// painting anything, without making the child available for hit testing, and
  /// without taking any room in the parent.
  ///
  /// If false, the child is included in the tree as normal.
  bool get hidden => _hidden;
  bool _hidden;
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

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    if (hidden && !_maintainSize)
      return 0.0;
    return super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (hidden && !_maintainSize)
      return 0.0;
    return super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (hidden && !_maintainSize)
      return 0.0;
    return super.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (hidden && !_maintainSize)
      return 0.0;
    return super.computeMaxIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    if (hidden && !_maintainSize)
      return null;
    return super.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool get sizedByParent => hidden && !_maintainSize;

  @override
  void performResize() {
    assert(hidden);
    if (_maintainSize) {
      super.performResize();
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void performLayout() {
    if (_maintainSize) {
      super.performLayout();
    } else {
      child?.layout(constraints);
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