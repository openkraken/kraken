/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String TEXTAREA = 'TEXTAREA';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class TextareaElement extends TextFormControlElement {
  TextareaElement(EventTargetContext? context)
    : super(context, isMultiline: true, defaultStyle: _defaultStyle, isIntrinsicBox: true);

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    if (!properties.containsKey(VALUE) && !properties.containsKey(DEFAULT_VALUE)) {
      setProperty(DEFAULT_VALUE, textContent);
    }
  }

  // Text content of textarea acts as default value when defaultValue property is not set.
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
}

