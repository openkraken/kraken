import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';

typedef ObjectElementClientFactory = ObjectElementClient Function();

ObjectElementClientFactory getObjectElementFactory() {
  return _objectElementFactory;
}

ObjectElementClientFactory _objectElementFactory;

void setObjectElementFactory(ObjectElementClientFactory factory) {
  _objectElementFactory = factory;
}

abstract class ObjectElementHost implements EventTarget {
  double get width;

  double get height;
}

abstract class ObjectElementClient {
  TextureBox createRenderObject(Map<String, dynamic> properties);

  dynamic method(String name, List args);

  void setStyle(String key, value);

  void setProperty(String key, value);

  dynamic getProperty(String key);

  void removeProperty(String key);
}
