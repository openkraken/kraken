

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
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
  CSSDisplay _previousDisplay = CSSDisplay.inline;
  CSSDisplay get previousDisplay => _previousDisplay;

  CSSDisplay _display = CSSDisplay.inline;
  CSSDisplay get display => _display;
  set display(CSSDisplay value) {
    if (_display != value) {
      _previousDisplay = _display;
      _display = value;
      updateTransformedDisplay();
      renderBoxModel?.markNeedsLayout();
    }
  }
  /// Some layout effects require blockification or inlinification of the box type
  /// https://www.w3.org/TR/css-display-3/#transformations
  CSSDisplay? transformedDisplay;

  void updateTransformedDisplay() {
    transformedDisplay = _getTransformedDisplay();
  }

  void initDisplay() {
    // Must take from style because it inited before flush pending properties.
    _previousDisplay = _display = resolveDisplay(style[DISPLAY]);
    updateTransformedDisplay();
  }

  static CSSDisplay resolveDisplay(String? displayString) {
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
  CSSDisplay? _getTransformedDisplay() {
    RenderStyle renderStyle = this as RenderStyle;
    CSSDisplay? transformedDisplay = renderStyle.display;

    // Must take from style because it inited before flush pending properties.
    CSSPositionType position = CSSPositionMixin.parsePositionType(style[POSITION]);

    // Display as inline-block when element is positioned
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      return CSSDisplay.inlineBlock;
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
