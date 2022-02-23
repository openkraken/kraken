/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/launcher.dart';

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
  HeadElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

const String _REL_STYLESHEET = 'stylesheet';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-link-element.html#the-link-element
class LinkElement extends Element with LinkElementBinding {
  LinkElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);

  Uri? _resolvedHyperlink;

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

  @override
  bool get disabled => getAttribute('disabled') != null;
  @override
  set disabled(bool value) {
    if (value) {
      internalSetAttribute('disabled', '');
    } else {
      removeAttribute('disabled');
    }
  }

  @override
  String get href => _resolvedHyperlink?.toString() ?? '';
  @override
  set href(String value) {
    internalSetAttribute('href', value);
    _resolveHyperlink();
    _fetchBundle();
  }

  @override
  String get rel => getAttribute('rel') ?? '';
  @override
  set rel(String value) {
    internalSetAttribute('rel', value);
  }

  @override
  String get type => getAttribute('type') ?? '';
  @override
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

  void _fetchBundle() async {
    if (_resolvedHyperlink != null && rel == _REL_STYLESHEET && isConnected) {
      String url = _resolvedHyperlink.toString();
      try {
        KrakenBundle bundle = KrakenBundle.fromUrl(url);
        await bundle.resolve(contextId);
        bundle.eval(contextId);

        // Successful load.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch (e) {
        // An error occurred.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_ERROR));
        });
      }
      SchedulerBinding.instance!.scheduleFrame();
    }
  }

  @override
  void connectedCallback() async {
    super.connectedCallback();
    if (_resolvedHyperlink != null) {
      _fetchBundle();
    }
  }
}

class MetaElement extends Element {
  MetaElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class TitleElement extends Element {
  TitleElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class NoScriptElement extends Element {
  NoScriptElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

const String _MIME_TEXT_JAVASCRIPT = 'text/javascript';
const String _MIME_APPLICATION_JAVASCRIPT = 'application/javascript';
const String _MIME_X_APPLICATION_JAVASCRIPT = 'application/x-javascript';
const String _JAVASCRIPT_MODULE = 'module';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-link-element.html
class ScriptElement extends Element with ScriptElementBinding {
  ScriptElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle) {
  }

  final String _type = _MIME_TEXT_JAVASCRIPT;

  Uri? _resolvedSource;

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

  @override
  String get src => _resolvedSource?.toString() ?? '';
  @override
  set src(String value) {
    internalSetAttribute('src', value);
    _resolveSource(value);
    _fetchAndExecuteSource();
    // Set src will not reflect to attribute src.
  }

  // @TODO: implement async.
  @override
  bool get async => getAttribute('async') != null;
  @override
  set async(bool value) {
    if (value) {
      internalSetAttribute('async', '');
    } else {
      removeAttribute('async');
    }
  }

  // @TODO: implement defer.
  @override
  bool get defer => getAttribute('defer') != null;
  @override
  set defer(bool value) {
    if (value) {
      internalSetAttribute('defer', '');
    } else {
      removeAttribute('defer');
    }
  }

  @override
  String get type => getAttribute('type') ?? '';
  @override
  set type(String value) {
    internalSetAttribute('type', value);
  }

  @override
  String get charset => getAttribute('charset') ?? '';
  @override
  set charset(String value) {
    internalSetAttribute('charset', value);
  }

  @override
  String get text => getAttribute('text') ?? '';
  @override
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
      try {
        KrakenBundle bundle = KrakenBundle.fromUrl(src.toString());
        await bundle.resolve(contextId);
        bundle.eval(contextId);
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
        KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
        if (controller != null) {
          KrakenBundle bundle = KrakenBundle.fromContent(script, url: controller.url);
          await bundle.resolve(contextId);
          bundle.eval(contextId);
        }
      }
    }
  }
}

const String _CSS_MIME = 'text/css';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-style-element.html
class StyleElement extends Element with StyleElementBinding {
  StyleElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
  final String _type = _CSS_MIME;
  CSSStyleSheet? _styleSheet;

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'type': type = attributeToProperty<String>(value); break;
    }
  }

  @override
  String get type => getAttribute('type') ?? '';
  @override
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
