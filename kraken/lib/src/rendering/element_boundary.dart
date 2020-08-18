/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class ElementBoundaryParentData extends ContainerBoxParentData<RenderBox> {}

enum BoxSizeType {
  // Element which have intrinsic before layout. Such as <img /> and <video />
  intrinsic,

  // Element which have width or min-width properties defined.
  specified,

  // Element which neither have intrinsic or predefined size.
  automatic,
}

//class RenderElementBoundary extends RenderTransform {
  class RenderElementBoundary extends RenderProxyBox {
//    with
//        ContainerRenderObjectMixin<RenderBox, ElementBoundaryParentData>,
//        RenderBoxContainerDefaultsMixin<RenderBox, ElementBoundaryParentData> {
  RenderElementBoundary(
      {RenderBox child,
      this.style,
      Matrix4 transform,
      this.origin,
      this.targetId,
      this.elementManager,
      bool shouldRender,
      this.alignment})
      : assert(child != null),
        _shouldRender = shouldRender,
        _originalTransform = transform,
        super(child) {
      this.child = child;
//    add(child);
  }

//  RenderBox child;

  Offset origin;
  Alignment alignment;

    // Positioned holder box ref.
  RenderPositionHolder positionedHolder;

  int targetId;

  // @TODO: need to remove this after RenderObject merge have completed.
  ElementManager elementManager;

  CSSStyleDeclaration style;

  Size layoutSize;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  Matrix4 _originalTransform;

  // Note the lack of a getter for transform because Matrix4 is not immutable
  Matrix4 _transform;

  /// The matrix to transform the child by during painting.
  set transform(Matrix4 value) {
    assert(value != null);
    if (_transform == value)
      return;
    _transform = Matrix4.copy(value);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
    _originalTransform = value;
  }

  bool _shouldRender;
  bool get shouldRender => _shouldRender;
  set shouldRender(bool value) {
    assert(value != null);
    if (_shouldRender != value) {
      markNeedsLayout();
      _shouldRender = value;
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ElementBoundaryParentData) {
      child.parentData = ElementBoundaryParentData();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints additionalConstraints = constraints;
      if (!shouldRender) {
        additionalConstraints = BoxConstraints(
          minWidth: 0,
          maxWidth: 0,
          minHeight: 0,
          maxHeight: 0,
        );
      }
      child.layout(additionalConstraints, parentUsesSize: true);
      size = layoutSize = child.size;
    } else {
      performResize();
    }

    if (positionedHolder != null) {
      // Make position holder preferred size equal to current element boundary size.
      positionedHolder.preferredSize = Size.copy(size);
    }
  }

//  Matrix4 getEffectiveTransform() {
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
//    if (origin == null) return _originalTransform;
//    final Matrix4 result = Matrix4.identity();
//    if (origin != null) {
//      result.translate(origin.dx, origin.dy);
//    }
//    Offset translation;
//    if (alignment != null && alignment != Alignment.topLeft) {
//      double width = (layoutSize?.width ?? 0.0);
//      double height = (layoutSize?.height ?? 0.0);
//
//      translation = (alignment as Alignment).alongSize(Size(width, height));
//      result.translate(translation.dx, translation.dy);
//    }
//    result.multiply(_originalTransform);
//    if (alignment != null && alignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);
//    if (origin != null) result.translate(-origin.dx, -origin.dy);
//    return result;
//  }

//  @override
//  void paint(PaintingContext context, Offset offset) {
//    void painter(PaintingContext context, Offset offset) {}
//
//    if (!shouldRender) {
//      context.pushClipRect(needsCompositing, offset, Offset.zero & size, painter);
//    } else {
//      if (child != null) {
//        final Matrix4 transform = getEffectiveTransform();
//        final Offset childOffset = MatrixUtils.getAsTranslation(transform);
//        if (childOffset == null) {
//          layer = context.pushTransform(
//            needsCompositing,
//            offset,
//            transform,
//            superPaint,
//            oldLayer: layer as TransformLayer,
//          );
//        } else {
//          superPaint(context, offset + childOffset);
//          layer = null;
//        }
//      }
//    }
//  }

//  // FIXME when super class RenderTransform paint change
//  void superPaint(PaintingContext context, Offset offset) {
//    if (child != null) context.paintChild(child, offset);
//  }

//  // FIXME when super class RenderTransform applyPaintTransform change
//  @override
//  void applyPaintTransform(RenderBox child, Matrix4 transform) {
//    transform.multiply(getEffectiveTransform());
//  }
//
//  // FIXME when super class RenderTransform hitTestChildren change
//  @override
//  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
//    assert(getEffectiveTransform() != null);
//    return result.addWithPaintTransform(
//      transform: getEffectiveTransform(),
//      position: position,
//      hitTest: (BoxHitTestResult result, Offset position) {
//        return child?.hitTest(result, position: position) ?? false;
//      },
//    );
//  }
}
