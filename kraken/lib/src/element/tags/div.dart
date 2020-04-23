/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String DIV = 'DIV';

class DivElement extends Element {
  DivElement(int targetId, Map<String, dynamic> props, List<String> events)
      : super(
          targetId: targetId,
          defaultDisplay: 'block',
          tagName: DIV,
          properties: props,
          events: events,
        );
}
