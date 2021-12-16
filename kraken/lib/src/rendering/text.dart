/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

class TextParentData extends ContainerBoxParentData<RenderBox> {}

enum WhiteSpace { normal, nowrap, pre, preWrap, preLine, breakSpaces }

class RenderTextBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(
    this.data, {
    required this.renderStyle,
  }) {
    TextSpan text = CSSTextMixin.createTextSpan(data, renderStyle);
    _renderParagraph = child = KrakenRenderParagraph(
      text,
      textDirection: TextDirection.ltr,
    );
  }

  late String data;
  late KrakenRenderParagraph _renderParagraph;
  CSSRenderStyle renderStyle;

  BoxSizeType? widthSizeType;
  BoxSizeType? heightSizeType;

  // Auto value for min-width
  double autoMinWidth = 0;

  // Auto value for min-height
  double autoMinHeight = 0;

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  WhiteSpace? get whiteSpace {
    return renderStyle.whiteSpace;
  }

  TextOverflow get overflow {
    // Set line-clamp to number makes text-overflow ellipsis which takes priority over text-overflow
    if (renderStyle.lineClamp != null && renderStyle.lineClamp! > 0) {
      return TextOverflow.ellipsis;
    } else if (renderStyle.effectiveOverflowX != CSSOverflowType.hidden || renderStyle.whiteSpace != WhiteSpace.nowrap) {
      //  To make text overflow its container you have to set overflowX hidden and white-space: nowrap.
      return TextOverflow.visible;
    } else {
      return renderStyle.textOverflow;
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    needsLayout = true;
  }

  // @HACK: sync _needsLayout flag in Flutter to do performance opt.
  void syncNeedsLayoutFlag() {
    needsLayout = true;
  }

  BoxConstraints getConstraints() {
    if (whiteSpace == WhiteSpace.nowrap &&
        overflow != TextOverflow.ellipsis) {
      return BoxConstraints();
    }
    double maxConstraintWidth = double.infinity;
    if (parent is RenderBoxModel) {
      RenderBoxModel parentRenderBoxModel = parent as RenderBoxModel;
      BoxConstraints parentConstraints = parentRenderBoxModel.constraints;

      if (parentRenderBoxModel.isScrollingContentBox) {
        maxConstraintWidth = parentConstraints.minWidth;
      } else if (parentConstraints.maxWidth == double.infinity) {
        final RenderLayoutParentData parentParentData = parentRenderBoxModel.parentData as RenderLayoutParentData;
        // Width of positioned element does not constrained by parent.
        if (parentParentData.isPositioned) {
          maxConstraintWidth = double.infinity;
        } else {
          maxConstraintWidth = parentRenderBoxModel.renderStyle.contentMaxConstraintsWidth;
          // @FIXME: Each character in the text will be placed in a new line when remaining space of
          // parent is 0 cause word-break behavior can not be specified in flutter.
          // https://github.com/flutter/flutter/issues/61081
          // This behavior is not desirable compared to the default word-break:break-word value in the browser.
          // So we choose to not do wrapping for text in this case.
          if (maxConstraintWidth == 0) {
            maxConstraintWidth = double.infinity;
          }
        }
      } else {
        EdgeInsets borderEdge = parentRenderBoxModel.renderStyle.border;
        EdgeInsetsGeometry? padding = parentRenderBoxModel.renderStyle.padding;
        double horizontalBorderLength = borderEdge.horizontal;
        double horizontalPaddingLength = padding.horizontal;

        maxConstraintWidth = parentConstraints.maxWidth - horizontalPaddingLength - horizontalBorderLength;
      }
    }

    // Text will not overflow from container, so it can inherit
    // constraints from parents
    return BoxConstraints(
        minWidth: 0,
        maxWidth: maxConstraintWidth,
        minHeight: 0,
        maxHeight: double.infinity);
  }

  @override
  void performLayout() {
    if (child != null) {
      // FIXME(yuanyan): do not create text span every time.
      _renderParagraph.text = CSSTextMixin.createTextSpan(data, renderStyle);
      _renderParagraph.overflow = overflow;
      // Forcing a break after a set number of lines
      // https://drafts.csswg.org/css-overflow-3/#max-lines
      _renderParagraph.maxLines = renderStyle.lineClamp;
      _renderParagraph.textAlign = renderStyle.textAlign;
      if (renderStyle.lineHeight.type != CSSLengthType.NORMAL) {
        _renderParagraph.lineHeight = renderStyle.lineHeight.computedValue;
      }

      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;

      // @FIXME: Minimum size of text equals to single word in browser
      // which cannot be calculated in Flutter currently.

      // Set minimum width to 0 to allow flex item containing text to shrink into
      // flex container which is similar to the effect of word-break: break-all in the browser.
      autoMinWidth = 0;
      autoMinHeight = size.height;
    } else {
      performResize();
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  double computeDistanceToBaseline() {
    return parent is RenderFlowLayout
        ? _renderParagraph.computeDistanceToLastLineBaseline()
        : _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToFirstLineBaseline() {
    return _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToLastLineBaseline() {
    return _renderParagraph.computeDistanceToLastLineBaseline();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  // Text node need hittest self to trigger scroll
  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return hasSize && size.contains(position!);
  }
}
