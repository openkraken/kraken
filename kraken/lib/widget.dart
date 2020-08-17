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

class KrakenWidget extends StatelessWidget {
  // the name of krakenWidget. a property used to communicate with native using Kraken SDK API.
  final String name;

  // the width of krakenWidget
  final double viewportWidth;
  // the height of krakenWidget
  final double viewportHeight;
  // the kraken controller.
  final KrakenController controller;

  KrakenWidget(String name, double viewportWidth, double viewportHeight,
      {Key key, String bundleURL, String bundlePath, String bundleContent})
      : viewportWidth = viewportWidth,
        viewportHeight = viewportHeight,
        name = name,
        controller = KrakenController(name, viewportWidth, viewportHeight,
            showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null),
        super(key: key) {
    controller.bundleURL = bundleURL;
    controller.bundlePath = bundlePath;
    controller.bundleContent = bundleContent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  Widget build(BuildContext context) {
    return KrakenRenderWidget(controller);
  }
}

class KrakenRenderWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const KrakenRenderWidget(KrakenController controller, {Key key})
      : _controller = controller,
        super(key: key);

  final KrakenController _controller;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _controller.view.getRootRenderObject();
  }

  @override
  _KrakenRenderElement createElement() => _KrakenRenderElement(this);
}

class _KrakenRenderElement extends SingleChildRenderObjectElement {
  _KrakenRenderElement(KrakenRenderWidget widget) : super(widget);

  @override
  void mount(Element parent, dynamic newSlot) async {
    super.mount(parent, newSlot);
    await widget._controller.loadBundle();
    await widget._controller.run();
  }

  @override
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;
}
