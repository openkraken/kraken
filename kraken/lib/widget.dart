/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/module.dart';
import 'package:meta/meta.dart';

typedef KrakenOnLoad = void Function(KrakenController controller);

class Kraken extends StatelessWidget {
  // the width of krakenWidget
  final double viewportWidth;

  // the height of krakenWidget
  final double viewportHeight;

  // The initial URL to load.
  final String bundleURL;
  // The initial assets path to load.
  final String bundlePath;
  // The initial raw javascript content to load.
  final String bundleContent;

  // The animationController of Flutter Route object.
  // Pass this object to KrakenWidget to make sure Kraken execute JavaScripts scripts after route transition animation completed.
  final AnimationController animationController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  final KrakenNavigationDelegate navigationDelegate;

  // A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final KrakenJavaScriptChannel javaScriptChannel;

  final LoadErrorHandler loadErrorHandler;

  final KrakenOnLoad onLoad;

  KrakenController get controller {
    return KrakenController.getControllerOfName(shortHash(this));
  }

  Kraken({
      Key key,
      @required this.viewportWidth,
      @required this.viewportHeight,
      this.bundleURL,
      this.bundlePath,
      this.bundleContent,
      this.onLoad,
      this.navigationDelegate,
      this.javaScriptChannel,
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
      this.loadErrorHandler,
      this.animationController})
      : super(key: key) {

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
  const KrakenRenderWidget(Kraken widget, {Key key})
      : _widget = widget,
        super(key: key);

  final Kraken _widget;

  @override
  RenderObject createRenderObject(BuildContext context) {
    KrakenController controller = KrakenController(shortHash(_widget.hashCode), _widget.viewportWidth, _widget.viewportHeight,
        showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
        bundleURL: _widget.bundleURL,
        bundlePath: _widget.bundlePath,
        loadErrorHandler: _widget.loadErrorHandler,
        methodChannel: _widget.javaScriptChannel,
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

    if (widget._widget.onLoad != null) {
      widget._widget.onLoad(controller);
    }
  }

  @override
  KrakenRenderWidget get widget => super.widget as KrakenRenderWidget;
}
