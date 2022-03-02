/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

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
  RenderBox createRenderer() {
    return renderIntrinsic ??= createRenderIntrinsic();
  }

  @override
  RenderIntrinsic createRenderIntrinsic() {
    return RenderTextControlMultiline(
      renderStyle,
    );
  }

  @override
  RenderIntrinsic createRenderRepaintBoundaryIntrinsic() {
    return RenderRepaintBoundaryTextControlMultiline(
      renderStyle,
    );
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
      : 1.2 * renderStyle.fontSize.computedValue;

    return computedLineHeight * double.parse(properties[ROWS] ?? '2');
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

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    if (!properties.containsKey(VALUE) && !properties.containsKey(DEFAULT_VALUE)) {
      setProperty(DEFAULT_VALUE, textContent);
    }
  }

}

