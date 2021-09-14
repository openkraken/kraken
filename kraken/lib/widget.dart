/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'dart:ui';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';
import 'package:kraken/src/dom/element_registry.dart';
import 'package:kraken/src/dom/element_manager.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart' as dom;

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

typedef WidgetCreator = Widget Function(Map<String, dynamic>);
class _WidgetCustomElement extends dom.Element {
  late WidgetCreator _widgetCreator;
  late Element _renderViewElement;
  late BuildOwner _buildOwner;
  late Widget _widget;
  _KrakenAdapterWidgetPropertiesState? _propertiesState;
  _WidgetCustomElement(int targetId, Pointer<NativeEventTarget> nativePtr, dom.ElementManager elementManager, String tagName, WidgetCreator creator)
      : super(
      targetId,
      nativePtr,
      elementManager,
      tagName: tagName,
      isIntrinsicBox: true,
      defaultStyle: _defaultStyle
  ) {
    _widgetCreator = creator;
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    WidgetsFlutterBinding.ensureInitialized();

    _propertiesState = _KrakenAdapterWidgetPropertiesState(_widgetCreator, properties);
    _widget = _KrakenAdapterWidget(_propertiesState!);
    _attachWidget(_widget);
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (_propertiesState != null) {
      _propertiesState!.onAttributeChanged(properties);
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (_propertiesState != null) {
      _propertiesState!.onAttributeChanged(properties);
    }
  }

  void _handleBuildScheduled() {
    // Register drawFrame callback same with [WidgetsBinding.drawFrame]
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      _buildOwner.buildScope(_renderViewElement);
      // ignore: invalid_use_of_protected_member
      RendererBinding.instance!.drawFrame();
      _buildOwner.finalizeTree();
    });
    SchedulerBinding.instance!.ensureVisualUpdate();
  }

  void _attachWidget(Widget widget) {
    // A new buildOwner difference with flutter's buildOwner
    _buildOwner = BuildOwner(focusManager: WidgetsBinding.instance!.buildOwner!.focusManager);
    _buildOwner.onBuildScheduled = _handleBuildScheduled;
    _renderViewElement = RenderObjectToWidgetAdapter<RenderBox>(
        child: widget,
        container: renderBoxModel as RenderObjectWithChildMixin<RenderBox>,
      ).attachToRenderTree(_buildOwner);
  }
}

