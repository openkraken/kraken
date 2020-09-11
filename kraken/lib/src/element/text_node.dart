/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

class TextNode extends Node with NodeLifeCycle, CSSTextMixin {
  TextNode(int targetId, this._data, ElementManager elementManager)
      : super(NodeType.TEXT_NODE, targetId, elementManager, '#text') {
    InlineSpan text = createTextSpan(_data, null);

    renderTextBox = RenderTextBox(text,
      targetId: targetId,
      style: null,
      elementManager: elementManager,
    );
  }

  RenderTextBox renderTextBox;

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

  void updateTextStyle() {
    if (isConnected) {
      _updateTextStyle();
    } else {
      queueAfterConnected(_updateTextStyle);
    }
  }

  void _setTextSizeType(BoxSizeType width, BoxSizeType height) {
    // migrate element's size type to RenderTextBox
    renderTextBox.widthSizeType = width;
    renderTextBox.heightSizeType = height;
  }

  void _updateTextStyle() {
    // parentNode must be an element.
    Element parentElement = parentNode;
    renderTextBox.style = parentElement.style;
    renderTextBox.text = createTextSpan(data, parentElement.style);
    _setTextNodeProperties(parentElement.style);

    RenderBoxModel parentRenderBoxModel = parentElement.renderBoxModel;
    _setTextSizeType(
      parentRenderBoxModel.widthSizeType, parentRenderBoxModel.heightSizeType);
  }

  void _setTextNodeProperties(CSSStyleDeclaration style) {
    renderTextBox.whiteSpace = CSSText.getWhiteSpace(parentElement.style);
    renderTextBox.overflow = CSSText.getTextOverflow(parentElement.style);
  }

  @override
  bool get attached => renderTextBox.attached;

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, {RenderObject after}) {
    // Text node whitespace collapse relate to siblings,
    // so text should update when appending
    renderTextBox.text = createTextSpan(data, parent.style);
    // TextNode's style is inherited from parent style
    renderTextBox.style = parent.style;
    _setTextNodeProperties(parent.style);
    parent.renderLayoutBox.insert(renderTextBox, after: after);
    RenderBoxModel parentRenderBoxModel = parentElement.renderBoxModel;
    _setTextSizeType(
      parentRenderBoxModel.widthSizeType, parentRenderBoxModel.heightSizeType);
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    parent.renderLayoutBox.remove(renderTextBox);
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
