/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';
import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';


final RegExp _whiteSpaceReg = RegExp(r'\s+');
const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

class TextNode extends Node {
  final Pointer<NativeTextNode> _nativePtr;

  static SplayTreeMap<int, TextNode> _nativeMap = SplayTreeMap();

  static TextNode getTextNodeOfNativePtr(Pointer<NativeTextNode> nativeTextNode) {
    TextNode textNode = _nativeMap[nativeTextNode.address];
    assert(textNode != null, 'Can not get textNode from nativeTextNode: $nativeTextNode');
    return textNode;
  }

  TextNode(int targetId, this._nativePtr, this._data, ElementManager elementManager)
      : super(NodeType.TEXT_NODE, targetId, _nativePtr.ref.nativeNode, elementManager, '#text') {
    _nativeMap[_nativePtr.address] = this;
  }

  RenderTextBox _renderTextBox;

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String _data;
  String get data {
    if (_data == null || _data.isEmpty) return '';

    WhiteSpace whiteSpace = CSSText.getWhiteSpace(parent?.style);

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
    if (whiteSpace == WhiteSpace.pre ||
        whiteSpace == WhiteSpace.preLine ||
        whiteSpace == WhiteSpace.preWrap ||
        whiteSpace == WhiteSpace.breakSpaces) {
      return whiteSpace == WhiteSpace.preLine ? collapseWhitespace(_data) : _data;
    } else {
      String collapsedData = collapseWhitespace(_data);
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

  set data(String newData) {
    assert(newData != null);
    _data = newData;
    updateTextStyle();
  }

  @override
  RenderObject get renderer => _renderTextBox;


  void updateTextStyle() {
    if (isRendererAttached) {
      _updateTextStyle();
    }
  }

  void _setTextSizeType(BoxSizeType width, BoxSizeType height) {
    // migrate element's size type to RenderTextBox
    _renderTextBox.widthSizeType = width;
    _renderTextBox.heightSizeType = height;
  }

  void _updateTextStyle() {
    // parentNode must be an element.
    Element parentElement = parent;
    _renderTextBox.style = parentElement.style;
    _renderTextBox.text = CSSTextMixin.createTextSpan(data, parentElement);
    // Update paragraph line height
    KrakenRenderParagraph renderParagraph = _renderTextBox.child;
    renderParagraph.lineHeight = parent.renderBoxModel.renderStyle.lineHeight;
    renderParagraph.markNeedsLayout();

    _setTextNodeProperties(parentElement.style);

    RenderBoxModel parentRenderBoxModel = parentElement.renderBoxModel;
    _setTextSizeType(parentRenderBoxModel.widthSizeType, parentRenderBoxModel.heightSizeType);
  }

  void _setTextNodeProperties(CSSStyleDeclaration style) {
    _renderTextBox.whiteSpace = CSSText.getWhiteSpace(parentElement.style);
    _renderTextBox.overflow = CSSText.getTextOverflow(parentElement.style);
    _renderTextBox.maxLines = CSSText.getLineClamp(parentElement.style);
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, { RenderObject after }) {
    willAttachRenderer();

    RenderLayoutBox parentRenderLayoutBox;
    if (parent.scrollingContentLayoutBox != null) {
      parentRenderLayoutBox = parent.scrollingContentLayoutBox;
    } else {
      parentRenderLayoutBox = parent.renderBoxModel;
    }

    parentRenderLayoutBox.insert(_renderTextBox, after: after);
    _setTextSizeType(parentRenderLayoutBox.widthSizeType, parentRenderLayoutBox.heightSizeType);

    didAttachRenderer();
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    willDetachRenderer();

    if (isRendererAttached) {
      ContainerRenderObjectMixin parent = _renderTextBox.parent;
      parent.remove(_renderTextBox);
    }

    didDetachRenderer();
    _renderTextBox = null;
  }

  @override
  void willAttachRenderer() {
    createRenderer();
    CSSStyleDeclaration parentStyle = parent.style;
    // Text node whitespace collapse relate to siblings,
    // so text should update when appending
    _renderTextBox.text = CSSTextMixin.createTextSpan(data, parent);
    // TextNode's style is inherited from parent style
    _renderTextBox.style = parentStyle;
    // Update paragraph line height
    KrakenRenderParagraph renderParagraph = _renderTextBox.child;
    renderParagraph.lineHeight = parent.renderBoxModel.renderStyle.lineHeight;

    _setTextNodeProperties(parent.style);
  }

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer;
    }

    InlineSpan text = CSSTextMixin.createTextSpan(_data, null);
    _renderTextBox = RenderTextBox(text,
      targetId: targetId,
      style: null,
      elementManager: elementManager,
    );
    return _renderTextBox;
  }

  @override
  void dispose() {
    super.dispose();
    if (isRendererAttached) {
      detach();
    }

    assert(_renderTextBox == null);
    _nativeMap.remove(_nativePtr.address);
  }
}

bool isWhiteSpace(String ch) => ch == WHITE_SPACE_CHAR || ch == TAB_CHAR || ch == NEW_LINE_CHAR || ch == RETURN_CHAR;

// '  a b  c   \n' => ' a b c '
String collapseWhitespace(String string) {
  return string.replaceAll(_whiteSpaceReg, WHITE_SPACE_CHAR);
}
