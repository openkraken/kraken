/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType {
  auto,
  visible,
  hidden,
  scroll,
  clip
}

// Styles which need to copy from outer scrolling box to inner scrolling content box.
List<String> _scrollingContentBoxCopyStyles = [
  DISPLAY,
  LINE_HEIGHT,
  TEXT_ALIGN,
  WHITE_SPACE,
  FLEX_DIRECTION,
  FLEX_WRAP,
  ALIGN_CONTENT,
  ALIGN_ITEMS,
  ALIGN_SELF,
  JUSTIFY_CONTENT,
  COLOR,
  TEXT_DECORATION_LINE,
  TEXT_DECORATION_COLOR,
  TEXT_DECORATION_STYLE,
  FONT_WEIGHT,
  FONT_STYLE,
  FONT_FAMILY,
  FONT_SIZE,
  LETTER_SPACING,
  WORD_SPACING,
  TEXT_SHADOW,
  TEXT_OVERFLOW,
  LINE_CLAMP,
];

mixin CSSOverflowMixin on RenderStyle {
  @override
  CSSOverflowType get overflowX => _overflowX ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowX;
  set overflowX(CSSOverflowType value) {
    if (_overflowX == value) return;
    _overflowX = value;
  }

  @override
  CSSOverflowType get overflowY => _overflowY ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowY;
  set overflowY(CSSOverflowType value) {
    if (_overflowY == value) return;
    _overflowY = value;
  }

  @override
  CSSOverflowType get effectiveOverflowX {
    if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    return overflowX;
  }

  @override
  CSSOverflowType get effectiveOverflowY {
    if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    return overflowY;
  }

  static CSSOverflowType resolveOverflowType(String definition) {
    switch (definition) {
      case HIDDEN:
        return CSSOverflowType.hidden;
      case SCROLL:
        return CSSOverflowType.scroll;
      case AUTO:
        return CSSOverflowType.auto;
      case CLIP:
        return CSSOverflowType.clip;
      case VISIBLE:
      default:
        return CSSOverflowType.visible;
    }
  }
}

