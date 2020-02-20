/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String SPAN = 'SPAN';

class SpanElement extends Element {
  SpanElement(
    int nodeId,
    Map<String, dynamic> props,
    List<String> events,
  ) : super(
            nodeId: nodeId,
            tagName: SPAN,
            defaultDisplay: 'inline',
            properties: props,
            events: events);
}
