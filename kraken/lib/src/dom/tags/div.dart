/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

const String DIV = 'DIV';

class DivElement extends Element {
  DivElement(int targetId, Pointer<NativeDivElement> nativePtr, ElementManager elementManager) : super(targetId, nativePtr.ref.nativeElement, elementManager, tagName: DIV);
}
