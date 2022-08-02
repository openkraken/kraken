/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/gesture.dart';
import 'package:webf/css.dart';
import 'package:webf/src/dom/element_registry.dart';

class WebF extends StatefulWidget {
  // The background color for viewport, default to transparent.
  final Color? background;

  // the width of webFWidget
  final double? viewportWidth;

  // the height of webFWidget
  final double? viewportHeight;

  //  The initial bundle to load.
  final WebFBundle? bundle;

  // The animationController of Flutter Route object.
  // Pass this object to webFWidget to make sure webF execute JavaScripts scripts after route transition animation completed.
  final AnimationController? animationController;

  // The methods of the webFNavigateDelegation help you implement custom behaviors that are triggered
  // during a webf view's process of loading, and completing a navigation request.
  final WebFNavigationDelegate? navigationDelegate;

  // A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final WebFMethodChannel? javaScriptChannel;

  // Register the RouteObserver to observer page navigation.
  // This is useful if you wants to pause webf timers and callbacks when webf widget are hidden by page route.
  // https://api.flutter.dev/flutter/widgets/RouteObserver-class.html
  final RouteObserver<ModalRoute<void>>? routeObserver;

  // Trigger when webf controller once created.
  final OnControllerCreated? onControllerCreated;

  final LoadErrorHandler? onLoadError;

  final LoadHandler? onLoad;

  final JSErrorHandler? onJSError;

  // Open a service to support Chrome DevTools for debugging.
  final DevToolsService? devToolsService;

  final GestureListener? gestureListener;

  final HttpClientInterceptor? httpClientInterceptor;

  final UriParser? uriParser;

  WebFController? get controller {
    return WebFController.getControllerOfName(shortHash(this));
  }

  // Set webf http cache mode.
  static void setHttpCacheMode(HttpCacheMode mode) {
    HttpCacheController.mode = mode;
    if (kDebugMode) {
      print('WebF http cache mode set to $mode.');
    }
  }

  static bool _isValidCustomElementName(localName) {
    return RegExp(r'^[a-z][.0-9_a-z]*-[\-.0-9_a-z]*$').hasMatch(localName);
  }

  static void defineCustomElement(String tagName, ElementCreator creator) {
    if (!_isValidCustomElementName(tagName)) {
      throw ArgumentError('The element name "$tagName" is not valid.');
    }
    defineElement(tagName.toUpperCase(), creator);
  }

  Future<void> load(WebFBundle bundle) async {
    await controller?.load(bundle);
  }

  Future<void> reload() async {
    await controller?.reload();
  }

  WebF(
      {Key? key,
      this.viewportWidth,
      this.viewportHeight,
      this.bundle,
      this.onControllerCreated,
      this.onLoad,
      this.navigationDelegate,
      this.javaScriptChannel,
      this.background,
      this.gestureListener,
      this.devToolsService,
      // webf's http client interceptor.
      this.httpClientInterceptor,
      this.uriParser,
      this.routeObserver,
      // webf's viewportWidth options only works fine when viewportWidth is equal to window.physicalSize.width / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version released. (v0.6.0)
      // Disable viewportWidth check and no assertion error report.
      bool disableViewportWidthAssertion = false,
      // webf's viewportHeight options only works fine when viewportHeight is equal to window.physicalSize.height / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version release. (v0.6.0)
      // Disable viewportHeight check and no assertion error report.
      bool disableViewportHeightAssertion = false,
      // Callback functions when loading Javascript scripts failed.
      this.onLoadError,
      this.animationController,
      this.onJSError})
      : super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  _WebFState createState() => _WebFState();
}

