/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'style.dart';

class FlexMixin {
  static const String DIRECTION = 'flexDirection';
  static const String WRAP = 'flexWrap';
  static const String FLOW = 'flexFlow';
  static const String JUSTIFY_CONTENT = 'justifyContent';
  static const String TEXT_ALIGN = 'textAlign';
  static const String ALIGN_ITEMS = 'alignItems';
  static const String ALIGN_CONTENT = 'alignContent';

  void decorateRenderFlex(RenderFlexLayout renderObject, Style style) {
    if (style != null) {
      Axis axis;
      TextDirection textDirection;
      VerticalDirection verticalDirection;
      String direction = style[DIRECTION];
      switch (direction) {
        case 'row':
          axis = Axis.horizontal;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
        case 'row-reverse':
          axis = Axis.horizontal;
          verticalDirection = VerticalDirection.down;
          textDirection = TextDirection.rtl;
          break;
        case 'column':
          axis = Axis.vertical;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
        case 'column-reverse':
          axis = Axis.vertical;
          verticalDirection = VerticalDirection.up;
          textDirection = TextDirection.ltr;
          break;
        default:
          axis = Axis.horizontal;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
      }
      renderObject.verticalDirection = verticalDirection;
      renderObject.direction = axis;
      renderObject.textDirection = textDirection;
      renderObject.mainAxisAlignment = _getJustifyContent(style, axis);
      renderObject.crossAxisAlignment = _getAlignItems(style, axis);
    }
  }

  MainAxisAlignment _getJustifyContent(Style style, Axis axis) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;

    if (style.contains(TEXT_ALIGN) && axis == Axis.horizontal) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          mainAxisAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          mainAxisAlignment = MainAxisAlignment.center;
          break;
      }
    }

    if (style.contains(JUSTIFY_CONTENT)) {
      String justifyContent = style[JUSTIFY_CONTENT];
      switch (justifyContent) {
        case 'flex-end':
          mainAxisAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          mainAxisAlignment = MainAxisAlignment.center;
          break;
        case 'space-between':
          mainAxisAlignment = MainAxisAlignment.spaceBetween;
          break;
        case 'space-around':
          mainAxisAlignment = MainAxisAlignment.spaceAround;
          break;
      }
    }
    return mainAxisAlignment;
  }

  CrossAxisAlignment _getAlignItems(Style style, Axis axis) {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch;
    if (style.contains(TEXT_ALIGN) && axis == Axis.vertical) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          crossAxisAlignment = CrossAxisAlignment.end;
          break;
        case 'center':
          crossAxisAlignment = CrossAxisAlignment.center;
          break;
      }
    }
    if (style.contains(ALIGN_ITEMS)) {
      String justifyContent = style[ALIGN_ITEMS];
      switch (justifyContent) {
        case 'flex-start':
          crossAxisAlignment = CrossAxisAlignment.start;
          break;
        case 'center':
          crossAxisAlignment = CrossAxisAlignment.center;
          break;
        case 'baseline':
          crossAxisAlignment = CrossAxisAlignment.baseline;
          break;
        case 'flex-end':
          crossAxisAlignment = CrossAxisAlignment.end;
          break;
      }
    }
    return crossAxisAlignment;
  }
}

class FlexItem {
  static const String GROW = 'flexGrow';
  static const String ALIGN_ITEMS = 'alignItems';

  static FlexParentData getParentData(Style style) {
    FlexParentData parentData = FlexParentData();
    parentData.flex = 1;
    parentData.fit = FlexFit.loose;

    if (style != null) {
      dynamic grow = style[GROW];
      if (grow != null && grow is num) {
        parentData.fit = FlexFit.loose;
        parentData.flex = grow.toInt();
      }
    }
    return parentData;
  }
}
