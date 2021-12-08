/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String OBJECT = 'OBJECT';
const String PARAM = 'PARAM';

const Map<String, dynamic> _objectStyle = {
  DISPLAY: INLINE_BLOCK,
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

const Map<String, dynamic> _paramStyle = {
  DISPLAY: NONE,
};

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/param
class ParamElement extends Element {
  ParamElement(EventTargetContext? context)
      : super(context, defaultStyle: _paramStyle);
}

_DefaultObjectElementClient _DefaultObjectElementClientFactory(ObjectElementHost objectElementHost) {
  return _DefaultObjectElementClient(objectElementHost);
}

///https://developer.mozilla.org/en-US/docs/Web/HTML/Element/object
class ObjectElement extends Element implements ObjectElementHost {

  late ObjectElementClientFactory _objectElementClientFactory;
  late ObjectElementClient _objectElementClient;

  ObjectElement(EventTargetContext? context)
      : super(context, defaultStyle: _objectStyle, isIntrinsicBox: true) {
    initObjectClient();
    initElementClient();
  }

  void initObjectClient() {
    _objectElementClientFactory = getObjectElementClientFactory() ?? _DefaultObjectElementClientFactory;
    _objectElementClient = _objectElementClientFactory(this);
  }

  Future initElementClient() async {
    try {
      await _objectElementClient.initElementClient(properties);
    } catch (error, stackTrace) {
      print('$error\n$stackTrace');
    }
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

  @override
  handleJSCall(String method, List argv) {
    var result = _objectElementClient.handleJSCall(method, argv);
    if (result == null) {
      return super.handleJSCall(method, argv);
    }
    return result;
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    _objectElementClient.willAttachRenderer();
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _objectElementClient.didAttachRenderer();
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();
    _objectElementClient.willDetachRenderer();
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _objectElementClient.didDetachRenderer();
  }

  @override
  void updateChildTextureBox(TextureBox? textureBox) {
    if (textureBox != null) addChild(textureBox);
  }

  @override
  void dispose() {
    super.dispose();
    disposeClient();
  }

  void disposeClient() {
    _objectElementClient.dispose();
  }
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

  /// called when Element js method called
  /// [name] method name
  /// [args] method params
  @override
  dynamic handleJSCall(String method, List argv) {
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

  @override
  void didAttachRenderer() {
  }

  @override
  void didDetachRenderer() {
  }

  @override
  void willAttachRenderer() {
  }

  @override
  void willDetachRenderer() {
  }
}
