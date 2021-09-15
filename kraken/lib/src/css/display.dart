

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

enum CSSDisplay {
  inline,
  block,
  inlineBlock,

  flex,
  inlineFlex,

  sliver, // @TODO temp name.

  none
}

mixin CSSDisplayMixin on RenderStyleBase {

  CSSDisplay? _display = CSSDisplay.inline;
  CSSDisplay? get display => _display;
  set display(CSSDisplay? value) {
    if (value == null) return;
    if (_display != value) {
      renderBoxModel!.markNeedsLayout();
      _display = value;
    }
  }
  /// Some layout effects require blockification or inlinification of the box type
  /// https://www.w3.org/TR/css-display-3/#transformations
  CSSDisplay? transformedDisplay;

  void updateDisplay(String value, Element element) {
    CSSDisplay? originalDisplay = display;
    CSSDisplay presentDisplay = getDisplay(value);
    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      element.detach();
      return;
    }
    display = presentDisplay;
    transformedDisplay = getTransformedDisplay();
    if (originalDisplay != presentDisplay && renderBoxModel is RenderLayoutBox) {
      RenderLayoutBox? prevRenderLayoutBox = renderBoxModel as RenderLayoutBox?;
      element.renderBoxModel = element.createRenderLayout(
        prevRenderLayoutBox: prevRenderLayoutBox,
        repaintSelf: element.repaintSelf
      );
      bool shouldReattach = element.isRendererAttached && element.parent != null && prevRenderLayoutBox != renderBoxModel;

      if (shouldReattach) {
        RenderLayoutBox parentRenderObject = element.parentElement!.renderBoxModel as RenderLayoutBox;
        Element? previousSibling = element.previousSibling as Element?;
        RenderObject? previous = previousSibling?.renderer;

        parentRenderObject.remove(prevRenderLayoutBox!);
        parentRenderObject.insert(renderBoxModel!, after: previous as RenderBox?);
      } else {
        renderBoxModel!.markNeedsLayout();
      }
    }
  }

  void updateTransformedDisplay() {
    transformedDisplay = getTransformedDisplay();
  }

  /// Set transformedDisplay when display is not set in style
  void initDisplay() {
    if (style[DISPLAY].isEmpty) {
      transformedDisplay = getTransformedDisplay();
    }
  }

  static CSSDisplay getDisplay(String? displayString) {
    switch (displayString) {
      case 'none':
        return CSSDisplay.none;
      case 'sliver':
        return CSSDisplay.sliver;
      case 'block':
        return CSSDisplay.block;
      case 'inline-block':
        return CSSDisplay.inlineBlock;
      case 'flex':
        return CSSDisplay.flex;
      case 'inline-flex':
        return CSSDisplay.inlineFlex;
      case 'inline':
      default:
        return CSSDisplay.inline;
    }
  }

  /// Element tree hierarchy can cause element display behavior to change,
  /// for example element which is flex-item can display like inline-block or block
  /// https://www.w3.org/TR/css-display-3/#transformations
  CSSDisplay? getTransformedDisplay() {
    RenderStyle renderStyle = this as RenderStyle;
    CSSDisplay? display = renderStyle.display;

    CSSPositionType position = renderStyle.position;

    // Display as inline-block when element is positioned
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      display = CSSDisplay.inlineBlock;
    } else if (renderBoxModel!.parent is! RenderBoxModel) {
      return renderStyle.display;
    } else if (renderBoxModel!.parent is RenderFlexLayout) {
      // Display as inline-block if parent node is flex
      display = CSSDisplay.inlineBlock;
      RenderBoxModel parent = renderBoxModel!.parent as RenderBoxModel;
      RenderStyle parentRenderStyle = parent.renderStyle;

      CSSMargin marginLeft = renderStyle.marginLeft;
      CSSMargin marginRight = renderStyle.marginRight;

      bool isVerticalDirection = parentRenderStyle.flexDirection == FlexDirection.column ||
        parentRenderStyle.flexDirection == FlexDirection.columnReverse;
      // Flex item will not stretch in stretch alignment when flex wrap is set to wrap or wrap-reverse
      bool isFlexNoWrap = parentRenderStyle.flexWrap == FlexWrap.nowrap;
      bool isAlignItemsStretch = parentRenderStyle.alignItems == AlignItems.stretch;

      // Display as block if flex vertical layout children and stretch children
      if (!marginLeft.isAuto! && !marginRight.isAuto! && isVerticalDirection && isFlexNoWrap && isAlignItemsStretch) {
        display = CSSDisplay.block;
      }
    }

    return display;
  }
}
