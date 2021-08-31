/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/dom.dart';
import 'package:flutter/rendering.dart';

const String DOCUMENT_FRAGMENT = 'DOCUMENTFRAGMENT';

class DocumentFragment extends Node {
  DocumentFragment(int targetId, nativeNodePtr, ElementManager elementManager)
      : super(NodeType.COMMENT_NODE, targetId, nativeNodePtr, elementManager, '#documentfragment');

  @override
  RenderObject? get renderer => null;
}
