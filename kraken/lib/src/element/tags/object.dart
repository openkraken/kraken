/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';
import 'package:kraken/src/element/object_element_factory.dart';

const String OBJECT = 'OBJECT';

const Map<String, dynamic> _defaultStyle = {
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

_DefaultObjectElementClient _DefaultObjectElementFactory() {
  return _DefaultObjectElementClient();
}

///https://developer.mozilla.org/en-US/docs/Web/HTML/Element/object
class ObjectElement extends Element implements ObjectElementHost {
  static double defaultWidth = 300.0;
  static double defaultHeight = 150.0;

  ObjectElementClientFactory _objectElementClientFactory;
  ObjectElementClient _objectElementClient;
  RenderConstrainedBox _sizedBox;
  TextureBox _textureBox;

  /// Element attribute width
  double _width;

  /// Element attribute height
  double _height;

  ObjectElement(targetId, ElementManager elementManager)
      : super(targetId, elementManager, tagName: OBJECT, defaultStyle: _defaultStyle, isIntrinsicBox: true) {
    initObjectClient();
    initSizedBox();
  }

  @override
  double get height => _height ?? 0.0;

  set height(double newValue) {
    if (newValue != null) {
      _height = newValue;
      _sizedBox.additionalConstraints = BoxConstraints.expand(
        width: width,
        height: height,
      );
    }
  }

  @override
  double get width => _width ?? 0.0;

  set width(double newValue) {
    if (newValue != null) {
      _width = newValue;
      _sizedBox.additionalConstraints = BoxConstraints.expand(
        width: width,
        height: height,
      );
    }
  }

  void initObjectClient() {
    _objectElementClientFactory = getObjectElementFactory() ?? _DefaultObjectElementFactory;
    _objectElementClient = _objectElementClientFactory();
  }

  void initSizedBox() {
    _sizedBox = RenderConstrainedBox(
        additionalConstraints: BoxConstraints.loose(Size(
      CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_WIDTH),
      CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_HEIGHT),
    )));
    addChild(_sizedBox);
    _textureBox = _objectElementClient?.createRenderObject(properties);
    if (_textureBox != null) {
      _sizedBox.child = _textureBox;
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case 'type':
        _objectElementClient?.setProperty(key, value);
        break;
      case 'data':
        _objectElementClient?.setProperty(key, value);
        break;
      default:
        break;
    }
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    switch (key) {
      case WIDTH:
      case HEIGHT:
        _updateSizedBox();
        break;
    }
    _objectElementClient?.setStyle(key, value);
  }

  void _updateSizedBox() {
    double w = style.contains(WIDTH) ? CSSLength.toDisplayPortValue(style[WIDTH]) : null;
    double h = style.contains(HEIGHT) ? CSSLength.toDisplayPortValue(style[HEIGHT]) : null;
    _sizedBox.additionalConstraints = BoxConstraints.tight(Size(w ?? defaultWidth, h ?? defaultHeight));
  }
}

class _DefaultObjectElementClient implements ObjectElementClient {
  @override
  TextureBox createRenderObject(Map<String, dynamic> properties) {
    print('call DefaultObjectElementClient createRenderObject properties[$properties]');
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
}
