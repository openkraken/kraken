/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
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

class LinkElement extends Element {
  LinkElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
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

const String _JAVASCRIPT_MIME = 'text/javascript';
const String _JAVASCRIPT_MODULE = 'module';

class ScriptElement extends Element {
  ScriptElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle) {
  }

  String type = _JAVASCRIPT_MIME;

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      _fetchBundle(value);
    } else if (key == 'type') {
      type = value.toString().toLowerCase().trim();
    }
  }

  void _fetchBundle(String src) async {
    int? contextId = ownerDocument.contextId;
    if (contextId == null) return;
    // Must
    if (src.isNotEmpty && isConnected && (type == _JAVASCRIPT_MIME || type == _JAVASCRIPT_MODULE)) {
      try {
        KrakenBundle bundle = KrakenBundle.fromUrl(src);
        await bundle.resolve(contextId);
        await bundle.eval(contextId);
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
    int? contextId = ownerDocument.contextId;
    if (contextId == null) return;
    String? src = getProperty('src');
    if (src != null) {
      _fetchBundle(src);
    } else if (type == _JAVASCRIPT_MIME || type == _JAVASCRIPT_MODULE){
      // Eval script context: <script> console.log(1) </script>
      StringBuffer buffer = StringBuffer();
      childNodes.forEach((node) {
        if (node is TextNode) {
          buffer.write(node.data);
        }
      });
      String script = buffer.toString();
      if (script.isNotEmpty) {
        KrakenController? controller = KrakenController.getControllerOfJSContextId(contextId);
        if (controller != null) {
          KrakenBundle bundle = KrakenBundle.fromContent(script, url: controller.href);
          bundle.resolve(contextId);
          await bundle.eval(contextId);
        }
      }
    }
  }
}

const String _CSS_MIME = 'text/css';

class StyleElement extends Element {
  StyleElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
  String type = _CSS_MIME;
  CSSStyleSheet? _styleSheet;

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'type') {
      type = value.toString().toLowerCase().trim();
    }
  }

  @override
  void connectedCallback() {
    if (type == _CSS_MIME) {
      StringBuffer buffer = StringBuffer();
       childNodes.forEach((node) {
        if (node is TextNode) {
          buffer.write(node.data);
        }
      });
      String style = buffer.toString();
      _styleSheet = CSSStyleSheet(style);
      ownerDocument.addStyleSheet(_styleSheet!);
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
