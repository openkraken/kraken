/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';

const String PREFORMATTED = 'PRE';

const Map<String, dynamic> _defaultStyle = {
  'whiteSpace': 'pre'
};

class PreElement extends Element {
  PreElement(
    int targetId
  ) : super(
        targetId: targetId,
        tagName: PREFORMATTED,
        defaultStyle: _defaultStyle
      );
}
