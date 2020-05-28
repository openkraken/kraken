/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Flexible Box Layout: https://drafts.csswg.org/css-flexbox-1/

mixin CSSFlexboxMixin {
  void decorateRenderFlex(RenderFlexLayout renderFlexLayout, CSSStyleDeclaration style) {
    if (style != null) {
      String flexDirection = style[FLEX_DIRECTION];
      String justifyContent = style[JUSTIFY_CONTENT];
      String alignItems = style[ALIGN_ITEMS];
      String flexWrap = style[FLEX_WRAP];

      renderFlexLayout.flexDirection = _getFlexDirection(flexDirection);
      renderFlexLayout.flexWrap = _getFlexWrap(flexWrap);
      renderFlexLayout.justifyContent = _getJustifyContent(justifyContent);
      renderFlexLayout.alignItems = _getAlignItems(alignItems);
    }
  }

  FlexDirection _getFlexDirection(String flexDirection) {
    switch(flexDirection) {
      case 'row':
        return FlexDirection.row;
      case 'row-reverse':
        return FlexDirection.rowReverse;
      case 'column':
        return FlexDirection.column;
      case 'column-reverse':
        return FlexDirection.columnReverse;
    }
    return FlexDirection.row;
  }

  FlexWrap _getFlexWrap(String flexWrap) {
    switch(flexWrap) {
      case 'nowrap':
        return FlexWrap.nowrap;
      case 'wrap':
        return FlexWrap.wrap;
      case 'wrap-reverse':
        return FlexWrap.wrapReverse;
    }
    return FlexWrap.nowrap;
  }

  JustifyContent _getJustifyContent(String justifyContent) {
    switch(justifyContent) {
      case 'normal':
        return JustifyContent.normal;
      case 'start':
        return JustifyContent.start;
      case 'flex-start':
        return JustifyContent.flexStart;
      case 'end':
        return JustifyContent.end;
      case 'flex-end':
        return JustifyContent.flexEnd;
      case 'center':
        return JustifyContent.center;
      case 'stretch':
        return JustifyContent.stretch;
      case 'space-between':
        return JustifyContent.spaceBetween;
      case 'space-around':
        return JustifyContent.spaceAround;
      case 'space-evenly':
        return JustifyContent.spaceEvenly;
    }
    return JustifyContent.normal;
  }

  AlignItems _getAlignItems(String alignItems) {
    switch(alignItems) {
      case 'normal':
        return AlignItems.normal;
      case 'start':
        return AlignItems.start;
      case 'flex-start':
        return AlignItems.flexStart;
      case 'end':
        return AlignItems.end;
      case 'flex-end':
        return AlignItems.flexEnd;
      case 'center':
        return AlignItems.center;
      case 'stretch':
        return AlignItems.stretch;
    }

    return AlignItems.normal;
  }
}

class CSSFlexItem {
  static const String GROW = 'flexGrow';
  static const String SHRINK = 'flexShrink';
  static const String BASIS = 'flexBasis';
  static const String ALIGN_ITEMS = 'alignItems';

  static RenderFlexParentData getParentData(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();

    String grow = style[GROW];
    parentData.flexGrow = CSSStyleDeclaration.isNullOrEmptyValue(grow)
        ? 0 // Grow default to 0.
        : CSSLength.toInt(grow);

    String shrink = style[SHRINK];
    parentData.flexShrink = CSSStyleDeclaration.isNullOrEmptyValue(shrink)
        ? 1 // Shrink default to 1.
        : CSSLength.toInt(shrink);

    String basis = style[BASIS];
    parentData.flexBasis = CSSStyleDeclaration.isNullOrEmptyValue(basis)
        ? 'auto' // flexBasis default to auto.
        : basis;

    return parentData;
  }
}
