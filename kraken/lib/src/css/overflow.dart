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

typedef ScrollListener = void Function(double scrollTop, AxisDirection axisDirection);

mixin CSSOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  KrakenScrollable _scrollableX;
  KrakenScrollable _scrollableY;

  /// All the children whose position is sticky to this element
  List<Element> stickyChildren = [];

  // House content which can be scrolled.
  RenderLayoutBox scrollingContentLayoutBox;

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

          _scrollableX.position.isScrollingNotifier.removeListener(_onScrollXStart);
          _scrollableX.position.isScrollingNotifier.addListener(_onScrollXStart);
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

          _scrollableY.position.isScrollingNotifier.removeListener(_onScrollYStart);
          _scrollableY.position.isScrollingNotifier.addListener(_onScrollYStart);
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
          _upgradeToSelfRepaint(element, renderBoxModel);
        } else {
          _downgradeToParentRepaint(element, renderBoxModel);
        }
      }
    }
  }

  void _createScrollingLayoutBox(Element element) {
    int shadowElementTargetId = 0 - element.targetId;
    if (element.targetId == BODY_ID || element.targetId == DOCUMENT_ID) {
      shadowElementTargetId = shadowElementTargetId - 1024;
    }
    // @HACK: create shadow element for scrollingLayoutBox
    // @TODO: remove this after rendering phase are working without element and targetId required
    Element scrollingElement = Element(shadowElementTargetId, element.nativeElementPtr, element.elementManager,
        defaultStyle: element.defaultStyle, isIntrinsicBox: element.isInlineBox, tagName: element.tagName, isScrollingElement: true);
    elementManager.setEventTarget(scrollingElement);
    CSSStyleDeclaration repaintBoundaryStyle = element.style.clone(scrollingElement);
    repaintBoundaryStyle.setProperty(OVERFLOW, VISIBLE);
    scrollingContentLayoutBox = element.createRenderLayout(scrollingElement, repaintSelf: true, style: repaintBoundaryStyle);
    scrollingContentLayoutBox.isScrollingContentBox = true;
    scrollingElement.renderBoxModel = scrollingContentLayoutBox;
    element.scrollingElement = scrollingElement;
  }

  // Create two repaintBoundary for an overflow scroll container.
  // Outer repaintBoundary avoid repaint of parent and sibling renderObjects when scrolling.
  // Inner repaintBoundary avoid repaint of child renderObjects when scrolling.
  void _upgradeToSelfRepaint(Element element, RenderBoxModel renderBoxModel) {
    if (renderBoxModel.isRepaintBoundary) return;
    RenderObject layoutBoxParent = renderBoxModel.parent;

    RenderObject previousSibling = _detachRenderObject(element, layoutBoxParent, renderBoxModel);
    RenderLayoutBox outerLayoutBox = element.createRenderLayout(element, repaintSelf: true, prevRenderLayoutBox: renderBoxModel);

    _createScrollingLayoutBox(element);
    outerLayoutBox.add(scrollingContentLayoutBox);
    element.renderBoxModel = outerLayoutBox;
    // Update renderBoxModel reference in renderStyle
    element.renderBoxModel.renderStyle.renderBoxModel = outerLayoutBox;

    _attachRenderObject(element, layoutBoxParent, previousSibling, outerLayoutBox);
  }

  void _downgradeToParentRepaint(Element element, RenderBoxModel renderBoxModel) {
    if (!renderBoxModel.isRepaintBoundary) return;
    RenderObject layoutBoxParent = renderBoxModel.parent;
    RenderObject previousSibling = _detachRenderObject(element, layoutBoxParent, renderBoxModel);
    RenderLayoutBox newLayoutBox = element.createRenderLayout(element, repaintSelf: false, prevRenderLayoutBox: renderBoxModel);
    element.renderBoxModel = newLayoutBox;
    // Update renderBoxModel reference in renderStyle
    element.renderBoxModel.renderStyle.renderBoxModel = newLayoutBox;
    scrollingContentLayoutBox = null;

    _attachRenderObject(element, layoutBoxParent, previousSibling, newLayoutBox);
  }

  RenderObject _detachRenderObject(Element element, RenderObject parent, RenderObject renderObject) {
    if (parent is RenderObjectWithChildMixin<RenderBox>) {
      parent.child = null;
    } else if (parent is ContainerRenderObjectMixin) {
      ContainerBoxParentData parentData = renderObject.parentData;
      RenderObject previousSibling = parentData.previousSibling;
      parent.remove(renderObject);
      return previousSibling;
    }

    return null;
  }

  void _attachRenderObject(Element element, RenderObject parent, RenderObject previousSibling, RenderObject newRenderObject) {
    if (parent is RenderObjectWithChildMixin<RenderBox>) {
      parent.child = newRenderObject;
    } else if (parent is ContainerRenderObjectMixin) {
      element.parent.addChildRenderObject(element, after: previousSibling);
    }
  }

  /// Cache sticky children when axis X starts scroll
  void _onScrollXStart() {
    if(_scrollableX.position.isScrollingNotifier.value) {
      stickyChildren = _findStickyChildren(this);
    }
  }

  /// Cache sticky children when axis Y starts scroll
  void _onScrollYStart() {
    if(_scrollableY.position.isScrollingNotifier.value) {
      stickyChildren = _findStickyChildren(this);
    }
  }

  /// Find all the children whose position is sticky to this element
  List<Element> _findStickyChildren(Element element) {
    assert(element != null);
    List<Element> result = [];
    for (Element child in element.children) {
      List<CSSOverflowType> overflow = getOverflowTypes(child.style);
      CSSOverflowType overflowX = overflow[0];
      CSSOverflowType overflowY = overflow[1];

      if (child.isValidSticky) result.add(child);

      // No need to loop scrollable container children
      if (overflowX != CSSOverflowType.visible || overflowY != CSSOverflowType.visible) {
        break;
      }

      List<Element> mergedChildren = _findStickyChildren(child);
      for (Element child in mergedChildren) {
        result.add(child);
      }
    }
    return result;
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

  double get scrollTop {
    if (_scrollableY != null) {
      return _scrollableY.position?.pixels ?? 0;
    }
    return 0.0;
  }
  set scrollTop(double value) {
    scrollTo(y: value);
  }

  double get scrollLeft {
    if (_scrollableX != null) {
      return _scrollableX.position?.pixels ?? 0;
    }
    return 0.0;
  }
  set scrollLeft(double value) {
    scrollTo(x: value);
  }

  get scrollHeight {
    Size scrollContainerSize = renderBoxModel.scrollableSize;
    return scrollContainerSize.height;
  }

  get scrollWidth {
    Size scrollContainerSize = renderBoxModel.scrollableSize;
    return scrollContainerSize.width;
  }

  void handleMethodScroll(num x, num y, { bool diff = false }) {
    if (diff) {
      scrollBy(dx: x, dy: y, withAnimation: false);
    } else {
      scrollTo(x: x, y: y, withAnimation: false);
    }
  }

  void scrollBy({ num dx = 0.0, num dy = 0.0, bool withAnimation }) {
    stickyChildren = _findStickyChildren(this);

    if (dx != 0) {
      _scroll(scrollLeft + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(scrollTop + dy, Axis.vertical, withAnimation: withAnimation);
    }
  }

  void scrollTo({ num x, num y, bool withAnimation }) {
    stickyChildren = _findStickyChildren(this);

    if (x != null) {
      _scroll(x, Axis.horizontal, withAnimation: withAnimation);
    }

    if (y != null) {
      _scroll(y, Axis.vertical, withAnimation: withAnimation);
    }
  }

  KrakenScrollable _getScrollable(Axis direction) {
    KrakenScrollable scrollable;
    if (renderer is RenderRecyclerLayout) {
      scrollable = (renderer as RenderRecyclerLayout).scrollable;
    } else {
      if (direction == Axis.horizontal) {
        scrollable = _scrollableX;
      } else if (direction == Axis.vertical) {
        scrollable = _scrollableY;
      }
    }
    return scrollable;
  }

  void _scroll(num aim, Axis direction, { bool withAnimation = false }) {
    KrakenScrollable scrollable = _getScrollable(direction);
    if (scrollable != null && aim is num) {
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
