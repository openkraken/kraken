import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

// TODO: rename it.
class ContextManager {

  static ContextManager _buildContextSingleton = ContextManager._();
  factory ContextManager() => _buildContextSingleton;
  Map<RenderObject, Style> styleMap;

  ContextManager._() {
    styleMap = {};
  }
}
