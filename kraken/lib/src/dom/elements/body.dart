/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String BODY = 'BODY';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class BodyElement extends Element {
  BodyElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);

  @override
  void addEvent(String eventType) {
    // Scroll event not working on body.
    if (eventType == EVENT_SCROLL) return;
    super.addEvent(eventType);
  }
}
