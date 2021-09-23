

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/gesture.dart';

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

mixin CSSOverflowStyleMixin on RenderStyleBase {
  CSSOverflowType _overflowX = CSSOverflowType.visible;
  CSSOverflowType get overflowX {
    return _overflowX;
  }
  set overflowX(CSSOverflowType value) {
    if (_overflowX == value) return;
    _overflowX = value;
  }

  CSSOverflowType _overflowY = CSSOverflowType.visible;
  CSSOverflowType get overflowY {
    return _overflowY;
  }
  set overflowY(CSSOverflowType value) {
    if (_overflowY == value) return;
    _overflowY = value;
  }

  void updateOverflow(CSSStyleDeclaration style) {
    RenderStyle renderStyle = this as RenderStyle;
    List<CSSOverflowType> overflow = getOverflowTypes(style);
    renderStyle.overflowX = overflow[0];
    renderStyle.overflowY = overflow[1];
  }
}

mixin CSSOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  KrakenScrollable? _scrollableX;
  KrakenScrollable? _scrollableY;

  // House content which can be scrolled.
  RenderLayoutBox? scrollingContentLayoutBox;

  void updateRenderOverflow(Element element) {
    ScrollListener scrollListener = element.elementDelegate.handleScroll;
    CSSStyleDeclaration style = element.style;
    RenderBoxModel renderBoxModel = element.renderBoxModel!;
    RenderStyle renderStyle = renderBoxModel.renderStyle;

    renderStyle.updateOverflow(style);

    if (renderBoxModel is RenderRecyclerLayout) {
      // Recycler layout not need repaintBoundary and scroll/pointer listeners,
      // ignoring overflowX or overflowY sets, which handle it self.
      renderBoxModel.clipX = renderBoxModel.clipY = false;
      renderBoxModel.scrollOffsetX = renderBoxModel.axis == Axis.horizontal
          ? renderBoxModel.scrollable.position : null;
      renderBoxModel.scrollOffsetY = renderBoxModel.axis == Axis.vertical
          ? renderBoxModel.scrollable.position : null;
    } else {
      CSSOverflowType overflowX = renderStyle.overflowX;
      CSSOverflowType overflowY = renderStyle.overflowY;
      bool shouldRepaintSelf = false;

      switch(overflowX) {
        case CSSOverflowType.hidden:
          _scrollableX = null;
          renderBoxModel.clipX = true;
          // Overflow hidden can be scrolled programmatically.
          renderBoxModel.enableScrollX = true;
          break;
        case CSSOverflowType.clip:
          _scrollableX = null;
          renderBoxModel.clipX = true;
          // Overflow clip can't scrolled programmatically.
          renderBoxModel.enableScrollX = false;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          _scrollableX = KrakenScrollable(axisDirection: AxisDirection.right, scrollListener: scrollListener);
          shouldRepaintSelf = true;
          renderBoxModel.clipX = true;
          renderBoxModel.enableScrollX = true;
          renderBoxModel.scrollOffsetX = _scrollableX!.position;
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
          renderBoxModel.enableScrollY = true;
          break;
        case CSSOverflowType.clip:
          _scrollableY = null;
          renderBoxModel.clipY = true;
          renderBoxModel.enableScrollY = false;
          break;
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          _scrollableY = KrakenScrollable(axisDirection: AxisDirection.down, scrollListener: scrollListener);
          shouldRepaintSelf = true;
          renderBoxModel.clipY = true;
          renderBoxModel.enableScrollY = true;
          renderBoxModel.scrollOffsetY = _scrollableY!.position;
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
        if (shouldRepaintSelf) {
          _upgradeToSelfRepaint(element);
        } else {
          _downgradeToParentRepaint(element);
        }
      }
    }
  }

  void _createScrollingLayoutBox(Element element) {
    CSSStyleDeclaration repaintBoundaryStyle = element.style.clone(element);
    repaintBoundaryStyle.setProperty(OVERFLOW, VISIBLE);
    scrollingContentLayoutBox = Element.createRenderLayout(
      element,
      repaintSelf: true,
      style: repaintBoundaryStyle
    );

    scrollingContentLayoutBox!.isScrollingContentBox = true;
  }

  // Create two repaintBoundary for an overflow scroll container.
  // Outer repaintBoundary avoid repaint of parent and sibling renderObjects when scrolling.
  // Inner repaintBoundary avoid repaint of child renderObjects when scrolling.
  void _upgradeToSelfRepaint(Element element) {
    RenderBoxModel? renderBoxModel = element.renderBoxModel;
    if (scrollingContentLayoutBox != null) {
      return;
    }
    // If renderBoxModel is already repaintBoundary caused by styles such as
    // transform or position fixed, degrade to non repaint boundary first
    // before creating two repaintBoundary.
    if (renderBoxModel!.isRepaintBoundary) {
      element.convertToNonRepaintBoundary();
      renderBoxModel = element.renderBoxModel;
    }
    RenderObject? layoutBoxParent = renderBoxModel!.parent as RenderObject?;
    RenderObject? previousSibling = _detachRenderObject(element, layoutBoxParent, renderBoxModel);
    RenderLayoutBox outerLayoutBox = Element.createRenderLayout(
      element,
      repaintSelf: true,
      prevRenderLayoutBox: renderBoxModel as RenderLayoutBox?
    );

    _createScrollingLayoutBox(element);

    // If outer scrolling box already has children in the case of element already attached,
    // move them into the children of inner scrolling box.
    List<RenderBox> children = [];
    outerLayoutBox.visitChildren((child) {
      children.add(child as RenderBox);
    });
    if (children.isNotEmpty) {
      for (RenderBox child in children) {
        outerLayoutBox.remove(child);
        scrollingContentLayoutBox!.insert(child);
      }
    }

    outerLayoutBox.add(scrollingContentLayoutBox!);

    _attachRenderObject(element, layoutBoxParent, previousSibling, outerLayoutBox);
    element.renderBoxModel = outerLayoutBox;
    // Update renderBoxModel reference in renderStyle
    element.renderBoxModel!.renderStyle.renderBoxModel = outerLayoutBox;
  }

  void _downgradeToParentRepaint(Element element) {
    RenderBoxModel? renderBoxModel = element.renderBoxModel;
    if (scrollingContentLayoutBox == null) return;
    RenderObject? layoutBoxParent = renderBoxModel!.parent as RenderObject?;
    RenderObject? previousSibling = _detachRenderObject(element, layoutBoxParent, renderBoxModel);
    RenderLayoutBox newLayoutBox = Element.createRenderLayout(
      element,
      repaintSelf: false,
      prevRenderLayoutBox: renderBoxModel as RenderLayoutBox?
    );

    _attachRenderObject(element, layoutBoxParent, previousSibling, newLayoutBox);
    element.renderBoxModel = newLayoutBox;

    // Move children of inner scrolling box to the children of outer scrolling box
    List<RenderBox> children = [];
    scrollingContentLayoutBox!.visitChildren((child) {
      children.add(child as RenderBox);
    });
    if (children.isNotEmpty) {
      for (RenderBox child in children) {
        scrollingContentLayoutBox!.remove(child);
        newLayoutBox.insert(child);
      }
    }
    // Remove inner scrolling box
    newLayoutBox.remove(scrollingContentLayoutBox!);
    scrollingContentLayoutBox = null;

    element.renderBoxModel!.renderStyle.renderBoxModel = newLayoutBox;

    // If renderBoxModel should be converted to repaintBoundary caused by styles
    // such as transform or position fixed, convert to repaintBoundary at last.
    if (element.shouldConvertToRepaintBoundary) {
      element.convertToRepaintBoundary();
    }
  }

  RenderObject? _detachRenderObject(Element element, RenderObject? parent, RenderObject? renderObject) {
    if (parent is RenderObjectWithChildMixin<RenderBox>) {
      parent.child = null;
    } else if (parent is ContainerRenderObjectMixin) {
      ContainerParentDataMixin parentData = renderObject!.parentData as ContainerParentDataMixin<RenderObject>;
      RenderObject? previousSibling = parentData.previousSibling;
      parent.remove(renderObject);
      return previousSibling;
    }

    return null;
  }

  void _attachRenderObject(Element element, RenderObject? parent, RenderObject? previousSibling, RenderObject newRenderObject) {
    if (parent is RenderObjectWithChildMixin<RenderBox>) {
      parent.child = newRenderObject as RenderBox?;
    } else if (parent is ContainerRenderObjectMixin) {
      // Update renderBoxModel reference before move to its containing block
      element.renderBoxModel = newRenderObject as RenderBoxModel?;
      element.parentElement!.addChildRenderObject(element, after: previousSibling as RenderBox?);
    }
  }

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (_scrollableX != null) {
        _scrollableX!.handlePointerDown(event);
      }
      if (_scrollableY != null) {
        _scrollableY!.handlePointerDown(event);
      }
    }
  }

  double get scrollTop {
    KrakenScrollable? scrollableY = _getScrollable(Axis.vertical);
    if (scrollableY != null) {
      return scrollableY.position?.pixels ?? 0;
    }
    return 0.0;
  }

  set scrollTop(double value) {
    scrollTo(y: value);
  }

  double get scrollLeft {
    KrakenScrollable? scrollableX = _getScrollable(Axis.horizontal);
    if (scrollableX != null) {
      return scrollableX.position?.pixels ?? 0;
    }
    return 0.0;
  }

  set scrollLeft(double value) {
    scrollTo(x: value);
  }

  double get scrollHeight {
    KrakenScrollable? scrollable = _getScrollable(Axis.vertical);
    if (scrollable?.position?.maxScrollExtent != null) {
      // Viewport height + maxScrollExtent
      return renderBoxModel!.clientHeight + scrollable!.position!.maxScrollExtent!;
    }

    Size scrollContainerSize = renderBoxModel!.scrollableSize;
    return scrollContainerSize.height;
  }

  double get scrollWidth {
    KrakenScrollable? scrollable = _getScrollable(Axis.horizontal);
    if (scrollable?.position?.maxScrollExtent != null) {
      return renderBoxModel!.clientWidth + scrollable!.position!.maxScrollExtent!;
    }
    Size scrollContainerSize = renderBoxModel!.scrollableSize;
    return scrollContainerSize.width;
  }

  void scrollBy({ num dx = 0.0, num dy = 0.0, bool? withAnimation }) {
    if (dx != 0) {
      _scroll(scrollLeft + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(scrollTop + dy, Axis.vertical, withAnimation: withAnimation);
    }
  }

  void scrollTo({ num? x, num? y, bool? withAnimation }) {
    if (x != null) {
      _scroll(x, Axis.horizontal, withAnimation: withAnimation);
    }

    if (y != null) {
      _scroll(y, Axis.vertical, withAnimation: withAnimation);
    }
  }

  KrakenScrollable? _getScrollable(Axis direction) {
    KrakenScrollable? scrollable;
    if (renderer is RenderRecyclerLayout) {
      RenderRecyclerLayout recyclerLayout = renderer as RenderRecyclerLayout;
      scrollable = direction == recyclerLayout.axis ? recyclerLayout.scrollable : null;
    } else {
      if (direction == Axis.horizontal) {
        scrollable = _scrollableX;
      } else if (direction == Axis.vertical) {
        scrollable = _scrollableY;
      }
    }
    return scrollable;
  }

  void _scroll(num aim, Axis direction, { bool? withAnimation = false }) {
    KrakenScrollable? scrollable = _getScrollable(direction);
    if (scrollable != null && aim is num) {
      double distance = aim.toDouble();

      // Apply scroll effect after layout.
      assert(renderer is RenderBox && isRendererAttached, 'Overflow can only be added to a RenderBox.');
      RenderBox renderBox = renderer as RenderBox;
      if (!renderBox.hasSize) {
        renderBox.owner!.flushLayout();
      }
      scrollable.position!.moveTo(distance,
        duration: withAnimation == true ? SCROLL_DURATION : null,
        curve: withAnimation == true ? Curves.easeOut : null,
      );
    }
  }
}
