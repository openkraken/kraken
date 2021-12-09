/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';

import 'render_style.dart';
const int _HYPHEN_CODE = 45; // -

mixin CSSVariableMixin on RenderStyle {
  static bool isVariable(String? value) {
    if (value == null) {
      return false;
    }
    return value.length > 2 && value.codeUnitAt(0) == _HYPHEN_CODE && value.codeUnitAt(1) == _HYPHEN_CODE;
  }

  Map<String, String>? _storage;

  @override
  String? getCSSVariable(String key) {
    Map<String, String>? storage = _storage;
    if (storage != null && storage.containsKey(key)) {
      return storage[key];
    } else {
      // Inherits from renderStyle tree.
      return parent?.getCSSVariable(key);
    }
  }

  @override
  void setCSSVariable(String key, String value) {
    _storage ??= HashMap<String, String>();
    _storage![key] = value;
  }
}
