/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

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
  DelElement(EventTargetContext? context)
      : super(context, defaultStyle: _delDefaultStyle);
}

class InsElement extends Element {
  InsElement(EventTargetContext? context)
      : super(context, defaultStyle: _insDefaultStyle);
}
