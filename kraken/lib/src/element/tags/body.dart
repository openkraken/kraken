/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

const String BODY = 'BODY';

final Map<String, dynamic> _defaultStyle = {
  WIDTH: '100vw',
  HEIGHT: '100vh',
  OVERFLOW: AUTO,
  BACKGROUND_COLOR: 'white'
};

class BodyElement extends Element {
  BodyElement(int targetId) : super(targetId: targetId, tagName: BODY, defaultStyle: _defaultStyle);
}
