/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'dart:ui';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/module.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/css.dart';
import 'package:kraken/src/dom/element_registry.dart';
import 'package:kraken/bridge.dart';

/// Get context of current widget.
typedef GetContext = BuildContext Function();
/// Request focus of current widget.
typedef RequestFocus = void Function();
/// Get the target platform.
typedef GetTargetPlatform = TargetPlatform Function();
/// Get the cursor color according to the widget theme and platform theme.
typedef GetCursorColor = Color Function();
/// Get the selection color according to the widget theme and platform theme.
typedef GetSelectionColor = Color Function();
/// Get the cursor radius according to the target platform.
typedef GetCursorRadius = Radius Function();
/// Get the text selection controls according to the target platform.
typedef GetTextSelectionControls = TextSelectionControls Function();

/// Delegate methods of widget
class WidgetDelegate {
  GetContext getContext;
  RequestFocus requestFocus;
  GetTargetPlatform getTargetPlatform;
  GetCursorColor getCursorColor;
  GetSelectionColor getSelectionColor;
  GetCursorRadius getCursorRadius;
  GetTextSelectionControls getTextSelectionControls;

  WidgetDelegate(
    this.getContext,
    this.requestFocus,
    this.getTargetPlatform,
    this.getCursorColor,
    this.getSelectionColor,
    this.getCursorRadius,
    this.getTextSelectionControls,
  );
}

