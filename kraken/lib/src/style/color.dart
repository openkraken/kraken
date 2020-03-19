/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ColorMixin on Node {
  RenderOpacity renderOpacity;

  RenderObject initRenderOpacity(RenderObject renderObject, StyleDeclaration style) {
    bool existsOpacity = style.contains('opacity');
    bool invisible = style['visibility'] == 'hidden';
    if (existsOpacity || invisible) {
      String opacityString = style['opacity'];
      double opacity =
          opacityString == null ? 1.0 : Number(opacityString).toDouble();
      if (invisible) {
        opacity = 0.0;
      }

      renderOpacity = RenderOpacity(
        opacity: opacity,
        child: renderObject
      );
      return invisible ?
        RenderIgnorePointer(
          child: renderOpacity,
          ignoring: true,
        ) : renderOpacity;
    } else {
      return renderObject;
    }
  }

  void updateRenderOpacity(double opacity, { RenderObjectWithChildMixin parentRenderObject }) {
    if (renderOpacity != null) {
      renderOpacity.opacity = opacity;
    } else {
      RenderObject child = parentRenderObject.child;
      parentRenderObject.child = null;

      renderOpacity = RenderOpacity(
        opacity: opacity,
        child: child,
      );

      parentRenderObject.child = opacity == 0 ?
      RenderIgnorePointer(
        child: renderOpacity,
        ignoring: true,
      ) : renderOpacity;
    }
  }
}
