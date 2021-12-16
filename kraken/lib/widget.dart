/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

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

abstract class WidgetElement extends dom.Element {
  late Element _renderViewElement;
  late BuildOwner _buildOwner;
  late Widget _widget;
  _KrakenAdapterWidgetPropertiesState? _propertiesState;
  WidgetElement(dom.EventTargetContext? context)
      : super(
      context,
      isIntrinsicBox: true,
      defaultStyle: _defaultStyle
  );

  Widget build(BuildContext context, Map<String, dynamic> properties);

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    WidgetsFlutterBinding.ensureInitialized();

    _propertiesState = _KrakenAdapterWidgetPropertiesState(this, properties);
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
  final WidgetElement _element;
  _KrakenAdapterWidgetPropertiesState(this._element, this._properties);

  void onAttributeChanged(Map<String, dynamic> properties) {
    setState(() {
      _properties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _element.build(context, _properties);
  }
}

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

  loadBundle(KrakenBundle bundle) async {
    await controller!.unload();
    await controller!.loadBundle(
        bundle: bundle
    );
    _evalBundle(controller!, animationController);
  }

  @deprecated
  loadContent(String bundleContent) async {
    await controller!.unload();
    await controller!.loadBundle(
        bundle: KrakenBundle.fromContent(bundleContent)
    );
    _evalBundle(controller!, animationController);
  }

  @deprecated
  loadByteCode(Uint8List bundleByteCode) async {
    await controller!.unload();
    await controller!.loadBundle(
        bundle: KrakenBundle.fromBytecode(bundleByteCode)
    );
    _evalBundle(controller!, animationController);
  }

  @deprecated
  loadURL(String bundleURL, { String? bundleContent, Uint8List? bundleByteCode }) async {
    await controller!.unload();

    KrakenBundle bundle;
    if (bundleByteCode != null) {
      bundle = KrakenBundle.fromBytecode(bundleByteCode, url: bundleURL);
    } else if (bundleContent != null) {
      bundle = KrakenBundle.fromContent(bundleContent, url: bundleURL);
    } else {
      bundle = KrakenBundle.fromUrl(bundleURL);
    }

    await controller!.loadBundle(
        bundle: bundle
    );
    _evalBundle(controller!, animationController);
  }

  @deprecated
  loadPath(String bundlePath, { String? bundleContent, Uint8List? bundleByteCode }) async {
    await controller!.unload();

    KrakenBundle bundle;
    if (bundleByteCode != null) {
      bundle = KrakenBundle.fromBytecode(bundleByteCode, url: bundlePath);
    } else if (bundleContent != null) {
      bundle = KrakenBundle.fromContent(bundleContent, url: bundlePath);
    } else {
      bundle = KrakenBundle.fromUrl(bundlePath);
    }

    await controller!.loadBundle(
        bundle: bundle
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
    this.bundle,
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
    dom.Element rootElement = _findRootElement();
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(focusableElements);
      // Currently only input element is focusable.
      if (focused) {
        if (dom.InputElement.focusInputElement == null) {
          (focusableElements[0] as dom.InputElement).focus();
        }
      } else {
        if (focusedElement != null) {
          (focusedElement as dom.InputElement).blur();
        }
      }
    }
  }

  // Handle focus action usually by pressing the [Tab] hotkey.
  void _handleNextFocus(NextFocusIntent intent) {
    dom.Element rootElement = _findRootElement();
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(focusableElements);
      // None focusable element is focused, focus the first focusable element.
      if (focusedElement == null) {
        _focusNode.requestFocus();
        (focusableElements[0] as dom.InputElement).focus();

      // Some focusable element is focused, focus the next element, if it is the last focusable element,
      // then focus the next widget.
      } else {
        int idx = focusableElements.indexOf(focusedElement);
        if (idx == focusableElements.length - 1) {
          _focusNode.nextFocus();
          (focusableElements[focusableElements.length - 1] as dom.InputElement).blur();
        } else {
          _focusNode.requestFocus();
          (focusableElements[idx] as dom.InputElement).blur();
          (focusableElements[idx + 1] as dom.InputElement).focus();
        }
      }

    // None focusable element exists, focus the next widget.
    } else {
      _focusNode.nextFocus();
    }
  }

