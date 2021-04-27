/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String BODY = 'BODY';

// FIXME: make display block and could scrolling
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

class BodyElement extends Element {
  BodyElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super( targetId, nativePtr, elementManager, tagName: BODY, defaultStyle: _defaultStyle);
}
