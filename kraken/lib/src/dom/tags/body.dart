/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:meta/meta.dart';

const String BODY = 'BODY';

class BodyElement extends Element {
  BodyElement(double viewportWidth, double viewportHeight,
      {@required int targetId, @required ElementManager elementManager})
      : super(
        targetId,
        elementManager,
        repaintSelf: true,
        tagName: BODY,
        defaultStyle: {
            WIDTH: '${viewportWidth}px',
            HEIGHT: '${viewportHeight}px',
            OVERFLOW: AUTO,
            BACKGROUND_COLOR: 'white',
          }
        );
}
