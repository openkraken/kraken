/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin ColorMixin on Node {
  RenderOpacity renderOpacity;

  RenderObject initRenderOpacity(RenderObject renderObject, Style style) {
    bool existsOpacity = style.contains('opacity');
    String opacityString = style['opacity'];
    double opacity =
        opacityString == null ? 1.0 : Number(opacityString).toDouble();
    if (existsOpacity) {
      renderOpacity = RenderOpacity(opacity: opacity, child: renderObject);
      return renderOpacity;
    } else {
      return renderObject;
    }
  }

  void updateRenderOpacity(Style style,
      {RenderBoxModel rootRenderObject}) {
    if (style.contains('opacity')) {
      String opacityString = style['opacity'];
      double opacity =
          opacityString == null ? 1.0 : Number(opacityString).toDouble();
      if (renderOpacity != null) {
        renderOpacity.opacity = opacity;
      } else {
        rootRenderObject.child = renderOpacity = RenderOpacity(
          opacity: opacity,
          child: rootRenderObject.child,
        );
      }
    } else {
      // Set opacity to 1.0 if exists.
      if (renderOpacity != null) {
        renderOpacity.opacity = 1.0;
      }
    }
  }
}
