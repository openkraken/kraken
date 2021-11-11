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

  BRElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
    : super(
    targetId, nativePtr, elementManager,
    defaultStyle: _breakDefaultStyle,
    isIntrinsicBox: true,
  );

  @override
  RenderBoxModel? get renderBoxModel => _renderBr;

  @override
  RenderObject? get renderer => renderBoxModel;

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer!;
    }
    _renderBr = RenderBr(renderStyle);
    return renderer!;
  }
}
