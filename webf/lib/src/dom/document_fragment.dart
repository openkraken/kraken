/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

const String DOCUMENT_FRAGMENT = 'DOCUMENTFRAGMENT';

class DocumentFragment extends Node {
  DocumentFragment([context]) : super(NodeType.COMMENT_NODE, context);

  @override
  String get nodeName => '#documentfragment';

  @override
  RenderBox? get renderer => null;
}
