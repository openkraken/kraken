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

    HTMLViewController view = HTMLViewController(
      viewportWidth,
      viewportHeight,
      background: null,
      enableDebug: false,
      rootController: null,
      navigationDelegate: KrakenNavigationDelegate(),
      widgetDelegate: _widgetDelegate,
    );

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_INIT_END);
    }

    return view.getRootRenderObject();
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;
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
    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;
    controller.dispose();
  }

  @override
  _HTMLViewRenderObjectElement createElement() {
    return _HTMLViewRenderObjectElement(this);
  }
}

class _HTMLViewRenderObjectElement extends SingleChildRenderObjectElement {
  _HTMLViewRenderObjectElement(_HTMLViewRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;
  }

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
  final String html;

  HTMLViewState(this.html);

  @override
  Widget build(BuildContext context) {
    // print('context.widget=${context.widget}');
    return RepaintBoundary(
        child: FocusableActionDetector(
            actions: actionMap,
            focusNode: focusNode,
            onFocusChange: handleFocusChange,
            // TODO: _HTMLViewRenderObjectWidget
            // child: Text(html),
            child: _HTMLViewRenderObjectWidget(
              context.widget as HTMLView,
              widgetDelegate,
            )
        )
    );
  }
}

class HTMLView extends StatefulWidget {

  // the string of HTML.
  final String data;

  // the width of krakenWidget.
  final double? viewportWidth;

  // the height of krakenWidget.
  final double? viewportHeight;

  HTMLView(this.data, {
    this.viewportWidth,
    this.viewportHeight,
  });

  @override
  HTMLViewState createState() => HTMLViewState(data);
}
