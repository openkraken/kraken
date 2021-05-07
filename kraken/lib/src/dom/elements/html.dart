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
      tagName: HTML,
      defaultStyle: {
        DISPLAY: BLOCK,
      }
  ) {
    if (kProfileMode) {
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_ROOT_ELEMENT_PROPERTY_INIT);
    }
    // Init renderer
    willAttachRenderer();
    // Init default render style value
    style.applyTargetProperties();
    RenderStyle renderStyle = renderBoxModel.renderStyle;
    // Must init with viewport width
    renderStyle.width = elementManager.viewportWidth;
    didAttachRenderer();
  }

  Element get parent => elementManager.viewportElement;

  // https://www.w3.org/TR/cssom-view-1/#dom-element-scrolltop
  // If the element is the root element return the value of scrollY on Window (viewport).
  double get scrollTop {
    return parent.scrollTop;
  }
  set scrollTop(double value) {
    parent.scrollTo(y: value);
  }

  double get scrollLeft {
    return parent.scrollLeft;
  }
  set scrollLeft(double value) {
    parent.scrollTo(x: value);
  }

  get scrollHeight {
    return parent.scrollHeight;
  }

  get scrollWidth {
    return parent.scrollWidth;
  }

  void scrollBy({ num dx = 0.0, num dy = 0.0, bool withAnimation }) {
    parent.scrollBy(dx: dx, dy: dy, withAnimation: withAnimation);
  }

  void scrollTo({ num x, num y, bool withAnimation }) {
    parent.scrollTo(x: x, y: x, withAnimation: withAnimation);
  }

}
