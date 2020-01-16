/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/style.dart';

class RenderBoxModel extends RenderTransform {
  RenderBoxModel({
    RenderBox child,
    Matrix4 transform,
    Offset origin,
    this.nodeId,
    this.style,
  }) : super(
    child: child,
    transform: transform,
    origin: origin,
  );
  int nodeId;
  Style style;
}

