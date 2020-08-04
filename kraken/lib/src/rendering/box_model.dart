/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
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

class RenderBoxModel extends RenderBox with RenderPaddingMixin, RenderOverflowMixin, RenderPointerListenerMixin {
  RenderBoxModel({this.targetId, this.style, this.elementManager});

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

    return newBox;
  }

  set size(Size value) {
    _contentSize = value;
    Size boxSize = value;
    if (padding != null) {
      boxSize = wrapPaddingSize(boxSize);
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

    // layout overflow Box
    _contentConstraints = deflateOverflowConstraints(_contentConstraints);

    return _contentConstraints;
  }

  // hooks when content box had layout.
  void didLayout() {
    setUpOverflowScroller(_contentSize);
  }

  void basePaint(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    paintOverflow(context, offset, callback);
  }
}
