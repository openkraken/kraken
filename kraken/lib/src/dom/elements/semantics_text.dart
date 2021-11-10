/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

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

class BringElement extends Element {
  BringElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _boldDefaultStyle);
}

class AbbreviationElement extends Element {
  AbbreviationElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _abbrDefaultStyle);
}

class EmphasisElement extends Element {
  EmphasisElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);
}

class CitationElement extends Element {
  CitationElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);
}

class DefinitionElement extends Element {
  DefinitionElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i
class IdiomaticElement extends Element {
  IdiomaticElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);
}

class CodeElement extends Element {
  CodeElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _codeDefaultStyle);
}

class SampleElement extends Element {
  SampleElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _codeDefaultStyle);
}

class KeyboardElement extends Element {
  KeyboardElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _codeDefaultStyle);
}

class SpanElement extends Element {
  SpanElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager);
}

class DataElement extends Element {
  DataElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager);
}

// TODO: enclosed text is a short inline quotation
class QuoteElement extends Element {
  QuoteElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager);
}

class StrongElement extends Element {
  StrongElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _boldDefaultStyle);
}

class TimeElement extends Element {
  TimeElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _boldDefaultStyle);
}

class SmallElement extends Element {
  SmallElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _smallDefaultStyle);
}

class StrikethroughElement extends Element {
  StrikethroughElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _sDefaultStyle);
}

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-u-element
class UnarticulatedElement extends Element {
  UnarticulatedElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _uDefaultStyle);
}

class VariableElement extends Element {
  VariableElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _defaultStyle);
}

class MarkElement extends Element {
  MarkElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, defaultStyle: _markDefaultStyle);
}
