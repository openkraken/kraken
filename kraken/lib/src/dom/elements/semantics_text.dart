/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#inline_text_semantics
const String SPAN = 'SPAN';
const String B = 'B';
const String ABBR = 'ABBR';
const String EM = 'EM';
const String CITE = 'CITE';
const String I = 'I';
const String CODE = 'CODE';
const String SAMP = 'SAMP';
const String STRONG = 'STRONG';
const String SMALL = 'SMALL';
const String S = 'S';
const String U = 'U';
const String VAR = 'VAR';
const String TIME = 'TIME';
const String DATA = 'DATA';
const String MARK = 'MARK';
const String Q = 'Q';
const String KBD = 'KBD';
const String DFN = 'DFN';
const String BR = 'BR';

const Map<String, dynamic> _uDefaultStyle = {
  TEXT_DECORATION: UNDERLINE
};

const Map<String, dynamic> _sDefaultStyle = {
  TEXT_DECORATION: LINE_THROUGH
};

const Map<String, dynamic> _smallDefaultStyle = {
  FONT_SIZE: SMALLER
};

const Map<String, dynamic> _codeDefaultStyle = {
  FONT_FAMILY: 'monospace'
};

const Map<String, dynamic> _boldDefaultStyle = {
  FONT_WEIGHT: BOLD
};

const Map<String, dynamic> _abbrDefaultStyle = {
  TEXT_DECORATION_LINE: UNDERLINE,
  TEXT_DECORATION_STYLE: DOTTED,
};

const Map<String, dynamic> _markDefaultStyle = {
  BACKGROUND_COLOR: 'yellow',
  COLOR: 'black'
};

const Map<String, dynamic> _defaultStyle = {
  FONT_STYLE: ITALIC
};

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  RenderLineBreak? _renderLineBreak;

  BRElement(EventTargetContext? context)
      : super(context, isIntrinsicBox: true);

  @override
  RenderBoxModel? get renderBoxModel => _renderLineBreak;

  @override
  void setRenderStyle(String property, String present) {
    // Noop
  }

  @override
  RenderBox createRenderer() {
    return _renderLineBreak ??= RenderLineBreak(renderStyle);
  }
}

class BringElement extends Element {
  BringElement(EventTargetContext? context)
      : super(context, defaultStyle: _boldDefaultStyle);
}

class AbbreviationElement extends Element {
  AbbreviationElement(EventTargetContext? context)
      : super(context, defaultStyle: _abbrDefaultStyle);
}

class EmphasisElement extends Element {
  EmphasisElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class CitationElement extends Element {
  CitationElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class DefinitionElement extends Element {
  DefinitionElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i
class IdiomaticElement extends Element {
  IdiomaticElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class CodeElement extends Element {
  CodeElement(EventTargetContext? context)
      : super(context, defaultStyle: _codeDefaultStyle);
}

class SampleElement extends Element {
  SampleElement(EventTargetContext? context)
      : super(context, defaultStyle: _codeDefaultStyle);
}

class KeyboardElement extends Element {
  KeyboardElement(EventTargetContext? context)
      : super(context, defaultStyle: _codeDefaultStyle);
}

class SpanElement extends Element {
  SpanElement(EventTargetContext? context)
      : super(context);
}

class DataElement extends Element {
  DataElement(EventTargetContext? context)
      : super(context);
}

// TODO: enclosed text is a short inline quotation
class QuoteElement extends Element {
  QuoteElement(EventTargetContext? context)
      : super(context);
}

class StrongElement extends Element {
  StrongElement(EventTargetContext? context)
      : super(context, defaultStyle: _boldDefaultStyle);
}

class TimeElement extends Element {
  TimeElement(EventTargetContext? context)
      : super(context, defaultStyle: _boldDefaultStyle);
}

class SmallElement extends Element {
  SmallElement(EventTargetContext? context)
      : super(context, defaultStyle: _smallDefaultStyle);
}

class StrikethroughElement extends Element {
  StrikethroughElement(EventTargetContext? context)
      : super(context, defaultStyle: _sDefaultStyle);
}

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-u-element
class UnarticulatedElement extends Element {
  UnarticulatedElement(EventTargetContext? context)
      : super(context, defaultStyle: _uDefaultStyle);
}

class VariableElement extends Element {
  VariableElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class MarkElement extends Element {
  MarkElement(EventTargetContext? context)
      : super(context, defaultStyle: _markDefaultStyle);
}
