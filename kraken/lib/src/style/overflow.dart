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
  KrakenScrollable _scrollableX;
  KrakenScrollable _scrollableY;

  Style _style;

  RenderObject initOverflowBox(RenderObject current, Style style, void scrollListener(double scrollTop)) {
    assert(style != null);
    _style = style;
    _child = current;
    // X direction overflow
    _renderObjectX = _getRenderObjectByOverflow(style.overflowX, current, AxisDirection.right, scrollListener);
    // Y direction overflow
    _renderObjectY = _getRenderObjectByOverflow(style.overflowY, _renderObjectX, AxisDirection.down, scrollListener);
    return _renderObjectY;
  }

  void updateOverFlowBox(Style style, void scrollListener(double scrollTop)) {
    if (style != null) {
      String oldOverflowY = null;
      if (_style != null) {
        oldOverflowY = _style.overflowY;
      }
      if (style.overflowY != oldOverflowY && _renderObjectY != null) {
        AbstractNode parent = _renderObjectY.parent;
        AbstractNode childParent = _renderObjectX.parent;
        AxisDirection axisDirection = AxisDirection.down;
        switch (style.overflowY) {
          case Style.VISIBLE:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              OverflowDirectionBox overflowCustomBox = OverflowDirectionBox(
                  child: _renderObjectX, textDirection: TextDirection.ltr, axisDirection: axisDirection);
              parent.child = _renderObjectY = overflowCustomBox;
              _scrollableY = null;
            }
            break;
          case Style.AUTO:
          case Style.SCROLL:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              _scrollableY = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
              parent.child = _renderObjectY = _scrollableY.getScrollableRenderObject(_renderObjectX);
            }
            break;
          case Style.HIDDEN:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = _renderObjectY = RenderSingleChildViewport(
                  axisDirection: axisDirection, offset: ViewportOffset.zero(), child: _renderObjectX, shouldClip: true);
              _scrollableY = null;
            }
            break;
        }
      }

      String oldOverflowX = null;
      if (_style != null) {
        oldOverflowX = _style.overflowX;
      }
      if (style.overflowX != oldOverflowX && _renderObjectX != null) {
        AbstractNode parent = _renderObjectX.parent;
        AbstractNode childParent = _child.parent;
        AxisDirection axisDirection = AxisDirection.right;
        switch (style.overflowX) {
          case Style.VISIBLE:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = _renderObjectX =
                  OverflowDirectionBox(child: _child, textDirection: TextDirection.ltr, axisDirection: axisDirection);
              _scrollableX = null;
            }
            break;
          case Style.AUTO:
          case Style.SCROLL:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              _scrollableX = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
              parent.child = _renderObjectX = _scrollableX.getScrollableRenderObject(_child);
            }
            break;
          case Style.HIDDEN:
            assert(parent is RenderObjectWithChildMixin);
            assert(childParent is RenderObjectWithChildMixin);
            if (parent is RenderObjectWithChildMixin && childParent is RenderObjectWithChildMixin) {
              childParent.child = null;
              parent.child = _renderObjectX = RenderSingleChildViewport(
                  axisDirection: axisDirection, offset: ViewportOffset.zero(), child: _child, shouldClip: true);
              _scrollableX = null;
            }
            break;
        }
      }
      _style = style;
    }
  }

  RenderObject _getRenderObjectByOverflow(
      String overflow, RenderObject current, AxisDirection axisDirection, void scrollListener(double scrollTop)) {
    switch (overflow) {
      case Style.VISIBLE:
        if (axisDirection == AxisDirection.right) {
          _scrollableX = null;
        } else {
          _scrollableY = null;
        }
        current = OverflowDirectionBox(
          child: current,
          textDirection: TextDirection.ltr,
          axisDirection: axisDirection,
        );
        break;
      case Style.AUTO:
      case Style.SCROLL:
        KrakenScrollable scrollable = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
        if (axisDirection == AxisDirection.right) {
          _scrollableX = scrollable;
        } else {
          _scrollableY = scrollable;
        }
        current = scrollable.getScrollableRenderObject(current);
        break;
      case Style.HIDDEN:
        if (axisDirection == AxisDirection.right) {
          _scrollableX = null;
        } else {
          _scrollableY = null;
        }
        current = RenderSingleChildViewport(
            axisDirection: axisDirection, offset: ViewportOffset.zero(), child: current, shouldClip: true);
        break;
    }
    return current;
  }

  double getScrollTop() {
    if (_scrollableY != null) {
      return _scrollableY.position?.pixels ?? 0;
    }
    return 0;
  }

  double getScrollLeft() {
    if (_scrollableX != null) {
      return _scrollableX.position?.pixels ?? 0;
    }
    return 0;
  }

  double getScrollHeight() {
    if (_scrollableY != null) {
      return _scrollableY.renderBox?.size?.height ?? 0;
    } else if (_renderObjectY is RenderBox) {
      RenderBox renderObjectY = _renderObjectY as RenderBox;
      return renderObjectY.hasSize ? renderObjectY.size.height : 0;
    }
    return 0;
  }

  double getScrollWidth() {
    if (_scrollableX != null) {
      return _scrollableX.renderBox?.size?.width ?? 0;
    } else if (_renderObjectX is RenderBox) {
      RenderBox renderObjectX = _renderObjectX as RenderBox;
      return renderObjectX.hasSize ? renderObjectX.size.width : 0;
    }
    return 0;
  }
}

class OverflowDirectionBox extends RenderSizedOverflowBox {
  AxisDirection axisDirection;

  OverflowDirectionBox(
      {RenderBox child,
      Size requestedSize = Size.zero,
      AlignmentGeometry alignment = Alignment.topLeft,
      TextDirection textDirection,
      this.axisDirection})
      : assert(requestedSize != null),
        super(child: child, alignment: alignment, textDirection: textDirection, requestedSize: requestedSize);

  @override
  void performLayout() {
    assert(child != null);
    BoxConstraints childConstraints;
    if (axisDirection == AxisDirection.down) {
      childConstraints = constraints.copyWith(minHeight: 0, maxHeight: double.infinity);
    } else {
      childConstraints = constraints.copyWith(minWidth: 0, maxWidth: double.infinity);
    }
    child.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(child.size);
    alignChild();
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final Rect outerRect = offset & size;
      debugPaintPadding(context.canvas, outerRect, outerRect);
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AxisDirection>('axisDirection', axisDirection));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}
