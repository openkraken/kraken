/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

mixin RenderTransformMixin on RenderBoxModelBase {

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

  // Copy from flutter [RenderTransform._effectiveTransform]
  Matrix4 getEffectiveTransform() {
    final Matrix4 result = Matrix4.identity();
    if (origin != null) {
      result.translate(origin.dx, origin.dy);
    }
    Offset translation;
    if (alignment != null && alignment != Alignment.topLeft) {
      // Use boxSize instead of size to avoid Flutter cannot access size beyond parent access warning
      translation = hasSize ? alignment.alongSize(boxSize) : Offset.zero;
      result.translate(translation.dx, translation.dy);
    }

    result.multiply(renderStyle.transform);

    if (alignment != null && alignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);
    if (origin != null) result.translate(-origin.dx, -origin.dy);
    return result;
  }

  TransformLayer _transformLayer;

  void paintTransform(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (renderStyle.transform != null) {
      final Matrix4 transform = getEffectiveTransform();
      final Offset childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        _transformLayer = context.pushTransform(
          needsCompositing,
          offset,
          transform,
          callback,
          oldLayer: _transformLayer,
        );
      } else {
        callback(context, offset + childOffset);
        _transformLayer = null;
      }
    } else {
      callback(context, offset);
    }
  }

  void applyEffectiveTransform(RenderBox child, Matrix4 transform) {
    if (renderStyle.transform != null) {
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
  }
}
