/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/dom.dart';

typedef ElementCreator = Element Function(EventTargetContext? context);

final Map<String, ElementCreator> _elementRegistry = {};

void defineElement(String name, ElementCreator creator) {
  if (_elementRegistry.containsKey(name)) {
    throw Exception('A element with name "$name" has already been defined.');
  }
  _elementRegistry[name] = creator;
}

Element createElement(String name, EventTargetContext? context){
  ElementCreator? creator = _elementRegistry[name];
  if (creator == null) {
    print('ERROR: unexpected element type "$name"');
    return Element(context);
  }

  Element element = creator(context);
  // Assign tagName, used by inspector.
  element.tagName = name;
  return element;
}

bool _isDefined = false;
void defineBuiltInElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  defineElement(BR, (context) => BRElement(context));
  defineElement(B, (context) => BringElement(context));
  defineElement(ABBR, (context) => AbbreviationElement(context));
  defineElement(EM, (context) => EmphasisElement(context));
  defineElement(CITE, (context) => CitationElement(context));
  defineElement(I, (context) => IdiomaticElement(context));
  defineElement(CODE, (context) => CodeElement(context));
  defineElement(SAMP, (context) => SampleElement(context));
  defineElement(STRONG, (context) => StrongElement(context));
  defineElement(SMALL, (context) => SmallElement(context));
  defineElement(S, (context) => StrikethroughElement(context));
  defineElement(U, (context) => UnarticulatedElement(context));
  defineElement(VAR, (context) => VariableElement(context));
  defineElement(TIME, (context) => TimeElement(context));
  defineElement(DATA, (context) => DataElement(context));
  defineElement(MARK, (context) => MarkElement(context));
  defineElement(Q, (context) => QuoteElement(context));
  defineElement(KBD, (context) => KeyboardElement(context));
  defineElement(DFN, (context) => DefinitionElement(context));
  defineElement(SPAN, (context) => SpanElement(context));
  defineElement(ANCHOR, (context) => AnchorElement(context));
  // Content
  defineElement(PRE, (context) => PreElement(context));
  defineElement(PARAGRAPH, (context) => ParagraphElement(context));
  defineElement(DIV, (context) => DivElement(context));
  defineElement(UL, (context) => UListElement(context));
  defineElement(OL, (context) => OListElement(context));
  defineElement(LI, (context) => LIElement(context));
  defineElement(DL, (context) => DListElement(context));
  defineElement(DT, (context) => DTElement(context));
  defineElement(DD, (context) => DDElement(context));
  defineElement(FIGURE, (context) => FigureElement(context));
  defineElement(FIGCAPTION, (context) => FigureCaptionElement(context));
  defineElement(BLOCKQUOTE, (context) => BlockQuotationElement(context));
  defineElement(TEMPLATE, (context) => TemplateElement(context));
  // Sections
  defineElement(ADDRESS, (context) => AddressElement(context));
  defineElement(ARTICLE, (context) => ArticleElement(context));
  defineElement(ASIDE, (context) => AsideElement(context));
  defineElement(FOOTER, (context) => FooterElement(context));
  defineElement(HEADER, (context) => HeaderElement(context));
  defineElement(MAIN, (context) => MainElement(context));
  defineElement(NAV, (context) => NavElement(context));
  defineElement(SECTION, (context) => SectionElement(context));
  // Headings
  defineElement(H1, (context) => H1Element(context));
  defineElement(H2, (context) => H2Element(context));
  defineElement(H3, (context) => H3Element(context));
  defineElement(H4, (context) => H4Element(context));
  defineElement(H5, (context) => H5Element(context));
  defineElement(H6, (context) => H6Element(context));
  // Forms
  defineElement(LABEL, (context) => LabelElement(context));
  defineElement(BUTTON, (context) => ButtonElement(context));
  defineElement(INPUT, (context) => InputElement(context));
  // Edits
  defineElement(DEL, (context) => DelElement(context));     
  defineElement(INS, (context) => InsElement(context));
  // Head
  defineElement(HEAD, (context) => HeadElement(context));
  defineElement(TITLE, (context) => TitleElement(context));
  defineElement(META, (context) => MetaElement(context));
  defineElement(LINK, (context) => LinkElement(context));
  defineElement(STYLE, (context) => StyleElement(context));
  defineElement(NOSCRIPT, (context) => NoScriptElement(context));
  defineElement(SCRIPT, (context) => ScriptElement(context));
  // Object
  defineElement(OBJECT, (context) => ObjectElement(context));
  defineElement(PARAM, (context) => ParamElement(context));
  // Others
  defineElement(HTML, (context) => HTMLElement(context));
  defineElement(BODY, (context) => BodyElement(context));
  defineElement(IMAGE, (context) => ImageElement(context));
  defineElement(CANVAS, (context) => CanvasElement(context));
}
