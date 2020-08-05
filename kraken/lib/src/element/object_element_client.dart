import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';

typedef ObjectElementClientFactory = ObjectElementClient Function(ObjectElementHost objectElementHost);

ObjectElementClientFactory getObjectElementClientFactory() {
  return _objectElementFactory;
}

ObjectElementClientFactory _objectElementFactory;

void setObjectElementFactory(ObjectElementClientFactory factory) {
  _objectElementFactory = factory;
}

abstract class ObjectElementHost implements EventTarget {

  updateChildTextureBox(TextureBox textureBox);

}

abstract class ObjectElementClient {
  Future<dynamic> initElementClient(Map<String, dynamic> properties);

  dynamic method(String name, List args);

  void setStyle(String key, value);

  void setProperty(String key, value);

  dynamic getProperty(String key);

  void removeProperty(String key);
}
