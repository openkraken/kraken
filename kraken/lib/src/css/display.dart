

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

  CSSDisplay _display = CSSDisplay.inline;
  CSSDisplay get display => _display;
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

    display = presentDisplay;
    transformedDisplay = getTransformedDisplay();

    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      element.detach();
      return;
    }

    if (originalDisplay == presentDisplay) return;

    // When renderer and style listener is not created when original display is none,
    // thus it needs to create renderer when style changed.
    if (originalDisplay == CSSDisplay.none) {
      RenderBox? after;
      Element parent = element.parent as Element;
      if (parent.scrollingContentLayoutBox != null) {
        after = parent.scrollingContentLayoutBox!.lastChild;
      } else {
        after = (parent.renderBoxModel as RenderLayoutBox).lastChild;
      }
      // Update renderBoxModel and attach it to parent.
      element.updateRenderBoxModel();
      parent.addChildRenderObject(element, after: after);
      // FIXME: avoid ensure something in display updating.
      element.ensureChildAttached();
    }
    
    if (renderBoxModel is RenderLayoutBox) {
      RenderLayoutBox? prevRenderLayoutBox = renderBoxModel as RenderLayoutBox?;
      if (originalDisplay != CSSDisplay.none) {
        // Don't updateRenderBoxModel twice.
        element.updateRenderBoxModel();
      }

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
    // Must take from style because it inited before flush pending properties.
    _display = getDisplay(style[DISPLAY]);
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
    CSSDisplay? transformedDisplay = renderStyle.display;

    // Must take from style because it inited before flush pending properties.
    CSSPositionType position = CSSPositionMixin.parsePositionType(style[POSITION]);

    // Display as inline-block when element is positioned
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      transformedDisplay = CSSDisplay.inlineBlock;
    }

    if (renderBoxModel != null) {
      if (renderBoxModel!.parent is! RenderBoxModel) {
        return transformedDisplay;
      } else if (renderBoxModel!.parent is RenderFlexLayout) {
        // Display as inline-block if parent node is flex
        transformedDisplay = CSSDisplay.inlineBlock;
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
          transformedDisplay = CSSDisplay.block;
        }
      }
    }


    return transformedDisplay;
  }
}
