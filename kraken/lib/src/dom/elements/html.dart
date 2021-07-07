/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';

const String HTML = 'HTML';

class HTMLElement extends Element {
  HTMLElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(
      targetId,
      nativePtr,
      elementManager,
      tagName: HTML,
      defaultStyle: {
        DISPLAY: BLOCK,
        OVERFLOW: AUTO
      }
  ) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ROOT_ELEMENT_PROPERTY_INIT);
    }
    // Init renderer
    willAttachRenderer();
    // Init default render style value
    style.applyTargetProperties();
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    // Must init with viewport width
    renderStyle.width = elementManager.viewportWidth;
    renderStyle.height = elementManager.viewportHeight;
    didAttachRenderer();
  }
}
