/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';

class _CanvasElementBinding extends CanvasElement with ElementPropertyImplementation implements BindingObject {
  _CanvasElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'width': return width;
      case 'height': return height;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    switch (method) {
      case 'getContext': return getContext(castToType<String>(args[0])).nativeCanvasRenderingContext2D;
      default: return _invokeElementMethod(method, args);
    }
  }
}

class _InputElementBinding extends InputElement with ElementPropertyImplementation implements BindingObject {
  _InputElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'width': return width;
      case 'height': return height;
      case 'value': return value;
      case 'accept': return accept;
      case 'autocomplete': return autocomplete;
      case 'autofocus': return autofocus;
      case 'required': return required;
      case 'readonly': return readOnly;
      case 'pattern': return pattern;
      case 'step': return step;
      case 'name': return name;
      case 'multiple': return multiple;
      case 'checked': return checked;
      case 'disabled': return disabled;
      case 'min': return min;
      case 'max': return max;
      case 'maxlength': return maxLength;
      case 'placeholder': return placeholder;
      case 'type': return type;
      case 'mode': return mode;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, val) {
    switch (key) {
      case 'width': width = castToType<int>(val); break;
      case 'height': height = castToType<int>(val); break;
      case 'value': value = castToType<String>(val); break;
      case 'accept': accept = castToType<String>(val); break;
      case 'autocomplete': autocomplete = castToType<String>(val); break;
      case 'autofocus': autofocus = castToType<bool>(val); break;
      case 'required': required = castToType<bool>(val); break;
      case 'readonly': readOnly = castToType<bool>(val); break;
      case 'pattern': pattern = castToType<String>(val); break;
      case 'step': step = castToType<String>(val); break;
      case 'name': name = castToType<String>(val); break;
      case 'multiple': multiple = castToType<bool>(val); break;
      case 'checked': checked = castToType<bool>(val); break;
      case 'disabled': disabled = castToType<bool>(val); break;
      case 'min': min = castToType<String>(val); break;
      case 'max': max = castToType<String>(val); break;
      case 'maxlength': maxLength = castToType<int>(val); break;
      case 'placeholder': placeholder = castToType<String>(val); break;
      case 'type': type = castToType<String>(val); break;
      case 'mode': mode = castToType<String>(val); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    switch (method) {
      case 'focus': return focus();
      case 'blur': return blur();
      default: return _invokeElementMethod(method, args);
    }
  }
}

class _ObjectElementBinding extends ObjectElement with ElementPropertyImplementation implements BindingObject {
  _ObjectElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return handleJSCall(method, args)
        ?? _invokeElementMethod(method, args);
  }
}

class _AnchorElementBinding extends AnchorElement with ElementPropertyImplementation implements BindingObject {
  _AnchorElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'href': return href;
      case 'target': return target;
      case 'rel': return rel;
      case 'type': return type;
      case 'protocol': return protocol;
      case 'host': return host;
      case 'hostname': return hostname;
      case 'port': return port;
      case 'pathname': return pathname;
      case 'search': return search;
      case 'hash': return hash;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'href': href = castToType<String>(value); break;
      case 'target': target = castToType<String>(value); break;
      case 'rel': rel = castToType<String>(value); break;
      case 'type': type = castToType<String>(value); break;
      case 'protocol': protocol = castToType<String>(value); break;
      case 'host': host = castToType<String>(value); break;
      case 'hostname': hostname = castToType<String>(value); break;
      case 'port': port = castToType<String>(value); break;
      case 'pathname': pathname = castToType<String>(value); break;
      case 'search': search = castToType<String>(value); break;
      case 'hash': hash = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

class _LinkElementBinding extends LinkElement with ElementPropertyImplementation implements BindingObject {
  _LinkElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'disabled': return disabled;
      case 'rel': return rel;
      case 'href': return href;
      case 'type': return type;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'disabled': disabled = castToType<bool>(value); break;
      case 'rel': rel = castToType<String>(value); break;
      case 'href': href = castToType<String>(value); break;
      case 'type': type = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

class _ScriptElementBinding extends ScriptElement with ElementPropertyImplementation implements BindingObject {
  _ScriptElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'async': return async;
      case 'defer': return defer;
      case 'type': return type;
      case 'charset': return charset;
      case 'text': return text;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'async': async = castToType<bool>(value); break;
      case 'defer': defer = castToType<bool>(value); break;
      case 'type': type = castToType<String>(value); break;
      case 'charset': charset = castToType<String>(value); break;
      case 'text': text = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

class _StyleElementBinding extends StyleElement with ElementPropertyImplementation implements BindingObject {
  _StyleElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'type': return type;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'type': type = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

class _ImageElementBinding extends ImageElement with ElementPropertyImplementation implements BindingObject {
  _ImageElementBinding(EventTargetContext? context) : super(context);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'loading': return loading;
      case 'width': return width;
      case 'height': return height;
      case 'scaling': return scaling;
      case 'naturalWidth': return naturalWidth;
      case 'naturalHeight': return naturalHeight;
      case 'complete': return complete;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'loading': loading = castToType<bool>(value); break;
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
      case 'scaling': scaling = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

class _BRElementBinding extends BRElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _BRElementBinding(EventTargetContext? context) : super(context);
}

class _BringElementBinding extends BringElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _BringElementBinding(EventTargetContext? context) : super(context);
}

class _AbbreviationElementBinding extends AbbreviationElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _AbbreviationElementBinding(EventTargetContext? context) : super(context);
}

class _EmphasisElementBinding extends EmphasisElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _EmphasisElementBinding(EventTargetContext? context) : super(context);
}

class _CitationElementBinding extends CitationElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _CitationElementBinding(EventTargetContext? context) : super(context);
}

