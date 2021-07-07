/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

typedef ElementCreator = Element Function(int id, Pointer nativePtr, ElementManager elementManager);
final Map<String, ElementCreator> _elementRegistry = Map();

void defineElement(String type, ElementCreator creator) {
  if (_elementRegistry.containsKey(type)) {
    throw Exception('Redefined element of type: $type');
  }
  _elementRegistry[type] = creator;
}

Element createElement(int id, Pointer nativePtr, String type, ElementManager elementManager) {
  ElementCreator? creator = _elementRegistry[type];
  if (creator == null) {
    print('ERROR: unexpected element type "$type"');
    return Element(id, nativePtr.cast<NativeEventTarget>(), elementManager, tagName: UNKNOWN);
  }

  Element element = creator(id, nativePtr, elementManager);
  return element;
}

bool _isDefined = false;
void defineBuiltInElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  // defineElement(BR, (id, nativePtr, elementManager) => BRElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(B, (id, nativePtr, elementManager) => BringElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(ABBR, (id, nativePtr, elementManager) => AbbreviationElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(EM, (id, nativePtr, elementManager) => EmphasisElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(CITE, (id, nativePtr, elementManager) => CitationElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(I, (id, nativePtr, elementManager) => IdiomaticElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(CODE, (id, nativePtr, elementManager) => CodeElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(SAMP, (id, nativePtr, elementManager) => SampleElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(STRONG, (id, nativePtr, elementManager) => StrongElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(SMALL, (id, nativePtr, elementManager) => SmallElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(S, (id, nativePtr, elementManager) => StrikethroughElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(U, (id, nativePtr, elementManager) => UnarticulatedElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(VAR, (id, nativePtr, elementManager) => VariableElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(TIME, (id, nativePtr, elementManager) => TimeElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(DATA, (id, nativePtr, elementManager) => DataElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(MARK, (id, nativePtr, elementManager) => MarkElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(Q, (id, nativePtr, elementManager) => QuoteElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(KBD, (id, nativePtr, elementManager) => KeyboardElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(DFN, (id, nativePtr, elementManager) => DefinitionElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(SPAN, (id, nativePtr, elementManager) => SpanElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(ANCHOR, (id, nativePtr, elementManager) => AnchorElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Content
  // defineElement(PRE, (id, nativePtr, elementManager) => PreElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(PARAGRAPH, (id, nativePtr, elementManager) => ParagraphElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  defineElement(DIV, (id, nativePtr, elementManager) => DivElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(UL, (id, nativePtr, elementManager) => UListElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(OL, (id, nativePtr, elementManager) => OListElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(LI, (id, nativePtr, elementManager) => LIElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(DL, (id, nativePtr, elementManager) => DListElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(DT, (id, nativePtr, elementManager) => DTElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(DD, (id, nativePtr, elementManager) => DDElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(FIGURE, (id, nativePtr, elementManager) => FigureElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(FIGCAPTION, (id, nativePtr, elementManager) => FigureCaptionElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(BLOCKQUOTE, (id, nativePtr, elementManager) => BlockQuotationElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Sections
  // defineElement(ADDRESS, (id, nativePtr, elementManager) => AddressElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(ARTICLE, (id, nativePtr, elementManager) => ArticleElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(ASIDE, (id, nativePtr, elementManager) => AsideElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(FOOTER, (id, nativePtr, elementManager) => FooterElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(HEADER, (id, nativePtr, elementManager) => HeaderElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(MAIN, (id, nativePtr, elementManager) => MainElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(NAV, (id, nativePtr, elementManager) => NavElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(SECTION, (id, nativePtr, elementManager) => SectionElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Headings
  // defineElement(H1, (id, nativePtr, elementManager) => H1Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(H2, (id, nativePtr, elementManager) => H2Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(H3, (id, nativePtr, elementManager) => H3Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(H4, (id, nativePtr, elementManager) => H4Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(H5, (id, nativePtr, elementManager) => H5Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(H6, (id, nativePtr, elementManager) => H6Element(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Forms
  // defineElement(LABEL, (id, nativePtr, elementManager) => LabelElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(BUTTON, (id, nativePtr, elementManager) => ButtonElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(INPUT, (id, nativePtr, elementManager) => InputElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Edits
  // defineElement(DEL, (id, nativePtr, elementManager) => DelElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(INS, (id, nativePtr, elementManager) => InsElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Metadata
  // defineElement(SCRIPT, (id, nativePtr, elementManager) => ScriptElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // // Others
  // defineElement(BODY, (id, nativePtr, elementManager) => BodyElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(HEAD, (id, nativePtr, elementManager) => HeadElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(IMAGE, (id, nativePtr, elementManager) => ImageElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(CANVAS, (id, nativePtr, elementManager) => CanvasElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
  // defineElement(OBJECT, (id, nativePtr, elementManager) => ObjectElement(id, nativePtr.cast<NativeEventTarget>(), elementManager));
}
