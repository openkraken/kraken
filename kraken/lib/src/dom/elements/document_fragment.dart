/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

const String DOCUMENT_FRAGMENT = 'DOCUMENTFRAGMENT';

class DocumentFragmentElement extends Element {
  DocumentFragmentElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: DOCUMENT_FRAGMENT);
}
