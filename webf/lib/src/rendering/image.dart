/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui' as ui show Image;
import 'package:flutter/rendering.dart';

class WebFRenderImage extends RenderImage {
  WebFRenderImage({
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
