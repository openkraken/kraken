/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'padding.dart';

class RenderLayoutParentData extends ContainerBoxParentData<RenderBox> {
  /// The distance by which the child's top edge is inset from the top of the stack.
  double top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  double width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  double height;

  bool isPositioned = false;

  /// Row index of child when wrapping
  int runIndex = 0;

  RenderPositionHolder renderPositionHolder;
  int zIndex = 0;
  CSSPositionType position = CSSPositionType.static;

  /// Get element original position offset to parent(layoutBox) should be.
  Offset get stackedChildOriginalRelativeOffset {
    if (renderPositionHolder == null) return Offset.zero;
    return (renderPositionHolder.parentData as BoxParentData).offset;
  }

  // Whether offset is already set
  bool isOffsetSet = false;

  @override
  String toString() {
    return 'zIndex=$zIndex; position=$position; isPositioned=$isPositioned; renderPositionHolder=$renderPositionHolder; ${super.toString()}; runIndex: $runIndex;';
  }
}

class RenderLayoutBox extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        CSSComputedMixin {
  RenderLayoutBox({int targetId, CSSStyleDeclaration style, ElementManager elementManager})
      : super(targetId: targetId, style: style, elementManager: elementManager);
}

class RenderBoxModel extends RenderBox with
  RenderPaddingMixin,
  RenderBoxDecorationMixin,
  RenderOverflowMixin,
  RenderPointerListenerMixin {
  RenderBoxModel({
    this.targetId,
    this.style,
    this.elementManager
  }) : super();

  BoxPainter _painter;

  bool _debugHasBoxLayout = false;

  BoxConstraints _contentConstraints;
  BoxConstraints get contentConstraints {
    assert(_debugHasBoxLayout, 'can not access contentConstraints, RenderBoxModel has not layout: ${toString()}');
    assert(_contentConstraints != null);
    return _contentConstraints;
  }

  // id of current element
  int targetId;

  // Element style;
  CSSStyleDeclaration style;

  ElementManager elementManager;

  RenderBoxModel fromCopy(RenderBoxModel newBox) {
    if (padding != null) {
      newBox.padding = padding;
    }
    if (borderEdge != null) {
      newBox.borderEdge = borderEdge;
    }
    if (decoration != null) {
      newBox.decoration = decoration;
    }

    return newBox;
  }

  set size(Size value) {
    _contentSize = value;
    Size boxSize = value;
    if (padding != null) {
      boxSize = wrapPaddingSize(boxSize);
    }
    if (borderEdge != null) {
      boxSize = wrapBorderSize(boxSize);
    }

    super.size = super.constraints.constrain(boxSize);
  }

  // the contentSize of layout box
  Size _contentSize;
  Size get contentSize {
    if (_contentSize == null) {
      return Size(0, 0);
    }
    return _contentSize;
  }

  double get clientWidth {
    double width = contentSize.width;
    if (padding != null) {
      width += padding.horizontal;
    }
    return width;
  }

  double get clientHeight {
    double height = contentSize.height;
    if (padding != null) {
      height += padding.vertical;
    }
    return height;
  }

  // base layout methods to compute content constraints before content box layout.
  // call this method before content box layout.
  BoxConstraints beforeLayout() {
    _debugHasBoxLayout = true;
    _contentConstraints = super.constraints;

    if (padding != null) {
      _contentConstraints = deflatePaddingConstraints(_contentConstraints);
    }

    _contentConstraints = deflateBorderConstraints(_contentConstraints);

    // layout overflow Box
    _contentConstraints = deflateOverflowConstraints(_contentConstraints);

    return _contentConstraints;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    applyOverflowPaintTransform(child, transform);
  }

  // hooks when content box had layout.
  void didLayout() {
    setUpOverflowScroller(_contentSize);
  }

  void basePaint(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    paintDecoration(context, offset);
    paintOverflow(context, offset, borderEdge, callback);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
    // Since we're disposing of our painter, we won't receive change
    // notifications. We mark ourselves as needing paint so that we will
    // resubscribe to change notifications. If we didn't do this, then, for
    // example, animated GIFs would stop animating when a DecoratedBox gets
    // moved around the tree due to GlobalKey reparenting.
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription(
              "Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'
            ),
            ErrorHint(
              'If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'
            ),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription(
            'Although this node is not marked as needing layout, '
              'its size is not set.'
          ),
          ErrorHint(
            'A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'
          ),
        ]);
      }
      return true;
    }());
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    return decoration.hitTest(size, position, textDirection: configuration.textDirection);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (decoration != null) properties.add(decoration.toDiagnosticsNode(name: 'decoration'));
    if (configuration != null) properties.add(DiagnosticsProperty<ImageConfiguration>('configuration', configuration));
  }
}
