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

  void _handleEventAfterLoaded() {
    // `load` event is a simple event.
    if (isConnected) {
      // If image in tree, make sure the image-box has been layout, using addPostFrameCallback.
      SchedulerBinding.instance.scheduleFrame();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        dispatchEvent(Event(EVENT_LOAD));
      });
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      _fetchBundle(value);
    }
  }

  void _fetchBundle(String src) async {
    if (src != null && src.isNotEmpty && isConnected) {
      KrakenBundle bundle = await KrakenBundle.getBundle(src);
      bundle.eval(elementManager.contextId);
      _handleEventAfterLoaded();
    }
  }

  @override
  void didAttachRenderer() async {
    super.didAttachRenderer();
    String src = getProperty('src');
    _fetchBundle(src);
  }
}
