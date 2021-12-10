/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/kraken.dart';

// HACK: current use block layout make text force line break
const Map<String, dynamic> _breakDefaultStyle = {
  DISPLAY: BLOCK,
};

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  RenderBr? _renderBr;

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
  RenderBoxModel? get renderBoxModel => _renderBr;

  @override
  RenderBox createRenderer() {
    return _renderBr ??= RenderBr(renderStyle);
  }
}
