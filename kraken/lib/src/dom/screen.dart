/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:kraken/foundation.dart';

// As its name suggests, the Screen interface represents information about the screen of the output device.
// https://drafts.csswg.org/cssom-view/#the-screen-interface
class Screen extends BindingObject {
  Screen([BindingContext? context]) : super(context);

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'availWidth': return availWidth;
      case 'availHeight': return availHeight;
      case 'width': return width;
      case 'height': return height;
      default: return super.getBindingProperty(key);
    }
  }

  // The availWidth attribute must return the width of the Web-exposed available screen area.
  // The Web-exposed available screen area is one of the following:
  //   - The available area of the rendering surface of the output device, in CSS pixels.
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  // @NOTE: Why using physicalSize: in most cases, kraken is integrated into host native app,
  //        so the size of kraken view is depending on how big is the flutter view, for users
  //        they can not adjust size of kraken view. The [window.physicalSize] is the size of
  //        native flutter view. (@zeroling)
  int get availWidth => window.physicalSize.width ~/ window.devicePixelRatio;

  // The availHeight attribute must return the height of the Web-exposed available screen area.
  int get availHeight => window.physicalSize.height ~/ window.devicePixelRatio;

  // The width attribute must return the width of the Web-exposed screen area.
  // The Web-exposed screen area is one of the following:
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  int get width => window.physicalSize.width ~/ window.devicePixelRatio;

  // The height attribute must return the height of the Web-exposed screen area.
  int get height => window.physicalSize.height ~/ window.devicePixelRatio;
}
