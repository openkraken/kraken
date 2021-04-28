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
  HTMLElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(
      targetId,
      nativePtr,
      elementManager,
      repaintSelf: false,
      tagName: HTML,
      defaultStyle: {
        WIDTH: '${elementManager.viewportWidth}px',
        HEIGHT: '${elementManager.viewportHeight}px',
        OVERFLOW: AUTO,
        DISPLAY: BLOCK,
      }
  ) {
    if (kProfileMode) {
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_ROOT_ELEMENT_PROPERTY_INIT);
    }

    // Attach body
    willAttachRenderer();
    style.applyTargetProperties();
    didAttachRenderer();
  }
}
