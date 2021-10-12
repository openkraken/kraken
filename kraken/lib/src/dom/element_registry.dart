/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

typedef ElementCreator = Element Function(int id, Pointer nativePtr, ElementManager elementManager);
final Map<String, ElementCreator> _elementRegistry = {};

void defineElement(String name, ElementCreator creator) {
  if (_elementRegistry.containsKey(name)) {
    throw Exception('A element with name "$name" has already been defined.');
  }
  _elementRegistry[name] = creator;
}

Element createElement(int id, Pointer nativePtr, String name, ElementManager elementManager) {
  ElementCreator? creator = _elementRegistry[name];
  if (creator == null) {
    print('ERROR: unexpected element name "$name"');
    return Element(id, nativePtr.cast<NativeElement>(), elementManager, tagName: UNKNOWN);
  }

  Element element = creator(id, nativePtr, elementManager);
  return element;
}

bool _isDefined = false;
void defineBuiltInElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  defineElement(BR, (id, nativePtr, elementManager) => BRElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(B, (id, nativePtr, elementManager) => BringElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(ABBR, (id, nativePtr, elementManager) => AbbreviationElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(EM, (id, nativePtr, elementManager) => EmphasisElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(CITE, (id, nativePtr, elementManager) => CitationElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(I, (id, nativePtr, elementManager) => IdiomaticElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(CODE, (id, nativePtr, elementManager) => CodeElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(SAMP, (id, nativePtr, elementManager) => SampleElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(STRONG, (id, nativePtr, elementManager) => StrongElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(SMALL, (id, nativePtr, elementManager) => SmallElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(S, (id, nativePtr, elementManager) => StrikethroughElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(U, (id, nativePtr, elementManager) => UnarticulatedElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(VAR, (id, nativePtr, elementManager) => VariableElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(TIME, (id, nativePtr, elementManager) => TimeElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DATA, (id, nativePtr, elementManager) => DataElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(MARK, (id, nativePtr, elementManager) => MarkElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(Q, (id, nativePtr, elementManager) => QuoteElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(KBD, (id, nativePtr, elementManager) => KeyboardElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DFN, (id, nativePtr, elementManager) => DefinitionElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(SPAN, (id, nativePtr, elementManager) => SpanElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(ANCHOR, (id, nativePtr, elementManager) => AnchorElement(id, nativePtr.cast<NativeAnchorElement>(), elementManager));
  // Content
  defineElement(PRE, (id, nativePtr, elementManager) => PreElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(PARAGRAPH, (id, nativePtr, elementManager) => ParagraphElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DIV, (id, nativePtr, elementManager) => DivElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(UL, (id, nativePtr, elementManager) => UListElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(OL, (id, nativePtr, elementManager) => OListElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(LI, (id, nativePtr, elementManager) => LIElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DL, (id, nativePtr, elementManager) => DListElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DT, (id, nativePtr, elementManager) => DTElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(DD, (id, nativePtr, elementManager) => DDElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(FIGURE, (id, nativePtr, elementManager) => FigureElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(FIGCAPTION, (id, nativePtr, elementManager) => FigureCaptionElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(BLOCKQUOTE, (id, nativePtr, elementManager) => BlockQuotationElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(TEMPLATE, (id, nativePtr, elementManager) => TemplateElement(id, nativePtr.cast<NativeElement>(), elementManager));
  // Sections
  defineElement(ADDRESS, (id, nativePtr, elementManager) => AddressElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(ARTICLE, (id, nativePtr, elementManager) => ArticleElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(ASIDE, (id, nativePtr, elementManager) => AsideElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(FOOTER, (id, nativePtr, elementManager) => FooterElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(HEADER, (id, nativePtr, elementManager) => HeaderElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(MAIN, (id, nativePtr, elementManager) => MainElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(NAV, (id, nativePtr, elementManager) => NavElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(SECTION, (id, nativePtr, elementManager) => SectionElement(id, nativePtr.cast<NativeElement>(), elementManager));
  // Headings
  defineElement(H1, (id, nativePtr, elementManager) => H1Element(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(H2, (id, nativePtr, elementManager) => H2Element(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(H3, (id, nativePtr, elementManager) => H3Element(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(H4, (id, nativePtr, elementManager) => H4Element(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(H5, (id, nativePtr, elementManager) => H5Element(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(H6, (id, nativePtr, elementManager) => H6Element(id, nativePtr.cast<NativeElement>(), elementManager));
  // Forms
  defineElement(LABEL, (id, nativePtr, elementManager) => LabelElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(BUTTON, (id, nativePtr, elementManager) => ButtonElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(INPUT, (id, nativePtr, elementManager) => InputElement(id, nativePtr.cast<NativeInputElement>(), elementManager));
  // Edits
  defineElement(DEL, (id, nativePtr, elementManager) => DelElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(INS, (id, nativePtr, elementManager) => InsElement(id, nativePtr.cast<NativeElement>(), elementManager));
  // Head
  defineElement(HEAD, (id, nativePtr, elementManager) => HeadElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(TITLE, (id, nativePtr, elementManager) => TitleElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(META, (id, nativePtr, elementManager) => MetaElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(LINK, (id, nativePtr, elementManager) => LinkElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(STYLE, (id, nativePtr, elementManager) => StyleElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(NOSCRIPT, (id, nativePtr, elementManager) => NoScriptElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(SCRIPT, (id, nativePtr, elementManager) => ScriptElement(id, nativePtr.cast<NativeElement>(), elementManager));
  // Object
  defineElement(OBJECT, (id, nativePtr, elementManager) => ObjectElement(id, nativePtr.cast<NativeObjectElement>(), elementManager));
  defineElement(PARAM, (id, nativePtr, elementManager) => ParamElement(id, nativePtr.cast<NativeElement>(), elementManager));
  // Others
  defineElement(BODY, (id, nativePtr, elementManager) => BodyElement(id, nativePtr.cast<NativeElement>(), elementManager));
  defineElement(IMAGE, (id, nativePtr, elementManager) => ImageElement(id, nativePtr.cast<NativeImgElement>(), elementManager));
  defineElement(CANVAS, (id, nativePtr, elementManager) => CanvasElement(id, nativePtr.cast<NativeCanvasElement>(), elementManager));
}