class _IdiomaticElementBinding extends IdiomaticElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _IdiomaticElementBinding(EventTargetContext? context) : super(context);
}

class _CodeElementBinding extends CodeElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _CodeElementBinding(EventTargetContext? context) : super(context);
}

class _SampleElementBinding extends SampleElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _SampleElementBinding(EventTargetContext? context) : super(context);
}

class _StrongElementBinding extends StrongElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _StrongElementBinding(EventTargetContext? context) : super(context);
}

class _SmallElementBinding extends SmallElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _SmallElementBinding(EventTargetContext? context) : super(context);
}

class _StrikethroughElementBinding extends StrikethroughElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _StrikethroughElementBinding(EventTargetContext? context) : super(context);
}

class _UnarticulatedElementBinding extends UnarticulatedElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _UnarticulatedElementBinding(EventTargetContext? context) : super(context);
}

class _VariableElementBinding extends VariableElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _VariableElementBinding(EventTargetContext? context) : super(context);
}

class _TimeElementBinding extends TimeElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _TimeElementBinding(EventTargetContext? context) : super(context);
}

class _DataElementBinding extends DataElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DataElementBinding(EventTargetContext? context) : super(context);
}

class _MarkElementBinding extends MarkElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _MarkElementBinding(EventTargetContext? context) : super(context);
}

class _QuoteElementBinding extends QuoteElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _QuoteElementBinding(EventTargetContext? context) : super(context);
}

class _KeyboardElementBinding extends KeyboardElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _KeyboardElementBinding(EventTargetContext? context) : super(context);
}

class _DefinitionElementBinding extends DefinitionElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DefinitionElementBinding(EventTargetContext? context) : super(context);
}

class _SpanElementBinding extends SpanElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _SpanElementBinding(EventTargetContext? context) : super(context);
}

class _PreElementBinding extends PreElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _PreElementBinding(EventTargetContext? context) : super(context);
}

class _ParagraphElementBinding extends ParagraphElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _ParagraphElementBinding(EventTargetContext? context) : super(context);
}

class _DivElementBinding extends DivElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DivElementBinding(EventTargetContext? context) : super(context);
}

class _UListElementBinding extends UListElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _UListElementBinding(EventTargetContext? context) : super(context);
}

class _OListElementBinding extends OListElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _OListElementBinding(EventTargetContext? context) : super(context);
}

class _LIElementBinding extends LIElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _LIElementBinding(EventTargetContext? context) : super(context);
}

class _DListElementBinding extends DListElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DListElementBinding(EventTargetContext? context) : super(context);
}

class _DTElementBinding extends DTElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DTElementBinding(EventTargetContext? context) : super(context);
}

class _DDElementBinding extends DDElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DDElementBinding(EventTargetContext? context) : super(context);
}

class _FigureElementBinding extends FigureElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _FigureElementBinding(EventTargetContext? context) : super(context);
}

class _FigureCaptionElementBinding extends FigureCaptionElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _FigureCaptionElementBinding(EventTargetContext? context) : super(context);
}

class _BlockQuotationElementBinding extends BlockQuotationElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _BlockQuotationElementBinding(EventTargetContext? context) : super(context);
}

class _TemplateElementBinding extends TemplateElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _TemplateElementBinding(EventTargetContext? context) : super(context);
}

class _AddressElementBinding extends AddressElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _AddressElementBinding(EventTargetContext? context) : super(context);
}

