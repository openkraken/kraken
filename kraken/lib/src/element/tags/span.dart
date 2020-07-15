/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String SPAN = 'SPAN';

const Map<String, dynamic> _defaultStyle = {'display': 'inline'};

class SpanElement extends Element {
  SpanElement(int targetId, ElementManager elementManager)
      : super(targetId, elementManager, tagName: SPAN, defaultStyle: _defaultStyle);
}
