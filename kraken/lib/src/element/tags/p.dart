/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';

const String PARAGRAPH = 'P';

class ParagraphElement extends Element {
  ParagraphElement(
    int nodeId,
    Map<String, dynamic> props,
    List<String> events,
  ) : super(
            nodeId: nodeId,
            tagName: PARAGRAPH,
            defaultDisplay: 'block',
            properties: props,
            events: events);
}
