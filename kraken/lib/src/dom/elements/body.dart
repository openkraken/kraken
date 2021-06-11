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
  BodyElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super( targetId, nativePtr, elementManager, tagName: BODY, defaultStyle: _defaultStyle);

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    renderStyle.width = elementManager.viewportWidth;
  }
}
