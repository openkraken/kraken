/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/dom.dart';

typedef ElementCreator = Element Function(EventTargetContext? context);

final Map<String, ElementCreator> _elementRegistry = {};

void defineElement(String name, ElementCreator creator) {
  if (_elementRegistry.containsKey(name)) {
    throw Exception('An element with name "$name" has already been defined.');
  }
  _elementRegistry[name] = creator;
}

class _UnknownElement extends Element {
  _UnknownElement(EventTargetContext? context) : super(context);
}

Element createElement(String name, EventTargetContext? context){
  ElementCreator? creator = _elementRegistry[name];
  if (creator == null) {
    print('Unexpected element "$name"');

    return _UnknownElement(context);
  }

  Element element = creator(context);
  // Assign tagName, used by inspector.
  element.tagName = name;
  return element;
}
