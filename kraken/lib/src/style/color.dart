/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin ColorMixin on Node {
  RenderOpacity renderOpacity;

  RenderObject initRenderOpacity(RenderObject renderObject, Style style) {
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

  void updateRenderOpacity(Style style, Style newStyle,
      {RenderObjectWithChildMixin rootRenderObject, RenderDecoratedBox childRenderObject}) {

    String oldVisibility = style['visibility'] ?? 'visible';
    String newVisibility = newStyle['visibility'] ?? 'visible';

    if (newVisibility != oldVisibility) { // visibility change
      rootRenderObject.child = null;
      rootRenderObject.child = initRenderOpacity(childRenderObject, newStyle);
    } else { // opacity change
      bool existsOpacity = newStyle.contains('opacity');
      bool invisible = newStyle['visibility'] == 'hidden';
      if (existsOpacity || invisible) {
        String opacityString = newStyle['opacity'];
        double opacity =
            opacityString == null ? 1.0 : Number(opacityString).toDouble();
        if (invisible) {
          opacity = 0.0;
        }

        if (renderOpacity != null) {
          renderOpacity.opacity = opacity;
        } else {
          RenderObject child = rootRenderObject.child;
          rootRenderObject.child = null;

          renderOpacity = RenderOpacity(
            opacity: opacity,
            child: child,
          );
          rootRenderObject.child = invisible ?
            RenderIgnorePointer(
              child: renderOpacity,
              ignoring: true,
            ) : renderOpacity;
        }
      } else {
        // Set opacity to 1.0 if exists.
        if (renderOpacity != null) {
          renderOpacity.opacity = 1.0;
        }
      }
    }
  }
}
