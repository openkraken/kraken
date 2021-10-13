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
  _WidgetCustomElement(int targetId, Pointer<NativeElement> nativePtr, dom.ElementManager elementManager, String tagName, WidgetCreator creator)
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
    this.gestureListener,
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
  Map<Type, Action<Intent>>? _actionMap;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      // Action of focus.
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handlePreviousFocus),

      // Action of mouse move hotkeys.
      MoveSelectionRightByLineTextIntent: CallbackAction<MoveSelectionRightByLineTextIntent>(onInvoke: _handleMoveSelectionRightByLineText),
      MoveSelectionLeftByLineTextIntent: CallbackAction<MoveSelectionLeftByLineTextIntent>(onInvoke: _handleMoveSelectionLeftByLineText),
      MoveSelectionRightByWordTextIntent: CallbackAction<MoveSelectionRightByWordTextIntent>(onInvoke: _handleMoveSelectionRightByWordText),
      MoveSelectionLeftByWordTextIntent: CallbackAction<MoveSelectionLeftByWordTextIntent>(onInvoke: _handleMoveSelectionLeftByWordText),
      MoveSelectionUpTextIntent: CallbackAction<MoveSelectionUpTextIntent>(onInvoke: _handleMoveSelectionUpText),
      MoveSelectionDownTextIntent: CallbackAction<MoveSelectionDownTextIntent>(onInvoke: _handleMoveSelectionDownText),
      MoveSelectionLeftTextIntent: CallbackAction<MoveSelectionLeftTextIntent>(onInvoke: _handleMoveSelectionLeftText),
      MoveSelectionRightTextIntent: CallbackAction<MoveSelectionRightTextIntent>(onInvoke: _handleMoveSelectionRightText),
      MoveSelectionToStartTextIntent: CallbackAction<MoveSelectionToStartTextIntent>(onInvoke: _handleMoveSelectionToStartText),
      MoveSelectionToEndTextIntent: CallbackAction<MoveSelectionToEndTextIntent>(onInvoke: _handleMoveSelectionToEndText),

      // Action of selection hotkeys.
      ExtendSelectionLeftTextIntent: CallbackAction<ExtendSelectionLeftTextIntent>(onInvoke: _handleExtendSelectionLeftText),
      ExtendSelectionRightTextIntent: CallbackAction<ExtendSelectionRightTextIntent>(onInvoke: _handleExtendSelectionRightText),
      ExtendSelectionUpTextIntent: CallbackAction<ExtendSelectionUpTextIntent>(onInvoke: _handleExtendSelectionUpText),
      ExtendSelectionDownTextIntent: CallbackAction<ExtendSelectionDownTextIntent>(onInvoke: _handleExtendSelectionDownText),
      ExpandSelectionToEndTextIntent: CallbackAction<ExpandSelectionToEndTextIntent>(onInvoke: _handleExtendSelectionToEndText),
      ExpandSelectionToStartTextIntent: CallbackAction<ExpandSelectionToStartTextIntent>(onInvoke: _handleExtendSelectionToStartText),
      ExpandSelectionLeftByLineTextIntent: CallbackAction<ExpandSelectionLeftByLineTextIntent>(onInvoke: _handleExtendSelectionLeftByLineText),
      ExpandSelectionRightByLineTextIntent: CallbackAction<ExpandSelectionRightByLineTextIntent>(onInvoke: _handleExtendSelectionRightByLineText),
      ExtendSelectionLeftByWordTextIntent: CallbackAction<ExtendSelectionLeftByWordTextIntent>(onInvoke: _handleExtendSelectionLeftByWordText),
      ExtendSelectionRightByWordTextIntent: CallbackAction<ExtendSelectionRightByWordTextIntent>(onInvoke: _handleExtendSelectionRightByWordText),
    };
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FocusableActionDetector(
        actions: _actionMap,
        focusNode: _focusNode,
        onFocusChange: _handleFocusChange,
        child: _KrakenRenderObjectWidget(
          context.widget as Kraken,
          widgetDelegate,
        )
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

  // Get context of current widget.
  BuildContext _getContext() {
    return context;
  }

  // Request focus of current widget.
  void _requestFocus() {
    _focusNode.requestFocus();
  }

  // Get the target platform.
  TargetPlatform _getTargetPlatform() {
    final ThemeData theme = Theme.of(context);
    return theme.platform;
  }

  // Get the cursor color according to the widget theme and platform theme.
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

  // Get the selection color according to the widget theme and platform theme.
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

  // Get the cursor radius according to the target platform.
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

  // Get the text selection controls according to the target platform.
  TextSelectionControls _getTextSelectionControls() {
    TextSelectionControls _selectionControls;
    TargetPlatform platform = _getTargetPlatform();

    switch (platform) {
      case TargetPlatform.iOS:
        _selectionControls = cupertinoTextSelectionControls;
        break;

      case TargetPlatform.macOS:
        _selectionControls = cupertinoDesktopTextSelectionControls;
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

  // Handle focus change of focusNode.
  void _handleFocusChange(bool focused) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      if (focused) {
        if (dom.InputElement.focusInputElement == null) {
          _focusInput(editables[0]);
        }
      } else {
        if (focusedEditable != null) {
          _blurInput(focusedEditable);
        }
      }
    }
  }

  // Handle focus action usually by pressing the [Tab] hotkey.
  void _handleNextFocus(NextFocusIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the first editable.
      if (focusedEditable == null) {
        _focusNode.requestFocus();
        _focusInput(editables[0]);

      // Some editable is focused, focus the next editable, if it is the last editable,
      // then focus the next widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == editables.length - 1) {
          _focusNode.nextFocus();
          _blurInput(editables[editables.length - 1]);
        } else {
          _focusNode.requestFocus();
          _blurInput(editables[idx]);
          _focusInput(editables[idx + 1]);
        }
      }

    // None editable exists, focus the next widget.
    } else {
      _focusNode.nextFocus();
    }
  }

  // Handle focus action usually by pressing the [Shift]+[Tab] hotkey in the reverse direction.
  void _handlePreviousFocus(PreviousFocusIntent intent) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    List<RenderEditable> editables = _findEditables(_rootRenderObject!);
    if (editables.isNotEmpty) {
      RenderEditable? focusedEditable = _findFocusedEditable(editables);
      // None editable is focused, focus the last editable.
      if (focusedEditable == null) {
        _focusNode.requestFocus();
        _focusInput(editables[editables.length - 1]);

        // Some editable is focused, focus the previous editable, if it is the first editable,
        // then focus the previous widget.
      } else {
        int idx = editables.indexOf(focusedEditable);
        if (idx == 0) {
          _focusNode.previousFocus();
          _blurInput(editables[0]);
        } else {
          _focusNode.requestFocus();
          _blurInput(editables[idx]);
          _focusInput(editables[idx - 1]);
        }
      }
    // None editable exists, focus the previous widget.
    } else {
      _focusNode.previousFocus();
    }
  }

  void _handleMoveSelectionRightByLineText(MoveSelectionRightByLineTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionRightByLine(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionLeftByLineText(MoveSelectionLeftByLineTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionLeftByLine(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionRightByWordText(MoveSelectionRightByWordTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionRightByWord(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionLeftByWordText(MoveSelectionLeftByWordTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionLeftByWord(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionUpText(MoveSelectionUpTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionUp(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionDownText(MoveSelectionDownTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionDown(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionLeftText(MoveSelectionLeftTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionLeft(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionRightText(MoveSelectionRightTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionRight(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionToEndText(MoveSelectionToEndTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionToEnd(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleMoveSelectionToStartText(MoveSelectionToStartTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.moveSelectionToStart(SelectionChangedCause.keyboard);
      // Make caret visilbe while moving cursor.
      _scrollFocusedInputToCaret(focusedEditable);
    }
  }

  void _handleExtendSelectionLeftText(ExtendSelectionLeftTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionLeft(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightText(ExtendSelectionRightTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionRight(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionUpText(ExtendSelectionUpTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionUp(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionDownText(ExtendSelectionDownTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionDown(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionToEndText(ExpandSelectionToEndTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.expandSelectionToEnd(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionToStartText(ExpandSelectionToStartTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.expandSelectionToStart(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionLeftByLineText(ExpandSelectionLeftByLineTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.expandSelectionLeftByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightByLineText(ExpandSelectionRightByLineTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.expandSelectionRightByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionLeftByWordText(ExtendSelectionLeftByWordTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionLeftByWord(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightByWordText(ExtendSelectionRightByWordTextIntent intent) {
    RenderEditable? focusedEditable = _findFocusedEditable();
    if (focusedEditable != null) {
      focusedEditable.extendSelectionRightByWord(SelectionChangedCause.keyboard);
    }
  }

  // Make the input element of the RenderEditable focus.
  void _focusInput(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    dom.RenderInputLeaderLayer renderInputLeaderLayer = renderInputBox.parent as dom.RenderInputLeaderLayer;
    RenderIntrinsic renderIntrisic = renderInputLeaderLayer.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.focusInput();
  }

  // Make the input element of the RenderEditable blur.
  void _blurInput(RenderEditable renderEditable) {
    dom.RenderInputBox renderInputBox = renderEditable.parent as dom.RenderInputBox;
    dom.RenderInputLeaderLayer renderInputLeaderLayer = renderInputBox.parent as dom.RenderInputLeaderLayer;
    RenderIntrinsic renderIntrisic = renderInputLeaderLayer.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.blurInput();
  }

  // Find all the RenderEditables in the widget.
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

  // Find the focused RenderEditable in the widget.
  RenderEditable? _findFocusedEditable([List<RenderEditable>? editables]) {
    RenderEditable? result;
    RenderObject? _rootRenderObject = context.findRenderObject();
    editables ??= _findEditables(_rootRenderObject!);

    if (editables.isNotEmpty) {
      for (RenderEditable editable in editables) {
        if (editable.hasFocus) {
          result = editable;
        }
      }
    }
    return result;
  }

  // Scroll the focused input box to the caret to make it visible.
  void _scrollFocusedInputToCaret(RenderEditable focusedEditable) {
    dom.RenderInputBox renderInputBox = focusedEditable.parent as dom.RenderInputBox;
    dom.RenderInputLeaderLayer renderInputLeaderLayer = renderInputBox.parent as dom.RenderInputLeaderLayer;
    RenderIntrinsic renderIntrisic = renderInputLeaderLayer.parent as RenderIntrinsic;
    renderIntrisic.elementDelegate.scrollInputToCaret();
  }
}

class _KrakenRenderObjectWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that visually hides its child.
  const _KrakenRenderObjectWidget(
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
      bundleContent: _krakenWidget.bundleContent,
      bundleURL: _krakenWidget.bundleURL,
      bundlePath: _krakenWidget.bundlePath,
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

