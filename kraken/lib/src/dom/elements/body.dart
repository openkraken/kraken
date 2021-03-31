/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';

const String BODY = 'BODY';

class BodyElement extends Element {
  BodyElement(double viewportWidth, double viewportHeight, int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(
        targetId,
        nativePtr,
        elementManager,
        repaintSelf: false,
        tagName: BODY,
        defaultStyle: {
            WIDTH: '${viewportWidth}px',
            HEIGHT: '${viewportHeight}px',
            OVERFLOW: AUTO,
            DISPLAY: BLOCK,
            BACKGROUND_COLOR: 'white',
          }
        ) {
    if (kProfileMode) {
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_BODY_ELEMENT_PROPERTY_INIT);
    }
  }

  void attachBody() {
    willAttachRenderer();
    style.applyTargetProperties();
    didAttachRenderer();
  }
}
