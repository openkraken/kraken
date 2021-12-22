/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

final RegExp _whiteSpaceReg = RegExp(r'\s+');
const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

class TextNode extends Node {
  TextNode(this._data, EventTargetContext? context)
      : super(NodeType.TEXT_NODE, context);

  // Must be existed after text node is attached, and all text update will after text attached.
  RenderTextBox? _renderTextBox;

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String? _data;
  String get data {
    String? _d = _data;

    if (_d == null || _d.isEmpty) return '';

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
    WhiteSpace whiteSpace = parentElement!.renderStyle.whiteSpace;
    if (whiteSpace == WhiteSpace.pre ||
        whiteSpace == WhiteSpace.preLine ||
        whiteSpace == WhiteSpace.preWrap ||
        whiteSpace == WhiteSpace.breakSpaces) {
      return whiteSpace == WhiteSpace.preLine ? _collapseWhitespace(_d) : _d;
    } else {
      String collapsedData = _collapseWhitespace(_d);
      // TODO:
      // Remove the leading space while prev element have space too:
      //   <p><span>foo </span> bar</p>
      // Refs:
      //   https://github.com/WebKit/WebKit/blob/6a970b217d59f36e64606ed03f5238d572c23c48/Source/WebCore/layout/inlineformatting/InlineLineBuilder.cpp#L295

      if (previousSibling == null) {
        collapsedData = collapsedData.trimLeft();
      }

      if (nextSibling == null) {
        collapsedData = collapsedData.trimRight();
      }

      return collapsedData;
    }
  }

  set data(String? newData) {
    assert(newData != null);

    String oldData = _data!;
    if (oldData == newData) return;

    _data = newData;

    // Empty string of textNode should not attach to render tree.
    if (oldData.isNotEmpty && newData!.isEmpty) {
      detach();
    } else if (oldData.isEmpty && newData!.isNotEmpty) {
      attachTo(parentElement!);
    } else {
      _applyTextStyle();
    }
  }

  @override
  String get nodeName => '#text';

  @override
  RenderBox? get renderer => _renderTextBox;

  void _applyTextStyle() {
    if (isRendererAttached) {
      Element _parentElement = parentElement!;

      // The parentNode must be an element.
      _renderTextBox!.renderStyle = _parentElement.renderStyle;
      _renderTextBox!.data = data;

      KrakenRenderParagraph renderParagraph = _renderTextBox!.child as KrakenRenderParagraph;
      renderParagraph.markNeedsLayout();

      RenderLayoutBox parentRenderLayoutBox = _parentElement.renderBoxModel as RenderLayoutBox;
      parentRenderLayoutBox = parentRenderLayoutBox.renderScrollingContent ?? parentRenderLayoutBox;
      _setTextSizeType(parentRenderLayoutBox.widthSizeType, parentRenderLayoutBox.heightSizeType);
    }
  }

  void _setTextSizeType(BoxSizeType width, BoxSizeType height) {
    // Migrate element's size type to RenderTextBox.
    _renderTextBox!.widthSizeType = width;
    _renderTextBox!.heightSizeType = height;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, { RenderBox? after }) {
    // Empty string of TextNode should not attach to render tree.
    if (_data == null || _data!.isEmpty) return;

    createRenderer();

    if (parent.renderBoxModel is RenderLayoutBox) {
      RenderLayoutBox parentRenderLayoutBox = parent.renderBoxModel as RenderLayoutBox;
      parentRenderLayoutBox = parentRenderLayoutBox.renderScrollingContent ?? parentRenderLayoutBox;
      parentRenderLayoutBox.insert(_renderTextBox!, after: after);
      _applyTextStyle();
    }
  }

  // Detach renderObject of current node from parent
  void detach() {
    if (isRendererAttached) {
      RenderTextBox renderTextBox = _renderTextBox!;
      ContainerRenderObjectMixin parent = renderTextBox.parent as ContainerRenderObjectMixin;
      parent.remove(renderTextBox);
    }
  }

  // Detach renderObject of current node from parent
  @override
  void disposeRenderObject() {
    detach();
    _renderTextBox = null;
  }

  @override
  RenderBox createRenderer() {
    if (_renderTextBox != null) {
      return _renderTextBox!;
    }
    return _renderTextBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
  }

  @override
  void dispose() {
    super.dispose();

    disposeRenderObject();

    assert(_renderTextBox == null);
  }
}

// '  a b  c   \n' => ' a b c '
String _collapseWhitespace(String string) {
  return string.replaceAll(_whiteSpaceReg, WHITE_SPACE_CHAR);
}
