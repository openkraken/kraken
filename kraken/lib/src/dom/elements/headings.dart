/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String H1 = 'H1';
const String H2 = 'H2';
const String H3 = 'H3';
const String H4 = 'H4';
const String H5 = 'H5';
const String H6 = 'H6';

const Map<String, dynamic> _h1DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '2em',  // 32px
  MARGIN_TOP: '0.67em',
  MARGIN_BOTTOM: '0.67em',
};

const Map<String, dynamic> _h2DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '1.5em', // 24px
  MARGIN_TOP: '0.83em',
  MARGIN_BOTTOM: '0.83em',
};

const Map<String, dynamic> _h3DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '1.17em', // 18.72px
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
};

const Map<String, dynamic> _h4DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '1em', // 16px
  MARGIN_TOP: '1.33em',
  MARGIN_BOTTOM: '1.33em',
};

const Map<String, dynamic> _h5DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '0.83em', // 13.28px
  MARGIN_TOP: '1.67em',
  MARGIN_BOTTOM: '1.67em',
};

const Map<String, dynamic> _h6DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '0.67em', // 10.72px
  MARGIN_TOP: '2.33em',
  MARGIN_BOTTOM: '2.33em',
};

class H1Element extends Element {
  H1Element(EventTargetContext? context)
      : super(context, defaultStyle: _h1DefaultStyle);
}

class H2Element extends Element {
  H2Element(EventTargetContext? context)
      : super(context, defaultStyle: _h2DefaultStyle);
}

class H3Element extends Element {
  H3Element(EventTargetContext? context)
      : super(context, defaultStyle: _h3DefaultStyle);
}

class H4Element extends Element {
  H4Element(EventTargetContext? context)
      : super(context, defaultStyle: _h4DefaultStyle);
}

class H5Element extends Element {
  H5Element(EventTargetContext? context)
      : super(context, defaultStyle: _h5DefaultStyle);
}

class H6Element extends Element {
  H6Element(EventTargetContext? context)
      : super(context, defaultStyle: _h6DefaultStyle);
}
