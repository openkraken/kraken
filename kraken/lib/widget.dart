/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';

class KrakenWidget extends StatelessWidget {
  // the name of krakenWidget. a property used to communicate with native using Kraken SDK API.
  final String name;

  // the width of krakenWidget
  final double viewportWidth;

  // the height of krakenWidget
  final double viewportHeight;

  final String bundleURL;
  final String bundlePath;
  final String bundleContent;

  // The animationController of Flutter Route object.
  // Pass this object to KrakenWidget to make sure Kraken execute JavaScripts scripts after route transition animation completed.
  final AnimationController animationController;

  KrakenWidget(String name, double viewportWidth, double viewportHeight,
      {Key key, String bundleURL, String bundlePath, String bundleContent, this.animationController})
      : viewportWidth = viewportWidth,
        viewportHeight = viewportHeight,
        bundleURL = bundleURL,
        bundlePath = bundlePath,
        bundleContent = bundleContent,
        name = name,
        super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  Widget build(BuildContext context) {
    return KrakenRenderWidget(this);
  }
}

class KrakenRenderWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const KrakenRenderWidget(KrakenWidget widget, {Key key})
      : _widget = widget,
        super(key: key);

  final KrakenWidget _widget;

  @override
  RenderObject createRenderObject(BuildContext context) {
    KrakenController controller = KrakenController(_widget.name, _widget.viewportWidth, _widget.viewportHeight,
        showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
        bundleURL: _widget.bundleURL,
        bundlePath: _widget.bundlePath,
        bundleContent: _widget.bundleContent);
    return controller.view.getRootRenderObject();
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    KrakenController controller = (renderObject as RenderBoxModel).controller;
    controller.dispose();
  }

  @override
  _KrakenRenderElement createElement() {
    return _KrakenRenderElement(this);
  }
}

class _KrakenRenderElement extends SingleChildRenderObjectElement {
  _KrakenRenderElement(KrakenRenderWidget widget) : super(widget);

  @override
  void mount(Element parent, dynamic newSlot) async {
    super.mount(parent, newSlot);
    KrakenController controller = (renderObject as RenderBoxModel).controller;
    await controller.loadBundle();
    // Execute JavaScript scripts will block the Flutter UI Threads.
    // Listen for animationController listener to make sure to execute Javascript after route transition had completed.
    if (controller.bundleURL == null && widget._widget.animationController != null) {
      widget._widget.animationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.run();
        }
      });
    } else {
      await controller.run();
    }
  }

  @override
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;
}
