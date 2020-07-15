/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String BODY = 'BODY';

final Map<String, dynamic> _defaultStyle = {
  'width': '100vw',
  'height': '100vh',
  'overflow': 'auto',
  'backgroundColor': 'white'
};

class BodyElement extends Element {
  BodyElement({@required int targetId, @required ElementManager elementManager}) : super(targetId: targetId, tagName: BODY, defaultStyle: _defaultStyle, elementManager: elementManager);
}
