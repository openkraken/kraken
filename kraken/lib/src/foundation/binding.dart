/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';

typedef BindingObjectOperation = void Function(BindingObject bindingObject);

class BindingContext {
  final int contextId;
  final pointer;
  const BindingContext(this.contextId, this.pointer);
}

abstract class BindingObject {
  static BindingObjectOperation? bind;
  static BindingObjectOperation? unbind;

  final BindingContext? _context;

  int? get contextId => _context?.contextId;
  get pointer => _context?.pointer;

  BindingObject([BindingContext? context]) : _context = context {
    _bind();
  }

  // Bind dart side object method to receive invoking from native side.
  void _bind() {
    if (bind != null) {
      bind!(this);
    }
  }

  void _unbind() {
    if (unbind != null) {
      unbind!(this);
    }
  }

  // Get a property, eg:
  //   console.log(el.foo);
  dynamic getBindingProperty(String key) {}

  // Set a property, eg:
  //   el.foo = 'bar';
  void setBindingProperty(String key, value) {}

  // Call a method, eg:
  //   el.getContext('2x');
  dynamic invokeBindingMethod(String method, List args) {}

  @mustCallSuper
  void dispose() {
    _unbind();
  }
}
