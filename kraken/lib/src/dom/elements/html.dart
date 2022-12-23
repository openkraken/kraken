/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

const String HTML = 'HTML';
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class HTMLElement extends Element {
  static Map<String, dynamic> defaultStyle = _defaultStyle;
  HTMLElement([BindingContext? context])
      : super(context, defaultStyle: defaultStyle);

  @override
  void dispatchEvent(Event event) {
    // Scroll event proxy to document.
    if (event.type == EVENT_SCROLL) {
      // https://www.w3.org/TR/2014/WD-DOM-Level-3-Events-20140925/#event-type-scroll
      // When dispatched on the Document element, this event type must bubble to the Window object.
      event.bubbles = true;
      ownerDocument.dispatchEvent(event);
      return;
    }
    super.dispatchEvent(event);
  }
}
