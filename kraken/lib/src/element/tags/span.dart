/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String SPAN = 'SPAN';

class SpanElement extends Element {
  SpanElement(
    int targetId,
    Map<String, dynamic> props,
    List<String> events,
  ) : super(
            targetId: targetId,
            tagName: SPAN,
            defaultDisplay: 'inline',
            properties: props,
            events: events);
}
