/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Flexible Box Layout: https://drafts.csswg.org/css-flexbox-1/

/// sets whether flex items are forced onto one line or can wrap onto multiple lines.
/// If wrapping is allowed, it sets the direction that lines are stacked.
enum FlexWrap {
  /// The flex items are laid out in a single line which may cause the flex container to overflow.
  /// The cross-start is either equivalent to start or before depending flex-direction value.
  /// This is the default value.
  nowrap,

  /// The flex items break into multiple lines.
  /// The cross-start is either equivalent to start or before depending flex-direction value and the cross-end is the opposite of the specified cross-start.
  wrap,

  /// Behaves the same as wrap but cross-start and cross-end are permuted.
  wrapReverse
}

/// sets how flex items are placed in the flex container defining the main axis and the direction (normal or reversed).
enum FlexDirection {
  /// The flex container's main-axis is defined to be the same as the text direction.
  /// The main-start and main-end points are the same as the content direction.
  row,

  /// Behaves the same as row but the main-start and main-end points are permuted.
  rowReverse,

  /// The flex container's main-axis is the same as the block-axis.
  /// The main-start and main-end points are the same as the before and after points of the writing-mode.
  column,

  /// Behaves the same as column but the main-start and main-end are permuted.
  columnReverse
}

/// Defines how the browser distributes space between and around content items along the main-axis of a flex container,
/// and the inline axis of a grid container.
enum JustifyContent {
  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the main axis.
  start,

  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the main axis.
  end,

  /// The items are packed flush to each other toward the center of the alignment container along the main axis.
  center,

  /// The items are evenly distributed within the alignment container along the main axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the main-start edge, and the last item is flush with the main-end edge.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items, the start edge and the first item,
  /// and the end edge and the last item, are all exactly the same.
  spaceEvenly,
}

/// Sets the distribution of space between and around content items along a flexbox's cross-axis.
enum AlignContent {
  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other against the start edge of the alignment container in the cross axis.
  start,

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other against the end edge of the alignment container in the cross axis.
  end,

  /// The items are packed flush to each other in the center of the alignment container along the cross axis.
  center,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the start edge of the alignment container in the cross axis, and the last item is flush with the end edge of the alignment container in the cross axis.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items, the start edge and the first item,
  /// and the end edge and the last item, are all exactly the same.
  spaceEvenly,

  /// If the combined size of the items along the cross axis is less than the size of the alignment container,
  /// any auto-sized items have their size increased equally (not proportionally),
  /// while still respecting the constraints imposed by max-height/max-width (or equivalent functionality),
  /// so that the combined size exactly fills the alignment container along the cross axis.
  stretch
}

/// Set the space distributed between and around content items along the cross-axis of their container.
enum AlignItems {
  /// The cross-start margin edges of the flex items are flushed with the cross-start edge of the line.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start,

  /// The cross-end margin edges of the flex items are flushed with the cross-end edge of the line.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end,

  /// The flex items' margin boxes are centered within the line on the cross-axis.
  /// If the cross-size of an item is larger than the flex container, it will overflow equally in both directions.
  center,

  /// Flex items are stretched such that the cross-size of the item's margin box is the same as the line while respecting width and height constraints.
  stretch,

  /// All flex items are aligned such that their flex container baselines align.
  /// The item with the largest distance between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline
}

/// Overrides a flex item's align-items value
enum AlignSelf {
  /// Computes to the parent's align-items value.
  auto,

  /// The cross-start margin edges of the flex items are flushed with the cross-start edge of the line.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start,

  /// The cross-end margin edges of the flex items are flushed with the cross-end edge of the line.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end,

  /// The flex items' margin boxes are centered within the line on the cross-axis.
  /// If the cross-size of an item is larger than the flex container, it will overflow equally in both directions.
  center,

  /// Flex items are stretched such that the cross-size of the item's margin box is the same as the line while respecting width and height constraints.
  stretch,

  /// All flex items are aligned such that their flex container baselines align.
  /// The item with the largest distance between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline
}

class _FlexShortHand {
  String flexGrow;
  String flexShrink;
  String flexBasis;

