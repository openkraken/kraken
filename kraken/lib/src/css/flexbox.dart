/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

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

mixin CSSFlexboxMixin on RenderStyle {

  @override
  FlexDirection get flexDirection => _flexDirection ?? FlexDirection.row;
  FlexDirection? _flexDirection;
  set flexDirection(FlexDirection? value) {
    if (value == _flexDirection) return;
    _flexDirection = value;
    if (renderBoxModel is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  FlexWrap get flexWrap => _flexWrap ?? FlexWrap.nowrap;
  FlexWrap? _flexWrap;
  set flexWrap(FlexWrap? value) {
    if (_flexWrap == value) return;
    _flexWrap = value;
    if (renderBoxModel is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  JustifyContent get justifyContent => _justifyContent ?? JustifyContent.flexStart;
  JustifyContent? _justifyContent;
  set justifyContent(JustifyContent? value) {
    if (_justifyContent == value) return;
    _justifyContent = value;
    if (renderBoxModel is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }


  @override
  AlignItems get alignItems => _alignItems ?? AlignItems.stretch;
  AlignItems? _alignItems;
  set alignItems(AlignItems? value) {
    if (_alignItems == value) return;
    _alignItems = value;
    if (renderBoxModel is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  AlignItems get effectiveAlignItems {
    if (CSSFlex.isVerticalFlexDirection(flexDirection)) {
      if (textAlign == TextAlign.right) {
        return AlignItems.flexEnd;
      } else if (textAlign == TextAlign.center) {
        return AlignItems.center;
      }
    }
    return alignItems;
  }

  @override
  AlignContent get alignContent => _alignContent ?? AlignContent.stretch;
  AlignContent? _alignContent;
  set alignContent(AlignContent? value) {
    if (_alignContent == value) return;
    _alignContent = value;
    if (renderBoxModel is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  AlignSelf get alignSelf => _alignSelf ?? AlignSelf.auto;
  AlignSelf? _alignSelf;
  set alignSelf(AlignSelf value) {
    if (_alignSelf == value) return;
    _alignSelf = value;
    if (renderBoxModel?.parent is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  CSSLengthValue? get flexBasis => _flexBasis;
  CSSLengthValue? _flexBasis;
  set flexBasis(CSSLengthValue? value) {
    // Negative value is invalid.
    if ((value != null && ((value.value != null && value.value! < 0))) ||
      _flexBasis == value
    ) {
      return;
    }
    _flexBasis = value;
    if (renderBoxModel?.parent is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  double get flexGrow => _flexGrow ?? 0.0;
  double? _flexGrow;
  set flexGrow(double? value) {
    if (_flexGrow == value) return;
    _flexGrow = value;
    if (renderBoxModel?.parent is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  @override
  double get flexShrink => _flexShrink ?? 1.0;
  double? _flexShrink;
  set flexShrink(double? value) {
    if (_flexShrink == value) return;
    _flexShrink = value;
    if (renderBoxModel?.parent is RenderFlexLayout) {
      renderBoxModel!.markNeedsLayout();
    }
  }

  static FlexDirection resolveFlexDirection(String flexDirection) {
    switch (flexDirection) {
      case 'row-reverse':
        return FlexDirection.rowReverse;
      case 'column':
        return FlexDirection.column;
      case 'column-reverse':
        return FlexDirection.columnReverse;
      case 'row':
      default:
        return FlexDirection.row;
    }
  }

  static FlexWrap resolveFlexWrap(String flexWrap) {
    switch (flexWrap) {
      case 'wrap':
        return FlexWrap.wrap;
      case 'wrap-reverse':
        return FlexWrap.wrapReverse;
      case 'nowrap':
      default:
        return FlexWrap.nowrap;
    }
  }

  static JustifyContent resolveJustifyContent(String justifyContent) {
    switch (justifyContent) {
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
      case 'flex-start':
      case 'start':
      default:
        return JustifyContent.flexStart;
    }
  }

  static AlignItems resolveAlignItems(String alignItems) {
    switch (alignItems) {
      case 'flex-start':
      case 'start':
        return AlignItems.flexStart;
      case 'flex-end':
      case 'end':
        return AlignItems.flexEnd;
      case 'center':
        return AlignItems.center;
      case 'baseline':
        return AlignItems.baseline;
      case 'stretch':
      default:
        return AlignItems.stretch;
    }
  }

  static AlignContent resolveAlignContent(String alignContent) {
    switch (alignContent) {
      case 'flex-start':
      case 'start':
        return AlignContent.flexStart;
      case 'flex-end':
      case 'end':
        return AlignContent.flexEnd;
      case 'center':
        return AlignContent.center;
      case 'space-around':
        return AlignContent.spaceAround;
      case 'space-between':
        return AlignContent.spaceBetween;
      case 'space-evenly':
        return AlignContent.spaceEvenly;
      case 'stretch':
      default:
        return AlignContent.stretch;
    }
  }

  static AlignSelf resolveAlignSelf(String alignSelf) {
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
      default:
        return AlignSelf.auto;
    }
  }

  static double resolveFlexGrow(String grow) {
    double? flexGrow = CSSLength.toDouble(grow);
    return flexGrow != null && flexGrow >= 0 ? flexGrow : 0.0;
  }

  static double resolveFlexShrink(String shrink) {
    double? flexShrink = CSSLength.toDouble(shrink);
    return flexShrink != null && flexShrink >= 0 ? flexShrink : 1.0;
  }
}


class CSSFlex {
  static bool isValidFlexWrapValue(String val) {
    return val == 'wrap' || val == 'nowrap' || val == 'wrap-reverse';
  }

  static bool isValidFlexDirectionValue(String val) {
    return val == 'row' || val == 'row-reverse' || val == 'column' || val == 'column-reverse';
  }

  static bool isHorizontalFlexDirection(FlexDirection flexDirection) {
    return flexDirection == FlexDirection.row || flexDirection == FlexDirection.rowReverse;
  }

  static bool isVerticalFlexDirection(FlexDirection flexDirection) {
    return flexDirection == FlexDirection.columnReverse || flexDirection == FlexDirection.column;
  }
}
