/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

final RegExp _whiteSpaceReg = RegExp(r'\s+');

class TextParentData extends ContainerBoxParentData<RenderBox> {}

enum WhiteSpace { normal, nowrap, pre, preWrap, preLine, breakSpaces }

class RenderTextBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(data, {
    required this.renderStyle,
  }) : _data = data {
    TextSpan text = CSSTextMixin.createTextSpan(_data, renderStyle);
    _renderParagraph = child = KrakenRenderParagraph(
      text,
      textDirection: TextDirection.ltr,
    );
  }

  String _data;

  set data(String value) {
    _data = value;
  }

  String get data => _data;

  bool isEndWithSpace(String str) {
    return str.endsWith(WHITE_SPACE_CHAR) || str.endsWith(NEW_LINE_CHAR) || str.endsWith(RETURN_CHAR) || str.endsWith(TAB_CHAR);
  }

  String get _trimmedData {
    if (parentData is RenderLayoutParentData) {
      /// https://drafts.csswg.org/css-text-3/#propdef-white-space
      /// The following table summarizes the behavior of the various white-space values:
      //
      //       New lines / Spaces and tabs / Text wrapping / End-of-line spaces
      // normal    Collapse  Collapse  Wrap     Remove
      // nowrap    Collapse  Collapse  No wrap  Remove
      // pre       Preserve  Preserve  No wrap  Preserve
      // pre-wrap  Preserve  Preserve  Wrap     Hang
      // pre-line  Preserve  Collapse  Wrap     Remove
      // break-spaces  Preserve  Preserve  Wrap  Wrap
      CSSRenderStyle parentRenderStyle = (parent as RenderLayoutBox).renderStyle;
      WhiteSpace whiteSpace = parentRenderStyle.whiteSpace;
      if (whiteSpace == WhiteSpace.pre ||
          whiteSpace == WhiteSpace.preLine ||
          whiteSpace == WhiteSpace.preWrap ||
          whiteSpace == WhiteSpace.breakSpaces) {
        return whiteSpace == WhiteSpace.preLine ? _collapseWhitespace(_data) : _data;
      } else {
        String collapsedData = _collapseWhitespace(_data);
        // TODO:
        // Remove the leading space while prev element have space too:
        //   <p><span>foo </span> bar</p>
        // Refs:
        //   https://github.com/WebKit/WebKit/blob/6a970b217d59f36e64606ed03f5238d572c23c48/Source/WebCore/layout/inlineformatting/InlineLineBuilder.cpp#L295
        RenderObject? previousSibling = (parentData as RenderLayoutParentData).previousSibling;

        if (previousSibling == null) {
          collapsedData = collapsedData.trimLeft();
        } else if (previousSibling is RenderBoxModel &&(previousSibling.renderStyle.display == CSSDisplay.block || previousSibling.renderStyle.display == CSSDisplay.flex)) {
          // If previousSibling is block,should trimLeft slef.
          CSSDisplay? display = previousSibling.renderStyle.display;
          if (display == CSSDisplay.block || display == CSSDisplay.sliver || display == CSSDisplay.flex) {
            collapsedData = collapsedData.trimLeft();
          }
        } else if (previousSibling is RenderTextBox && isEndWithSpace(previousSibling.data)) {
          collapsedData = collapsedData.trimLeft();
        }

        RenderObject? nextSibling = (parentData as RenderLayoutParentData).nextSibling;
        if (nextSibling == null) {
          collapsedData = collapsedData.trimRight();
        } else if (nextSibling is RenderBoxModel && (nextSibling.renderStyle.display == CSSDisplay.block || nextSibling.renderStyle.display == CSSDisplay.flex)) {
          // If nextSibling is block,should trimRight slef.
          CSSDisplay? display = nextSibling.renderStyle.display;
          if (display == CSSDisplay.block || display == CSSDisplay.sliver || display == CSSDisplay.flex) {
            collapsedData = collapsedData.trimRight();
          }
        }

        return collapsedData;
      }
    }

    return _data;
  }

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

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  int? get _maxLines {
    int? lineClamp = renderStyle.lineClamp;
    // Forcing a break after a set number of lines.
    // https://drafts.csswg.org/css-overflow-3/#max-lines
    if (lineClamp != null) {
      return lineClamp;
    }
    // Force display single line when white-space is nowrap.
    if (renderStyle.whiteSpace == WhiteSpace.nowrap) {
      return 1;
    }
    return null;
  }

  double? get _lineHeight {
    if (renderStyle.lineHeight.type != CSSLengthType.NORMAL) {
      return renderStyle.lineHeight.computedValue;
    }
    return null;
  }

  TextSpan get _textSpan {
    String clippedText = _getClippedText(_trimmedData);
    // FIXME(yuanyan): do not create text span every time.
    return CSSTextMixin.createTextSpan(clippedText, renderStyle);
  }

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    needsLayout = true;
  }

  void markRenderParagraphNeedsLayout() {
    _renderParagraph.markNeedsLayout();
  }

  // @HACK: sync _needsLayout flag in Flutter to do performance opt.
  void syncNeedsLayoutFlag() {
    needsLayout = true;
  }

  BoxConstraints getConstraints() {
    if (renderStyle.whiteSpace == WhiteSpace.nowrap &&
        renderStyle.effectiveTextOverflow != TextOverflow.ellipsis) {
      return BoxConstraints();
    }

    double maxConstraintWidth = double.infinity;
    if (parent is RenderBoxModel) {
      RenderBoxModel parentRenderBoxModel = parent as RenderBoxModel;
      BoxConstraints parentConstraints = parentRenderBoxModel.constraints;

      if (parentRenderBoxModel.isScrollingContentBox) {
        maxConstraintWidth = parentConstraints.minWidth;
      } else if (parentConstraints.maxWidth == double.infinity) {
        final ParentData? parentParentData = parentRenderBoxModel.parentData;
        // Width of positioned element does not constrained by parent.
        if (parentParentData is RenderLayoutParentData && parentParentData.isPositioned) {
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

  // Empty string is the minimum size character, use it as the base size
  // for calculating the maximum characters to display in its container.
  Size get minCharSize {
    TextStyle textStyle = TextStyle(
      fontFamilyFallback: renderStyle.fontFamily,
      fontSize: renderStyle.fontSize.computedValue,
      textBaseline: CSSText.getTextBaseLine(),
      package: CSSText.getFontPackage(),
      locale: CSSText.getLocale(),
    );
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: ' ',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr
    );
    painter.layout();
    return painter.size;
  }

  // Avoid to render the whole text when text overflows its parent and text is not
  // displayed fully and parent is not scrollable to improve text layout performance.
  String _getClippedText(String data) {
    // Only clip text in container which meets CSS box model spec.
    if (parent is! RenderBoxModel) {
      return data;
    }

    String clippedText = data;
    RenderBoxModel parentRenderBoxModel = parent as RenderBoxModel;
    BoxConstraints? parentContentConstraints = parentRenderBoxModel.contentConstraints;
    // Text only need to render in parent container's content area when
    // white-space is nowrap and overflow is hidden/clip.
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;

    if (parentContentConstraints != null
      && (effectiveOverflowX == CSSOverflowType.hidden
      || effectiveOverflowX == CSSOverflowType.clip)
    ) {
      // Max character to display in one line.
      int? maxCharsOfLine;
      // Max lines in parent.
      int? maxLines;

      if (parentContentConstraints.maxWidth.isFinite) {
        maxCharsOfLine = (parentContentConstraints.maxWidth / minCharSize.width).ceil();
      }
      if (parentContentConstraints.maxHeight.isFinite) {
        maxLines = (parentContentConstraints.maxHeight / (_lineHeight ?? minCharSize.height)).ceil();
      }

      if (renderStyle.whiteSpace == WhiteSpace.nowrap) {
        if (maxCharsOfLine != null) {
          int maxChars = maxCharsOfLine;
          if (data.length > maxChars) {
            clippedText = data.substring(0, maxChars);
          }
        }
      } else {
        if (maxCharsOfLine != null && maxLines != null) {
          int maxChars = maxCharsOfLine * maxLines;
          if (data.length > maxChars) {
            clippedText = data.substring(0, maxChars);
          }
        }
      }
    }
    return clippedText;
  }

  // '  a b  c   \n' => ' a b c '
  static String _collapseWhitespace(String string) {
    return string.replaceAll(_whiteSpaceReg, WHITE_SPACE_CHAR);
  }

  @override
  void performLayout() {
    KrakenRenderParagraph? paragraph = child as KrakenRenderParagraph?;
    if (paragraph != null) {
      paragraph.overflow = renderStyle.effectiveTextOverflow;
      paragraph.textAlign = renderStyle.textAlign;
      paragraph.text = _textSpan;
      paragraph.maxLines = _maxLines;
      paragraph.lineHeight = _lineHeight;
      paragraph.layout(constraints, parentUsesSize: true);

      size = paragraph.size;

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
