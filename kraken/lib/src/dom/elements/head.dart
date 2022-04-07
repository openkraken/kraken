/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';

// Children of the <head> element all have display:none
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

const String HEAD = 'HEAD';
const String LINK = 'LINK';
const String META = 'META';
const String TITLE = 'TITLE';
const String STYLE = 'STYLE';
const String NOSCRIPT = 'NOSCRIPT';
const String SCRIPT = 'SCRIPT';

class HeadElement extends Element {
  HeadElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

const String _REL_STYLESHEET = 'stylesheet';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-link-element.html#the-link-element
class LinkElement extends Element {
  LinkElement([BindingContext? context]) : super(context, defaultStyle: _defaultStyle);

  Uri? _resolvedHyperlink;


  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'disabled': return disabled;
      case 'rel': return rel;
      case 'href': return href;
      case 'type': return type;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'disabled': disabled = castToType<bool>(value); break;
      case 'rel': rel = castToType<String>(value); break;
      case 'href': href = castToType<String>(value); break;
      case 'type': type = castToType<String>(value); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'disabled': disabled = attributeToProperty<bool>(value); break;
      case 'rel': rel = attributeToProperty<String>(value); break;
      case 'href': href = attributeToProperty<String>(value); break;
      case 'type': type = attributeToProperty<String>(value); break;
    }
  }

  bool get disabled => getAttribute('disabled') != null;
  set disabled(bool value) {
    if (value) {
      internalSetAttribute('disabled', '');
    } else {
      removeAttribute('disabled');
    }
  }

  String get href => _resolvedHyperlink?.toString() ?? '';
  set href(String value) {
    internalSetAttribute('href', value);
    _resolveHyperlink();
    _fetchAndApplyCSSStyle();
  }

  String get rel => getAttribute('rel') ?? '';
  set rel(String value) {
    internalSetAttribute('rel', value);
  }

  String get type => getAttribute('type') ?? '';
  set type(String value) {
    internalSetAttribute('type', value);
  }

  void _resolveHyperlink() {
    String? href = getAttribute('href');
    if (href != null) {
      String base = ownerDocument.controller.url;
      try {
        _resolvedHyperlink = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(href));
      } catch (_) {
        // Ignoring the failure of resolving, but to remove the resolved hyperlink.
        _resolvedHyperlink = null;
      }
    }
  }

  void _fetchAndApplyCSSStyle() async {
    if (_resolvedHyperlink != null && rel == _REL_STYLESHEET && isConnected) {
      String url = _resolvedHyperlink.toString();
      KrakenBundle bundle = KrakenBundle.fromUrl(url);
      try {
        await bundle.resolve(contextId);
        assert(bundle.isResolved, 'Failed to obtain $url');
        final String cssString = await resolveStringFromData(bundle.data!);
        _addCSSStyleSheet(cssString);

        // Successful load.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch (e) {
        // An error occurred.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_ERROR));
        });
      } finally {
        bundle.dispose();
      }
      SchedulerBinding.instance!.scheduleFrame();
    }
  }

  void _addCSSStyleSheet(String css) {
    ownerDocument.addStyleSheet(CSSStyleSheet(css));
  }

  @override
  void connectedCallback() async {
    super.connectedCallback();
    if (_resolvedHyperlink != null) {
      _fetchAndApplyCSSStyle();
    }
  }
}

class MetaElement extends Element {
  MetaElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class TitleElement extends Element {
  TitleElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class NoScriptElement extends Element {
  NoScriptElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

const String _MIME_TEXT_JAVASCRIPT = 'text/javascript';
const String _MIME_APPLICATION_JAVASCRIPT = 'application/javascript';
const String _MIME_X_APPLICATION_JAVASCRIPT = 'application/x-javascript';
const String _JAVASCRIPT_MODULE = 'module';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-link-element.html
class ScriptElement extends Element {
  ScriptElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle) {
  }

  final String _type = _MIME_TEXT_JAVASCRIPT;

  Uri? _resolvedSource;

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'async': return async;
      case 'defer': return defer;
      case 'type': return type;
      case 'charset': return charset;
      case 'text': return text;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'async': async = castToType<bool>(value); break;
      case 'defer': defer = castToType<bool>(value); break;
      case 'type': type = castToType<String>(value); break;
      case 'charset': charset = castToType<String>(value); break;
      case 'text': text = castToType<String>(value); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'src': src = attributeToProperty<String>(value); break;
      case 'async': async = attributeToProperty<bool>(value); break;
      case 'defer': defer = attributeToProperty<bool>(value); break;
      case 'type': type = attributeToProperty<String>(value); break;
      case 'charset': charset = attributeToProperty<String>(value); break;
      case 'text': text = attributeToProperty<String>(value); break;
    }
  }

  String get src => _resolvedSource?.toString() ?? '';
  set src(String value) {
    internalSetAttribute('src', value);
    _resolveSource(value);
    _fetchAndExecuteSource();
    // Set src will not reflect to attribute src.
  }

