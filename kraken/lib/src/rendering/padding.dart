/*
<<<<<<< HEAD
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Insets its child by the given padding.
///
/// When passing layout constraints to its child, padding shrinks the
/// constraints by the given padding, causing the child to layout at a smaller
/// size. Padding then sizes itself to its child's size, inflated by the
/// padding, effectively creating empty space around the child.
class KrakenRenderPadding extends RenderPadding {
  /// Creates a render object that insets its child.
  ///
  /// The [padding] argument must not be null and must have non-negative insets.
  KrakenRenderPadding({
    @required EdgeInsetsGeometry padding,
    TextDirection textDirection,
    RenderBox child,
  }) : super(padding: padding, textDirection: textDirection, child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}


mixin RenderPaddingMixin on RenderBox {
  EdgeInsets _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) return;
    if (padding == null) return;
    _resolvedPadding = padding.resolve(TextDirection.ltr);
    assert(_resolvedPadding.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  double get paddingTop {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.top;
  }

  double get paddingRight {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.right;
  }

  double get paddingBottom {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.bottom;
  }

  double get paddingLeft {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.left;
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    _resolve();
    return constraints.deflate(_resolvedPadding);
  }

  Size wrapPaddingSize(Size innerSize) {
    _resolve();
    return Size(_resolvedPadding.left + innerSize.width + _resolvedPadding.right,
        _resolvedPadding.top + innerSize.height + _resolvedPadding.bottom);
  }
}
