/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String TEXTAREA = 'TEXTAREA';

/// https://www.w3.org/TR/css-sizing-3/#intrinsic-sizes
/// For boxes without a preferred aspect ratio:
/// If the available space is definite in the appropriate dimension, use the stretch fit into that size in that dimension.
///
/// Otherwise, if the box has a <length> as its computed minimum size (min-width/min-height) in that dimension, use that size.
//
/// Otherwise, use 300px for the width and/or 150px for the height as needed.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

// @TODO Implement textarea attributes and multiline editing for textarea.
class TextareaElement extends InputElement {
  TextareaElement(EventTargetContext? context)
    : super(context, defaultStyle: _defaultStyle, isIntrinsicBox: true);
  static TextareaElement? focusInputElement;
}

