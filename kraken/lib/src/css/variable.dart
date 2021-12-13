/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
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
  final Map<String, List<String>> _propertyDependencies = {};

  void _addDependency(String identifier, String propertyName) {
    List<String>? dep = _propertyDependencies[identifier];
    if (dep == null) {
      _propertyDependencies[identifier] = [propertyName];
    } else if (!dep.contains(propertyName)) {
      dep.add(propertyName);
    }
  }

  @override
  String? getCSSVariable(String identifier, String propertyName) {
    Map<String, String>? storage = _storage;
    _addDependency(identifier, propertyName);

    if (storage != null && storage.containsKey(identifier)) {
      return storage[identifier];
    } else {
      // Inherits from renderStyle tree.
      return parent?.getCSSVariable(identifier, propertyName);
    }
  }

  // --x: red
  // key: --x
  // value: red
  @override
  void setCSSVariable(String identifier, String value) {
    _storage ??= HashMap<String, String>();
    _storage![identifier] = value;

    if (_propertyDependencies.containsKey(identifier)) {
      _notifyCSSVariableChanged(_propertyDependencies[identifier]!, value);
    }
  }

  void _notifyCSSVariableChanged(List<String> propertyNames, String value) {
    propertyNames.forEach((String propertyName) {
      target.setRenderStyle(propertyName, value);
      visitChildren((CSSRenderStyle childRenderStyle) {
        childRenderStyle._notifyCSSVariableChanged(propertyNames, value);
      });
    });
  }
}
