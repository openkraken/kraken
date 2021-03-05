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

const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

class TextNode extends Node {
  final Pointer<NativeTextNode> nativeTextNodePtr;

  static SplayTreeMap<int, TextNode> _nativeMap = SplayTreeMap();

  static TextNode getTextNodeOfNativePtr(Pointer<NativeTextNode> nativeTextNode) {
    TextNode textNode = _nativeMap[nativeTextNode.address];
    assert(textNode != null, 'Can not get textNode from nativeTextNode: $nativeTextNode');
    return textNode;
  }

  TextNode(int targetId, this.nativeTextNodePtr, this._data, ElementManager elementManager)
      : super(NodeType.TEXT_NODE, targetId, nativeTextNodePtr.ref.nativeNode, elementManager, '#text') {
    _nativeMap[nativeTextNodePtr.address] = this;
  }

  RenderTextBox _renderTextBox;

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String _data;
  String get data {
    if (_data == null || _data.isEmpty) return '';

    WhiteSpace whiteSpace = CSSText.getWhiteSpace(parent?.style);

    /// The following table summarizes the behavior of the various white-space values:
    //
    // New lines	Spaces and tabs	Text wrapping	End-of-line spaces
    // normal	Collapse	Collapse	Wrap	Remove
    // nowrap	Collapse	Collapse	No wrap	Remove
    // pre	Preserve	Preserve	No wrap	Preserve
    // pre-wrap	Preserve	Preserve	Wrap	Hang
    // pre-line	Preserve	Collapse	Wrap	Remove
    // break-spaces	Preserve	Preserve	Wrap	Wrap
    if (whiteSpace == WhiteSpace.pre ||
        whiteSpace == WhiteSpace.preLine ||
        whiteSpace == WhiteSpace.preWrap ||
        whiteSpace == WhiteSpace.breakSpaces) {
      return whiteSpace == WhiteSpace.preLine ? collapseWhitespace(_data, collapseSpace: true) : _data;
    } else {
      String collapsedData = collapseWhitespace(_data);
      // Append space while prev is element.
      //   Consider:
      //        <ltr><span>foo</span>bar</ltr>
      // Append space while next is node(including textNode).
      //   Consider: (PS: ` is text node seperater.)
      //        <ltr><span>foo</span>`bar``hello`</ltr>
      if ((previousSibling is TextNode || 
          previousSibling is ParagraphElement ||
          previousSibling is SpanElement) &&
          isWhiteSpace(_data[0])) {
        collapsedData = NORMAL_SPACE + collapsedData;
      }

      if (nextSibling is Node && isWhiteSpace(_data[_data.length - 1])) {
        collapsedData = collapsedData + NORMAL_SPACE;
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
    _nativeMap.remove(nativeTextNodePtr.address);
  }
}

bool isWhiteSpace(String ch) => ch == WHITE_SPACE_CHAR || ch == TAB_CHAR;
bool isLineBreak(String ch) => ch == NEW_LINE_CHAR || ch == RETURN_CHAR;

/// https://drafts.csswg.org/css-text-3/#propdef-white-space
/// Utility function to collapse whitespace runs to single spaces
/// and strip leading/trailing whitespace.
String collapseWhitespace(String string, {bool collapseSpace = true, bool collapseLineBreak = true}) {
  var result = StringBuffer();
  var _skip = true;
  for (var i = 0; i < string.length; i++) {
    var character = string[i];
    if ((collapseSpace && isWhiteSpace(character)) || (collapseLineBreak && isLineBreak(character))) {
      if (!_skip) {
        result.write(WHITE_SPACE_CHAR);
        _skip = true;
      }
    } else {
      result.write(character);
      _skip = false;
    }
  }

  return result.toString().trim();
}
