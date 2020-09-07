/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

mixin RenderTransformMixin on RenderBox {

  Offset get origin => _origin;
  Offset _origin = Offset(0, 0);
  set origin(Offset value) {
    if (_origin == value) return;
    _origin = value;
    markNeedsPaint();
  }

  Alignment get alignment => _alignment;
  Alignment _alignment = Alignment.center;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  Matrix4 get transform => _transform;
  Matrix4 _transform;
  set transform(Matrix4 value) {
    if (_transform == value) return;
    _transform = value;
    markNeedsPaint();
  }

  Matrix4 getEffectiveTransform() {
    if (origin == null) return _transform;
    final Matrix4 result = Matrix4.identity();
    if (origin != null) {
      result.translate(origin.dx, origin.dy);
    }
    Offset translation;
    if (alignment != null && alignment != Alignment.topLeft) {
      double width = (size?.width ?? 0.0);
      double height = (size?.height ?? 0.0);

      translation = alignment.alongSize(Size(width, height));
      result.translate(translation.dx, translation.dy);
    }
    result.multiply(_transform);
    if (alignment != null && alignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);
    if (origin != null) result.translate(-origin.dx, -origin.dy);
    return result;
  }

  TransformLayer _transformLayer;

  void paintTransform(PaintingContext context, Offset offset, PaintingContextCallback superPaint) {
    if (_transform != null) {
      final Matrix4 transform = getEffectiveTransform();
      final Offset childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        _transformLayer = context.pushTransform(
          needsCompositing,
          offset,
          transform,
          superPaint,
          oldLayer: _transformLayer,
        );
      } else {
        superPaint(context, offset + childOffset);
        _transformLayer = null;
      }
    } else {
      superPaint(context, offset);
    }
  }

  void applyEffectiveTransform(RenderBox child, Matrix4 transform) {
    if (_transform != null) {
      transform.multiply(getEffectiveTransform());
    }
  }

  bool hitTestLayoutChildren(BoxHitTestResult result, RenderBox child, Offset position) {
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      final bool isHit = result.addWithPaintTransform(
        transform: getEffectiveTransform(),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          return result.addWithPaintOffset(
            offset: childParentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - childParentData.offset);
              return child.hitTest(result, position: transformed);
            },
          );
        },
      );
      if (isHit)
        return true;
      child = childParentData.previousSibling;
    }
    return false;
  }

  bool hitTestIntrinsicChild(BoxHitTestResult result, RenderBox child, Offset position) {
    final bool isHit = result.addWithPaintTransform(
      transform: getEffectiveTransform(),
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return child?.hitTest(result, position: position) ?? false;
      },
    );
    if (isHit)
      return true;
    return false;
  }

  void debugTransformProperties(DiagnosticPropertiesBuilder properties) {
    if (origin != null) properties.add(DiagnosticsProperty('transformOrigin', origin));
    if (alignment != null) properties.add(DiagnosticsProperty('transformAlignment', alignment));
    if (transform != null) properties.add(DiagnosticsProperty('transform', transform));
  }
}
