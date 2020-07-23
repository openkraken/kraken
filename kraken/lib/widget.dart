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
  // a absolute URL address which point to a javascript source file.
  final String bundleURL;
  // a local file path which point to a javascript source file.
  final String bundlePath;
  // a raw javascript source content which will evaluate after kraken have initialized.
  final String bundleContent;
  // the name of krakenWidget. a property used to communicate with native using Kraken SDK API.
  final String name;

  // the width of krakenWidget
  final double viewportWidth;
  // the height of krakenWidget
  final double viewportHeight;
  // the kraken controller.
  final KrakenController controller;

  KrakenWidget(String name, double viewportWidth, double viewportHeight,
      {Key key, this.bundleURL, this.bundlePath, this.bundleContent})
      : viewportWidth = viewportWidth,
        viewportHeight = viewportHeight,
        name = name,
        controller = KrakenController(name, viewportWidth, viewportHeight,
            showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null),
        super(key: key);

  @override
  _KrakenWidgetState createState() => _KrakenWidgetState(controller);

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
  final KrakenController _controller;
  _KrakenWidgetState(this._controller);

  @override
  Widget build(BuildContext context) {
    return KrakenRenderWidget(_controller);
  }

  @override
  void initState() {
    super.initState();
    // Bootstrap binding.
    init();
  }

  Future init() async {
    await _controller.loadBundle(
        bundleURLOverride: widget.bundleURL,
        bundlePathOverride: widget.bundlePath,
        bundleContentOverride: widget.bundleContent);
    await _controller.run();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
