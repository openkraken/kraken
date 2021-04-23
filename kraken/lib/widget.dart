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
import 'package:kraken/module.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';

class Kraken extends StatelessWidget {
  // The background color for viewport, default to transparent.
  final Color background;

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

  final LoadErrorHandler onLoadError;

  final LoadHandler onLoad;

  final JSErrorHandler onJSError;

  final KrakenDevToolsInterface devTools;

  final bool debugEnableInspector;

  final GestureClient gestureClient;

  KrakenController get controller {
    return KrakenController.getControllerOfName(shortHash(this));
  }

  loadContent(String bundleContent) async {
    if (bundleContent == null) return;
    await controller.unload();
    await controller.loadBundle(
      bundleContent: bundleContent
    );
    _evalBundle(controller, animationController);
  }

  loadURL(String bundleURL) async {
    if (bundleURL == null) return;
    await controller.unload();
    await controller.loadBundle(
      bundleURL: bundleURL
    );
    _evalBundle(controller, animationController);
  }

  loadPath(String bundlePath) async {
    if (bundlePath == null) return;
    await controller.unload();
    await controller.loadBundle(
      bundlePath: bundlePath
    );
    _evalBundle(controller, animationController);
  }

  reload() async {
    await controller.reload();
  }

  Kraken({
    Key key,
    this.viewportWidth,
    this.viewportHeight,
    this.bundleURL,
    this.bundlePath,
    this.bundleContent,
    this.onLoad,
    this.navigationDelegate,
    this.javaScriptChannel,
    this.background,
    this.gestureClient,
    this.devTools,
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
    this.onLoadError,
    this.animationController,
    this.debugEnableInspector,
    this.onJSError
  }) : super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  Widget build(BuildContext context) {
    return _KrakenRenderObjectWidget(this);
  }
}

class _KrakenRenderObjectWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const _KrakenRenderObjectWidget(Kraken widget, {Key key})
      : _krakenWidget = widget,
        super(key: key);

  final Kraken _krakenWidget;

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (kProfileMode) {
      PerformanceTiming.instance(0).mark(PERF_CONTROLLER_INIT_START);
    }

    double viewportWidth = _krakenWidget.viewportWidth ?? window.physicalSize.width / window.devicePixelRatio;
    double viewportHeight = _krakenWidget.viewportHeight ?? window.physicalSize.height / window.devicePixelRatio;

    KrakenController controller = KrakenController(shortHash(_krakenWidget.hashCode), viewportWidth, viewportHeight,
      background: _krakenWidget.background,
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      bundleContent: _krakenWidget.bundleContent,
      bundleURL: _krakenWidget.bundleURL,
      bundlePath: _krakenWidget.bundlePath,
      onLoad: _krakenWidget.onLoad,
      onLoadError: _krakenWidget.onLoadError,
      onJSError: _krakenWidget.onJSError,
      methodChannel: _krakenWidget.javaScriptChannel,
      debugEnableInspector: _krakenWidget.debugEnableInspector,
      gestureClient: _krakenWidget.gestureClient,
      navigationDelegate: _krakenWidget.navigationDelegate,
      devToolsInterface: _krakenWidget.devTools
    );

    if (kProfileMode) {
      PerformanceTiming.instance(controller.view.contextId).mark(PERF_CONTROLLER_INIT_END);
    }

    return controller.view.getRootRenderObject();
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller;
    controller.name = shortHash(_krakenWidget.hashCode);

    bool viewportWidthHasChanged = controller.view.viewportWidth != _krakenWidget.viewportWidth;
    bool viewportHeightHasChanged = controller.view.viewportHeight != _krakenWidget.viewportHeight;

    if (viewportWidthHasChanged) {
      controller.view.viewportWidth = _krakenWidget.viewportWidth;
      controller.view.document.body.style.setProperty(WIDTH, controller.view.viewportWidth.toString() + 'px');
    }

    if (viewportHeightHasChanged) {
      controller.view.viewportHeight = _krakenWidget.viewportHeight;
      controller.view.document.body.style.setProperty(HEIGHT, controller.view.viewportHeight.toString() + 'px');
    }

    if (viewportWidthHasChanged || viewportHeightHasChanged) {
      traverseElement(controller.view.document.body, (element) {
        element.style.applyTargetProperties();
        element.renderBoxModel.markNeedsLayout();
      });
    }
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller;
    controller.dispose();
  }

  @override
  _KrakenRenderObjectElement createElement() {
    return _KrakenRenderObjectElement(this);
  }
}

class _KrakenRenderObjectElement extends SingleChildRenderObjectElement {
  _KrakenRenderObjectElement(_KrakenRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element parent, dynamic newSlot) async {
    super.mount(parent, newSlot);

    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller;

    if (controller.bundleContent == null && controller.bundlePath == null && controller.bundleURL == null) {
      return;
    }

    await controller.loadBundle();

    _evalBundle(controller, widget._krakenWidget.animationController);
  }

  @override
  _KrakenRenderObjectWidget get widget => super.widget as _KrakenRenderObjectWidget;
}

void _evalBundle(KrakenController controller, AnimationController animationController) async {
  // Execute JavaScript scripts will block the Flutter UI Threads.
  // Listen for animationController listener to make sure to execute Javascript after route transition had completed.
  if (animationController != null) {
    animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        controller.evalBundle();
      }
    });
  } else {
    await controller.evalBundle();
  }
}

