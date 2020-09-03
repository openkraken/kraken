/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
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

  KrakenWidget(String name, double viewportWidth, double viewportHeight,
      {Key key,
      String bundleURL,
      String bundlePath,
      String bundleContent,
      // Kraken's viewportWidth options only works fine when viewportWidth is equal to window.physicalSize.width / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version released. (v0.6.0)
      // Disable viewportWidth check and no assertion error report.
      bool disableViewportWidthAssertion = false,
      // Kraken's viewportHeight options only works fine when viewportHeight is equal to window.physicalSize.height / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version release. (v0.6.0)
      // Disable viewportHeight check and no assertion error report.
      bool disableViewportHeightAssertion = false,
      // Callback functions when loading Javascript scripts failed.
      KrakenLoadErrorFunction loadErrorFn})
      : viewportWidth = viewportWidth,
        viewportHeight = viewportHeight,
        bundleURL = bundleURL,
        bundlePath = bundlePath,
        bundleContent = bundleContent,
        name = name,
        super(key: key) {
    assert(!(viewportWidth != window.physicalSize.width / window.devicePixelRatio && !disableViewportWidthAssertion),
    'viewportWidth must temporarily equal to window.physicalSize.width / window.devicePixelRatio, as a result of vw uint in current version is not relative to viewportWidth.');
    assert(!(viewportHeight != window.physicalSize.height / window.devicePixelRatio && !disableViewportHeightAssertion),
    'viewportHeight must temporarily equal to window.physicalSize.height / window.devicePixelRatio, as a result of vh uint in current version is not relative to viewportHeight.');
  }

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
    await controller.run();
  }

  @override
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;
}
