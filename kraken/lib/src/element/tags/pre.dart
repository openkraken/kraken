/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

const String PRE = 'PRE';

const Map<String, dynamic> _defaultStyle = {
  WHITE_SPACE: 'pre',
};

class PreElement extends Element {
  PreElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: PRE, defaultStyle: _defaultStyle);
}
