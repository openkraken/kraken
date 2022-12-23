/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
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


