/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

const String BODY = 'BODY';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class BodyElement extends Element {
  BodyElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);

  @override
  void addEventListener(String eventType, EventHandler eventHandler) {
    // Scroll event not working on body.
    if (eventType == EVENT_SCROLL) return;

    // Event of body should set to document element.
    // The render object of element which set position may be at the same level as the render object of body,
    // resulting in the failure to get events handlers.
    ownerDocument.documentElement?.addEventListener(eventType, eventHandler);
  }

  @override
  void removeEventListener(String eventType, EventHandler eventHandler) {
    ownerDocument.documentElement?.removeEventListener(eventType, eventHandler);
  }
}
