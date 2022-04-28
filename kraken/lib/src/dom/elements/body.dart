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
    // UAs must apply the overflow-* values set on the root element to the viewport when the root element’s display value is not none.
    // However, when the root element is an [HTML] html element (including XML syntax for HTML) whose overflow value is visible (in both axes),
    // and that element has as a child a body element whose display value is also not none,
    // user agents must instead apply the overflow-* values of the first such child element to the viewport.
    // The element from which the value is propagated must then have a used overflow value of visible.
    // https://drafts.csswg.org/css-overflow-3/#overflow-propagation
    if (property == OVERFLOW || property == OVERFLOW_X || property == OVERFLOW_Y) {
      ownerDocument.documentElement?.setRenderStyle(property, present);
    }
    super.setRenderStyle(property, present);
  }
}
