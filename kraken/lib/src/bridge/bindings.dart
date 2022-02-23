/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'package:kraken/dom.dart';

abstract class BindingObject {
  // Get a property, eg:
  //   console.log(el.foo);
  dynamic getProperty(String key) {}

  // Set a property, eg:
  //   el.foo = 'bar';
  void setProperty(String key, value) {}

  // Call a method, eg:
  //   el.getContext('2x');
  dynamic invokeMethod(String method, List args) {}
}

// https://www.w3.org/TR/cssom-view-1/#extensions-to-the-window-interface
mixin WindowBinding implements BindingObject {
  // browsing context
  // void moveTo(long x, long y);
  // void moveBy(long x, long y);
  // void resizeTo(long x, long y);
  // void resizeBy(long x, long y);

  // viewport
  // int get innerWidth;
  // int get innerHeight;

  // viewport scrolling
  double get scrollX;
  // [Replaceable] readonly attribute double pageXOffset;
  double get scrollY;
  // [Replaceable] readonly attribute double pageYOffset;

  void scrollTo(double x, double y);
  void scrollBy(double x, double y);
  void open(String url);

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case 'scrollX': return scrollX;
      case 'scrollY': return scrollY;
    }
  }

  @override
  dynamic invokeMethod(String method, List args) {
    switch (method) {
      case 'scroll':
      case 'scrollTo':
        return scrollTo(args[0], args[1]);
      case 'scrollBy':
        return scrollBy(args[0], args[1]);
      case 'open':
        return open(args[0]);
    }
  }
}

// https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
// https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
mixin ElementBinding {
  // Extensions to the HTMLElement Interface
  int get offsetTop;
  int get offsetLeft;
  int get offsetWidth;
  int get offsetHeight;

  // Extensions to the Element Interface
  BoundingClientRect getBoundingClientRect();
  void scroll(double x, double y);
  void scrollTo(double x, double y);
  void scrollBy(double x, double y);
  void click();

  double get scrollTop;
  set scrollTop(double value);

  double get scrollLeft;
  set scrollLeft(double value);

  int get scrollWidth;
  int get scrollHeight;
  int get clientTop;
  int get clientLeft;
  int get clientWidth;
  int get clientHeight;

  _getElementProperty(String key) {
    switch (key) {
      case 'offsetTop': return offsetLeft;
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
    }
  }

  void _setElementProperty(String key, value) {
    switch (key) {
      case 'scrollTop': scrollTop = attributeToProperty<double>(value); break;
      case 'scrollLeft': scrollTop = attributeToProperty<double>(value); break;
    }
  }

  _invokeElementMethod(String method, List args) {
    switch (method) {
      case 'getBoundingClientRect': return getBoundingClientRect().toNative();
      case 'scroll': return scroll(args[0], args[1]);
      case 'scrollBy': return scrollBy(args[0], args[1]);
      case 'scrollTo': return scrollTo(args[0], args[1]);
    }
  }
}

// @NOTE: Following code could be auto generated.
mixin CanvasElementBinding on ElementBinding implements BindingObject {
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
      case 'width': width = attributeToProperty<int>(value); break;
      case 'height': height = attributeToProperty<int>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    switch (method) {
      case 'getContext': return getContext(args[0]).nativeCanvasRenderingContext2D;
      default: return _invokeElementMethod(method, args);
    }
  }

  // Interface of CanvasElement.
  int get width;
  set width(int value);

  int get height;
  set height(int value);

  // RenderingContext? getContext(DOMString contextId, optional any options = null);
  CanvasRenderingContext2D getContext(String contextId);
}

mixin InputElementBinding on ElementBinding implements BindingObject {
  void focus();
  void blur();

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
    switch (method) {
      case 'focus': return focus();
      case 'blur': return blur();
      default: return _invokeElementMethod(method, args);
    }
  }
}

mixin ObjectElementBinding on ElementBinding implements BindingObject {
  dynamic handleJSCall(String method, List args);

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
