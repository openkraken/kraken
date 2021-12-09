/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK
};

class LabelElement extends Element {
  LabelElement(EventTargetContext? context)
      : super(context);
}

class ButtonElement extends Element {
  ButtonElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}
