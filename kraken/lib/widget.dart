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

class KrakenWidget extends StatefulWidget {
  final String bundleURL;
  final String bundlePath;
  final String bundleContent;
  final double viewportWidth;
  final double viewportHeight;

  KrakenWidget(double viewportWidth, double viewportHeight,
      {Key key, this.bundleURL, this.bundlePath, this.bundleContent})
      : viewportWidth = viewportWidth,
        viewportHeight = viewportHeight,
        super(key: key);

  @override
  _KrakenWidgetState createState() => _KrakenWidgetState(viewportWidth, viewportHeight);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
    properties.add(DiagnosticsProperty<String>('bundleURL', bundleURL));
    properties.add(DiagnosticsProperty<String>('bundlePath', bundlePath));
    properties.add(DiagnosticsProperty<String>('bundleContent', bundleContent));
  }
}

class _KrakenWidgetState extends State<KrakenWidget> {
  KrakenController controller;

  _KrakenWidgetState(double viewportWidth, double viewportHeight) {
    controller = KrakenController(viewportWidth, viewportHeight,
        showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null);
  }

  @override
  Widget build(BuildContext context) {
    return KrakenRenderWidget(controller);
  }

  @override
  void initState() {
    super.initState();
    // Bootstrap binding.
    init();
  }

  Future init() async {
    await controller.loadBundle(
        bundleURLOverride: widget.bundleURL,
        bundlePathOverride: widget.bundlePath,
        bundleContentOverride: widget.bundleContent);
    await controller.run();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;
}
