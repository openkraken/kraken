/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/src/element/element_manager.dart';

class KrakenWidget extends StatefulWidget {
  final String url;

  KrakenWidget(this.url, {Key key}) : super(key: key);

  @override
  _KrakenWidgetState createState() => _KrakenWidgetState();

  @override
  StatefulElement createElement() {
    return super.createElement();
  }
}

class _KrakenWidgetState extends State<KrakenWidget> {
  ElementManager elementManager;
  String _bundleURLOverride;
  String _bundlePathOverride;
  String _bundleContentOverride;

  KrakenViewController controller;

  _KrakenWidgetState() {
    controller = KrakenViewController(
        showPerformanceOverlay:
            Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null);
    elementManager = controller.getElementManager();
  }

  @override
  Widget build(BuildContext context) {
    if (elementManager == null) {
      return Container();
    }
    return KrakenRenderWidget(elementManager);
  }

  @override
  void initState() {
    super.initState();
    // Bootstrap binding.
    init();
  }

  Future init() async {
    _bundleURLOverride = widget.url;
    await controller.loadBundle(
        bundleURLOverride: _bundleURLOverride,
        bundlePathOverride: _bundlePathOverride,
        bundleContentOverride: _bundleContentOverride);
    await controller.run();
    setState(() {});
  }

  int currentId;

  bool disposed = false;

  @override
  void dispose() {
    super.dispose();
    controller.getElementManager().detach();
    disposed = true;
  } // See http://github.com/flutter/flutter/wiki/Desktop-shells
}

class KrakenRenderWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const KrakenRenderWidget(ElementManager elementManager, {Key key})
      : _elementManager = elementManager,
        super(key: key);

  final ElementManager _elementManager;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _elementManager.getRootRenderObject();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('KrakenRenderWidget', 'url'));
  }

  @override
  _KrakenRenderElement createElement() => _KrakenRenderElement(this);
}

class _KrakenRenderElement extends SingleChildRenderObjectElement {
  _KrakenRenderElement(KrakenRenderWidget widget) : super(widget);

  @override
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    super.debugVisitOnstageChildren(visitor);
  }

  @override
  void update(SingleChildRenderObjectWidget newWidget) {
    super.update(newWidget);
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
  }

  @override
  void attachRenderObject(dynamic newSlot) {
    super.attachRenderObject(newSlot);
  }
}
