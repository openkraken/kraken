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

  @override
  void setRenderStyle(String property, String present) {
    // The overflow of body should apply to html.
    // https://drafts.csswg.org/css-overflow-3/#overflow-propagation
    if (property == OVERFLOW || property == OVERFLOW_X || property == OVERFLOW_Y) {
      ownerDocument.documentElement?.setRenderStyle(property, present);
    }
    super.setRenderStyle(property, present);
  }
}
