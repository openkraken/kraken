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

  static final SplayTreeMap<int, TextNode> _nativeMap = SplayTreeMap();

  static TextNode getTextNodeOfNativePtr(Pointer<NativeTextNode> nativeTextNode) {
    TextNode? textNode = _nativeMap[nativeTextNode.address];
    if (textNode == null) throw FlutterError('Can not get textNode from nativeTextNode: $nativeTextNode');
    return textNode;
  }

  TextNode(int targetId, this._nativePtr, this._data, ElementManager elementManager)
      : super(NodeType.TEXT_NODE, targetId, _nativePtr.ref.nativeNode, elementManager, '#text') {
    _nativeMap[_nativePtr.address] = this;
  }

  // Must be existed after text node is attached, and all text update will after text attached.
  RenderTextBox? _renderTextBox;

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String? _data;
  String get data {
    String? _d = _data;

    if (_d == null || _d.isEmpty) return '';

    WhiteSpace whiteSpace = CSSText.resolveWhiteSpace(parentElement!.style[WHITE_SPACE]);

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
    _data = newData;
    _applyTextStyle();
  }

  @override
  RenderObject? get renderer => _renderTextBox;

  void _applyTextStyle() {
    if (isRendererAttached) {
      Element _parentElement = parentElement!;

      // The parentNode must be an element.
      _renderTextBox!.renderStyle = _parentElement.renderStyle;
      _renderTextBox!.data = data;

      _updateLineHeight();
      _updateTextAlign();

      RenderLayoutBox? parentRenderLayoutBox;
      if (_parentElement.scrollingContentLayoutBox != null) {
        parentRenderLayoutBox = _parentElement.scrollingContentLayoutBox!;
      } else {
        parentRenderLayoutBox = (_parentElement.renderBoxModel as RenderLayoutBox?)!;
      }
      _setTextSizeType(parentRenderLayoutBox.widthSizeType, parentRenderLayoutBox.heightSizeType);
    }
  }

  void _setTextSizeType(BoxSizeType width, BoxSizeType height) {
    // Migrate element's size type to RenderTextBox.
    _renderTextBox!.widthSizeType = width;
    _renderTextBox!.heightSizeType = height;
  }

  void _updateTextAlign() {
    KrakenRenderParagraph renderParagraph = _renderTextBox!.child as KrakenRenderParagraph;
    Element _parentElement = parentElement!;
    renderParagraph.textAlign = _parentElement.renderStyle.textAlign;
  }

  void _updateLineHeight() {
    KrakenRenderParagraph renderParagraph = _renderTextBox!.child as KrakenRenderParagraph;
    renderParagraph.lineHeight = parentElement!.renderStyle.lineHeight.computedValue;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, { RenderBox? after }) {
    willAttachRenderer();

    RenderLayoutBox? parentRenderLayoutBox;
    if (parent.scrollingContentLayoutBox != null) {
      parentRenderLayoutBox = parent.scrollingContentLayoutBox!;
    } else {
      parentRenderLayoutBox = (parent.renderBoxModel as RenderLayoutBox?)!;
    }

    parentRenderLayoutBox.insert(_renderTextBox!, after: after);

    _applyTextStyle();

    didAttachRenderer();
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    willDetachRenderer();

    if (isRendererAttached) {
      RenderTextBox renderTextBox = _renderTextBox!;
      ContainerRenderObjectMixin parent = renderTextBox.parent as ContainerRenderObjectMixin;
      parent.remove(renderTextBox);
    }

    didDetachRenderer();
    _renderTextBox = null;
  }

  @override
  void willAttachRenderer() {
    createRenderer();
  }

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer!;
    }
    return _renderTextBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
  }

  @override
  void dispose() {
    super.dispose();

    detach();

    assert(_renderTextBox == null);
    _nativeMap.remove(_nativePtr.address);
  }
}

// '  a b  c   \n' => ' a b c '
String _collapseWhitespace(String string) {
  return string.replaceAll(_whiteSpaceReg, WHITE_SPACE_CHAR);
}
