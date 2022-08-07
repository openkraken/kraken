/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';

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

  void setStyle(String key, value);

  void dispose();

  void setProperty(String key, value);

  dynamic getProperty(String key);

  void removeProperty(String key);

  void willAttachRenderer();
  void didAttachRenderer();
  void willDetachRenderer();
  void didDetachRenderer();
}
