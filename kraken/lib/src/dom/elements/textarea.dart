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

