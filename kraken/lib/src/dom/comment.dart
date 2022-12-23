/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

class Comment extends Node {
  Comment([context]) : super(NodeType.COMMENT_NODE, context);

  @override
  String get nodeName => '#comment';

  @override
  RenderBox? get renderer => null;

  // @TODO: Get data from bridge side.
  String get data => '';

  int get length => data.length;
}
