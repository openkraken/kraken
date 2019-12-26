import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin StyleOverflowMixin {
  RenderObject _renderObjectX;
  RenderObject _child;
  RenderObject _renderObjectY;

  Style _style;

  RenderObject initOverflowBox(RenderObject current, Style style) {
    if (style != null) {
      _style = style;
      _child = current;
      _renderObjectX =
          _getRenderObjectByOverflow(style.overflowX, current, AxisDirection.right);

      _renderObjectY =
          _getRenderObjectByOverflow(style.overflowY, _renderObjectX, AxisDirection.down);
    }
    return _renderObjectY;
  }

  void updateOverFlowBox(Style style) {
    if (style != null) {
      if (style.overflowY != _style.overflowY) {
        AbstractNode parent = _renderObjectY.parent;
        AbstractNode childParent = _renderObjectX.parent;
        AxisDirection axisDirection = AxisDirection.down;
        switch (style.overflowY) {
          case Style.VISIBLE:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
                childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              OverflowCustomBox overflowCustomBox = OverflowCustomBox(
                child: _renderObjectX, textDirection: TextDirection.ltr,
                axisDirection: axisDirection);
              parent.child = overflowCustomBox;
            }
            break;
          case Style.AUTO:
          case Style.SCROLL:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
                childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = KrakenScrollable(axisDirection: axisDirection)
                  .getScrollableRenderObject(_renderObjectX);
            }
            break;
          case Style.HIDDEN:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
              childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = RenderSingleChildViewport(
                axisDirection: axisDirection, offset: ViewportOffset.zero(), child: _renderObjectX);
            }
            break;
        }
      }

      if (style.overflowX != _style.overflowX) {
        AbstractNode parent = _renderObjectX.parent;
        AbstractNode childParent = _child.parent;
        AxisDirection axisDirection = AxisDirection.right;
        switch (style.overflowX) {
          case Style.VISIBLE:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
              childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = OverflowCustomBox(
                child: _child, textDirection: TextDirection.ltr, axisDirection: axisDirection);
            }
            break;
          case Style.AUTO:
          case Style.SCROLL:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
              childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = KrakenScrollable(axisDirection: axisDirection)
                .getScrollableRenderObject(_child);
            }
            break;
          case Style.HIDDEN:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin &&
              childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = RenderSingleChildViewport(
                axisDirection: axisDirection, offset: ViewportOffset.zero(), child: _child);
            }
            break;
        }
      }
      _style = style;
    }
  }

  RenderObject _getRenderObjectByOverflow(
      String overflow, RenderObject current, AxisDirection axisDirection) {
    switch (overflow) {
      case Style.VISIBLE:
        current =
            OverflowCustomBox(child: current,
              textDirection: TextDirection.ltr, axisDirection: axisDirection);
         break;
      case Style.AUTO:
      case Style.SCROLL:
        current = KrakenScrollable(axisDirection: axisDirection)
            .getScrollableRenderObject(current);
        break;
      case Style.HIDDEN:
        current = RenderSingleChildViewport(
          axisDirection: axisDirection, offset: ViewportOffset.zero(), child: current);
        break;
    }
    return current;
  }
}

class OverflowCustomBox extends RenderSizedOverflowBox {
  AxisDirection axisDirection;
  OverflowCustomBox({
    RenderBox child,
    Size requestedSize = Size.zero,
    AlignmentGeometry alignment = Alignment.topLeft,
    TextDirection textDirection,
    AxisDirection axisDirection
  })  : assert(requestedSize != null),
        axisDirection = axisDirection,
        super(
            child: child,
            alignment: alignment,
            textDirection: textDirection,
            requestedSize: requestedSize);

  @override
  void performLayout() {
    assert(child != null);
    BoxConstraints childConstraints;
    if (axisDirection == AxisDirection.down) {
      childConstraints = constraints.copyWith(maxHeight: double.infinity);
    } else {
      childConstraints = constraints.copyWith(maxWidth: double.infinity);
    }
    child.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(child.size);
    alignChild();
  }
}
