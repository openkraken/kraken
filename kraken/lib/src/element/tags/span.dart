/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

const String SPAN = 'SPAN';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE
};

class SpanElement extends Element {
  SpanElement(int targetId) : super(targetId: targetId, tagName: SPAN, defaultStyle: _defaultStyle);
}
