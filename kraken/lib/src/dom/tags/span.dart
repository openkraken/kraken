/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String SPAN = 'SPAN';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE};

class SpanElement extends Element {
  SpanElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: SPAN, defaultStyle: _defaultStyle);
}
