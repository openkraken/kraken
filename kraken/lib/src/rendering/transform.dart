/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

mixin RenderTransformMixin on RenderBox {

  Offset get origin => _origin;
  Offset _origin = Offset(0, 0);
  set origin(Offset value) {
    if (_origin == value) return;
    _origin = value;
    markNeedsLayout();
  }

  Alignment get alignment => _alignment;
  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  Matrix4 get transform => _transform;
  Matrix4 _transform;
  set transform(Matrix4 value) {
    if (_transform == value) return;
    _transform = value;
    markNeedsLayout();
  }

  Matrix4 getEffectiveTransform() {
//    // @TODO: need to remove this after RenderObject merge have completed.
//    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
//    // transform origin is apply to border in browser
//    // so apply the margin child offset
//    // percent or keyword apply by border size
//    if (element != null) {
//      RenderBox renderBox = element.renderIntersectionObserver;
//      if (renderBox != null) {
//        BoxParentData boxParentData = renderBox.parentData;
//        origin += boxParentData.offset;
//      }
//    }

//  origin = Offset(0, 0);

  if (origin == null) return _transform;
    final Matrix4 result = Matrix4.identity();
    if (origin != null) {
      result.translate(origin.dx, origin.dy);
    }
    Offset translation;
    if (alignment != null && alignment != Alignment.topLeft) {
      double width = (size?.width ?? 0.0);
      double height = (size?.height ?? 0.0);

      translation = (alignment as Alignment).alongSize(Size(width, height));
      result.translate(translation.dx, translation.dy);
    }
    result.multiply(_transform);
    if (alignment != null && alignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);
    if (origin != null) result.translate(-origin.dx, -origin.dy);
    return result;
  }

  void paintTransform(PaintingContext context, Offset offset, PaintingContextCallback superPaint) {
//    print('_transform------------------ $_transform $origin $alignment');
      if (_transform != null) {
        final Matrix4 transform = getEffectiveTransform();
        final Offset childOffset = MatrixUtils.getAsTranslation(transform);
        if (childOffset == null) {
          layer = context.pushTransform(
            needsCompositing,
            offset,
            transform,
            superPaint,
            oldLayer: layer as TransformLayer,
          );
        } else {
          superPaint(context, offset + childOffset);
          layer = null;
        }
      }
  }

//  // FIXME when super class RenderTransform paint change
//  void superPaint(PaintingContext context, Offset offset) {
//    if (child != null) context.paintChild(child, offset);
//  }

  // FIXME when super class RenderTransform applyPaintTransform change
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getEffectiveTransform());
  }

  // FIXME when super class RenderTransform hitTestChildren change
  bool hitTestTransformChildren(BoxHitTestResult result, RenderBox child, {Offset position}) {
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      final bool isHit = result.addWithPaintTransform(
        transform: getEffectiveTransform(),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          return child?.hitTest(result, position: position) ?? false;
        },
      );
      if (isHit)
        return true;
      child = childParentData.previousSibling;
    }
    return false;
  }
}
