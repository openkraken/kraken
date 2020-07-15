/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';

const String PRE = 'PRE';

const Map<String, dynamic> _defaultStyle = {
  'whiteSpace': 'pre',
};

class PreElement extends Element {
  PreElement(targetId, ElementManager elementManager)
      : super(targetId, elementManager, tagName: PRE, defaultStyle: _defaultStyle);
}
