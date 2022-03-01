/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String INPUT = 'INPUT';
const String SIZE = 'size';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class InputElement extends TextFormControlElement {
  InputElement(EventTargetContext? context)
    : super(context, defaultStyle: _defaultStyle, isIntrinsicBox: true);

  @override
  double? get defaultWidth {
    // size defaults to 20.
    // https://html.spec.whatwg.org/multipage/input.html#attr-input-size
    return avgCharWidth * double.parse(properties[SIZE] ?? '20');
  }
}

