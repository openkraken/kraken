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

class RenderElementBoundary extends RenderTransform
    with
        ContainerRenderObjectMixin<RenderBox, ElementBoundaryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ElementBoundaryParentData> {
  RenderElementBoundary(
      {this.child, this.style, Matrix4 transform, Offset origin, this.targetId, bool shouldRender, Alignment alignment})
      : assert(child != null),
        _shouldRender = shouldRender,
        _transform = transform,
        super(child: child, transform: transform, origin: origin, alignment: alignment) {
    add(child);
  }

  RenderBox child;

  // Positioned holder box ref.
  RenderPositionHolder positionedHolder;

  int targetId;

  CSSStyleDeclaration style;

  Matrix4 _transform;
  Size layoutSize;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  set transform(Matrix4 value) {
    super.transform = value;
    _transform = value;
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

  Matrix4 getEffectiveTransform() {
    Offset origin = this.origin;
    Element element = getEventTargetByTargetId<Element>(targetId);
    // transform origin is apply to border in browser
    // so apply the margin child offset
    // percent or keyword apply by border size
    if (element != null) {
      RenderBox renderBox = element.renderMargin?.child;
      if (renderBox != null) {
        BoxParentData boxParentData = renderBox.parentData;
        origin += boxParentData.offset;
      }
    }
    if (origin == null) return _transform;
    final Matrix4 result = Matrix4.identity();
    if (origin != null) {
      result.translate(origin.dx, origin.dy);
    }
    Offset translation;
    if (alignment != null && alignment != Alignment.topLeft) {
      double width = (layoutSize?.width ?? 0.0) - (element?.cropMarginWidth ?? 0.0);
      double height = (layoutSize?.height ?? 0.0) - (element?.cropMarginHeight ?? 0.0);

      translation = (alignment as Alignment).alongSize(Size(width, height));
      result.translate(translation.dx, translation.dy);
    }
    result.multiply(_transform);
    if (alignment != null && alignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);
    if (origin != null) result.translate(-origin.dx, -origin.dy);
    return result;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void painter(PaintingContext context, Offset offset) {}

    if (!shouldRender) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, painter);
    } else {
      if (child != null) {
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
  }

  // FIXME when super class RenderTransform paint change
  void superPaint(PaintingContext context, Offset offset) {
    if (child != null) context.paintChild(child, offset);
  }

  // FIXME when super class RenderTransform applyPaintTransform change
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getEffectiveTransform());
  }

  // FIXME when super class RenderTransform hitTestChildren change
  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    assert(!transformHitTests || getEffectiveTransform() != null);
    return result.addWithPaintTransform(
      transform: transformHitTests ? getEffectiveTransform() : null,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return child?.hitTest(result, position: position) ?? false;
      },
    );
  }
}
