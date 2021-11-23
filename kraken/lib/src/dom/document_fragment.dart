/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

const String DOCUMENT_FRAGMENT = 'DOCUMENTFRAGMENT';

class DocumentFragment extends Node {
  DocumentFragment(int targetId, nativeNodePtr, ElementManager elementManager)
      : super(NodeType.COMMENT_NODE, targetId, nativeNodePtr, elementManager);

  @override
  String get nodeName => '#documentfragment';

  @override
  RenderBox? get renderer => null;
}
