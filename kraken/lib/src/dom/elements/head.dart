import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:flutter/scheduler.dart';
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
  HeadElement(int targetId, Pointer<NativeEventTarget>   nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: HEAD, defaultStyle: _defaultStyle);
}

class LinkElement extends Element {
  LinkElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: LINK, defaultStyle: _defaultStyle);
}

class MetaElement extends Element {
  MetaElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: META, defaultStyle: _defaultStyle);
}

class TitleElement extends Element {
  TitleElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: TITLE, defaultStyle: _defaultStyle);
}

class NoScriptElement extends Element {
  NoScriptElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: NOSCRIPT, defaultStyle: _defaultStyle);
}

class ScriptElement extends Element {
  ScriptElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: SCRIPT, defaultStyle: _defaultStyle) {
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      _fetchBundle(value);
    }
  }

  void _fetchBundle(String src) async {
    if (src.isNotEmpty && isConnected) {
      try {
        KrakenBundle bundle = await KrakenBundle.getBundle(src, contextId: elementManager.contextId);
        await bundle.eval(elementManager.contextId);
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
  void connectedCallback() {
    super.connectedCallback();
    String? src = getProperty('src');
    if (src != null) {
      _fetchBundle(src);
    }
  }
}

// TODO
class StyleElement extends Element {
  StyleElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: STYLE, defaultStyle: _defaultStyle);
}
