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

class LinkElement extends Element {
  LinkElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);

  // Supported properties:
  // - href
  // - rel
  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case 'href':
        _fetchBundle(value);
        break;
    }
  }

  @override
  getProperty(String key) {
    switch (key) {
      case 'href':
      case 'rel':
        return attributes[key];
    }
    return super.getProperty(key);
  }

  String? get _rel => attributes['rel'];

  void _fetchBundle(String url) async {
    if (url.isNotEmpty && _rel == _REL_STYLESHEET && isConnected) {
      try {
        KrakenBundle bundle = KrakenBundle.fromUrl(url);
        await bundle.resolve(contextId);
        bundle.eval(contextId);

        // Successful load.
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch(e) {
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
    String? url = getAttribute('href');
    if (url != null) {
      _fetchBundle(url);
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

class ScriptElement extends Element {
  ScriptElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle) {
  }

  String _type = _MIME_TEXT_JAVASCRIPT;

  // Supported properties:
  // - src
  // - type
  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case 'src':
        _fetchBundle(value);
        break;
      case 'type':
        _type = value.toString();
        break;
    }
  }

  @override
  getProperty(String key) {
    switch (key) {
      case 'src':
      case 'type':
        return attributes[key];
    }

    return super.getProperty(key);
  }

  void _fetchBundle(String src) async {
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
        // Resolve uri.
        String baseUrl = ownerDocument.controller.url;
        Uri baseUri = Uri.parse(baseUrl);
        Uri uri = ownerDocument.controller.uriParser!.resolve(baseUri, Uri.parse(src));
        // Load and evaluate using kraken bundle.
        KrakenBundle bundle = KrakenBundle.fromUrl(uri.toString());
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
    String? src = getAttribute('src');
    if (src != null) {
      _fetchBundle(src);
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

class StyleElement extends Element {
  StyleElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
  String _type = _CSS_MIME;
  CSSStyleSheet? _styleSheet;

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
  void setProperty(String key, value) {
    super.setProperty(key, value);
    if (key == 'type') {
      _type = value.toString();
    }
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
