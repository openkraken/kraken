/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#demarcating_edits
const String DEL = 'DEL';
const String INS = 'INS';

const Map<String, dynamic> _insDefaultStyle = {
  TEXT_DECORATION: UNDERLINE
};

const Map<String, dynamic> _delDefaultStyle = {
  TEXT_DECORATION: LINE_THROUGH
};

class DelElement extends Element {
  DelElement([BindingContext? context])
      : super(context, defaultStyle: _delDefaultStyle);
}

class InsElement extends Element {
  InsElement([BindingContext? context])
      : super(context, defaultStyle: _insDefaultStyle);
}