mixin ElementOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  KrakenScrollable? _scrollableX;
  KrakenScrollable? _scrollableY;

  void disposeScrollable() {
    _scrollableX = null;
    _scrollableY = null;
  }

  void updateRenderBoxModelWithOverflowX(ScrollListener scrollListener) {
    if (renderBoxModel is RenderSliverListLayout) {
      RenderSliverListLayout renderBoxModel = this.renderBoxModel as RenderSliverListLayout;
      // Recycler layout not need repaintBoundary and scroll/pointer listeners,
      // ignoring overflowX or overflowY sets, which handle it self.
      renderBoxModel.clipX = false;
      renderBoxModel.scrollOffsetX = renderBoxModel.axis == Axis.horizontal
          ? renderBoxModel.scrollable.position : null;
    } else if (renderBoxModel != null) {
      RenderBoxModel renderBoxModel = this.renderBoxModel!;
      CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
      bool shouldScrolling = false;
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
          shouldScrolling = true;
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

      renderBoxModel.scrollListener = scrollListener;
      renderBoxModel.scrollablePointerListener = _scrollablePointerListener;

      if (renderBoxModel is RenderLayoutBox) {
        if (shouldScrolling) {
          _attachScrollingContentBox();
        } else {
          _detachScrollingContentBox();
        }
      }
    }
  }

  void updateRenderBoxModelWithOverflowY(ScrollListener scrollListener) {
    if (renderBoxModel is RenderSliverListLayout) {
      RenderSliverListLayout renderBoxModel = this.renderBoxModel as RenderSliverListLayout;
      // Recycler layout not need repaintBoundary and scroll/pointer listeners,
      // ignoring overflowX or overflowY sets, which handle it self.
      renderBoxModel.clipY = false;
      renderBoxModel.scrollOffsetY = renderBoxModel.axis == Axis.vertical
          ? renderBoxModel.scrollable.position : null;
    } else if (renderBoxModel != null) {
      RenderBoxModel renderBoxModel = this.renderBoxModel!;
      CSSOverflowType overflowY = renderStyle.effectiveOverflowY;
      bool shouldScrolling = false;
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
          shouldScrolling = true;
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
      renderBoxModel.scrollablePointerListener = _scrollablePointerListener;

      if (renderBoxModel is RenderLayoutBox) {
        if (shouldScrolling) {
          _attachScrollingContentBox();
        } else {
          _detachScrollingContentBox();
        }
      }
    }
  }

  void scrollingContentBoxStyleListener(String property, String? original, String present) {
    RenderLayoutBox? scrollingContentBox = (renderBoxModel as RenderLayoutBox).renderScrollingContent;
    // Sliver content has no multi scroll content box.
    if (scrollingContentBox == null) return;

    CSSRenderStyle scrollingContentRenderStyle = scrollingContentBox.renderStyle;

    switch (property) {
      case DISPLAY:
        scrollingContentRenderStyle.display = renderStyle.display;
        break;
      case LINE_HEIGHT:
        scrollingContentRenderStyle.lineHeight = renderStyle.lineHeight;
        break;
      case TEXT_ALIGN:
        scrollingContentRenderStyle.textAlign = renderStyle.textAlign;
        break;
      case WHITE_SPACE:
        scrollingContentRenderStyle.whiteSpace = renderStyle.whiteSpace;
        break;
      case FLEX_DIRECTION:
        scrollingContentRenderStyle.flexDirection = renderStyle.flexDirection;
        break;
      case FLEX_WRAP:
        scrollingContentRenderStyle.flexWrap = renderStyle.flexWrap;
        break;
      case ALIGN_CONTENT:
        scrollingContentRenderStyle.alignContent = renderStyle.alignContent;
        break;
      case ALIGN_ITEMS:
        scrollingContentRenderStyle.alignItems = renderStyle.alignItems;
        break;
      case ALIGN_SELF:
        scrollingContentRenderStyle.alignSelf = renderStyle.alignSelf;
        break;
      case JUSTIFY_CONTENT:
        scrollingContentRenderStyle.justifyContent = renderStyle.justifyContent;
        break;
      case COLOR:
        scrollingContentRenderStyle.color = renderStyle.color;
        break;
      case TEXT_DECORATION_LINE:
        scrollingContentRenderStyle.textDecorationLine = renderStyle.textDecorationLine;
        break;
      case TEXT_DECORATION_COLOR:
        scrollingContentRenderStyle.textDecorationColor = renderStyle.textDecorationColor;
        break;
      case TEXT_DECORATION_STYLE:
        scrollingContentRenderStyle.textDecorationStyle = renderStyle.textDecorationStyle;
        break;
      case FONT_WEIGHT:
        scrollingContentRenderStyle.fontWeight = renderStyle.fontWeight;
        break;
      case FONT_STYLE:
        scrollingContentRenderStyle.fontStyle = renderStyle.fontStyle;
        break;
      case FONT_FAMILY:
        scrollingContentRenderStyle.fontFamily = renderStyle.fontFamily;
        break;
      case FONT_SIZE:
        scrollingContentRenderStyle.fontSize = renderStyle.fontSize;
        break;
      case LETTER_SPACING:
        scrollingContentRenderStyle.letterSpacing = renderStyle.letterSpacing;
        break;
      case WORD_SPACING:
        scrollingContentRenderStyle.wordSpacing = renderStyle.wordSpacing;
        break;
      case TEXT_SHADOW:
        scrollingContentRenderStyle.textShadow = renderStyle.textShadow;
        break;
      case TEXT_OVERFLOW:
        scrollingContentRenderStyle.textOverflow = renderStyle.textOverflow;
        break;
      case LINE_CLAMP:
        scrollingContentRenderStyle.lineClamp = renderStyle.lineClamp;
        break;
    }
  }

  void updateScrollingContentBox() {
    _detachScrollingContentBox();
    _attachScrollingContentBox();
  }

  // Create two repaintBoundary for an overflow scroll container.
  // Outer repaintBoundary avoid repaint of parent and sibling renderObjects when scrolling.
  // Inner repaintBoundary avoid repaint of child renderObjects when scrolling.
  void _attachScrollingContentBox() {
    RenderLayoutBox outerLayoutBox = renderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox != null) {
      return;
    }

    Element element = this as Element;
    // If outer scrolling box already has children in the case of element already attached,
    // move them into the children of inner scrolling box.
    List<RenderBox> children = outerLayoutBox.detachChildren();

    RenderLayoutBox renderScrollingContent = element.createScrollingContentLayout();
    renderScrollingContent.addAll(children);

    outerLayoutBox.add(renderScrollingContent);
    element.style.addStyleChangeListener(scrollingContentBoxStyleListener);

    // Manually copy already set filtered styles to the renderStyle of scrollingContentLayoutBox.
    _scrollingContentBoxCopyStyles.forEach((String styleProperty) {
      scrollingContentBoxStyleListener(styleProperty, null, '');
    });
  }

  void _detachScrollingContentBox() {
    RenderLayoutBox outerLayoutBox = renderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox == null) return;

    List<RenderBox> children = scrollingContentBox.detachChildren();
    // Remove scrolling content box.
    outerLayoutBox.remove(scrollingContentBox);

    (this as Element).style.removeStyleChangeListener(scrollingContentBoxStyleListener);
    // Move children of scrolling content box to the children to outer layout box.
    outerLayoutBox.addAll(children);
  }

  void _scrollablePointerListener(PointerEvent event) {
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
      return renderBoxModel!.clientHeight + scrollable!.position!.maxScrollExtent;
    }

    Size scrollContainerSize = renderBoxModel!.scrollableSize;
    return scrollContainerSize.height;
  }

  double get scrollWidth {
    KrakenScrollable? scrollable = _getScrollable(Axis.horizontal);
    if (scrollable?.position?.maxScrollExtent != null) {
      return renderBoxModel!.clientWidth + scrollable!.position!.maxScrollExtent;
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
    if (renderer is RenderSliverListLayout) {
      RenderSliverListLayout recyclerLayout = renderer as RenderSliverListLayout;
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
