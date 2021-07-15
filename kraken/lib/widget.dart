/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/module.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';

class Kraken extends StatefulWidget {
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

  // The animationController of Flutter Route object.
  // Pass this object to KrakenWidget to make sure Kraken execute JavaScripts scripts after route transition animation completed.
  final AnimationController? animationController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  final KrakenNavigationDelegate? navigationDelegate;

  // A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final KrakenJavaScriptChannel? javaScriptChannel;

  final LoadErrorHandler? onLoadError;

  final LoadHandler? onLoad;

  final JSErrorHandler ?onJSError;

  // Open a service to support Chrome DevTools for debugging.
  // https://github.com/openkraken/devtools
  final DevToolsService? devToolsService;

  final GestureClient? gestureClient;

  final EventClient? eventClient;

  final HttpClientInterceptor? httpClientInterceptor;

  KrakenController? get controller {
    return KrakenController.getControllerOfName(shortHash(this));
  }

  loadContent(String bundleContent) async {
    await controller!.unload();
    await controller!.loadBundle(
      bundleContent: bundleContent
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
    this.onLoad,
    this.navigationDelegate,
    this.javaScriptChannel,
    this.background,
    this.gestureClient,
    this.eventClient,
    this.devToolsService,
    // Kraken's http client interceptor.
    this.httpClientInterceptor,
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
class _KrakenState extends State<Kraken> {
  Map<LogicalKeySet, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _krakenFocus;

  void initState() {
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handlePreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: _handleDirectionFocus),
    };
    _krakenFocus = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: _actionMap,
      shortcuts: _shortcutMap,
      focusNode: _krakenFocus,
      onFocusChange: _handleFocusChange,
      child: _KrakenRenderObjectWidget(context.widget as Kraken)
    );
  }

  void _handleFocusChange(bool focused) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.length != 0) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      if (focused) {
        // @TODO: need to detect hotkey to determine focus order of inputs in kraken widget.
        _focusEditable(editables[0]);
      } else {
        if (focusedEditable != null) {
          _blurEditable(focusedEditable);
        }
      }
    }
  }

  void _handleNextFocus(NextFocusIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.length != 0) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the first editable.
      if (focusedEditable == null) {
        _krakenFocus.requestFocus();
        _focusEditable(editables[0]);

      // Some editable is focused, focus the next editable, if it is the last editable,
      // then focus the next widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == editables.length - 1) {
          _krakenFocus.nextFocus();
        } else {
          _krakenFocus.requestFocus();
          _blurEditable(editables[idx]);
          _focusEditable(editables[idx + 1]);
        }
      }
    // None editable exists, focus the next widget.
    } else {
      _krakenFocus.nextFocus();
    }
  }

  void _handlePreviousFocus(PreviousFocusIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.length != 0) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the last editable.
      if (focusedEditable == null) {
        _krakenFocus.requestFocus();
        _focusEditable(editables[editables.length - 1]);

        // Some editable is focused, focus the previous editable, if it is the first editable,
        // then focus the previous widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == 0) {
          _krakenFocus.previousFocus();
        } else {
          _krakenFocus.requestFocus();
          _blurEditable(editables[idx]);
          _focusEditable(editables[idx - 1]);
        }
      }
    // None editable exists, focus the previous widget.
    } else {
      _krakenFocus.previousFocus();
    }
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
  }

  void _focusEditable(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    RenderIntrinsic renderIntrisic = renderInputBox.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.focusInput();
  }

  void _blurEditable(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    RenderIntrinsic renderIntrisic = renderInputBox.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.blurInput();
  }

  List<RenderEditable> _findEditables(RenderObject parent) {
    List<RenderEditable> result = [];
    parent.visitChildren((RenderObject child) {
      if (child is RenderEditable) {
        result.add(child);
      } else {
        List<RenderEditable> children = _findEditables(child);
        result.addAll(children);
      }
    });
    return result;
  }

  RenderEditable? _findFocusedEditable(List<RenderEditable> editables) {
    RenderEditable? result;
    if (editables.length != 0) {
      for (RenderEditable editable in editables) {
        if (editable.hasFocus) {
          result = editable;
        }
      }
    }
    return result;
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

