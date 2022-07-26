/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';
import 'package:kraken/src/dom/element_registry.dart';

class Kraken extends StatefulWidget {
  // The background color for viewport, default to transparent.
  final Color? background;

  // the width of krakenWidget
  final double? viewportWidth;

  // the height of krakenWidget
  final double? viewportHeight;

  //  The initial bundle to load.
  final KrakenBundle? bundle;

  // The animationController of Flutter Route object.
  // Pass this object to KrakenWidget to make sure Kraken execute JavaScripts scripts after route transition animation completed.
  final AnimationController? animationController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  final KrakenNavigationDelegate? navigationDelegate;

  // A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final KrakenMethodChannel? javaScriptChannel;

  // Register the RouteObserver to observer page navigation.
  // This is useful if you wants to pause kraken timers and callbacks when kraken widget are hidden by page route.
  // https://api.flutter.dev/flutter/widgets/RouteObserver-class.html
  final RouteObserver<ModalRoute<void>>? routeObserver;

  // Trigger when kraken controller once created.
  final OnControllerCreated? onControllerCreated;

  final LoadErrorHandler? onLoadError;

  final LoadHandler? onLoad;

  final JSErrorHandler ?onJSError;

  // Open a service to support Chrome DevTools for debugging.
  // https://github.com/openkraken/devtools
  final DevToolsService? devToolsService;

  final GestureListener? gestureListener;

  final HttpClientInterceptor? httpClientInterceptor;

  final UriParser? uriParser;

  KrakenController? get controller {
    return KrakenController.getControllerOfName(shortHash(this));
  }

  // Set kraken http cache mode.
  static void setHttpCacheMode(HttpCacheMode mode) {
    HttpCacheController.mode = mode;
    if (kDebugMode) {
      print('Kraken http cache mode set to $mode.');
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

  Future<void> load(KrakenBundle bundle) async {
    await controller?.load(bundle);
  }

  Future<void> reload() async {
    await controller?.reload();
  }

  Kraken({
    Key? key,
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
    // Kraken's http client interceptor.
    this.httpClientInterceptor,
    this.uriParser,
    this.routeObserver,
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
    this.onJSError
  }) : super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  _KrakenState createState() => _KrakenState();
}

class _KrakenState extends State<Kraken> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return KrakenTextControl(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.routeObserver != null) {
      widget.routeObserver!.subscribe(this, ModalRoute.of(context)!);
    }
  }

  // Resume call timer and callbacks when kraken widget change to visible.
  @override
  void didPopNext() {
    assert(widget.controller != null);
    widget.controller!.resume();
  }

  // Pause all timer and callbacks when kraken widget has been invisible.
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
    // Deactivate all WidgetElements in Kraken when Kraken Widget is deactivated.
    widget.controller!.view.deactivateWidgetElements();

    super.deactivate();
  }
}

class KrakenRenderObjectWidget extends SingleChildRenderObjectWidget {
  // Creates a widget that visually hides its child.
  const KrakenRenderObjectWidget(
      Kraken widget,
      WidgetDelegate widgetDelegate,
      {Key? key}
      ) : _krakenWidget = widget,
        _widgetDelegate = widgetDelegate,
        super(key: key);

  final Kraken _krakenWidget;
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

    KrakenController controller = KrakenController(
        shortHash(_krakenWidget.hashCode),
        viewportWidth,
        viewportHeight,
        background: _krakenWidget.background,
        showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
        entrypoint: _krakenWidget.bundle,
        // Execute entrypoint when mount manually.
        autoExecuteEntrypoint: false,
        onLoad: _krakenWidget.onLoad,
        onLoadError: _krakenWidget.onLoadError,
        onJSError: _krakenWidget.onJSError,
        methodChannel: _krakenWidget.javaScriptChannel,
        gestureListener: _krakenWidget.gestureListener,
        navigationDelegate: _krakenWidget.navigationDelegate,
        devToolsService: _krakenWidget.devToolsService,
        httpClientInterceptor: _krakenWidget.httpClientInterceptor,
        widgetDelegate: _widgetDelegate,
        uriParser: _krakenWidget.uriParser
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
  _KrakenRenderObjectElement createElement() {
    return _KrakenRenderObjectElement(this);
  }
}

class _KrakenRenderObjectElement extends SingleChildRenderObjectElement {
  _KrakenRenderObjectElement(KrakenRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;

    // We should make sure every flutter elements created under kraken can be walk up to the root.
    // So we bind _KrakenRenderObjectElement into KrakenController, and widgetElements created by controller can follow this to the root.
    controller.rootFlutterElement = this;
    await controller.executeEntrypoint(animationController: widget._krakenWidget.animationController);
  }

  // RenderObjects created by kraken are manager by kraken itself. There are no needs to operate renderObjects on _KrakenRenderObjectElement.
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}
  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {}
  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  KrakenRenderObjectWidget get widget => super.widget as KrakenRenderObjectWidget;
}
