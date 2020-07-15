/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String STRONG = 'STRONG';

const Map<String, dynamic> _defaultStyle = {'display': 'inline', 'fontWeight': 'bold'};

class StrongElement extends Element {
  StrongElement({
    @required int targetId,
    @required ElementManager elementManager
  }) : super(targetId: targetId, tagName: STRONG, defaultStyle: _defaultStyle, elementManager: elementManager);
}
