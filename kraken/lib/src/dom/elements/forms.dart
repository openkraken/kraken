// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK
};

class LabelElement extends Element {
  LabelElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: LABEL);
}

class ButtonElement extends Element {
  ButtonElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: BUTTON, defaultStyle: _defaultStyle);
}
