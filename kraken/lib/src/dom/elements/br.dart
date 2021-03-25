/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

const String BR = 'BR';

class LineBreakElement extends Element {

  RenderTextBox _renderTextBox;

  LineBreakElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: BR) {
    TextSpan text = TextSpan(text: NEW_LINE_CHAR);
    _renderTextBox = RenderTextBox(text,
      targetId: targetId,
      elementManager: elementManager,
    );
  }

  @override
  void attachTo(Element parent, { RenderObject after }) {
    RenderLayoutBox parentRenderLayoutBox;
    if (parent.scrollingContentLayoutBox != null) {
      parentRenderLayoutBox = parent.scrollingContentLayoutBox;
    } else {
      parentRenderLayoutBox = parent.renderBoxModel;
    }

    parentRenderLayoutBox.insert(_renderTextBox, after: after);
  }
}