typedef WidgetCreator = Widget Function(Map<String, dynamic>);
class _WidgetCustomElement extends dom.Element {
  late WidgetCreator _widgetCreator;
  late Element _renderViewElement;
  late BuildOwner _buildOwner;
  late Widget _widget;
  _KrakenAdapterWidgetPropertiesState? _propertiesState;
  _WidgetCustomElement(int targetId, Pointer<NativeElement> nativePtr, dom.ElementManager elementManager, String tagName, WidgetCreator creator)
      : super(
      targetId,
      nativePtr,
      elementManager,
      tagName: tagName,
      isIntrinsicBox: true,
      defaultStyle: {
        DISPLAY: INLINE_BLOCK,
      }
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

  static bool _isValidCustomElementName(localName) {
    return RegExp(r'^[a-z][.0-9_a-z]*-[\-.0-9_a-z]*$').hasMatch(localName);
  }

  static void defineCustomElement(String localName, WidgetCreator creator) {
    if (!_isValidCustomElementName(localName)) {
      throw ArgumentError('The element name "$localName" is not valid.');
    }

    String tagName = localName.toUpperCase();

    defineElement(tagName, (id, nativePtr, elementManager) {
      return _WidgetCustomElement(id, nativePtr.cast<NativeElement>(), elementManager, tagName, creator);
    });
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
  _KrakenState createState() => _KrakenState();

}
class _KrakenState extends State<Kraken> {
  Map<LogicalKeySet, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveSelectionLeftTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): const MoveSelectionRightTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const MoveSelectionToStartTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveSelectionToEndTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft): const ExtendSelectionLeftTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight): const ExtendSelectionRightTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp): const ExtendSelectionUpTextIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown): const ExtendSelectionDownTextIntent(),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handlePreviousFocus),
      MoveSelectionLeftTextIntent: CallbackAction<MoveSelectionLeftTextIntent>(onInvoke: _handleMoveSelectionLeftText),
      MoveSelectionRightTextIntent: CallbackAction<MoveSelectionRightTextIntent>(onInvoke: _handleMoveSelectionRightText),
      MoveSelectionToStartTextIntent: CallbackAction<MoveSelectionToStartTextIntent>(onInvoke: _handleMoveSelectionToStartText),
      MoveSelectionToEndTextIntent: CallbackAction<MoveSelectionToEndTextIntent>(onInvoke: _handleMoveSelectionToEndText),
      ExtendSelectionLeftTextIntent: CallbackAction<ExtendSelectionLeftTextIntent>(onInvoke: _handleExtendSelectionLeftText),
      ExtendSelectionRightTextIntent: CallbackAction<ExtendSelectionRightTextIntent>(onInvoke: _handleExtendSelectionRightText),
      ExtendSelectionUpTextIntent: CallbackAction<ExtendSelectionUpTextIntent>(onInvoke: _handleExtendSelectionUpText),
      ExtendSelectionDownTextIntent: CallbackAction<ExtendSelectionDownTextIntent>(onInvoke: _handleExtendSelectionDownText),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: _actionMap,
      shortcuts: _shortcutMap,
      focusNode: _focusNode,
      onFocusChange: _handleFocusChange,
      child: _KrakenRenderObjectWidget(
        context.widget as Kraken,
        widgetDelegate,
        context
      )
    );
  }

  WidgetDelegate get widgetDelegate {
    return WidgetDelegate(
      _getContext,
      _requestFocus,
      _getTargetPlatform,
      _getCursorColor,
      _getSelectionColor,
      _getCursorRadius,
      _getTextSelectionControls,
    );
  }

  BuildContext _getContext() {
    return context;
  }

  void _requestFocus() {
    _focusNode.requestFocus();
  }

  TargetPlatform _getTargetPlatform() {
    final ThemeData theme = Theme.of(context);
    return theme.platform;
  }

  Color _getCursorColor() {
    Color cursorColor = CSSColor.initial;
    TextSelectionThemeData selectionTheme = TextSelectionTheme.of(context);
    ThemeData theme = Theme.of(context);

    switch (theme.platform) {
      case TargetPlatform.iOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        cursorColor = selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        break;

      case TargetPlatform.macOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        cursorColor = selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        cursorColor = selectionTheme.cursorColor ?? theme.colorScheme.primary;
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        cursorColor = selectionTheme.cursorColor ?? theme.colorScheme.primary;
        break;
    }

    return cursorColor;
  }

  Color _getSelectionColor() {
    Color selectionColor = CSSColor.initial.withOpacity(0.4);
    TextSelectionThemeData selectionTheme = TextSelectionTheme.of(context);
    ThemeData theme = Theme.of(context);

    switch (theme.platform) {
      case TargetPlatform.iOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        selectionColor = selectionTheme.selectionColor ?? cupertinoTheme.primaryColor.withOpacity(0.40);
        break;

      case TargetPlatform.macOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        selectionColor = selectionTheme.selectionColor ?? cupertinoTheme.primaryColor.withOpacity(0.40);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        selectionColor = selectionTheme.selectionColor ?? theme.colorScheme.primary.withOpacity(0.40);
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        selectionColor = selectionTheme.selectionColor ?? theme.colorScheme.primary.withOpacity(0.40);
        break;
    }

    return selectionColor;
  }

  Radius _getCursorRadius() {
    Radius cursorRadius = const Radius.circular(2.0);
    TargetPlatform platform = _getTargetPlatform();

    switch (platform) {
      case TargetPlatform.iOS:
        cursorRadius = const Radius.circular(2.0);
        break;

      case TargetPlatform.macOS:
        cursorRadius = const Radius.circular(2.0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        break;
    }

    return cursorRadius;
  }

  TextSelectionControls _getTextSelectionControls() {
    TextSelectionControls _selectionControls;
    TargetPlatform platform = _getTargetPlatform();

    switch (platform) {
      case TargetPlatform.iOS:
        _selectionControls = cupertinoTextSelectionControls;
        break;

      case TargetPlatform.macOS:
//        _selectionControls = cupertinoDesktopTextSelectionControls;
        // For test
        _selectionControls = materialTextSelectionControls;
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        _selectionControls = materialTextSelectionControls;
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _selectionControls = desktopTextSelectionControls;
        break;
    }

    return _selectionControls;
  }

  void _handleFocusChange(bool focused) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      if (focused) {
        // @TODO: need to detect hotkey to determine focus order of inputs in kraken widget.
        if (dom.InputElement.focusInputElement == null) {
          _focusEditable(editables[0]);
        }
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
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the first editable.
      if (focusedEditable == null) {
        _focusNode.requestFocus();
        _focusEditable(editables[0]);

      // Some editable is focused, focus the next editable, if it is the last editable,
      // then focus the next widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == editables.length - 1) {
          _focusNode.nextFocus();
          _blurEditable(editables[editables.length - 1]);
        } else {
          _focusNode.requestFocus();
          _blurEditable(editables[idx]);
          _focusEditable(editables[idx + 1]);
        }
      }
    // None editable exists, focus the next widget.
    } else {
      _focusNode.nextFocus();
    }
  }

  void _handlePreviousFocus(PreviousFocusIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the last editable.
      if (focusedEditable == null) {
        _focusNode.requestFocus();
        _focusEditable(editables[editables.length - 1]);

        // Some editable is focused, focus the previous editable, if it is the first editable,
        // then focus the previous widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == 0) {
          _focusNode.previousFocus();
          _blurEditable(editables[0]);
        } else {
          _focusNode.requestFocus();
          _blurEditable(editables[idx]);
          _focusEditable(editables[idx - 1]);
        }
      }
    // None editable exists, focus the previous widget.
    } else {
      _focusNode.previousFocus();
    }
  }

  void _handleMoveSelectionLeftText(MoveSelectionLeftTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.moveSelectionLeft(SelectionChangedCause.keyboard);

      // Scroll input box to the caret.
      dom.RenderInputBox renderInputBox = focusedEditable.parent as dom.RenderInputBox;
      RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
      RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
      renderIntrisic.elementDelegate.scrollInputToCaret();
    }
  }

  void _handleMoveSelectionRightText(MoveSelectionRightTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.moveSelectionRight(SelectionChangedCause.keyboard);

      // Scroll input box to the caret.
      dom.RenderInputBox renderInputBox = focusedEditable.parent as dom.RenderInputBox;
      RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
      RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
      renderIntrisic.elementDelegate.scrollInputToCaret();
    }
  }

  void _handleMoveSelectionToEndText(MoveSelectionToEndTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.moveSelectionToEnd(SelectionChangedCause.keyboard);

      // Scroll input box to the caret.
      dom.RenderInputBox renderInputBox = focusedEditable.parent as dom.RenderInputBox;
      RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
      RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
      renderIntrisic.elementDelegate.scrollInputToCaret();
    }
  }

  void _handleMoveSelectionToStartText(MoveSelectionToStartTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.moveSelectionToStart(SelectionChangedCause.keyboard);

      // Scroll input box to the caret.
      dom.RenderInputBox renderInputBox = focusedEditable.parent as dom.RenderInputBox;
      RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
      RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
      renderIntrisic.elementDelegate.scrollInputToCaret();
    }
  }

  void _handleExtendSelectionLeftText(ExtendSelectionLeftTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.extendSelectionLeft(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightText(ExtendSelectionRightTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.extendSelectionRight(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionUpText(ExtendSelectionUpTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.extendSelectionUp(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionDownText(ExtendSelectionDownTextIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      focusedEditable!.extendSelectionDown(SelectionChangedCause.keyboard);
    }
  }

  void _focusEditable(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
    RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.focusInput();
  }

  void _blurEditable(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    RenderLeaderLayer renderLeaderLayer = renderInputBox.parent as RenderLeaderLayer;
    RenderIntrinsic renderIntrisic = renderLeaderLayer.parent as RenderIntrinsic;
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
    if (editables.isNotEmpty) {
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
  const _KrakenRenderObjectWidget(
    Kraken widget,
    WidgetDelegate widgetDelegate,
    BuildContext context,
    {Key? key}
  ) : _krakenWidget = widget,
      _widgetDelegate = widgetDelegate,
      _context = context,
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
      widgetDelegate: _widgetDelegate,
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

