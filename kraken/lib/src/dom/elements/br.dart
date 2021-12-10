/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

// HACK: current use block layout make text force line break
const Map<String, dynamic> _breakDefaultStyle = {
  DISPLAY: BLOCK,
};

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  RenderLineBreak? _renderLineBreak;

  BRElement(EventTargetContext? context)
    : super(
    context,
    defaultStyle: _breakDefaultStyle,
    isIntrinsicBox: true,
  ) {
    // Init style and add change listener.
    style = CSSStyleDeclaration.computedStyle(this, _breakDefaultStyle, _onStyleChanged);
  }

  // Do nothing in style change listener cause styles take no effect on BR element.
  StyleChangeListener? _onStyleChanged;

  @override
  RenderBoxModel? get renderBoxModel => _renderLineBreak;

  @override
  RenderBox createRenderer() {
    return _renderLineBreak ??= RenderLineBreak(renderStyle);
  }
}
