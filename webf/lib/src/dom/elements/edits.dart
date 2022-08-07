/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#demarcating_edits
const String DEL = 'DEL';
const String INS = 'INS';

const Map<String, dynamic> _insDefaultStyle = {TEXT_DECORATION: UNDERLINE};

const Map<String, dynamic> _delDefaultStyle = {TEXT_DECORATION: LINE_THROUGH};

class DelElement extends Element {
  DelElement([BindingContext? context]) : super(context, defaultStyle: _delDefaultStyle);
}

class InsElement extends Element {
  InsElement([BindingContext? context]) : super(context, defaultStyle: _insDefaultStyle);
}
