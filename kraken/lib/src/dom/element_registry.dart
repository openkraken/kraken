/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

final Map<String, ElementCreator> _elementRegistry = {};

void defineElement(String name, ElementCreator creator) {
  name = name.toUpperCase();
  if (_elementRegistry.containsKey(name)) {
    throw Exception('A element with name "$name" has already been defined.');
  }
  _elementRegistry[name] = creator;
}

Element createElement(int id, Pointer<NativeEventTarget> nativePtr, String name, ElementManager elementManager) {
  ElementCreator? creator = _elementRegistry[name];
  if (creator == null) {
    print('ERROR: unexpected element type "$name"');
    return Element(id, nativePtr, elementManager);
  }

  Element element = creator(id, nativePtr, elementManager);
  // Assign tagName, used by inspector.
  element.tagName = name;
  return element;
}

bool _isDefined = false;
void defineBuiltInElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  defineElement(BR, (id, nativePtr, elementManager) => BRElement(id, nativePtr, elementManager));
  defineElement(B, (id, nativePtr, elementManager) => BringElement(id, nativePtr, elementManager));
  defineElement(ABBR, (id, nativePtr, elementManager) => AbbreviationElement(id, nativePtr, elementManager));
  defineElement(EM, (id, nativePtr, elementManager) => EmphasisElement(id, nativePtr, elementManager));
  defineElement(CITE, (id, nativePtr, elementManager) => CitationElement(id, nativePtr, elementManager));
  defineElement(I, (id, nativePtr, elementManager) => IdiomaticElement(id, nativePtr, elementManager));
  defineElement(CODE, (id, nativePtr, elementManager) => CodeElement(id, nativePtr, elementManager));
  defineElement(SAMP, (id, nativePtr, elementManager) => SampleElement(id, nativePtr, elementManager));
  defineElement(STRONG, (id, nativePtr, elementManager) => StrongElement(id, nativePtr, elementManager));
  defineElement(SMALL, (id, nativePtr, elementManager) => SmallElement(id, nativePtr, elementManager));
  defineElement(S, (id, nativePtr, elementManager) => StrikethroughElement(id, nativePtr, elementManager));
  defineElement(U, (id, nativePtr, elementManager) => UnarticulatedElement(id, nativePtr, elementManager));
  defineElement(VAR, (id, nativePtr, elementManager) => VariableElement(id, nativePtr, elementManager));
  defineElement(TIME, (id, nativePtr, elementManager) => TimeElement(id, nativePtr, elementManager));
  defineElement(DATA, (id, nativePtr, elementManager) => DataElement(id, nativePtr, elementManager));
  defineElement(MARK, (id, nativePtr, elementManager) => MarkElement(id, nativePtr, elementManager));
  defineElement(Q, (id, nativePtr, elementManager) => QuoteElement(id, nativePtr, elementManager));
  defineElement(KBD, (id, nativePtr, elementManager) => KeyboardElement(id, nativePtr, elementManager));
  defineElement(DFN, (id, nativePtr, elementManager) => DefinitionElement(id, nativePtr, elementManager));
  defineElement(SPAN, (id, nativePtr, elementManager) => SpanElement(id, nativePtr, elementManager));
  defineElement(ANCHOR, (id, nativePtr, elementManager) => AnchorElement(id, nativePtr, elementManager));
  // Content
  defineElement(PRE, (id, nativePtr, elementManager) => PreElement(id, nativePtr, elementManager));
  defineElement(PARAGRAPH, (id, nativePtr, elementManager) => ParagraphElement(id, nativePtr, elementManager));
  defineElement(DIV, (id, nativePtr, elementManager) => DivElement(id, nativePtr, elementManager));
  defineElement(UL, (id, nativePtr, elementManager) => UListElement(id, nativePtr, elementManager));
  defineElement(OL, (id, nativePtr, elementManager) => OListElement(id, nativePtr, elementManager));
  defineElement(LI, (id, nativePtr, elementManager) => LIElement(id, nativePtr, elementManager));
  defineElement(DL, (id, nativePtr, elementManager) => DListElement(id, nativePtr, elementManager));
  defineElement(DT, (id, nativePtr, elementManager) => DTElement(id, nativePtr, elementManager));
  defineElement(DD, (id, nativePtr, elementManager) => DDElement(id, nativePtr, elementManager));
  defineElement(FIGURE, (id, nativePtr, elementManager) => FigureElement(id, nativePtr, elementManager));
  defineElement(FIGCAPTION, (id, nativePtr, elementManager) => FigureCaptionElement(id, nativePtr, elementManager));
  defineElement(BLOCKQUOTE, (id, nativePtr, elementManager) => BlockQuotationElement(id, nativePtr, elementManager));
  defineElement(TEMPLATE, (id, nativePtr, elementManager) => TemplateElement(id, nativePtr, elementManager));
  // Sections
  defineElement(ADDRESS, (id, nativePtr, elementManager) => AddressElement(id, nativePtr, elementManager));
  defineElement(ARTICLE, (id, nativePtr, elementManager) => ArticleElement(id, nativePtr, elementManager));
  defineElement(ASIDE, (id, nativePtr, elementManager) => AsideElement(id, nativePtr, elementManager));
  defineElement(FOOTER, (id, nativePtr, elementManager) => FooterElement(id, nativePtr, elementManager));
  defineElement(HEADER, (id, nativePtr, elementManager) => HeaderElement(id, nativePtr, elementManager));
  defineElement(MAIN, (id, nativePtr, elementManager) => MainElement(id, nativePtr, elementManager));
  defineElement(NAV, (id, nativePtr, elementManager) => NavElement(id, nativePtr, elementManager));
  defineElement(SECTION, (id, nativePtr, elementManager) => SectionElement(id, nativePtr, elementManager));
  // Headings
  defineElement(H1, (id, nativePtr, elementManager) => H1Element(id, nativePtr, elementManager));
  defineElement(H2, (id, nativePtr, elementManager) => H2Element(id, nativePtr, elementManager));
  defineElement(H3, (id, nativePtr, elementManager) => H3Element(id, nativePtr, elementManager));
  defineElement(H4, (id, nativePtr, elementManager) => H4Element(id, nativePtr, elementManager));
  defineElement(H5, (id, nativePtr, elementManager) => H5Element(id, nativePtr, elementManager));
  defineElement(H6, (id, nativePtr, elementManager) => H6Element(id, nativePtr, elementManager));
  // Forms
  defineElement(LABEL, (id, nativePtr, elementManager) => LabelElement(id, nativePtr, elementManager));
  defineElement(BUTTON, (id, nativePtr, elementManager) => ButtonElement(id, nativePtr, elementManager));
  defineElement(INPUT, (id, nativePtr, elementManager) => InputElement(id, nativePtr, elementManager));
  // Edits
  defineElement(DEL, (id, nativePtr, elementManager) => DelElement(id, nativePtr, elementManager));
  defineElement(INS, (id, nativePtr, elementManager) => InsElement(id, nativePtr, elementManager));
  // Head
  defineElement(HEAD, (id, nativePtr, elementManager) => HeadElement(id, nativePtr, elementManager));
  defineElement(TITLE, (id, nativePtr, elementManager) => TitleElement(id, nativePtr, elementManager));
  defineElement(META, (id, nativePtr, elementManager) => MetaElement(id, nativePtr, elementManager));
  defineElement(LINK, (id, nativePtr, elementManager) => LinkElement(id, nativePtr, elementManager));
  defineElement(STYLE, (id, nativePtr, elementManager) => StyleElement(id, nativePtr, elementManager));
  defineElement(NOSCRIPT, (id, nativePtr, elementManager) => NoScriptElement(id, nativePtr, elementManager));
  defineElement(SCRIPT, (id, nativePtr, elementManager) => ScriptElement(id, nativePtr, elementManager));
  // Object
  defineElement(OBJECT, (id, nativePtr, elementManager) => ObjectElement(id, nativePtr, elementManager));
  defineElement(PARAM, (id, nativePtr, elementManager) => ParamElement(id, nativePtr, elementManager));
  // Others
  defineElement(BODY, (id, nativePtr, elementManager) => BodyElement(id, nativePtr, elementManager));
  defineElement(IMAGE, (id, nativePtr, elementManager) => ImageElement(id, nativePtr, elementManager));
  defineElement(CANVAS, (id, nativePtr, elementManager) => CanvasElement(id, nativePtr, elementManager));
}
