/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/style.dart';

final String STYLE = 'style';

class Style {
  static const String VISIBLE = 'visible';
  static const String HIDDEN = 'hidden';
  static const String SCROLL = 'scroll';
  static const String AUTO = 'auto';
  static const String FIXED = 'fixed';
  static const String LOCAL = 'local';

  Map<String, dynamic> _styleMap;
  String _overflowX;
  String _overflowY;
  String backgroundAttachment;
  String backgroundImage;
  int zIndex = 0;
  String position;
  double left;
  double right;
  double top;
  double bottom;
  double width;
  double height;
  String transform;
  String transformOrigin;
  String transition;

  Style(Map<String, dynamic> styleMap) {
    this._styleMap = styleMap ?? {};
    _overflowX = _overflowY = _styleMap['overflow'];
    _overflowX = _styleMap['overflowX'] ?? _overflowX ?? VISIBLE;
    _overflowY = _styleMap['overflowY'] ?? _overflowY ?? VISIBLE;

    if (_overflowX != null && _overflowX != VISIBLE) {
      _overflowY = _overflowY ?? AUTO;
    }

    if (_overflowY != null && _overflowY != VISIBLE) {
      _overflowX = _overflowX ?? AUTO;
    }

    if (_overflowX == VISIBLE && (_overflowY == SCROLL || _overflowY == AUTO)) {
      _overflowX = AUTO;
    }

    if (_overflowY == VISIBLE && (_overflowX == SCROLL || _overflowX == AUTO)) {
      _overflowY = AUTO;
    }
    backgroundAttachment = _styleMap['backgroundAttachment'] ?? SCROLL;
    backgroundImage = _styleMap['backgroundImage'];
    dynamic zIndexValue = _styleMap['zIndex'];
    zIndex = zIndexValue is num ? zIndexValue.toInt() : 0;
    position = _styleMap['position'] ?? 'static';
    left = _styleMap.containsKey('left') ? Length(_styleMap['left']).displayPortValue : null;
    right = _styleMap.containsKey('right') ? Length(_styleMap['right']).displayPortValue : null;
    top = _styleMap.containsKey('top') ? Length(_styleMap['top']).displayPortValue : null;
    bottom = _styleMap.containsKey('bottom') ? Length(_styleMap['bottom']).displayPortValue : null;
    width = _styleMap.containsKey('width') ? Length(_styleMap['width']).displayPortValue : null;
    height = _styleMap.containsKey('height') ? Length(_styleMap['height']).displayPortValue : null;
    transform = _styleMap['transform'];
    transformOrigin = _styleMap['transformOrigin'];
    transition = _styleMap['transition'];
  }

  String get overflowY => _overflowY;

  String get overflowX => _overflowX;

  dynamic get(String key) => _styleMap[key];
  dynamic operator [](String key) => this.get(key);
  bool contains(String key) {
    if (_styleMap.containsKey(key)) {
      dynamic value = _styleMap[key];
      // Null or empty string both means the style not exists.
      return !(value == null || (value is String && value.isEmpty));
    } else {
      return false;
    }
  }

  /// Reserved to use.
  Map<String, dynamic> getOriginalStyleMap() => _styleMap;

  Style copyWith(Map<String, dynamic> overrides) {
    Map<String, dynamic> copiedStyleMap =
        Map<String, dynamic>.from(getOriginalStyleMap());
    overrides?.forEach((String key, value) {
      copiedStyleMap[key] = value;
    });
    return Style(copiedStyleMap);
  }

  @override
  String toString() {
    return _styleMap.toString();
  }
}
