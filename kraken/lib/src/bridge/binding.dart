/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'package:kraken/dom.dart';

// Cast any input type to determined type.
T castToType<T>(value) {
  assert(value is T, '$value is not or not a subtype of $T');
  return value as T;
}

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
class WindowBinding extends Window implements BindingObject {
  WindowBinding(EventTargetContext context, Document document) : super(context, document);

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
        return scrollTo(
          castToType<double>(args[0]),
          castToType<double>(args[1])
        );
      case 'scrollBy':
        return scrollBy(
            castToType<double>(args[0]),
            castToType<double>(args[1])
        );
      case 'open':
        return open(castToType<String>(args[0]));
    }
  }
}
