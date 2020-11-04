/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

const String STRONG = 'STRONG';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE, FONT_WEIGHT: BOLD};

class StrongElement extends Element {
  StrongElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: STRONG, defaultStyle: _defaultStyle);
}
