/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String INPUT = 'INPUT';
const String SIZE = 'size';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class InputElement extends TextFormControlElement {
  InputElement(EventTargetContext? context)
    : super(context, defaultStyle: _defaultStyle, isIntrinsicBox: true);

  double? get _defaultWidth {
    // size defaults to 20.
    // https://html.spec.whatwg.org/multipage/input.html#attr-input-size
    return avgCharWidth * double.parse(properties[SIZE] ?? '20');
  }

  // Width set through style.
  double? _styleWidth;

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    if (key == SIZE) {
      _updateDefaultWidth();
    }
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _updateDefaultWidth();
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null;
      _updateDefaultWidth();
    } else if (property == LINE_HEIGHT) {
      // Need to mark RenderTextControlLeaderLayer as needsLayout manually cause
      // line-height change will not affect constraints which will in turn
      // make RenderTextControlLeaderLayer jump layout.
      if (isRendererAttached && renderTextControlLeaderLayer != null) {
        renderTextControlLeaderLayer!.markNeedsLayout();
      }
    } else if (property == FONT_SIZE) {
      _updateDefaultWidth();
    }
  }

  void _updateDefaultWidth() {
    // cols is only valid when width in style is not set.
    if (_styleWidth == null) {
      renderStyle.width = CSSLengthValue(_defaultWidth, CSSLengthType.PX);
    }
  }
}

