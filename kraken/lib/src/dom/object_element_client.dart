/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

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

  dynamic handleJSCall(String method, List argv);

  void setStyle(String key, dynamic value);

  void dispose();

  void setProperty(String key, dynamic value);

  dynamic getProperty(String key);

  void removeProperty(String key);

  void willAttachRenderer();
  void didAttachRenderer();
  void willDetachRenderer();
  void didDetachRenderer();
}
