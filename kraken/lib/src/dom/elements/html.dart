/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';

const String HTML = 'HTML';
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
  OVERFLOW: AUTO
};

class HTMLElement extends Element {
  static Map<String, dynamic> defaultStyle = _defaultStyle;
  HTMLElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(
      targetId,
      nativePtr,
      elementManager,
      tagName: HTML,
      defaultStyle: defaultStyle
  ) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ROOT_ELEMENT_PROPERTY_INIT);
    }
    elementManager.viewportElement = this;
    // Must init with viewport width.
    renderStyle.width = CSSLengthValue(elementManager.viewportWidth, CSSLengthType.PX);
    renderStyle.height = CSSLengthValue(elementManager.viewportHeight, CSSLengthType.PX);
  }

  @override
  void attachTo(Node parent, {RenderBox? after}) {
    super.attachTo(parent);
    if (renderBoxModel != null) {
      elementManager.viewport.child = renderBoxModel;
    }
  }

  @override
  void detach() {
    super.detach();
    elementManager.viewport.child = null;
  }
}
