/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

class RenderFlexParentData extends RenderLayoutParentData {
  /// Flex grow
  int flexGrow;

  /// Flex shrink
  int flexShrink;

  /// Flex basis
  String flexBasis;

  /// How a flexible child is inscribed into the available space.
  ///
  /// If [flex] is non-zero, the [fit] determines whether the child fills the
  /// space the parent makes available during layout. If the fit is
  /// [FlexFit.tight], the child is required to fill the available space. If the
  /// fit is [FlexFit.loose], the child can be at most as large as the available
  /// space (but is allowed to be smaller).
  FlexFit fit;

  @override
  String toString() => '${super.toString()}; flexGrow=$flexGrow; flexShrink=$flexShrink; flexBasis=$flexBasis, fit=$fit';
}

mixin FlexMixin {
  static const String DIRECTION = 'flexDirection';
  static const String WRAP = 'flexWrap';
  static const String FLOW = 'flexFlow';
  static const String JUSTIFY_CONTENT = 'justifyContent';
  static const String TEXT_ALIGN = 'textAlign';
  static const String ALIGN_ITEMS = 'alignItems';
  static const String ALIGN_CONTENT = 'alignContent';

  void decorateRenderFlex(ContainerRenderObjectMixin renderObject, StyleDeclaration style) {
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

      if (renderObject is RenderFlowLayout) {
        renderObject.verticalDirection = verticalDirection;
        renderObject.direction = axis;
        renderObject.textDirection = textDirection;
        renderObject.mainAxisAlignment = _getJustifyContent(style, axis);
        renderObject.crossAxisAlignment = _getAlignItems(style, axis);
      } else if (renderObject is RenderFlexLayout) {
        renderObject.verticalDirection = verticalDirection;
        renderObject.direction = axis;
        renderObject.textDirection = textDirection;
        renderObject.mainAxisAlignment = _getJustifyContent(style, axis);
        renderObject.crossAxisAlignment = _getAlignItems(style, axis);
      }
    }
  }

  MainAxisAlignment _getJustifyContent(StyleDeclaration style, Axis axis) {
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

  CrossAxisAlignment _getAlignItems(StyleDeclaration style, Axis axis) {
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
  static const String SHRINK = 'flexShrink';
  static const String BASIS = 'flexBasis';
  static const String ALIGN_ITEMS = 'alignItems';

  static RenderFlexParentData getParentData(StyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();
    parentData.flexGrow = 0;
    parentData.flexShrink = 1;
    parentData.flexBasis = 'auto';
    parentData.fit = FlexFit.loose;

    if (style != null) {
      parentData.fit = FlexFit.tight;

      String grow = style[GROW];
      if (grow != '') {
        parentData.flexGrow = Length.toInt(grow);
      }

      String shrink = style[SHRINK];
      if (shrink != '') {
        parentData.flexShrink = Length.toInt(shrink);
      }

      String basis = style[BASIS];
      if (basis != '') {
        parentData.flexBasis = basis;
      }
    }
    return parentData;
  }
}
