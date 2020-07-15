/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String PRE = 'PRE';

const Map<String, dynamic> _defaultStyle = {
  'whiteSpace': 'pre',
};

class PreElement extends Element {
  PreElement({
    @required int targetId,
    @required ElementManager elementManager
}) : super(targetId: targetId, tagName: PRE, defaultStyle: _defaultStyle, elementManager: elementManager);
}
