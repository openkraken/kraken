/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

final String BODY = 'BODY';
final Map<String, dynamic> bodyProps = {
  'style': {
    'position': 'absolute',
    'width': '100vw',
    'height': '100vh',
    'overflow': 'auto',
  },
};

class BodyElement extends DivElement {
  BodyElement(int nodeId) : super(nodeId, bodyProps, null);
}
