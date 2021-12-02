/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String BODY = 'BODY';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class BodyElement extends Element {
  BodyElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super( targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    renderBoxModel!.renderStyle.width = CSSLengthValue(elementManager.viewportWidth, CSSLengthType.PX);
  }

  @override
  void addEvent(String eventType) {
    // Scroll event not working on body.
    if (eventType == EVENT_SCROLL) return;
    super.addEvent(eventType);
  }
}
