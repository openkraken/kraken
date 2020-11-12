/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/dom.dart';

import 'dart:ffi';
import 'package:kraken/bridge.dart';

const String PARAGRAPH = 'P';

class ParagraphElement extends Element {
  ParagraphElement(int targetId, Pointer<NativeParagraphElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr.ref.nativeElement, elementManager, tagName: PARAGRAPH);
}
