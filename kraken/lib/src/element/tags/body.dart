/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String BODY = 'BODY';

Map<String, dynamic> createBodyStyle(double viewportWidth, double viewportHeight) {
  return {WIDTH: '${viewportWidth}px', HEIGHT: '${viewportHeight}px', OVERFLOW: AUTO, BACKGROUND_COLOR: 'white'};
}

class BodyElement extends Element {
  BodyElement(double viewportWidth, double viewportHeight,
      {@required int targetId, @required ElementManager elementManager})
      : super(targetId, elementManager, tagName: BODY, defaultStyle: createBodyStyle(viewportWidth, viewportHeight));
}
