/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
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

    super.addEventListener(eventType, eventHandler);
  }
}
