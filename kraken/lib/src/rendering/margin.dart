/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class RenderMargin extends RenderShiftedBox {
  /// Creates a render object that insets its child.
  ///
  /// The [margin] argument must not be null and must have non-negative insets.
  RenderMargin({
    @required EdgeInsetsGeometry margin,
    TextDirection textDirection,
    RenderBox child,
  })  : assert(margin != null),
        assert(margin.isNonNegative),
        _textDirection = textDirection,
        _margin = margin,
        super(child);

  EdgeInsets _resolvedMargin;

  void _resolve() {
    if (_resolvedMargin != null) return;
    _resolvedMargin = margin.resolve(textDirection);
    assert(_resolvedMargin.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedMargin = null;
    markNeedsLayout();
    // force child re-layout
    RenderBox childBox = child;
    child = null;
    child = childBox;
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get margin => _margin;
  EdgeInsetsGeometry _margin;
  set margin(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_margin == value) return;
    _margin = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [margin].
  ///
  /// This may be changed to null, but only after the [margin] has been changed
  /// to a value that does not depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding = _resolvedMargin.left + _resolvedMargin.right;
    final double totalVerticalPadding = _resolvedMargin.top + _resolvedMargin.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child.getMinIntrinsicWidth(math.max(0.0, height - totalVerticalPadding)) + totalHorizontalPadding;
    return totalHorizontalPadding;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding = _resolvedMargin.left + _resolvedMargin.right;
    final double totalVerticalPadding = _resolvedMargin.top + _resolvedMargin.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child.getMaxIntrinsicWidth(math.max(0.0, height - totalVerticalPadding)) + totalHorizontalPadding;
    return totalHorizontalPadding;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding = _resolvedMargin.left + _resolvedMargin.right;
    final double totalVerticalPadding = _resolvedMargin.top + _resolvedMargin.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child.getMinIntrinsicHeight(math.max(0.0, width - totalHorizontalPadding)) + totalVerticalPadding;
    return totalVerticalPadding;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding = _resolvedMargin.left + _resolvedMargin.right;
    final double totalVerticalPadding = _resolvedMargin.top + _resolvedMargin.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child.getMaxIntrinsicHeight(math.max(0.0, width - totalHorizontalPadding)) + totalVerticalPadding;
    return totalVerticalPadding;
  }

  @override
  void performLayout() {
    _resolve();
    assert(_resolvedMargin != null);
    if (child == null) {
      size = constraints.constrain(Size(
        _resolvedMargin.left + _resolvedMargin.right,
        _resolvedMargin.top + _resolvedMargin.bottom,
      ));
      return;
    }

    child.layout(constraints.deflate(_resolvedMargin), parentUsesSize: true);
    final BoxParentData childParentData = child.parentData;
    childParentData.offset = Offset(_resolvedMargin.left, _resolvedMargin.top);
    size = constraints.constrain(Size(
      _resolvedMargin.left + child.size.width + _resolvedMargin.right,
      _resolvedMargin.top + child.size.height + _resolvedMargin.bottom,
    ));
  }

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    child?.hitTest(result, position: position);
    if (this.size.contains(this.globalToLocal(position))) {
      result.add(BoxHitTestEntry(this, position));
    }
    return true;
  }
}
