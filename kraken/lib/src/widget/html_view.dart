/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';

import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/module.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';
import 'package:kraken/src/dom/element_registry.dart';

class _HTMLViewRenderObjectWidget extends SingleChildRenderObjectWidget {
  // Creates a widget that visually hides its child.
  const _HTMLViewRenderObjectWidget(
      HTMLView widget,
      WidgetDelegate widgetDelegate,
      {Key? key}
      ) : _krakenWidget = widget,
        _widgetDelegate = widgetDelegate,
        super(key: key);

  final HTMLView _krakenWidget;
  final WidgetDelegate _widgetDelegate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_INIT_START);
    }

    double viewportWidth = _krakenWidget.viewportWidth ?? window.physicalSize.width / window.devicePixelRatio;
    double viewportHeight = _krakenWidget.viewportHeight ?? window.physicalSize.height / window.devicePixelRatio;

    if (viewportWidth == 0.0 && viewportHeight == 0.0) {
      throw FlutterError('''Can't get viewportSize from window. Please set viewportWidth and viewportHeight manually.
This situation often happened when you trying creating kraken when FlutterView not initialized.''');
    }

    HTMLViewController controller = HTMLViewController(
      shortHash(_krakenWidget.hashCode),
      viewportWidth,
      viewportHeight,
      bundle: _krakenWidget.bundle,
      background: _krakenWidget.background,
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      devToolsService: _krakenWidget.devToolsService,
      widgetDelegate: _widgetDelegate,
      uriParser: _krakenWidget.uriParser,
    );

    OnControllerCreated? onControllerCreated = _krakenWidget.onControllerCreated;
    if (onControllerCreated != null) {
      onControllerCreated(controller);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_INIT_END);
    }

    return controller.view.getRootRenderObject();
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    HTMLViewController controller = (renderObject as RenderObjectWithControllerMixin).controller as HTMLViewController;
    controller.name = shortHash(_krakenWidget.hashCode);

    bool viewportWidthHasChanged = controller.view.viewportWidth != _krakenWidget.viewportWidth;
    bool viewportHeightHasChanged = controller.view.viewportHeight != _krakenWidget.viewportHeight;

    double viewportWidth = _krakenWidget.viewportWidth ?? window.physicalSize.width / window.devicePixelRatio;
    double viewportHeight = _krakenWidget.viewportHeight ?? window.physicalSize.height / window.devicePixelRatio;

    if (controller.view.document.documentElement == null) return;

    if (viewportWidthHasChanged) {
      controller.view.viewportWidth = viewportWidth;
      controller.view.document.documentElement!.renderStyle.width = CSSLengthValue(viewportWidth, CSSLengthType.PX);
    }

    if (viewportHeightHasChanged) {
      controller.view.viewportHeight = viewportHeight;
      controller.view.document.documentElement!.renderStyle.height = CSSLengthValue(viewportHeight, CSSLengthType.PX);
    }
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    HTMLViewController controller = (renderObject as RenderObjectWithControllerMixin).controller as HTMLViewController;
    controller.dispose();
  }

  @override
  _HTMLViewRenderObjectElement createElement() {
    return _HTMLViewRenderObjectElement(this);
  }
}

class _HTMLViewRenderObjectElement extends SingleChildRenderObjectElement {
  _HTMLViewRenderObjectElement(_HTMLViewRenderObjectWidget widget) : super(widget);

  // RenderObjects created by HTMLView are manager by HTMLView itself. There are no needs to operate renderObjects on _KrakenRenderObjectElement.
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}
  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {}
  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  _HTMLViewRenderObjectWidget get widget => super.widget as _HTMLViewRenderObjectWidget;
}

class HTMLViewState extends KrakenState<HTMLView> {
  final KrakenBundle bundle;

  HTMLViewState(this.bundle);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: FocusableActionDetector(
            actions: actionMap,
            focusNode: focusNode,
            onFocusChange: handleFocusChange,
            // TODO: _HTMLViewRenderObjectWidget
            child: _HTMLViewRenderObjectWidget(
              context.widget as HTMLView,
              widgetDelegate,
            )
        )
    );
  }
}

class HTMLView extends StatefulWidget {

  // the bundle of HTML.
  final KrakenBundle bundle;

  // the width of krakenWidget.
  final double? viewportWidth;

  // the height of krakenWidget.
  final double? viewportHeight;

  // The background color for viewport, default to transparent.
  final Color? background;

  // Open a service to support Chrome DevTools for debugging.
  // https://github.com/openkraken/devtools
  final DevToolsService? devToolsService;

  final HttpClientInterceptor? httpClientInterceptor;

  final UriParser? uriParser;

  // Trigger when kraken controller once created.
  final OnControllerCreated? onControllerCreated;

  HTMLView({
    required this.bundle,
    this.viewportWidth,
    this.viewportHeight,
    this.background,
    this.devToolsService,
    this.httpClientInterceptor,
    this.uriParser,
    this.onControllerCreated
  });

  @override
  HTMLViewState createState() => HTMLViewState(bundle);
}