class _ArticleElementBinding extends ArticleElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _ArticleElementBinding(EventTargetContext? context) : super(context);
}

class _AsideElementBinding extends AsideElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _AsideElementBinding(EventTargetContext? context) : super(context);
}

class _FooterElementBinding extends FooterElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _FooterElementBinding(EventTargetContext? context) : super(context);
}

class _HeaderElementBinding extends HeaderElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _HeaderElementBinding(EventTargetContext? context) : super(context);
}

class _MainElementBinding extends MainElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _MainElementBinding(EventTargetContext? context) : super(context);
}

class _NavElementBinding extends NavElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _NavElementBinding(EventTargetContext? context) : super(context);
}

class _SectionElementBinding extends SectionElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _SectionElementBinding(EventTargetContext? context) : super(context);
}

class _H1ElementBinding extends H1Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H1ElementBinding(EventTargetContext? context) : super(context);
}

class _H2ElementBinding extends H2Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H2ElementBinding(EventTargetContext? context) : super(context);
}

class _H3ElementBinding extends H3Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H3ElementBinding(EventTargetContext? context) : super(context);
}

class _H4ElementBinding extends H4Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H4ElementBinding(EventTargetContext? context) : super(context);
}

class _H5ElementBinding extends H5Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H5ElementBinding(EventTargetContext? context) : super(context);
}

class _H6ElementBinding extends H6Element with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _H6ElementBinding(EventTargetContext? context) : super(context);
}

class _LabelElementBinding extends LabelElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _LabelElementBinding(EventTargetContext? context) : super(context);
}

class _ButtonElementBinding extends ButtonElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _ButtonElementBinding(EventTargetContext? context) : super(context);
}

class _DelElementBinding extends DelElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _DelElementBinding(EventTargetContext? context) : super(context);
}

class _InsElementBinding extends InsElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _InsElementBinding(EventTargetContext? context) : super(context);
}

class _HeadElementBinding extends HeadElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _HeadElementBinding(EventTargetContext? context) : super(context);
}

class _TitleElementBinding extends TitleElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _TitleElementBinding(EventTargetContext? context) : super(context);
}

class _MetaElementBinding extends MetaElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _MetaElementBinding(EventTargetContext? context) : super(context);
}

class _NoScriptElementBinding extends NoScriptElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _NoScriptElementBinding(EventTargetContext? context) : super(context);
}

class _ParamElementBinding extends ParamElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _ParamElementBinding(EventTargetContext? context) : super(context);
}

class _HTMLElementBinding extends HTMLElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _HTMLElementBinding(EventTargetContext? context) : super(context);
}

class _BodyElementBinding extends BodyElement with ElementPropertyImplementation, ElementBinding implements BindingObject {
  _BodyElementBinding(EventTargetContext? context) : super(context);
}