  // Handle focus action usually by pressing the [Shift]+[Tab] hotkey in the reverse direction.
  void _handlePreviousFocus(PreviousFocusIntent intent) {
    dom.Element rootElement = _findRootElement();
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(focusableElements);
      // None editable is focused, focus the last editable.
      if (focusedElement == null) {
        _focusNode.requestFocus();
        (focusableElements[focusableElements.length - 1] as dom.InputElement).focus();

        // Some editable is focused, focus the previous editable, if it is the first editable,
        // then focus the previous widget.
      } else {
        int idx = focusableElements.indexOf(focusedElement);
        if (idx == 0) {
          _focusNode.previousFocus();
          (focusableElements[0] as dom.InputElement).blur();
        } else {
          _focusNode.requestFocus();
          (focusableElements[idx] as dom.InputElement).blur();
          (focusableElements[idx - 1] as dom.InputElement).focus();
        }
      }
    // None editable exists, focus the previous widget.
    } else {
      _focusNode.previousFocus();
    }
  }

  void _handleMoveSelectionRightByLineText(MoveSelectionRightByLineTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionRightByLine(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionLeftByLineText(MoveSelectionLeftByLineTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionLeftByLine(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionRightByWordText(MoveSelectionRightByWordTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionRightByWord(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionLeftByWordText(MoveSelectionLeftByWordTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionLeftByWord(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionUpText(MoveSelectionUpTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionUp(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionDownText(MoveSelectionDownTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionDown(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionLeftText(MoveSelectionLeftTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionLeft(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionRightText(MoveSelectionRightTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionRight(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionToEndText(MoveSelectionToEndTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionToEnd(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleMoveSelectionToStartText(MoveSelectionToStartTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.moveSelectionToStart(SelectionChangedCause.keyboard);
        // Make caret visible while moving cursor.
        focusedElement.scrollToCaret();
      }
    }
  }

  void _handleExtendSelectionLeftText(ExtendSelectionLeftTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionLeft(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionRightText(ExtendSelectionRightTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionRight(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionUpText(ExtendSelectionUpTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionUp(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionDownText(ExtendSelectionDownTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionDown(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionToEndText(ExpandSelectionToEndTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.expandSelectionToEnd(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionToStartText(ExpandSelectionToStartTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.expandSelectionToStart(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionLeftByLineText(ExpandSelectionLeftByLineTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.expandSelectionLeftByLine(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionRightByLineText(ExpandSelectionRightByLineTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.expandSelectionRightByLine(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionLeftByWordText(ExtendSelectionLeftByWordTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionLeftByWord(SelectionChangedCause.keyboard);
      }
    }
  }

  void _handleExtendSelectionRightByWordText(ExtendSelectionRightByWordTextIntent intent) {
    dom.Element? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      RenderEditable? focusedRenderEditable = (focusedElement as dom.InputElement).renderEditable;
      if (focusedRenderEditable != null) {
        focusedRenderEditable.extendSelectionRightByWord(SelectionChangedCause.keyboard);
      }
    }
  }

  // Find RenderViewportBox in the renderObject tree.
  RenderViewportBox? _findRenderViewportBox(RenderObject parent) {
    RenderViewportBox? result;
    parent.visitChildren((RenderObject child) {
      if (child is RenderViewportBox) {
        result = child;
      } else {
        result = _findRenderViewportBox(child);
      }
    });
    return result;
  }

  // Find root element of dom tree.
  dom.Element _findRootElement() {
    RenderObject? _rootRenderObject = context.findRenderObject();
    RenderViewportBox? renderViewportBox = _findRenderViewportBox(_rootRenderObject!);
    KrakenController controller = (renderViewportBox as RenderObjectWithControllerMixin).controller!;
    dom.Element documentElement = controller.view.document.documentElement!;
    return documentElement;
  }

  // Find all the focusable elements in the element tree.
  List<dom.Element> _findFocusableElements(dom.Element element) {
    List<dom.Element> result = [];
    traverseElement(element, (dom.Element child) {
      // Currently only input element is focusable.
      if (child is dom.InputElement) {
        result.add(child);
      }
    });
    return result;
  }

  // Find the focused element in the element tree.
  dom.Element? _findFocusedElement([List<dom.Element>? focusableElements]) {
    dom.Element? result;
    if (focusableElements == null) {
      dom.Element rootElement = _findRootElement();
      focusableElements = _findFocusableElements(rootElement);
    }

    if (focusableElements.isNotEmpty) {
      // Currently only input element is focusable.
      for (dom.Element inputElement in focusableElements) {
        RenderEditable? renderEditable = (inputElement as dom.InputElement).renderEditable;
        if (renderEditable != null && renderEditable.hasFocus) {
          result = inputElement;
          break;
        }
      }
    }
    return result;
  }
}

class _KrakenRenderObjectWidget extends SingleChildRenderObjectWidget {
  // Creates a widget that visually hides its child.
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
      bundle: _krakenWidget.bundle,
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
  _KrakenRenderObjectElement(_KrakenRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    KrakenController controller = (renderObject as RenderObjectWithControllerMixin).controller!;


    if (controller.bundle == null || (controller.bundle?.content == null && controller.bundle?.bytecode == null && controller.bundle?.src == null)) {
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