class _KrakenAdapterWidget extends StatefulWidget {
  final _KrakenAdapterWidgetPropertiesState _state;
  _KrakenAdapterWidget(this._state);
  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class _KrakenAdapterWidgetPropertiesState extends State<_KrakenAdapterWidget> {
  Map<String, dynamic> _properties;
  final WidgetCreator _widgetCreator;
  _KrakenAdapterWidgetPropertiesState(this._widgetCreator, this._properties);

  void onAttributeChanged(Map<String, dynamic> properties) {
    setState(() {
      _properties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _widgetCreator(_properties);
  }
}

class Kraken extends StatelessWidget {
  // The background color for viewport, default to transparent.
  final Color? background;

  // the width of krakenWidget
  final double? viewportWidth;

  // the height of krakenWidget
  final double? viewportHeight;

  // The initial URL to load.
  final String? bundleURL;

  // The initial assets path to load.
  final String? bundlePath;

  // The initial raw javascript content to load.
  final String? bundleContent;

  // The initial raw bytecode to load.
  final Uint8List? bundleByteCode;

  // The animationController of Flutter Route object.
  // Pass this object to KrakenWidget to make sure Kraken execute JavaScripts scripts after route transition animation completed.
  final AnimationController? animationController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  final KrakenNavigationDelegate? navigationDelegate;

  // A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final KrakenMethodChannel? javaScriptChannel;

  final LoadErrorHandler? onLoadError;

  final LoadHandler? onLoad;

  final JSErrorHandler ?onJSError;

  // Open a service to support Chrome DevTools for debugging.
  // https://github.com/openkraken/devtools
  final DevToolsService? devToolsService;

  final GestureClient? gestureClient;

  final EventClient? eventClient;

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

  static void defineCustomElement<T extends Function>(String localName, T creator) {
    if (!_isValidCustomElementName(localName)) {
      throw ArgumentError('The element name "$localName" is not valid.');
    }

    String tagName = localName.toUpperCase();

    print(ElementCreator == T);

    if (T == ElementCreator) {
      defineElement(tagName, creator as ElementCreator);
    } else if (T == WidgetCreator) {
      defineElement(tagName, (id, nativePtr, elementManager) {
        return _WidgetCustomElement(id, nativePtr.cast<NativeEventTarget>(), elementManager, tagName, creator as WidgetCreator);
      });
    }
  }

  loadContent(String bundleContent, {String aaa = ''}) async {
    await controller!.unload();
    await controller!.loadBundle(
      bundleContent: bundleContent
    );
    _evalBundle(controller!, animationController);
  }

  loadByteCode(Uint8List bytecode) async {
    await controller!.unload();
    await controller!.loadBundle(
      bundleByteCode: bytecode
    );
    _evalBundle(controller!, animationController);
  }

  loadURL(String bundleURL) async {
    await controller!.unload();
    await controller!.loadBundle(
      bundleURL: bundleURL
    );
    _evalBundle(controller!, animationController);
  }

  loadPath(String bundlePath) async {
    await controller!.unload();
    await controller!.loadBundle(
      bundlePath: bundlePath
    );
    _evalBundle(controller!, animationController);
  }

  reload() async {
    await controller!.reload();
  }

  Kraken({
    Key? key,
    this.viewportWidth,
    this.viewportHeight,
    this.bundleURL,
    this.bundlePath,
    this.bundleContent,
    this.bundleByteCode,
    this.onLoad,
    this.navigationDelegate,
    this.javaScriptChannel,
    this.background,
    this.gestureClient,
    this.eventClient,
    this.devToolsService,
    // Kraken's http client interceptor.
    this.httpClientInterceptor,
    this.uriParser,
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
  Widget build(BuildContext context) {
    return _KrakenRenderObjectWidget(this);
  }
}

class _KrakenRenderObjectWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const _KrakenRenderObjectWidget(Kraken widget, {Key? key})
      : _krakenWidget = widget,
        super(key: key);

  final Kraken _krakenWidget;

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
      gestureClient: _krakenWidget.gestureClient,
      eventClient: _krakenWidget.eventClient,
      navigationDelegate: _krakenWidget.navigationDelegate,
      devToolsService: _krakenWidget.devToolsService,
      httpClientInterceptor: _krakenWidget.httpClientInterceptor,
      uriParser: _krakenWidget.uriParser
    );

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

    Size viewportSize = Size(viewportWidth, viewportHeight);

    if (viewportWidthHasChanged) {
      controller.view.viewportWidth = viewportWidth;
      controller.view.document!.documentElement.style.setProperty(WIDTH, controller.view.viewportWidth.toString() + 'px', viewportSize);
    }

    if (viewportHeightHasChanged) {
      controller.view.viewportHeight = viewportHeight;
      controller.view.document!.documentElement.style.setProperty(HEIGHT, controller.view.viewportHeight.toString() + 'px', viewportSize);
    }

    if (viewportWidthHasChanged || viewportHeightHasChanged) {
      traverseElement(controller.view.document!.documentElement, (element) {
        if (element.isRendererAttached) {
          element.style.applyTargetProperties();
          element.renderBoxModel?.markNeedsLayout();
        }
      });
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
  _KrakenRenderObjectElement(_KrakenRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;

    if (controller.bundleContent == null && controller.bundlePath == null && controller.bundleURL == null) {
      return;
    }

    await controller.loadBundle();

    _evalBundle(controller, widget._krakenWidget.animationController);
  }

  @override
  _KrakenRenderObjectWidget get widget => super.widget as _KrakenRenderObjectWidget;
}

void _evalBundle(KrakenController controller, AnimationController? animationController) async {
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

