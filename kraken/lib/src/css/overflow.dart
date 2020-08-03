import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType {
  auto,
  visible,
  hidden,
  scroll,
}

List<CSSOverflowType> getOverflowFromStyle(CSSStyleDeclaration style) {
  CSSOverflowType overflowX, overflowY;
  overflowX = overflowY = _getOverflow(style['overflow']);

  if (style.contains('overflowX')) {
    overflowX = _getOverflow(style['overflowX']);
  }

  if (style.contains('overflowY')) {
    overflowY = _getOverflow(style['overflowY']);
  }

  // Apply overflow special rules from w3c.
  if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
    overflowX = CSSOverflowType.auto;
  }

  if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
    overflowY = CSSOverflowType.auto;
  }

  return [overflowX, overflowY];
}

CSSOverflowType _getOverflow(String definition) {
  switch (definition) {
    case 'hidden':
      return CSSOverflowType.hidden;
    case 'scroll':
      return CSSOverflowType.scroll;
    case 'auto':
      return CSSOverflowType.auto;
    case 'visible':
      return CSSOverflowType.visible;
  }
  return CSSOverflowType.visible;
}

mixin CSSOverflowMixin {
  KrakenScrollable _scrollableX;
  KrakenScrollable _scrollableY;
  void updateRenderOverflow(
      RenderBoxModel renderBoxModel,
      CSSStyleDeclaration style,
      void scrollListener(double scrollTop, AxisDirection axisDirection)) {
    if (style != null) {
      List<CSSOverflowType> overflow = getOverflowFromStyle(style);
      CSSOverflowType overflowX = overflow[0];
      CSSOverflowType overflowY = overflow[1];

      switch(overflowX) {
        case CSSOverflowType.hidden:
          renderBoxModel.clipX = true;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          _scrollableX = KrakenScrollable(axisDirection: AxisDirection.right, scrollListener: scrollListener);
          renderBoxModel.clipX = true;
          renderBoxModel.enableScroll = true;
          renderBoxModel.scrollOffsetX = ViewportOffset.zero();
          break;
        case CSSOverflowType.visible:
        default:
          _scrollableX = null;
          break;
      }

      switch(overflowY) {
        case CSSOverflowType.hidden:
          renderBoxModel.clipY = true;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          renderBoxModel.clipY = true;
          renderBoxModel.enableScroll = true;
          renderBoxModel.scrollOffsetY = ViewportOffset.zero();
          break;
        case CSSOverflowType.visible:
        default:
          break;
      }
    }
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
//    if (_scrollableY != null) {
//      return _scrollableY.renderBox?.size?.height ?? 0;
//    } else if (renderScrollViewPortY is RenderBox) {
//      RenderBox renderObjectY = renderScrollViewPortY;
//      return renderObjectY.hasSize ? renderObjectY.size.height : 0;
//    }
    return 0;
  }

  double getScrollWidth() {
//    if (_scrollableX != null) {
//      return _scrollableX.renderBox?.size?.width ?? 0;
//    } else if (renderScrollViewPortX is RenderBox) {
//      RenderBox renderObjectX = renderScrollViewPortX;
//      return renderObjectX.hasSize ? renderObjectX.size.width : 0;
//    }
    return 0;
  }

  void scroll(List args, {bool isScrollBy = false}) {
    if (args != null && args.length > 0) {
      dynamic option = args[0];
      if (option is Map) {
        num top = option['top'];
        num left = option['left'];
        dynamic behavior = option['behavior'];
        Curve curve;
        if (behavior == 'smooth') {
          curve = Curves.linear;
        }
        _scroll(top, curve, isScrollBy: isScrollBy, isDirectionX: false);
        _scroll(left, curve, isScrollBy: isScrollBy, isDirectionX: true);
      }
    }
  }

  void _scroll(num aim, Curve curve, {bool isScrollBy = false, bool isDirectionX = false}) {
    Duration duration;
    KrakenScrollable scrollable;
    if (isDirectionX) {
      scrollable = _scrollableX;
    } else {
      scrollable = _scrollableY;
    }
    if (scrollable != null && aim != null) {
      if (curve != null) {
        double diff = aim - (scrollable.position?.pixels ?? 0);
        duration = Duration(milliseconds: diff.abs().toInt() * 5);
      }
      double distance;
      if (isScrollBy) {
        distance = (scrollable.position?.pixels ?? 0) + aim;
      } else {
        distance = aim.toDouble();
      }
      scrollable.position.moveTo(distance, duration: duration, curve: curve);
    }
  }
}

class CSSOverflowDirectionBox extends RenderSizedOverflowBox {
  AxisDirection axisDirection;

  CSSOverflowDirectionBox(
      {RenderObject child,
      Size requestedSize = Size.zero,
      AlignmentGeometry alignment = Alignment.topLeft,
      TextDirection textDirection,
      this.axisDirection})
      : assert(requestedSize != null),
        super(child: child, alignment: alignment, textDirection: textDirection, requestedSize: requestedSize);

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
      alignChild();
    } else {
      size = Size.zero;
    }
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
    properties.add(DiagnosticsProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }

    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    return child?.hitTest(result, position: position);
  }
}

void setChild(RenderObject parent, RenderObject child) {
  if (parent is RenderObjectWithChildMixin)
    parent.child = child;
  else if (parent is ContainerRenderObjectMixin) parent.add(child);
}
