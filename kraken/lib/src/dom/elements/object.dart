/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String OBJECT = 'OBJECT';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

_DefaultObjectElementClient _DefaultObjectElementClientFactory(ObjectElementHost objectElementHost) {
  return _DefaultObjectElementClient(objectElementHost);
}

///https://developer.mozilla.org/en-US/docs/Web/HTML/Element/object
class ObjectElement extends Element implements ObjectElementHost {

  late ObjectElementClientFactory _objectElementClientFactory;
  late ObjectElementClient _objectElementClient;

  ObjectElement(int targetId, Pointer<NativeObjectElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr.ref.nativeElement, elementManager, tagName: OBJECT, defaultStyle: _defaultStyle, isIntrinsicBox: true) {
    initObjectClient();
    initElementClient();
    initDetachCallback(elementManager);
  }

  void initObjectClient() {
    _objectElementClientFactory = getObjectElementClientFactory() ?? _DefaultObjectElementClientFactory;
    _objectElementClient = _objectElementClientFactory(this);
  }

  Future<dynamic> initElementClient() async {
    try {
      await _objectElementClient.initElementClient(properties);
    } catch (e) {
      print(e);
    }
  }

  void initDetachCallback(final ElementManager elementManager) {
    elementManager.setDetachCallback(disposeClient);
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case 'type':
        _objectElementClient.setProperty(key, value);
        break;
      case 'data':
        _objectElementClient.setProperty(key, value);
        break;
      default:
        break;
    }
  }

  // @override
  // void setStyle(String key, value) {
  //   super.setStyle(key, value);
  //   _objectElementClient?.setStyle(key, value);
  // }

  @override
  void updateChildTextureBox(TextureBox? textureBox) {
    addChild(textureBox!);
  }

  @override
  void dispose() {
    super.dispose();
    disposeClient();
  }

  void disposeClient() {
    _objectElementClient.dispose();
  }

//  @override
//  method(String name, List args) {
//   super.method(name, args);
//   _objectElementClient?.method(name, args);
//  }
}

class _DefaultObjectElementClient implements ObjectElementClient {
  ObjectElementHost objectElementHost;

  _DefaultObjectElementClient(this.objectElementHost);

  @override
  Future<dynamic> initElementClient(Map<String, dynamic> properties) async {
    print('call DefaultObjectElementClient initElementClient properties[$properties]');
    return null;
  }

  ///@TODO extend in future
  @override
  getProperty(String key) {
    print('call DefaultObjectElementClient getProperty key[$key]');
    return null;
  }

  /// @TODO extend in future
  /// called when Element js method called
  /// [name] method name
  /// [args] method params
  @override
  method(String name, List args) {
    print('call DefaultObjectElementClient method name[$name] args[$args]');
  }

  @override
  void removeProperty(String key) {
    print('call DefaultObjectElementClient removeProperty[$key]');
  }

  /// called when Element following properties change
  /// width,height
  /// [dataType] indicate the content type of the resource specified by data.
  /// [data] indicate the address of the resource as a valid URL.
  ///
  /// NOTE:
  /// At least one of data and type must be defined.
  @override
  void setProperty(String key, value) {
    print('call DefaultObjectElementClient setProperty key[$key] value[$value]');
  }

  ///@TODO extend in future
  @override
  void setStyle(String key, value) {
    print('call DefaultObjectElementClient setStyle key[$key] value[$value]');
  }

  @override
  void dispose() {
    print('call DefaultObjectElementClient dispose');
  }
}
