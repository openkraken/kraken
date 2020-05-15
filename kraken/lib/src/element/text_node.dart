/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:matcher/matcher.dart';

class TextNode extends Node with NodeLifeCycle, CSSTextMixin {
  static bool _isWhitespace(String ch) =>
      ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t';

  TextNode(int targetId, this._data)
      : super(NodeType.TEXT_NODE, targetId, '#text') {
    renderTextBox = RenderTextBox(
      targetId: targetId,
      text: '',
      style: null,
    );
  }

  RenderTextBox renderTextBox;

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String _data;
  String get data {
    if (_data.isEmpty) {
      return _data;
    }
    // @TODO(zl): Need to judge style white-spacing.
    String collapsedData = collapseWhitespace(_data);
    // Append space while prev is element.
    //   Consider:
    //        <ltr><span>foo</span>bar</ltr>
    // Append space while next is node(including textNode).
    //   Consider: (PS: ` is text node seperater.)
    //        <ltr><span>foo</span>`bar``hello`</ltr>
    if (previousSibling is Element && _isWhitespace(_data[0])) {
      collapsedData = NORMAL_SPACE + collapsedData;
    }

    if (nextSibling is Node && _isWhitespace(_data[_data.length - 1])) {
      collapsedData = collapsedData + NORMAL_SPACE;
    }
    return collapsedData;
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

  void _updateTextStyle() {
    // parentNode must be an element.
    Element parentElement = parentNode;
    renderTextBox.text = data;
    renderTextBox.style = parentElement.style;
  }

  @override
  bool get attached => renderTextBox.attached;

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, { RenderObject after }) {
    // Text node whitespace collapse relate to siblings,
    // so text should update when appending
    renderTextBox.text = data;
    // TextNode's style is inherited from parent style
    renderTextBox.style = parent.style;
    parent.renderLayoutBox.insert(renderTextBox, after: after);
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    parent.renderLayoutBox.remove(renderTextBox);
  }
}

