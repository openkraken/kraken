/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String TEXTAREA = 'TEXTAREA';
const String ROWS = 'rows';
const String COLS = 'cols';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class TextareaElement extends TextFormControlElement {
  TextareaElement(context)
    : super(context, isMultiline: true, defaultStyle: _defaultStyle, isIntrinsicBox: true);

  @override
  void setAttribute(String qualifiedName, String val) {
    super.setAttribute(qualifiedName, val);
    switch (qualifiedName) {
      case 'rows':
        rows = attributeToProperty<int>(val);
        break;
      case 'cols':
        cols = attributeToProperty<int>(val);
        break;
    }
  }

  int get rows => int.tryParse(getAttribute('rows') ?? '') ?? 0;
  set rows(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('rows', value.toString());
    _updateDefaultHeight();
  }

  int get cols => int.tryParse(getAttribute('cols') ?? '') ?? 0;
  set cols(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('cols', value.toString());
    _updateDefaultWidth();
  }

  double? get _defaultWidth {
    // cols defaults to 20.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-cols
    return avgCharWidth * double.parse(attributes[COLS] ?? '20');
  }

  double? get _defaultHeight {
    // rows defaults to 2.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-rows
    double computedLineHeight = renderStyle.lineHeight != CSSLengthValue.normal
      ? renderStyle.lineHeight.computedValue
      : avgCharHeight;

    return computedLineHeight * double.parse(attributes[ROWS] ?? '2');
  }

  // The concatenation of the data of all the Text node descendants of node.
  // https://dom.spec.whatwg.org/#concept-descendant-text-content
  String get textContent {
    String str = '';
    // Set data of all text node children as value of textarea.
    for (Node child in childNodes) {
      if (child is TextNode) {
        str += child.data;
      }
    }
    return str;
  }

  // Width and height set through style.
  double? _styleWidth;
  double? _styleHeight;

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _updateDefaultWidth();
    _updateDefaultHeight();
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null;
      _updateDefaultWidth();
    } else if (property == HEIGHT) {
      _styleHeight = renderStyle.height.isNotAuto ? renderStyle.height.computedValue : null;
      _updateDefaultHeight();
    } else if (property == LINE_HEIGHT) {
      _updateDefaultHeight();
    } else if (property == FONT_SIZE) {
      _updateDefaultWidth();
      _updateDefaultHeight();
    }
  }

  void _updateDefaultWidth() {
    // cols is only valid when width in style is not set.
    if (_styleWidth == null) {
      renderStyle.width = CSSLengthValue(_defaultWidth, CSSLengthType.PX);
    }
  }

  void _updateDefaultHeight() {
    // rows is only valid when height in style is not set.
    if (_styleHeight == null) {
      renderStyle.height = CSSLengthValue(_defaultHeight, CSSLengthType.PX);
    }
  }

  @override
  Node appendChild(Node child) {
    super.appendChild(child);
    // Need to update defaultValue when child text node is appended.
    updateDefaultValue();
    return child;
  }

  @override
  Node removeChild(Node child) {
    super.removeChild(child);
    // Need to update defaultValue when child text node is removed.
    updateDefaultValue();
    return child;
  }

  void updateDefaultValue() {
    defaultValue = textContent;
  }
}

