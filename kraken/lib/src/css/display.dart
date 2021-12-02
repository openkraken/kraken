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

  sliver,

  none
}

mixin CSSDisplayMixin on RenderStyle {

  CSSDisplay? _display;

  @override
  CSSDisplay get display => _display ?? CSSDisplay.inline;
  set display(CSSDisplay value) {
    if (_display != value) {
      _display = value;

      renderBoxModel?.markNeedsLayout();
    }
  }

  void initDisplay() {
    // Must take from style because it inited before flush pending properties.
    _display ??= resolveDisplay(target.style[DISPLAY]);
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

  /// Some layout effects require blockification or inlinification of the box type
  /// https://www.w3.org/TR/css-display-3/#transformations
  @override
  CSSDisplay get effectiveDisplay {
    CSSDisplay transformedDisplay = display;

    // Must take `position` from style because it inited before flush pending properties.
    // Display as inline-block when element is positioned
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      return CSSDisplay.inlineBlock;
    }

    if (renderBoxModel != null) {
      if (renderBoxModel!.parent is! RenderBoxModel) {
        return transformedDisplay;
      } else if (renderBoxModel!.parent is RenderFlexLayout) {
        // Margin change in flex layout may affect transformed display
        // https://www.w3.org/TR/css-display-3/#transformations

        // Display as inline-block if parent node is flex
        transformedDisplay = CSSDisplay.inlineBlock;
        RenderBoxModel parent = renderBoxModel!.parent as RenderBoxModel;
        RenderStyle parentRenderStyle = parent.renderStyle;

        bool isVerticalDirection = parentRenderStyle.flexDirection == FlexDirection.column ||
            parentRenderStyle.flexDirection == FlexDirection.columnReverse;
        // Flex item will not stretch in stretch alignment when flex wrap is set to wrap or wrap-reverse
        bool isFlexNoWrap = parentRenderStyle.flexWrap == FlexWrap.nowrap;
        bool isAlignItemsStretch = parentRenderStyle.effectiveAlignItems == AlignItems.stretch;

        // Display as block if flex vertical layout children and stretch children
        if (!marginLeft.isAuto && !marginRight.isAuto && isVerticalDirection && isFlexNoWrap && isAlignItemsStretch) {
          transformedDisplay = CSSDisplay.block;
        }
      }
    }


    return transformedDisplay;
  }
}
