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
  ScriptElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: SCRIPT, defaultStyle: _defaultStyle);

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      _fetchBundle(value);
    }
  }

  void _fetchBundle(String src) async {
    if (src != null && src.isNotEmpty && isConnected) {
      try {
        KrakenBundle bundle = await KrakenBundle.getBundle(src);
        await bundle.eval(elementManager.contextId);
        // Successful load.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch(e) {
        // An error occurred.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_ERROR));
        });
      }
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  @override
  void didAttachRenderer() async {
    super.didAttachRenderer();
    String src = getProperty('src');
    _fetchBundle(src);
  }
}
