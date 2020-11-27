import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType {
  auto,
  visible,
  hidden,
  scroll,
  clip
}

List<CSSOverflowType> getOverflowTypes(CSSStyleDeclaration style) {
  CSSOverflowType overflowX = _getOverflowType(style[OVERFLOW_X]);
  CSSOverflowType overflowY = _getOverflowType(style[OVERFLOW_Y]);

  // Apply overflow special rules from w3c.
  if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
    overflowX = CSSOverflowType.auto;
  }

  if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
    overflowY = CSSOverflowType.auto;
  }

  return [overflowX, overflowY];
}

CSSOverflowType _getOverflowType(String definition) {
  switch (definition) {
    case HIDDEN:
      return CSSOverflowType.hidden;
    case SCROLL:
      return CSSOverflowType.scroll;
    case AUTO:
      return CSSOverflowType.auto;
    case VISIBLE:
    default:
      return CSSOverflowType.visible;
  }
}

typedef ScrollListener = void Function(double scrollTop, AxisDirection axisDirection);

mixin CSSOverflowMixin on Node {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  KrakenScrollable _scrollableX;
  KrakenScrollable _scrollableY;

  void updateRenderOverflow(RenderBoxModel renderBoxModel, Element element, ScrollListener scrollListener) {
    CSSStyleDeclaration style = element.style;
    if (style != null) {
      List<CSSOverflowType> overflow = getOverflowTypes(style);
      CSSOverflowType overflowX = overflow[0];
      CSSOverflowType overflowY = overflow[1];
      bool shouldRepaintSelf = false;

      switch(overflowX) {
        case CSSOverflowType.hidden:
          _scrollableX = null;
          renderBoxModel.clipX = true;
          // overflow hidden can be scrolled programmatically
          renderBoxModel.enableScrollX = true;
          break;
        case CSSOverflowType.clip:
          _scrollableX = null;
          renderBoxModel.clipX = true;
          // overflow clip can't scrolled programmatically
          renderBoxModel.enableScrollX = false;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          _scrollableX = KrakenScrollable(axisDirection: AxisDirection.right, scrollListener: scrollListener);
          shouldRepaintSelf = true;
          renderBoxModel.clipX = true;
          renderBoxModel.enableScrollX = true;
          renderBoxModel.scrollOffsetX = _scrollableX.position;
          break;
        case CSSOverflowType.visible:
        default:
          _scrollableX = null;
          renderBoxModel.clipX = false;
          renderBoxModel.enableScrollX = false;
          break;
      }

      switch(overflowY) {
        case CSSOverflowType.hidden:
          _scrollableY = null;
          renderBoxModel.clipY = true;
          // overflow hidden can be scrolled programmatically
          renderBoxModel.enableScrollY = true;
          break;
        case CSSOverflowType.clip:
          _scrollableY = null;
          renderBoxModel.clipY = true;
          // overflow clip can't scrolled programmatically
          renderBoxModel.enableScrollY = false;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          _scrollableY = KrakenScrollable(axisDirection: AxisDirection.down, scrollListener: scrollListener);
          shouldRepaintSelf = true;
          renderBoxModel.clipY = true;
          renderBoxModel.enableScrollY = true;
          renderBoxModel.scrollOffsetY = _scrollableY.position;
          break;
        case CSSOverflowType.visible:
        default:
          _scrollableY = null;
          renderBoxModel.clipY = false;
          renderBoxModel.enableScrollY = false;
          break;
      }

      renderBoxModel.scrollListener = scrollListener;
      renderBoxModel.pointerListener = _pointerListener;

      if (renderBoxModel is RenderLayoutBox) {
        RenderObject layoutBoxParent = renderBoxModel.parent;

        // Overflow auto/scroll will create repaint boundary to improve scroll performance
        // So it needs to transform between layout and its repaint boundary replacement when transform changes
        RenderLayoutBox newLayoutBox = createRenderLayout(element, repaintSelf: shouldRepaintSelf, prevRenderLayoutBox: renderBoxModel);

        if (newLayoutBox == renderBoxModel) {
          return;
        }
        if (layoutBoxParent is RenderObjectWithChildMixin<RenderBox>) {
          layoutBoxParent.child = null;
          layoutBoxParent.child = newLayoutBox;
        } else if (layoutBoxParent is ContainerRenderObjectMixin) {
          ContainerBoxParentData parentData = renderBoxModel.parentData;
          RenderObject previousSibling = parentData.previousSibling;
          layoutBoxParent.remove(renderBoxModel);
          element.renderBoxModel = newLayoutBox;
          element.parent.addChildRenderObject(element, after: previousSibling);
        }
      }
    }
  }

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (_scrollableX != null) {
        _scrollableX.handlePointerDown(event);
      }
      if (_scrollableY != null) {
        _scrollableY.handlePointerDown(event);
      }
    }
  }

  double getScrollTop() {
    if (_scrollableY != null) {
      return _scrollableY.position?.pixels ?? 0;
    }
    return 0;
  }

  void setScrollTop(double value) {
    scrollTo(dy: value);
  }

  void setScrollLeft(double value) {
    scrollTo(dx: value);
  }

  double getScrollLeft() {
    if (_scrollableX != null) {
      return _scrollableX.position?.pixels ?? 0;
    }
    return 0;
  }

  double getScrollHeight(RenderBoxModel renderBoxModel) {
    Size scrollContainerSize = renderBoxModel.maxScrollableSize;
    return scrollContainerSize.height;
  }

  double getScrollWidth(RenderBoxModel renderBoxModel) {
    Size scrollContainerSize = renderBoxModel.maxScrollableSize;
    return scrollContainerSize.width;
  }

  void handleMethodScroll(List args, { bool diff = false }) {
    if (args != null && args.length > 0) {
      dynamic option = args[0];
      if (option is Map) {
        num top = option['top'];
        num left = option['left'];
        bool withAnimation = option['behavior'] == 'smooth';

        if (diff) {
          scrollBy(dx: left, dy: top, withAnimation: withAnimation);
        } else {
          scrollTo(dx: left, dy: top, withAnimation: withAnimation);
        }
      }
    }
  }

  void scrollBy({ double dx = 0.0, double dy = 0.0, bool withAnimation }) {
    if (dx != 0) {
      _scroll(dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(dy, Axis.horizontal, withAnimation: withAnimation);
    }
  }

  void scrollTo({ double dx = 0.0, double dy = 0.0, bool withAnimation }) {
    if (dx != 0) {
      _scroll(getScrollTop() + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(getScrollLeft() + dy, Axis.horizontal, withAnimation: withAnimation);
    }
  }

  void _scroll(num aim, Axis direction, { bool withAnimation = false }) {
    KrakenScrollable scrollable;
    if (direction == Axis.horizontal) {
      scrollable = _scrollableX;
    } else if (direction == Axis.vertical) {
      scrollable = _scrollableY;
    }

    if (scrollable != null && aim != null) {
      double distance = aim.toDouble();

      // Apply scroll effect after layout.
      assert(renderer is RenderBox && isRendererAttached, 'Overflow can only be added to a RenderBox.');
      RenderBox renderBox = renderer;
      if (!renderBox.hasSize) {
        renderBox.owner.flushLayout();
      }
      scrollable.position.moveTo(distance,
        duration: withAnimation == true ? SCROLL_DURATION : null,
        curve: withAnimation == true ? Curves.easeOut : null,
      );
    }
  }
}
