/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

class TextNode extends Node with NodeLifeCycle, CSSTextMixin {
  TextNode(int targetId, Pointer<NativeEventTarget> nativePtr, this._data, ElementManager elementManager)
      : super(NodeType.TEXT_NODE, targetId, nativePtr, elementManager, '#text');

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
      if (previousSibling is Element && isSpace(_data[0])) {
        collapsedData = NORMAL_SPACE + collapsedData;
      }

      if (nextSibling is Node && isSpace(_data[_data.length - 1])) {
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
    _renderTextBox.text = createTextSpan(data, parentElement.style);
    _setTextNodeProperties(parentElement.style);

    RenderBoxModel parentRenderBoxModel = parentElement.renderBoxModel;
    _setTextSizeType(parentRenderBoxModel.widthSizeType, parentRenderBoxModel.heightSizeType);
  }

  void _setTextNodeProperties(CSSStyleDeclaration style) {
    _renderTextBox.whiteSpace = CSSText.getWhiteSpace(parentElement.style);
    _renderTextBox.overflow = CSSText.getTextOverflow(parentElement.style);
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, { RenderObject after }) {
    willAttachRenderer();

    RenderLayoutBox parentRenderLayoutBox = parent.renderBoxModel;
    parentRenderLayoutBox.insert(_renderTextBox, after: after);
    _setTextSizeType(parentRenderLayoutBox.widthSizeType, parentRenderLayoutBox.heightSizeType);

    didAttachRenderer();
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    willDetachRenderer();

    ContainerRenderObjectMixin parent = _renderTextBox.parent;
    parent.remove(_renderTextBox);

    didDetachRenderer();
    dispose();
  }

  @override
  void willAttachRenderer() {
    createRenderer();
    // Text node whitespace collapse relate to siblings,
    // so text should update when appending
    _renderTextBox.text = createTextSpan(data, parent.style);
    // TextNode's style is inherited from parent style
    _renderTextBox.style = parent.style;

    _setTextNodeProperties(parent.style);
  }

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer;
    }

    InlineSpan text = createTextSpan(_data, null);
    _renderTextBox = RenderTextBox(text,
      targetId: targetId,
      style: null,
      elementManager: elementManager,
    );
    return _renderTextBox;
  }

  @override
  void dispose() {
    assert(_renderTextBox != null);
    assert(_renderTextBox.parent == null);

    _renderTextBox = null;
  }
}

bool isSpace(String ch) => ch == ' ';
bool isLineBreaker(String ch) => ch == '\n' || ch == '\r' || ch == '\t';

/// Utility function to collapse whitespace runs to single spaces
/// and strip leading/trailing whitespace.
String collapseWhitespace(String string, {bool collapseSpace = true, bool collapseLineBreaker = true}) {
  var result = StringBuffer();
  var _skip = true;
  for (var i = 0; i < string.length; i++) {
    var character = string[i];
    if ((collapseSpace && isSpace(character)) || (collapseLineBreaker && isLineBreaker(character))) {
      if (!_skip) {
        result.write(' ');
        _skip = true;
      }
    } else {
      result.write(character);
      _skip = false;
    }
  }
  return result.toString().trim();
}