// https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
// https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
mixin ElementPropertyImplementation on Element {
  _getElementProperty(String key) {
    switch (key) {
      case 'offsetTop': return offsetTop;
      case 'offsetLeft': return offsetLeft;
      case 'offsetWidth': return offsetWidth;
      case 'offsetHeight': return offsetHeight;

      case 'scrollTop': return scrollTop;
      case 'scrollLeft': return scrollLeft;
      case 'scrollWidth': return scrollWidth;
      case 'scrollHeight': return scrollHeight;

      case 'clientTop': return clientTop;
      case 'clientLeft': return clientLeft;
      case 'clientWidth': return clientWidth;
      case 'clientHeight': return clientHeight;

      case 'className': return className;
      case 'classList': return classList;
    }
  }

  void _setElementProperty(String key, value) {
    switch (key) {
      case 'scrollTop': scrollTop = castToType<double>(value); break;
      case 'scrollLeft': scrollLeft = castToType<double>(value); break;

      case 'className': className = castToType<String>(value); break;
    }
  }

  _invokeElementMethod(String method, List args) {
    switch (method) {
      case 'getBoundingClientRect': return getBoundingClientRect().toNative();
      case 'scroll': return scroll(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'scrollBy': return scrollBy(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'scrollTo': return scrollTo(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'click': return click();
    }
  }
}

mixin ElementBinding on ElementPropertyImplementation implements BindingObject {
  @override
  getProperty(String key) => _getElementProperty(key);

  @override
  void setProperty(String key, value) => _setElementProperty(key, value);

  @override
  invokeMethod(String method, List args) => _invokeElementMethod(method, args);
}

bool _isDefined = false;
void defineBuiltInBindingElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  defineElement(BR, (context) => _BRElementBinding(context));
  defineElement(B, (context) => _BringElementBinding(context));
  defineElement(ABBR, (context) => _AbbreviationElementBinding(context));
  defineElement(EM, (context) => _EmphasisElementBinding(context));
  defineElement(CITE, (context) => _CitationElementBinding(context));
  defineElement(I, (context) => _IdiomaticElementBinding(context));
  defineElement(CODE, (context) => _CodeElementBinding(context));
  defineElement(SAMP, (context) => _SampleElementBinding(context));
  defineElement(STRONG, (context) => _StrongElementBinding(context));
  defineElement(SMALL, (context) => _SmallElementBinding(context));
  defineElement(S, (context) => _StrikethroughElementBinding(context));
  defineElement(U, (context) => _UnarticulatedElementBinding(context));
  defineElement(VAR, (context) => _VariableElementBinding(context));
  defineElement(TIME, (context) => _TimeElementBinding(context));
  defineElement(DATA, (context) => _DataElementBinding(context));
  defineElement(MARK, (context) => _MarkElementBinding(context));
  defineElement(Q, (context) => _QuoteElementBinding(context));
  defineElement(KBD, (context) => _KeyboardElementBinding(context));
  defineElement(DFN, (context) => _DefinitionElementBinding(context));
  defineElement(SPAN, (context) => _SpanElementBinding(context));
  defineElement(ANCHOR, (context) => _AnchorElementBinding(context));
  // Content
  defineElement(PRE, (context) => _PreElementBinding(context));
  defineElement(PARAGRAPH, (context) => _ParagraphElementBinding(context));
  defineElement(DIV, (context) => _DivElementBinding(context));
  defineElement(UL, (context) => _UListElementBinding(context));
  defineElement(OL, (context) => _OListElementBinding(context));
  defineElement(LI, (context) => _LIElementBinding(context));
  defineElement(DL, (context) => _DListElementBinding(context));
  defineElement(DT, (context) => _DTElementBinding(context));
  defineElement(DD, (context) => _DDElementBinding(context));
  defineElement(FIGURE, (context) => _FigureElementBinding(context));
  defineElement(FIGCAPTION, (context) => _FigureCaptionElementBinding(context));
  defineElement(BLOCKQUOTE, (context) => _BlockQuotationElementBinding(context));
  defineElement(TEMPLATE, (context) => _TemplateElementBinding(context));
  // Sections
  defineElement(ADDRESS, (context) => _AddressElementBinding(context));
  defineElement(ARTICLE, (context) => _ArticleElementBinding(context));
  defineElement(ASIDE, (context) => _AsideElementBinding(context));
  defineElement(FOOTER, (context) => _FooterElementBinding(context));
  defineElement(HEADER, (context) => _HeaderElementBinding(context));
  defineElement(MAIN, (context) => _MainElementBinding(context));
  defineElement(NAV, (context) => _NavElementBinding(context));
  defineElement(SECTION, (context) => _SectionElementBinding(context));
  // Headings
  defineElement(H1, (context) => _H1ElementBinding(context));
  defineElement(H2, (context) => _H2ElementBinding(context));
  defineElement(H3, (context) => _H3ElementBinding(context));
  defineElement(H4, (context) => _H4ElementBinding(context));
  defineElement(H5, (context) => _H5ElementBinding(context));
  defineElement(H6, (context) => _H6ElementBinding(context));
  // Forms
  defineElement(LABEL, (context) => _LabelElementBinding(context));
  defineElement(BUTTON, (context) => _ButtonElementBinding(context));
  defineElement(INPUT, (context) => _InputElementBinding(context));
  // Edits
  defineElement(DEL, (context) => _DelElementBinding(context));
  defineElement(INS, (context) => _InsElementBinding(context));
  // Head
  defineElement(HEAD, (context) => _HeadElementBinding(context));
  defineElement(TITLE, (context) => _TitleElementBinding(context));
  defineElement(META, (context) => _MetaElementBinding(context));
  defineElement(LINK, (context) => _LinkElementBinding(context));
  defineElement(STYLE, (context) => _StyleElementBinding(context));
  defineElement(NOSCRIPT, (context) => _NoScriptElementBinding(context));
  defineElement(SCRIPT, (context) => _ScriptElementBinding(context));
  // Object
  defineElement(OBJECT, (context) => _ObjectElementBinding(context));
  defineElement(PARAM, (context) => _ParamElementBinding(context));
  // Others
  defineElement(HTML, (context) => _HTMLElementBinding(context));
  defineElement(BODY, (context) => _BodyElementBinding(context));
  defineElement(IMAGE, (context) => _ImageElementBinding(context));
  defineElement(CANVAS, (context) => _CanvasElementBinding(context));
}
