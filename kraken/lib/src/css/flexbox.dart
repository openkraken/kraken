/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Flexible Box Layout: https://drafts.csswg.org/css-flexbox-1/

class _FlexShortHand {
  String flexGrow;
  String flexShrink;
  String flexBasis;

  _FlexShortHand(String flex) {
    assert(flex != null);

    List<String> group = flex.split(' ');
    if (group.length == 0) return;

    if (group.length == 1) {
      flexGrow = group[0];
    } else if (group.length == 2) {
      flexGrow = group[0];

      if (CSSLength.isValidateLength(group[1])) {
        flexBasis = group[1];
      } else {
        flexShrink = group[1];
      }
    } else {
      flexGrow = group[0];
      flexShrink = group[1];
      flexBasis = group[2];
    }
  }

  @override
  String toString() {
    return "flexShotHand(flexGrow: $flexGrow, flexShrink: $flexShrink, flexBasis: $flexBasis)";
  }
}

mixin CSSFlexboxMixin {
  void decorateRenderFlex(RenderFlexLayout renderFlexLayout, CSSStyleDeclaration style) {
    if (style != null) {
      String flexDirection = style[FLEX_DIRECTION];
      String justifyContent = style[JUSTIFY_CONTENT];
      String alignItems = style[ALIGN_ITEMS];
      String flexWrap = style[FLEX_WRAP];

      renderFlexLayout.flexDirection = _getFlexDirection(flexDirection);
      renderFlexLayout.flexWrap = _getFlexWrap(flexWrap);
      renderFlexLayout.justifyContent = _getJustifyContent(justifyContent, style, renderFlexLayout.flexDirection);
      renderFlexLayout.alignItems = _getAlignItems(alignItems, style, renderFlexLayout.flexDirection);
      renderFlexLayout.runAlignment = _getAlignContent(style);
    }
  }

  FlexDirection _getFlexDirection(String flexDirection) {
    switch (flexDirection) {
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
    switch (flexWrap) {
      case 'nowrap':
        return FlexWrap.nowrap;
      case 'wrap':
        return FlexWrap.wrap;
      case 'wrap-reverse':
        return FlexWrap.wrapReverse;
    }
    return FlexWrap.nowrap;
  }

  JustifyContent _getJustifyContent(String justifyContent, CSSStyleDeclaration style, FlexDirection flexDirection) {
    if (isHorizontalFlexDirection(flexDirection) && style.contains(TEXT_ALIGN)) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          return JustifyContent.end;
          break;
        case 'center':
          return JustifyContent.center;
          break;
      }
    }

    switch (justifyContent) {
      case 'normal':
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
      case 'space-between':
        return JustifyContent.spaceBetween;
      case 'space-around':
        return JustifyContent.spaceAround;
      case 'space-evenly':
        return JustifyContent.spaceEvenly;
    }
    return JustifyContent.start;
  }

  AlignItems _getAlignItems(String alignItems, CSSStyleDeclaration style, FlexDirection flexDirection) {
    if (isVerticalFlexDirection(flexDirection) && style.contains(TEXT_ALIGN)) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          return AlignItems.end;
          break;
        case 'center':
          return AlignItems.center;
          break;
      }
    }

    switch (alignItems) {
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
      case 'normal':
      case 'stretch':
        return AlignItems.stretch;
      case 'baseline':
        return AlignItems.baseline;
    }

    return AlignItems.stretch;
  }

  MainAxisAlignment _getAlignContent(CSSStyleDeclaration style) {
    String flexProperty = style[ALIGN_CONTENT];
    MainAxisAlignment runAlignment = MainAxisAlignment.start;
    switch (flexProperty) {
      case 'flex-end':
      case 'end':
        runAlignment = MainAxisAlignment.end;
        break;
      case 'center':
        runAlignment = MainAxisAlignment.center;
        break;
      case 'space-around':
        runAlignment = MainAxisAlignment.spaceAround;
        break;
      case 'space-between':
        runAlignment = MainAxisAlignment.spaceBetween;
        break;
      case 'space-evenly':
        runAlignment = MainAxisAlignment.spaceEvenly;
        break;
    }
    return runAlignment;
  }
}

class CSSFlexItem {
  static const String GROW = 'flexGrow';
  static const String SHRINK = 'flexShrink';
  static const String BASIS = 'flexBasis';
  static const String ALIGN_ITEMS = 'alignItems';
  static const String FLEX = 'flex';

  static RenderFlexParentData getParentData(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();
    String flexShotHand = style[FLEX];
    String grow = style[GROW] ?? '';
    String shrink = style[SHRINK] ?? '';
    String basis = style[BASIS] ?? '';

    if (flexShotHand != null) {
      _FlexShortHand _flexShortHand = _FlexShortHand(flexShotHand);
      grow = grow.isEmpty ? _flexShortHand.flexGrow : grow;
      shrink = shrink.isEmpty ? _flexShortHand.flexShrink : shrink;
      basis = basis.isEmpty ? _flexShortHand.flexBasis : basis;
    }

    parentData.flexGrow = CSSStyleDeclaration.isNullOrEmptyValue(grow)
        ? 0 // Grow default to 0.
        : CSSLength.toInt(grow);
    parentData.flexShrink = CSSStyleDeclaration.isNullOrEmptyValue(shrink)
        ? 1 // Shrink default to 1.
        : CSSLength.toInt(shrink);
    parentData.flexBasis = CSSStyleDeclaration.isNullOrEmptyValue(basis)
        ? 'auto' // flexBasis default to auto.
        : basis;

    return parentData;
  }
}
