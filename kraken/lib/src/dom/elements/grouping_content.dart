/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#text_content
const String UL = 'UL';
const String OL = 'OL';
const String LI = 'LI';
const String DL = 'DL';
const String DT = 'DT';
const String DD = 'DD';
const String FIGURE = 'FIGURE';
const String FIGCAPTION = 'FIGCAPTION';
const String BLOCKQUOTE = 'BLOCKQUOTE';
const String PRE = 'PRE';
const String PARAGRAPH = 'P';
const String DIV = 'DIV';
// TODO: <hr> element

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

const Map<String, dynamic> _preDefaultStyle = {
  DISPLAY: BLOCK,
  WHITE_SPACE: 'pre',
};

const Map<String, dynamic> _bDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
  MARGIN_LEFT: '40px',
  MARGIN_RIGHT: '40px'
};

const Map<String, dynamic> _ddDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_LEFT: '40px',
};

const Map<String, dynamic> _pDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em'
};

const Map<String, dynamic> _lDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
  PADDING_LEFT: '40px'
};


class DivElement extends Element {
  DivElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class FigureElement extends Element {
  FigureElement(EventTargetContext? context)
      : super(context, defaultStyle: _bDefaultStyle);
}

class FigureCaptionElement extends Element {
  FigureCaptionElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class BlockQuotationElement extends Element {
  BlockQuotationElement(EventTargetContext? context)
      : super(context, defaultStyle: _bDefaultStyle);
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlparagraphelement
class ParagraphElement extends Element {
  static Map<String, dynamic> defaultStyle = _pDefaultStyle;
  ParagraphElement(EventTargetContext? context)
      : super(context, defaultStyle: defaultStyle);
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlulistelement
class UListElement extends Element {
  UListElement(EventTargetContext? context)
      : super(context, defaultStyle: _lDefaultStyle);
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlolistelement
class OListElement extends Element {
  OListElement(EventTargetContext? context)
      : super(context, defaultStyle: _lDefaultStyle);
}

class LIElement extends Element {
  LIElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlpreelement
class PreElement extends Element {
  PreElement(EventTargetContext? context)
      : super(context, defaultStyle: _preDefaultStyle);
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dd
class DDElement extends Element {
  DDElement(EventTargetContext? context)
      : super(context, defaultStyle: _ddDefaultStyle);
}

class DTElement extends Element {
  DTElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmldlistelement
class DListElement extends Element {
  DListElement(EventTargetContext? context)
      : super(context, defaultStyle: _pDefaultStyle);
}
