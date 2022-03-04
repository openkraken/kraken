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
  TextareaElement(EventTargetContext? context)
    : super(context, isMultiline: true, defaultStyle: _defaultStyle, isIntrinsicBox: true);

  // Width and height set through style.
  double? _styleWidth;
  double? _styleHeight;

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    if (key == ROWS) {
      _updateDefaultHeight();
    } else if (key == COLS) {
      _updateDefaultWidth();
    }
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener();
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null;
      _updateDefaultWidth();
    } else if (property == HEIGHT) {
      _styleHeight = renderStyle.height.isNotAuto ? renderStyle.height.computedValue : null;
      _updateDefaultHeight();
    }
  }

  void _updateDefaultWidth() {
    // cols is only valid when width in style is not set.
    if (_styleWidth == null) {
      renderStyle.width = CSSLengthValue(defaultWidth, CSSLengthType.PX);
    }
  }

  void _updateDefaultHeight() {
    // rows is only valid when height in style is not set.
    if (_styleHeight == null) {
      renderStyle.height = CSSLengthValue(defaultHeight, CSSLengthType.PX);
    }
  }

  @override
  double? get defaultWidth {
    // cols defaults to 20.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-cols
    return avgCharWidth * double.parse(properties[COLS] ?? '20');
  }

  @override
  double? get defaultHeight {
    // rows defaults to 2.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-rows
    double computedLineHeight = renderStyle.lineHeight != CSSLengthValue.normal
      ? renderStyle.lineHeight.computedValue
      : avgCharHeight;

    return computedLineHeight * double.parse(properties[ROWS] ?? '2');
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
    // Text content of textarea acts as default value when defaultValue property is not set.
    if (!properties.containsKey(VALUE)) {
      setProperty(DEFAULT_VALUE, textContent);
    }
  }
}

