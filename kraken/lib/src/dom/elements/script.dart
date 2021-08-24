import 'dart:ffi';

import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/launcher.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

const String SCRIPT = 'SCRIPT';

class ScriptElement extends Element {
  ScriptElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: SCRIPT, defaultStyle: _defaultStyle);

  String? _src;

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      _fetchBundle(value);
    }
  }

  @override
  handleJSCall(String method, List argv) {
    switch(method) {
      case 'getSrc':
        return _src ?? '';
      default:
        return super.handleJSCall(method, argv);
    }
  }

  void _fetchBundle(String src) async {
    _src = src;
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