class _WebFState extends State<WebF> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return WebFTextControl(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.routeObserver != null) {
      widget.routeObserver!.subscribe(this, ModalRoute.of(context)!);
    }
  }

  // Resume call timer and callbacks when webf widget change to visible.
  @override
  void didPopNext() {
    assert(widget.controller != null);
    widget.controller!.resume();
  }

  // Pause all timer and callbacks when webf widget has been invisible.
  @override
  void didPushNext() {
    assert(widget.controller != null);
    widget.controller!.pause();
  }

  @override
  void dispose() {
    if (widget.routeObserver != null) {
      widget.routeObserver!.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void deactivate() {
    // Deactivate all WidgetElements in webf when webf Widget is deactivated.
    widget.controller!.view.deactivateWidgetElements();

    super.deactivate();
  }
}

class WebFRenderObjectWidget extends SingleChildRenderObjectWidget {
  // Creates a widget that visually hides its child.
  const WebFRenderObjectWidget(WebF widget, WidgetDelegate widgetDelegate, {Key? key})
      : _webfWidget = widget,
        _widgetDelegate = widgetDelegate,
        super(key: key);

  final WebF _webfWidget;
  final WidgetDelegate _widgetDelegate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_INIT_START);
    }

    double viewportWidth = _webfWidget.viewportWidth ?? window.physicalSize.width / window.devicePixelRatio;
    double viewportHeight = _webfWidget.viewportHeight ?? window.physicalSize.height / window.devicePixelRatio;

    if (viewportWidth == 0.0 && viewportHeight == 0.0) {
      throw FlutterError('''Can't get viewportSize from window. Please set viewportWidth and viewportHeight manually.
This situation often happened when you trying creating webf when FlutterView not initialized.''');
    }

    WebFController controller = WebFController(shortHash(_webfWidget.hashCode), viewportWidth, viewportHeight,
        background: _webfWidget.background,
        showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
        entrypoint: _webfWidget.bundle,
        // Execute entrypoint when mount manually.
        autoExecuteEntrypoint: false,
        onLoad: _webfWidget.onLoad,
        onLoadError: _webfWidget.onLoadError,
        onJSError: _webfWidget.onJSError,
        methodChannel: _webfWidget.javaScriptChannel,
        gestureListener: _webfWidget.gestureListener,
        navigationDelegate: _webfWidget.navigationDelegate,
        devToolsService: _webfWidget.devToolsService,
        httpClientInterceptor: _webfWidget.httpClientInterceptor,
        widgetDelegate: _widgetDelegate,
        uriParser: _webfWidget.uriParser);

    OnControllerCreated? onControllerCreated = _webfWidget.onControllerCreated;
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
    WebFController controller = (renderObject as RenderObjectWithControllerMixin).controller!;
    controller.name = shortHash(_webfWidget.hashCode);

    bool viewportWidthHasChanged = controller.view.viewportWidth != _webfWidget.viewportWidth;
    bool viewportHeightHasChanged = controller.view.viewportHeight != _webfWidget.viewportHeight;

    double viewportWidth = _webfWidget.viewportWidth ?? window.physicalSize.width / window.devicePixelRatio;
    double viewportHeight = _webfWidget.viewportHeight ?? window.physicalSize.height / window.devicePixelRatio;

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
    WebFController controller = (renderObject as RenderObjectWithControllerMixin).controller!;
    controller.dispose();
  }

  @override
  _WebFRenderObjectElement createElement() {
    return _WebFRenderObjectElement(this);
  }
}

class _WebFRenderObjectElement extends SingleChildRenderObjectElement {
  _WebFRenderObjectElement(WebFRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    WebFController controller = (renderObject as RenderObjectWithControllerMixin).controller!;

    // We should make sure every flutter elements created under webf can be walk up to the root.
    // So we bind _WebFRenderObjectElement into WebFController, and widgetElements created by controller can follow this to the root.
    controller.rootFlutterElement = this;
    await controller.executeEntrypoint(animationController: widget._webfWidget.animationController);
  }

  // RenderObjects created by webf are manager by webf itself. There are no needs to operate renderObjects on _WebFRenderObjectElement.
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}
  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {}
  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  WebFRenderObjectWidget get widget => super.widget as WebFRenderObjectWidget;
}
