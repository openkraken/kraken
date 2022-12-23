/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK
};

class LabelElement extends Element {
  LabelElement([BindingContext? context])
      : super(context);
}

class ButtonElement extends Element {
  ButtonElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}
