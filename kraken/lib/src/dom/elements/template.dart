/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

const String TEMPLATE = 'TEMPLATE';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

class TemplateElement extends Element {
  TemplateElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}