  // @TODO: implement async.
  bool get async => getAttribute('async') != null;
  set async(bool value) {
    if (value) {
      internalSetAttribute('async', '');
    } else {
      removeAttribute('async');
    }
  }

  // @TODO: implement defer.
  bool get defer => getAttribute('defer') != null;
  set defer(bool value) {
    if (value) {
      internalSetAttribute('defer', '');
    } else {
      removeAttribute('defer');
    }
  }

  String get type => getAttribute('type') ?? '';
  set type(String value) {
    internalSetAttribute('type', value);
  }

  String get charset => getAttribute('charset') ?? '';
  set charset(String value) {
    internalSetAttribute('charset', value);
  }

  String get text => getAttribute('text') ?? '';
  set text(String value) {
    internalSetAttribute('text', value);
  }

  void _resolveSource(String source) {
    String base = ownerDocument.controller.url;
    try {
      _resolvedSource = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(source));
    } catch (_) {
      // Ignoring the failure of resolving, but to remove the resolved hyperlink.
      _resolvedSource = null;
    }
  }

  void _fetchAndExecuteSource() async {
    int? contextId = ownerDocument.contextId;
    if (contextId == null) return;
    // Must
    if (src.isNotEmpty && isConnected && (
        _type == _MIME_TEXT_JAVASCRIPT
          || _type == _MIME_APPLICATION_JAVASCRIPT
          || _type == _MIME_X_APPLICATION_JAVASCRIPT
          || _type == _JAVASCRIPT_MODULE
    )) {
      String url = src.toString();

      // Obtain bundle.
      KrakenBundle bundle = KrakenBundle.fromUrl(url);
      try {
        await bundle.resolve(contextId);
        assert(bundle.isResolved, 'Failed to obtain $url');

        // Evaluate bundle.
        if (bundle.isJavascript) {
          final String contentInString = await resolveStringFromData(bundle.data!);
          evaluateScripts(contextId, contentInString, url: url);
        } else if (bundle.isBytecode) {
          evaluateQuickjsByteCode(contextId, bundle.data!);
        } else {
          throw FlutterError('Unknown type for <script> to execute. $url');
        }

        // Successful load.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch (e, st) {
        // An error occurred.
        debugPrint('Failed to load script: $src, reason: $e\n$st');
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_ERROR));
        });
      } finally {
        bundle.dispose();
      }
      SchedulerBinding.instance!.scheduleFrame();
    }
  }

  @override
  void connectedCallback() async {
    super.connectedCallback();
    int? contextId = ownerDocument.contextId;
    if (contextId == null) return;
    if (src.isNotEmpty) {
      _fetchAndExecuteSource();
    } else if (_type == _MIME_TEXT_JAVASCRIPT || _type == _JAVASCRIPT_MODULE){
      // Eval script context: <script> console.log(1) </script>
      String? script = _collectElementChildText(this);
      if (script != null && script.isNotEmpty) {
        evaluateScripts(contextId, script);
      }
    }
  }
}

const String _CSS_MIME = 'text/css';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-style-element.html
class StyleElement extends Element {
  StyleElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
  final String _type = _CSS_MIME;
  CSSStyleSheet? _styleSheet;

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'type': return type;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'type': type = castToType<String>(value); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'type': type = attributeToProperty<String>(value); break;
    }
  }

  String get type => getAttribute('type') ?? '';
  set type(String value) {
    internalSetAttribute('type', value);
  }

  void _recalculateStyle() {
    String? text = _collectElementChildText(this);
    if (text != null) {
      if (_styleSheet != null) {
        _styleSheet!.replaceSync(text);
        ownerDocument.recalculateDocumentStyle();
      } else {
        ownerDocument.addStyleSheet(_styleSheet = CSSStyleSheet(text));
      }
    }
  }

  @override
  Node appendChild(Node child) {
    Node ret = super.appendChild(child);
    _recalculateStyle();
    return ret;
  }

  @override
  Node insertBefore(Node child, Node referenceNode) {
    Node ret = super.insertBefore(child, referenceNode);
    _recalculateStyle();
    return ret;
  }

  @override
  Node removeChild(Node child) {
    Node ret = super.removeChild(child);
    _recalculateStyle();
    return ret;
  }

  @override
  void connectedCallback() {
    if (_type == _CSS_MIME) {
      _recalculateStyle();
    }
    super.connectedCallback();
  }

  @override
  void disconnectedCallback() {
    if (_styleSheet != null) {
      ownerDocument.removeStyleSheet(_styleSheet!);
    }
    super.disconnectedCallback();
  }
}

String? _collectElementChildText(Element el) {
  StringBuffer buffer = StringBuffer();
  el.childNodes.forEach((node) {
    if (node is TextNode) {
      buffer.write(node.data);
    }
  });
  if (buffer.isNotEmpty) {
    return buffer.toString();
  } else {
    return null;
  }
}
