/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/element.dart';
import 'package:kraken/bridge.dart';

const String DIV = 'DIV';

class DivElement extends Element {
  DivElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager) : super(targetId, nativePtr, elementManager, tagName: DIV);
}
