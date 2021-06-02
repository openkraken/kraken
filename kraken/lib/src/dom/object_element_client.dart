import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

typedef ObjectElementClientFactory = ObjectElementClient Function(ObjectElementHost objectElementHost);

ObjectElementClientFactory? _objectElementFactory;

ObjectElementClientFactory? getObjectElementClientFactory() {
  return _objectElementFactory;
}

void setObjectElementFactory(ObjectElementClientFactory factory) {
  _objectElementFactory = factory;
}

abstract class ObjectElementHost implements EventTarget {
  updateChildTextureBox(TextureBox? textureBox);
}

abstract class ObjectElementClient {
  Future<dynamic> initElementClient(Map<String, dynamic> properties);

  dynamic method(String name, List args);

  void setStyle(String key, dynamic value);

  void dispose();

  void setProperty(String key, dynamic value);

  dynamic getProperty(String key);

  void removeProperty(String key);
}
