/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' as ui show Image;
import 'package:flutter/rendering.dart';

class KrakenRenderImage extends RenderImage {
  KrakenRenderImage({
    ui.Image? image,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
  }) : super(
    image: image,
    fit: fit,
    alignment: alignment,
  );

  @override
  void performLayout() {
    Size trySize = constraints.biggest;
    size = trySize.isInfinite ? constraints.smallest : trySize;
  }
}


