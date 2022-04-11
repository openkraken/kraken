/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/css.dart';
import 'package:path/path.dart';

// Children of the <head> element all have display:none
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

const String _MIME_TEXT_JAVASCRIPT = 'text/javascript';
const String _MIME_APPLICATION_JAVASCRIPT = 'application/javascript';
const String _MIME_X_APPLICATION_JAVASCRIPT = 'application/x-javascript';
const String _JAVASCRIPT_MODULE = 'module';

class ScriptRunner {
  ScriptRunner(Document document, int contextId) : _document = document, _contextId = contextId;
  final Document _document;
  final int _contextId;

  final List<KrakenBundle> _scriptsToExecute = [];

  void _executeScripts() async {
    while (_scriptsToExecute.isNotEmpty) {
      KrakenBundle bundle = _scriptsToExecute.first;

      // If bundle is not resolved, should wait for it resolve to prevent the next script running.
      if (!bundle.isResolved) break;

      // Evaluate bundle.
      if (bundle.isJavascript) {
        final String contentInString = await resolveStringFromData(bundle.data!);
        evaluateScripts(_contextId, contentInString, url: bundle.url);
      } else if (bundle.isBytecode) {
        evaluateQuickjsByteCode(_contextId, bundle.data!);
      } else {
        throw FlutterError('Unknown type for <script> to execute. $url');
      }

      _scriptsToExecute.remove(bundle);

      bundle.dispose();

      // Decrement load event delay count after eval.
      _document.decrementLoadEventDelayCount();
    }
  }

  void queueScriptForExecution(ScriptElement element) async {
    // Increment load event delay count before eval.
    _document.incrementLoadEventDelayCount();

    String url = element.src.toString();

    // Obtain bundle.
    KrakenBundle bundle = KrakenBundle.fromUrl(url);

    _scriptsToExecute.add(bundle);

    try {
      // Increment count when request.
      _document.incrementRequestCount();

      await bundle.resolve(_contextId);
      assert(bundle.isResolved, 'Failed to obtain ${bundle.url}');

      // Decrement count when response.
      _document.decrementRequestCount();

      _executeScripts();

      // Successful load.
      Timer.run(() {
        element.dispatchEvent(Event(EVENT_LOAD));
      });
    } catch (e, st) {
      // An error occurred.
      debugPrint('Failed to load script: $url, reason: $e\n$st');
      Timer.run(() {
        element.dispatchEvent(Event(EVENT_ERROR));
      });
    }
  }
}

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
      // Add bundle to scripts queue.
      ownerDocument.scriptRunner.queueScriptForExecution(this);

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
      String? script = collectElementChildText();
      if (script != null && script.isNotEmpty) {
        evaluateScripts(contextId, script);
      }
    }
  }
}
