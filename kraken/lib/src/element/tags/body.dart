/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String BODY = 'BODY';
final Map<String, dynamic> bodyProps = {
  'style': {
    'position': 'absolute',
    'width': '100vw',
    'overflow': 'auto',
    'backgroundColor': 'white',
  },
};

class BodyElement extends DivElement {
  BodyElement(int nodeId) : super(nodeId, bodyProps, null);
}
