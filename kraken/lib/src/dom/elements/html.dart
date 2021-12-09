/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String HTML = 'HTML';
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class HTMLElement extends Element {
  static Map<String, dynamic> defaultStyle = _defaultStyle;
  HTMLElement(EventTargetContext? context)
      : super(context, defaultStyle: defaultStyle);

  @override
  void addEvent(String eventType) {
    // Scroll event not working on html.
    if (eventType == EVENT_SCROLL) return;
    super.addEvent(eventType);
  }
}