  _FlexShortHand(String flex) {
    assert(flex != null);

    List<String> group = flex.split(' ');
    if (group.length == 0) return;

    if (group.length == 1) {
      String flexValue = group[0];
      if (flexValue == 'initial') {
        flexGrow = '0';
        flexShrink = '1';
        flexBasis = 'auto';
      } else if (flexValue == 'auto') {
        flexGrow = '1';
        flexShrink = '1';
        flexBasis = 'auto';
      } else if (flexValue == 'none') {
        flexGrow = '0';
        flexShrink = '0';
        flexBasis = 'auto';
      } else {
        flexGrow = group[0];
      }
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

class _FlexFlowShortHand {
  String flexDirection;
  String flexWrap;

  _FlexFlowShortHand(String flexFlow) {
    assert(flexFlow != null);

    List<String> group = flexFlow.split(' ');
    if (group.length == 0) return;

    if (group.length == 1) {
      String firstValue = group[0];
      if (_isFlexDirection(firstValue)) {
        flexDirection = firstValue;
      } else if (_isFlexWrap(firstValue)) {
        flexWrap = firstValue;
      }
    } else if (group.length == 2) {
      String firstValue = group[0];
      String secondValue = group[1];
      if (_isFlexDirection(firstValue) && _isFlexWrap(secondValue)) {
        flexDirection = firstValue;
        flexWrap = secondValue;
      } else if (_isFlexWrap(firstValue) && _isFlexDirection(secondValue)) {
        flexWrap = firstValue;
        flexDirection = secondValue;
      }
    }
  }

  _isFlexWrap(String val) {
    if (val == 'wrap' ||
      val == 'nowrap' ||
      val == 'wrap-reverse'
    ) {
      return true;
    }
    return false;
  }

  _isFlexDirection(String val) {
    if (val == 'row' ||
      val == 'row-reverse' ||
      val == 'column' ||
      val == 'column-reverse'
    ) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "flexFlowShotHand(flexDirection: $flexDirection, flexWrap: $flexWrap)";
  }
}

mixin CSSFlexboxMixin {
  void decorateRenderFlex(RenderFlexLayout renderFlexLayout, CSSStyleDeclaration style) {
    if (style != null) {
      String flexDirection = style[FLEX_DIRECTION];
      String justifyContent = style[JUSTIFY_CONTENT];
      String alignItems = style[ALIGN_ITEMS];
      String flexWrap = style[FLEX_WRAP];
      String flexFlowShortHand = style[FLEX_FLOW];

      if (flexFlowShortHand != null) {
        _FlexFlowShortHand _flexFlowShortHand = _FlexFlowShortHand(flexFlowShortHand);
        flexDirection = flexDirection.isEmpty ? _flexFlowShortHand.flexDirection : flexDirection;
        flexWrap = flexWrap.isEmpty ? _flexFlowShortHand.flexWrap : flexWrap;
      }

      renderFlexLayout.flexDirection = _getFlexDirection(flexDirection);
      renderFlexLayout.flexWrap = _getFlexWrap(flexWrap);
      renderFlexLayout.justifyContent = _getJustifyContent(justifyContent, style, renderFlexLayout.flexDirection);
      renderFlexLayout.alignItems = _getAlignItems(alignItems, style, renderFlexLayout.flexDirection);
      renderFlexLayout.alignContent = _getAlignContent(style);
    }
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
        return JustifyContent.flexEnd;
        break;
      case 'center':
        return JustifyContent.center;
        break;
    }
  }

  switch (justifyContent) {
    case 'flex-start':
    case 'start':
      return JustifyContent.flexStart;
    case 'flex-end':
    case 'end':
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
  return JustifyContent.flexStart;
}

AlignItems _getAlignItems(String alignItems, CSSStyleDeclaration style, FlexDirection flexDirection) {
  if (isVerticalFlexDirection(flexDirection) && style.contains(TEXT_ALIGN)) {
    String textAlign = style[TEXT_ALIGN];
    switch (textAlign) {
      case 'right':
        return AlignItems.flexEnd;
        break;
      case 'center':
        return AlignItems.center;
        break;
    }
  }

  switch (alignItems) {
    case 'flex-start':
    case 'start':
      return AlignItems.flexStart;
    case 'flex-end':
    case 'end':
      return AlignItems.flexEnd;
    case 'center':
      return AlignItems.center;
    case 'stretch':
      return AlignItems.stretch;
    case 'baseline':
      return AlignItems.baseline;
  }

  return AlignItems.stretch;
}

AlignContent _getAlignContent(CSSStyleDeclaration style) {
  String flexProperty = style[ALIGN_CONTENT];
  AlignContent alignContent = AlignContent.stretch;
  switch (flexProperty) {
    case 'flex-start':
    case 'start':
      alignContent = AlignContent.flexStart;
      break;
    case 'flex-end':
    case 'end':
      alignContent = AlignContent.flexEnd;
      break;
    case 'center':
      alignContent = AlignContent.center;
      break;
    case 'space-around':
      alignContent = AlignContent.spaceAround;
      break;
    case 'space-between':
      alignContent = AlignContent.spaceBetween;
      break;
    case 'space-evenly':
      alignContent = AlignContent.spaceEvenly;
      break;
    case 'stretch':
      alignContent = AlignContent.stretch;
      break;
  }
  return alignContent;
}
AlignSelf _getAlignSelf(String alignSelf, CSSStyleDeclaration style) {
  switch (alignSelf) {
    case 'flex-start':
    case 'start':
      return AlignSelf.flexStart;
    case 'flex-end':
    case 'end':
      return AlignSelf.flexEnd;
    case 'center':
      return AlignSelf.center;
    case 'stretch':
      return AlignSelf.stretch;
    case 'baseline':
      return AlignSelf.baseline;
  }

  return AlignSelf.auto;
}

class CSSFlexItem {
  static const String GROW = 'flexGrow';
  static const String SHRINK = 'flexShrink';
  static const String BASIS = 'flexBasis';
  static const String ALIGN_SELF = 'alignSelf';
  static const String FLEX = 'flex';

  static RenderFlexParentData getParentData(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();
    String flexShotHand = style[FLEX];
    String grow = style[GROW] ?? '';
    String shrink = style[SHRINK] ?? '';
    String basis = style[BASIS] ?? '';
    String alignSelf = style[ALIGN_SELF] ?? '';

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
    parentData.alignSelf = CSSStyleDeclaration.isNullOrEmptyValue(alignSelf)
      ? AlignSelf.auto // alignSelf default to auto.
      : _getAlignSelf(alignSelf, style);

    return parentData;
  }

}
