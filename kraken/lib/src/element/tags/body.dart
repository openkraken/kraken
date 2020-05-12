/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String BODY = 'BODY';
final Map<String, dynamic> bodyProps = {
  'style': {
    'width': '100vw',
    'height': '100vh',
    'overflow': 'auto',
    'backgroundColor': 'white',
  },
};

class BodyElement extends DivElement {
  BodyElement(int targetId) : super(targetId, bodyProps, null);
}
