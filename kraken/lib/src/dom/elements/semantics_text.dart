// /*
//  * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
//  * Author: Kraken Team.
//  */
//
// import 'dart:ffi';
// import 'package:kraken/bridge.dart';
// import 'package:kraken/css.dart';
// import 'package:kraken/dom.dart';
//
// // https://developer.mozilla.org/en-US/docs/Web/HTML/Element#inline_text_semantics
// const String SPAN = 'SPAN';
// const String B = 'B';
// const String ABBR = 'ABBR';
// const String EM = 'EM';
// const String CITE = 'CITE';
// const String I = 'I';
// const String CODE = 'CODE';
// const String SAMP = 'SAMP';
// const String STRONG = 'STRONG';
// const String SMALL = 'SMALL';
// const String S = 'S';
// const String U = 'U';
// const String VAR = 'VAR';
// const String TIME = 'TIME';
// const String DATA = 'DATA';
// const String MARK = 'MARK';
// const String Q = 'Q';
// const String KBD = 'KBD';
// const String DFN = 'DFN';
// const String BR = 'BR';
//
// // HACK: current use block layout make text force line break
// const Map<String, dynamic> _breakDefaultStyle = {
//   DISPLAY: BLOCK,
// };
//
// const Map<String, dynamic> _uDefaultStyle = {
//   TEXT_DECORATION: UNDERLINE
// };
//
// const Map<String, dynamic> _sDefaultStyle = {
//   TEXT_DECORATION: LINE_THROUGH
// };
//
// const Map<String, dynamic> _smallDefaultStyle = {
//   FONT_SIZE: SMALLER
// };
//
// const Map<String, dynamic> _codeDefaultStyle = {
//   FONT_FAMILY: 'monospace'
// };
//
// const Map<String, dynamic> _boldDefaultStyle = {
//   FONT_WEIGHT: BOLD
// };
//
// const Map<String, dynamic> _abbrDefaultStyle = {
//   TEXT_DECORATION_LINE: UNDERLINE,
//   TEXT_DECORATION_STYLE: DOTTED,
// };
//
// const Map<String, dynamic> _markDefaultStyle = {
//   BACKGROUND_COLOR: 'yellow',
//   COLOR: 'black'
// };
//
// const Map<String, dynamic> _defaultStyle = {
//   FONT_STYLE: ITALIC
// };
//
// // https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
// class BRElement extends Element {
//   BRElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(
//         targetId, nativePtr, elementManager,
//         tagName: BR,
//         defaultStyle: _breakDefaultStyle,
//         isIntrinsicBox: true,
//       );
// }
//
// class BringElement extends Element {
//   BringElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: B, defaultStyle: _boldDefaultStyle);
// }
//
// class AbbreviationElement extends Element {
//   AbbreviationElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: ABBR, defaultStyle: _abbrDefaultStyle);
// }
//
// class EmphasisElement extends Element {
//   EmphasisElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: EM, defaultStyle: _defaultStyle);
// }
//
// class CitationElement extends Element {
//   CitationElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: CITE, defaultStyle: _defaultStyle);
// }
//
// class DefinitionElement extends Element {
//   DefinitionElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: DFN, defaultStyle: _defaultStyle);
// }
//
// // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i
// class IdiomaticElement extends Element {
//   IdiomaticElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: I, defaultStyle: _defaultStyle);
// }
//
// class CodeElement extends Element {
//   CodeElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: CODE, defaultStyle: _codeDefaultStyle);
// }
//
// class SampleElement extends Element {
//   SampleElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: SAMP, defaultStyle: _codeDefaultStyle);
// }
//
// class KeyboardElement extends Element {
//   KeyboardElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: KBD, defaultStyle: _codeDefaultStyle);
// }
//
// class SpanElement extends Element {
//   SpanElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: SPAN);
// }
//
// class DataElement extends Element {
//   DataElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: DATA);
// }
//
// // TODO: enclosed text is a short inline quotation
// class QuoteElement extends Element {
//   QuoteElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: Q);
// }
//
// class StrongElement extends Element {
//   StrongElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: STRONG, defaultStyle: _boldDefaultStyle);
// }
//
// class TimeElement extends Element {
//   TimeElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: TIME, defaultStyle: _boldDefaultStyle);
// }
//
// class SmallElement extends Element {
//   SmallElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: SMALL, defaultStyle: _smallDefaultStyle);
// }
//
// class StrikethroughElement extends Element {
//   StrikethroughElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: S, defaultStyle: _sDefaultStyle);
// }
//
// // https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-u-element
// class UnarticulatedElement extends Element {
//   UnarticulatedElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: U, defaultStyle: _uDefaultStyle);
// }
//
// class VariableElement extends Element {
//   VariableElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: VAR, defaultStyle: _defaultStyle);
// }
//
// class MarkElement extends Element {
//   MarkElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
//       : super(targetId, nativePtr, elementManager, tagName: MARK, defaultStyle: _markDefaultStyle);
// }
