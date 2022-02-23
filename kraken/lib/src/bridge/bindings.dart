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

  // class
  String get className;
  set className(String value);

  List<String> get classList;

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

      case 'className': return className;
      case 'classList': return classList;
    }
  }

  void _setElementProperty(String key, value) {
    switch (key) {
      case 'scrollTop': scrollTop = castToType<double>(value); break;
      case 'scrollLeft': scrollTop = castToType<double>(value); break;

      case 'className': className = castToType<String>(value); break;
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
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
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
  int get width;
  set width(int value);

  int get height;
  set height(int value);

  String get value;
  set value(String text);

  String get accept;
  set accept(String value);

  String get autocomplete;
  set autocomplete(String value);

  bool get autofocus;
  set autofocus(bool value);

  bool get required;
  set required(bool value);

  bool get readOnly;
  set readOnly(bool value);

  String get pattern;
  set pattern(String value);

  String get step;
  set step(String value);

  String get name;
  set name(String value);

  bool get multiple;
  set multiple(bool value);

  bool get checked;
  set checked(bool value);

  bool get disabled;
  set disabled(bool value);

  String get min;
  set min(String value);

  String get max;
  set max(String value);

  int get maxLength;
  set maxLength(int value);

  String get placeholder;
  set placeholder(String value);

  String get type;
  set type(String value);

  String get mode;
  set mode(String value);

  void focus();
  void blur();

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'width': return width;
      case 'height': return height;
      case 'value': return value;
      case 'accept': return accept;
      case 'autocomplete': return autocomplete;
      case 'autofocus': return autofocus;
      case 'required': return required;
      case 'readonly': return readOnly;
      case 'pattern': return pattern;
      case 'step': return step;
      case 'name': return name;
      case 'multiple': return multiple;
      case 'checked': return checked;
      case 'disabled': return disabled;
      case 'min': return min;
      case 'max': return max;
      case 'maxlength': return maxLength;
      case 'placeholder': return placeholder;
      case 'type': return type;
      case 'mode': return mode;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, val) {
    switch (key) {
      case 'width': width = castToType<int>(val); break;
      case 'height': height = castToType<int>(val); break;
      case 'value': value = castToType<String>(val); break;
      case 'accept': accept = castToType<String>(val); break;
      case 'autocomplete': autocomplete = castToType<String>(val); break;
      case 'autofocus': autofocus = castToType<bool>(val); break;
      case 'required': required = castToType<bool>(val); break;
      case 'readonly': readOnly = castToType<bool>(val); break;
      case 'pattern': pattern = castToType<String>(val); break;
      case 'step': step = castToType<String>(val); break;
      case 'name': name = castToType<String>(val); break;
      case 'multiple': multiple = castToType<bool>(val); break;
      case 'checked': checked = castToType<bool>(val); break;
      case 'disabled': disabled = castToType<bool>(val); break;
      case 'min': min = castToType<String>(val); break;
      case 'max': max = castToType<String>(val); break;
      case 'maxlength': maxLength = castToType<int>(val); break;
      case 'placeholder': placeholder = castToType<String>(val); break;
      case 'type': type = castToType<String>(val); break;
      case 'mode': mode = castToType<String>(val); break;
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

mixin AnchorElementBinding on ElementBinding implements BindingObject {
  String get href;
  set href(String value);

  String get target;
  set target(String value);

  String get rel;
  set rel(String value);

  String get type;
  set type(String value);

  String get protocol;
  set protocol(String value);

  String get host;
  set host(String value);

  String get hostname;
  set hostname(String value);

  String get port;
  set port(String value);

  String get pathname;
  set pathname(String value);

  String get search;
  set search(String value);

  String get hash;
  set hash(String value);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'href': return href;
      case 'target': return target;
      case 'rel': return rel;
      case 'type': return type;
      case 'protocol': return protocol;
      case 'host': return host;
      case 'hostname': return hostname;
      case 'port': return port;
      case 'pathname': return pathname;
      case 'search': return search;
      case 'hash': return hash;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'href': href = castToType<String>(value); break;
      case 'target': target = castToType<String>(value); break;
      case 'rel': rel = castToType<String>(value); break;
      case 'type': type = castToType<String>(value); break;
      case 'protocol': protocol = castToType<String>(value); break;
      case 'host': host = castToType<String>(value); break;
      case 'hostname': hostname = castToType<String>(value); break;
      case 'port': port = castToType<String>(value); break;
      case 'pathname': pathname = castToType<String>(value); break;
      case 'search': search = castToType<String>(value); break;
      case 'hash': hash = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

mixin LinkElementBinding on ElementBinding implements BindingObject {
  bool get disabled;
  set disabled(bool value);

  String get rel;
  set rel(String value);

  String get href;
  set href(String value);

  String get type;
  set type(String value);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'disabled': return disabled;
      case 'rel': return rel;
      case 'href': return href;
      case 'type': return type;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'disabled': disabled = castToType<bool>(value); break;
      case 'rel': rel = castToType<String>(value); break;
      case 'href': href = castToType<String>(value); break;
      case 'type': type = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}


mixin ScriptElementBinding on ElementBinding implements BindingObject {
  String get src;
  set src(String value);

  bool get async;
  set async(bool value);

  bool get defer;
  set defer(bool value);

  String get type;
  set type(String value);

  String get charset;
  set charset(String value);

  String get text;
  set text(String value);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'async': return async;
      case 'defer': return defer;
      case 'type': return type;
      case 'charset': return charset;
      case 'text': return text;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'async': async = castToType<bool>(value); break;
      case 'defer': defer = castToType<bool>(value); break;
      case 'type': type = castToType<String>(value); break;
      case 'charset': charset = castToType<String>(value); break;
      case 'text': text = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

mixin StyleElementBinding on ElementBinding implements BindingObject {
  String get type;
  set type(String value);

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'type': return type;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'type': type = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

mixin ImageElementBinding on ElementBinding implements BindingObject {
  String get src;
  set src(String value);

  bool get loading;
  set loading(bool value);

  int get width;
  set width(int value);

  int get height;
  set height(int value);

  String get scaling;
  set scaling(String value);

  // Read only.
  int get naturalWidth;
  int get naturalHeight;
  bool get complete;

  // Bindings.
  @override
  getProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'loading': return loading;
      case 'width': return width;
      case 'height': return height;
      case 'scaling': return scaling;
      case 'naturalWidth': return naturalWidth;
      case 'naturalHeight': return naturalHeight;
      case 'complete': return complete;
      default: return _getElementProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'loading': loading = castToType<bool>(value); break;
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
      case 'scaling': scaling = castToType<String>(value); break;
      default: return _setElementProperty(key, value);
    }
  }

  @override
  invokeMethod(String method, List args) {
    return _invokeElementMethod(method, args);
  }
}

// Cast any input type to determined type.
T castToType<T>(value) {
  switch (T) {
    case String: return _castToString(value) as T;
    case bool: return _castToBool(value)  as T;
    case int: return _castToInt(value) as T;
    case double: return _castToDouble(value) as T;
    default: return value as T;
  }
}

String _castToString(value) {
  return value == null ? '' : value.toString();
}

bool _castToBool(value) {
  return value != null && value != 0 && !(value is String && value.isEmpty);
}

int _castToInt(value) {
  return int.tryParse(value.toString()) ?? 0;
}

double _castToDouble(value) {
  return double.tryParse(value.toString()) ?? 0.0;
}
