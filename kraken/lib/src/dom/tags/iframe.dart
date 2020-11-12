/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ffi';
import 'dart:async';
import 'package:kraken/bridge.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken_webview/kraken_webview.dart';


const String IFRAME = 'IFRAME';

const Map<String, dynamic> _defaultStyle = {
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

/// Optional callback invoked when a web view is first created. [controller] is
/// the [WebViewController] for the created web view.
typedef void WebViewCreatedCallback(WebViewController controller);

class RenderWebViewBoundaryBox extends RenderConstrainedBox {
  VoidCallback onDetach;

  RenderWebViewBoundaryBox(
    this.onDetach, {
    BoxConstraints additionalConstraints,
    RenderBox child,
  }) : super(additionalConstraints: additionalConstraints, child: child);

  @override
  void detach() {
    super.detach();

    if (onDetach != null) {
      onDetach();
    }
  }
}

/// Callback type for handling messages sent from Javascript running in a web view.
typedef void JavascriptMessageHandler(JavascriptMessage message);

/// Information about a navigation action that is about to be executed.
class NavigationRequest {
  NavigationRequest({this.url, this.isForMainFrame});

  /// The URL that will be loaded if the navigation is executed.
  final String url;

  /// Whether the navigation request is to be loaded as the main frame.
  final bool isForMainFrame;

  @override
  String toString() {
    return '$runtimeType(url: $url, isForMainFrame: $isForMainFrame)';
  }
}

/// A decision on how to handle a navigation request.
enum NavigationDecision {
  /// Prevent the navigation from taking place.
  prevent,

  /// Allow the navigation to take place.
  navigate,
}

/// Decides how to handle a specific navigation request.
///
/// The returned [NavigationDecision] determines how the navigation described by
/// `navigation` should be handled.
///
/// See also: [WebView.navigationDelegate].
typedef FutureOr<NavigationDecision> NavigationDelegate(NavigationRequest navigation);

/// Signature for when a [WebView] has started loading a page.
typedef void PageStartedCallback(String url);

/// Signature for when a [WebView] has finished loading a page.
typedef void PageFinishedCallback(String url);

final RegExp _validChannelNames = RegExp('^[a-zA-Z_][a-zA-Z0-9_]*\$');

/// A named channel for receiving messaged from JavaScript code running inside a web view.
class JavascriptChannel {
  /// Constructs a Javascript channel.
  ///
  /// The parameters `name` and `onMessageReceived` must not be null.
  JavascriptChannel({
    @required this.name,
    @required this.onMessageReceived,
  })  : assert(name != null),
        assert(onMessageReceived != null),
        assert(_validChannelNames.hasMatch(name));

  /// The channel's name.
  ///
  /// Passing this channel object as part of a [WebView.javascriptChannels] adds a channel object to
  /// the Javascript window object's property named `name`.
  ///
  /// The name must start with a letter or underscore(_), followed by any combination of those
  /// characters plus digits.
  ///
  /// Note that any JavaScript existing `window` property with this name will be overriden.
  ///
  /// See also [WebView.javascriptChannels] for more details on the channel registration mechanism.
  final String name;

  /// A callback that's invoked when a message is received through the channel.
  final JavascriptMessageHandler onMessageReceived;
}

/// Controls a [WebView].
///
/// A [WebViewController] instance can be obtained by setting the [WebView.onWebViewCreated]
/// callback for a [WebView] widget.
class WebViewController {
  WebViewController(
    this._element,
    this._webViewPlatformController,
    this._platformCallbacksHandler,
  ) : assert(_webViewPlatformController != null) {
    _settings = _webSettingsFromElement(_element);
  }

  final WebViewPlatformController _webViewPlatformController;

  final _PlatformCallbacksHandler _platformCallbacksHandler;

  WebSettings _settings;

  WebViewElement _element;

  /// Loads the specified URL.
  ///
  /// If `headers` is not null and the URL is an HTTP URL, the key value paris in `headers` will
  /// be added as key value pairs of HTTP headers for the request.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
  Future<void> loadUrl(
    String url, {
    Map<String, String> headers,
  }) async {
    assert(url != null);
    _validateUrlString(url);
    return _webViewPlatformController.loadUrl(url, headers);
  }

  /// Accessor to the current URL that the WebView is displaying.
  ///
  /// If [WebViewElement.initialUrl] was never specified, returns `null`.
  /// Note that this operation is asynchronous, and it is possible that the
  /// current URL changes again by the time this function returns (in other
  /// words, by the time this future completes, the WebView may be displaying a
  /// different URL).
  Future<String> currentUrl() {
    return _webViewPlatformController.currentUrl();
  }

  /// Checks whether there's a back history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoBack" state has
  /// changed by the time the future completed.
  Future<bool> canGoBack() {
    return _webViewPlatformController.canGoBack();
  }

  /// Checks whether there's a forward history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoForward" state has
  /// changed by the time the future completed.
  Future<bool> canGoForward() {
    return _webViewPlatformController.canGoForward();
  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
  Future<void> goBack() {
    return _webViewPlatformController.goBack();
  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
  Future<void> goForward() {
    return _webViewPlatformController.goForward();
  }

  /// Reloads the current URL.
  Future<void> reload() {
    return _webViewPlatformController.reload();
  }

  Future<void> setupJSBridge() {
    return _webViewPlatformController.setupJavascriptBridge();
  }

  Future<void> teardownJSBridge() {
    return _webViewPlatformController.teardownJavascriptBridge();
  }

  /// Clears all caches used by the [WebView].
  ///
  /// The following caches are cleared:
  ///	1. Browser HTTP Cache.
  ///	2. [Cache API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api) caches.
  ///    These are not yet supported in iOS WkWebView. Service workers tend to use this cache.
  ///	3. Application cache.
  ///	4. Local Storage.
  ///
  /// Note: Calling this method also triggers a reload.
  Future<void> clearCache() async {
    await _webViewPlatformController.clearCache();
    return reload();
  }

  // ignore: unused_element
  Future<void> _updateElement(WebViewElement element) async {
    _element = element;
    await _updateSettings(_webSettingsFromElement(element));
    await _updateJavascriptChannels(element.javascriptChannels);
  }

  Future<void> _updateSettings(WebSettings newSettings) {
    final WebSettings update = _clearUnchangedWebSettings(_settings, newSettings);
    _settings = newSettings;
    return _webViewPlatformController.updateSettings(update);
  }

  Future<void> _updateJavascriptChannels(Set<JavascriptChannel> newChannels) async {
    final Set<String> currentChannels = _platformCallbacksHandler._javascriptChannels.keys.toSet();
    final Set<String> newChannelNames = _extractChannelNames(newChannels);
    final Set<String> channelsToAdd = newChannelNames.difference(currentChannels);
    final Set<String> channelsToRemove = currentChannels.difference(newChannelNames);
    if (channelsToRemove.isNotEmpty) {
      await _webViewPlatformController.removeJavascriptChannels(channelsToRemove);
    }
    if (channelsToAdd.isNotEmpty) {
      await _webViewPlatformController.addJavascriptChannels(channelsToAdd);
    }
    _platformCallbacksHandler._updateJavascriptChannelsFromSet(newChannels);
  }

  /// Evaluates a JavaScript expression in the context of the current page.
  ///
  /// On Android returns the evaluation result as a JSON formatted string.
  ///
  /// On iOS depending on the value type the return value would be one of:
  ///
  ///  - For primitive JavaScript types: the value string formatted (e.g JavaScript 100 returns '100').
  ///  - For JavaScript arrays of supported types: a string formatted NSArray(e.g '(1,2,3), note that the string for NSArray is formatted and might contain newlines and extra spaces.').
  ///  - Other non-primitive types are not supported on iOS and will complete the Future with an error.
  ///
  /// The Future completes with an error if a JavaScript error occurred, or on iOS, if the type of the
  /// evaluated expression is not supported as described above.
  ///
  /// When evaluating Javascript in a [WebView], it is best practice to wait for
  /// the [WebView.onPageFinished] callback. This guarantees all the Javascript
  /// embedded in the main frame HTML has been loaded.
  Future<String> evaluateJavascript(String javascriptString) {
    if (_settings.javascriptMode == JavascriptMode.disabled) {
      return Future<String>.error(
          FlutterError('JavaScript mode must be enabled/unrestricted when calling evaluateJavascript.'));
    }
    if (javascriptString == null) {
      return Future<String>.error(ArgumentError('The argument javascriptString must not be null.'));
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _webViewPlatformController.evaluateJavascript(javascriptString);
  }

  /// Returns the title of the currently loaded page.
  Future<String> getTitle() {
    return _webViewPlatformController.getTitle();
  }
}

/// Manages cookies pertaining to all [WebView]s.
class CookieManager {
  /// Creates a [CookieManager] -- returns the instance if it's already been called.
  factory CookieManager() {
    return _instance ??= CookieManager._();
  }

  CookieManager._();

  static CookieManager _instance;

  /// Clears all cookies for all [WebView] instances.
  ///
  /// This is a no op on iOS version smaller than 9.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() => WebViewElement.platform.clearCookies();
}

class _PlatformCallbacksHandler implements WebViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._element) {
    _updateJavascriptChannelsFromSet(_element.javascriptChannels);
  }

  WebViewElement _element;

  // Maps a channel name to a channel.
  final Map<String, JavascriptChannel> _javascriptChannels = <String, JavascriptChannel>{};

  @override
  void onJavaScriptChannelMessage(String channel, String message) {
    _javascriptChannels[channel].onMessageReceived(JavascriptMessage(message));
  }

  @override
  FutureOr<bool> onNavigationRequest({String url, bool isForMainFrame}) async {
    final NavigationRequest request = NavigationRequest(url: url, isForMainFrame: isForMainFrame);
    final bool allowNavigation = _element.navigationDelegate == null ||
        await _element.navigationDelegate(request) == NavigationDecision.navigate;
    return allowNavigation;
  }

  @override
  void onPageStarted(String url) {
    if (_element.onPageStarted != null) {
      _element.onPageStarted(url);
    }
  }

  @override
  void onPageFinished(String url) {
    if (_element.onPageFinished != null) {
      _element.onPageFinished(url);
    }
  }

  @override
  void onPostMessage(String message) {
    if (_element.onPostMessage != null) {
      _element.onPostMessage(message);
    }
  }

  void _updateJavascriptChannelsFromSet(Set<JavascriptChannel> channels) {
    _javascriptChannels.clear();
    if (channels == null) {
      return;
    }
    for (JavascriptChannel channel in channels) {
      _javascriptChannels[channel.name] = channel;
    }
  }
}

// Throws an ArgumentError if `url` is not a valid URL string.
void _validateUrlString(String url) {
  try {
    final Uri uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      throw ArgumentError('Missing scheme in URL string: "$url"');
    }
  } on FormatException catch (e) {
    throw ArgumentError(e);
  }
}

CreationParams _creationParamsFromElement(WebViewElement element) {
  return CreationParams(
    initialUrl: element.initialUrl,
    webSettings: _webSettingsFromElement(element),
    javascriptChannelNames: _extractChannelNames(element.javascriptChannels),
    userAgent: element.userAgent,
    autoMediaPlaybackPolicy: element.initialMediaPlaybackPolicy,
  );
}

WebSettings _webSettingsFromElement(WebViewElement element) {
  return WebSettings(
    javascriptMode: element.javascriptMode,
    hasNavigationDelegate: element.navigationDelegate != null,
    debuggingEnabled: element.debuggingEnabled,
    gestureNavigationEnabled: element.gestureNavigationEnabled,
    userAgent: WebSetting<String>.of(element.userAgent),
  );
}

// This method assumes that no fields in `currentValue` are null.
WebSettings _clearUnchangedWebSettings(WebSettings currentValue, WebSettings newValue) {
  assert(currentValue.javascriptMode != null);
  assert(currentValue.hasNavigationDelegate != null);
  assert(currentValue.debuggingEnabled != null);
  assert(currentValue.userAgent.isPresent);
  assert(newValue.javascriptMode != null);
  assert(newValue.hasNavigationDelegate != null);
  assert(newValue.debuggingEnabled != null);
  assert(newValue.userAgent.isPresent);

  JavascriptMode javascriptMode;
  bool hasNavigationDelegate;
  bool debuggingEnabled;
  WebSetting<String> userAgent = WebSetting<String>.absent();
  if (currentValue.javascriptMode != newValue.javascriptMode) {
    javascriptMode = newValue.javascriptMode;
  }
  if (currentValue.hasNavigationDelegate != newValue.hasNavigationDelegate) {
    hasNavigationDelegate = newValue.hasNavigationDelegate;
  }
  if (currentValue.debuggingEnabled != newValue.debuggingEnabled) {
    debuggingEnabled = newValue.debuggingEnabled;
  }
  if (currentValue.userAgent != newValue.userAgent) {
    userAgent = newValue.userAgent;
  }

  return WebSettings(
    javascriptMode: javascriptMode,
    hasNavigationDelegate: hasNavigationDelegate,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
  );
}

Set<String> _extractChannelNames(Set<JavascriptChannel> channels) {
  final Set<String> channelNames = channels == null
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      ? Set<String>()
      : channels.map((JavascriptChannel channel) => channel.name).toSet();
  return channelNames;
}

/// A web view widget for showing html content.
abstract class WebViewElement extends Element {
  /// Creates a new web view.
  ///
  /// The web view can be controlled using a `WebViewController` that is passed to the
  /// `onWebViewCreated` callback once the web view is created.
  ///
  /// The `javascriptMode` and `autoMediaPlaybackPolicy` parameters must not be null.
  WebViewElement(
    int targetId,
    Pointer<NativeElement> nativePtr,
    ElementManager elementManager, {
    String tagName,
    this.initialUrl,
    this.javascriptMode = JavascriptMode.unrestricted,
    this.javascriptChannels,
    this.navigationDelegate,
    this.gestureRecognizers,
    this.debuggingEnabled = false,
    this.gestureNavigationEnabled = false,
    this.userAgent = DEFAULT_USER_AGENT,
    this.initialMediaPlaybackPolicy = AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
  })  : assert(javascriptMode != null),
        assert(initialMediaPlaybackPolicy != null),
        super(targetId, nativePtr, elementManager, tagName: tagName, defaultStyle: _defaultStyle, isIntrinsicBox: true, repaintSelf: true);

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _setupRenderer();
  }

  @override
  void didDetachRenderer() {
    super.didAttachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);
  }

  /// The url that WebView loaded at first time.
  String initialUrl;

  /// The constrained to platformed render box, applying width and height.
  RenderConstrainedBox sizedBox;

  /// The webview render box itself.
  RenderBox platformRenderBox;
  _PlatformCallbacksHandler _platformCallbacksHandler;

  static const String SRC = 'src';
  static const String WIDTH = 'width';
  static const String HEIGHT = 'height';

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    if (key == SRC) {
      String url = value;
      initialUrl = url;

      if (renderer != null) {
        _setupRenderer();
      }
    } else if (key == WIDTH || key == HEIGHT) {
      setStyle(key, value);
    }
  }

  void _setupRenderer() {
    assert(renderBoxModel is RenderIntrinsic);
    (renderBoxModel as RenderIntrinsic).child = null;

    _buildPlatformRenderBox();
    addChild(sizedBox);
  }

  void _stylePropertyChanged(String property, String prev, String present, bool isAnimation) {
    if (property == WIDTH) {
      width = CSSLength.toDisplayPortValue(present);
    } else if (property == HEIGHT) {
      height = CSSLength.toDisplayPortValue(present);
    }
  }

  /// Create a new platformed render box.
  void _buildPlatformRenderBox() {
    _assertJavascriptChannelNamesAreUnique();
    _platformCallbacksHandler = _PlatformCallbacksHandler(this);
    platformRenderBox = platform.buildRenderBox(
      creationParams: _creationParamsFromElement(this),
      webViewPlatformCallbacksHandler: _platformCallbacksHandler,
      onWebViewPlatformCreated: _onWebViewPlatformCreated,
      gestureRecognizers: gestureRecognizers ?? _emptyRecognizersSet,
      // On focus only works in android now.
      onFocus: onFocus,
    );
    sizedBox = RenderWebViewBoundaryBox(onDetach,
        additionalConstraints: BoxConstraints.tight(Size(width, height)), child: platformRenderBox);
  }

  // Dispose controller.
  void onDetach() {
    platform?.dispose();
    _controller.future.then((WebViewController controller) {
      controller.teardownJSBridge();
    });
  }

  Size get size => Size(width, height);

  /// Element attribute width
  double _width = CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_WIDTH);
  double get width => _width;
  set width(double value) {
    if (value == null) {
      return;
    }
    if (value != _width) {
      _width = value;

      if (sizedBox != null) {
        sizedBox.additionalConstraints = BoxConstraints.tight(size);
      }
    }
  }

  /// Element attribute height
  double _height = CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_HEIGHT);
  double get height => _height;
  set height(double value) {
    if (value == null) {
      return;
    }
    if (value != _height) {
      _height = value;

      if (sizedBox != null) {
        sizedBox.additionalConstraints = BoxConstraints.tight(size);
      }
    }
  }

  /// Default userAgent for kraken.
  static const String DEFAULT_USER_AGENT =
      'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome Mobile Safari/537.36 AliApp(Kraken/0.3.0)';

  static WebViewPlatform _platform;

  /// Sets a custom [WebViewPlatform].
  ///
  /// This property can be set to use a custom platform implementation for WebViews.
  ///
  /// Setting `platform` doesn't affect [WebView]s that were already created.
  ///
  /// The default value is [AndroidWebView] on Android and [CupertinoWebView] on iOS.
  static set platform(WebViewPlatform platform) {
    _platform = platform;
  }

  /// The WebView platform that's used by this WebView.
  ///
  /// The default value is [AndroidWebView] on Android and [CupertinoWebView] on iOS.
  static WebViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidWebView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoWebView();
          break;
        default:
          _platform = FallbackWebView();
          break;
      }
    }
    return _platform;
  }

  /// If not null invoked once the web view is created.
  void onWebViewCreated(WebViewController controller);

  // Receive message from webview.
  void onPostMessage(String message);

  // While webview is focus.
  void onFocus();

  /// Which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Whether Javascript execution is enabled.
  final JavascriptMode javascriptMode;

  static final Set<Factory<OneSequenceGestureRecognizer>> _emptyRecognizersSet =
      <Factory<OneSequenceGestureRecognizer>>{};

  /// The set of [JavascriptChannel]s available to JavaScript code running in the web view.
  ///
  /// For each [JavascriptChannel] in the set, a channel object is made available for the
  /// JavaScript code in a window property named [JavascriptChannel.name].
  /// The JavaScript code can then call `postMessage` on that object to send a message that will be
  /// passed to [JavascriptChannel.onMessageReceived].
  ///
  /// For example for the following JavascriptChannel:
  ///
  /// ```dart
  /// JavascriptChannel(name: 'Print', onMessageReceived: (JavascriptMessage message) { print(message.message); });
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// Print.postMessage('Hello');
  /// ```
  ///
  /// To asynchronously invoke the message handler which will print the message to standard output.
  ///
  /// Adding a new JavaScript channel only takes affect after the next page is loaded.
  ///
  /// Set values must not be null. A [JavascriptChannel.name] cannot be the same for multiple
  /// channels in the list.
  ///
  /// A null value is equivalent to an empty set.
  final Set<JavascriptChannel> javascriptChannels;

  /// A delegate function that decides how to handle navigation actions.
  ///
  /// When a navigation is initiated by the WebView (e.g when a user clicks a link)
  /// this delegate is called and has to decide how to proceed with the navigation.
  ///
  /// See [NavigationDecision] for possible decisions the delegate can take.
  ///
  /// When null all navigation actions are allowed.
  ///
  /// Caveats on Android:
  ///
  ///   * Navigation actions targeted to the main frame can be intercepted,
  ///     navigation actions targeted to subframes are allowed regardless of the value
  ///     returned by this delegate.
  ///   * Setting a navigationDelegate makes the WebView treat all navigations as if they were
  ///     triggered by a user gesture, this disables some of Chromium's security mechanisms.
  ///     A navigationDelegate should only be set when loading trusted content.
  ///   * On Android WebView versions earlier than 67(most devices running at least Android L+ should have
  ///     a later version):
  ///     * When a navigationDelegate is set pages with frames are not properly handled by the
  ///       webview, and frames will be opened in the main frame.
  ///     * When a navigationDelegate is set HTTP requests do not include the HTTP referer header.
  final NavigationDelegate navigationDelegate;

  /// Invoked when a page starts loading.
  void onPageStarted(String url);

  /// Invoked when a page has finished loading.
  ///
  /// This is invoked only for the main frame.
  ///
  /// When [onPageFinished] is invoked on Android, the page being rendered may
  /// not be updated yet.
  ///
  /// When invoked on iOS or Android, any Javascript code that is embedded
  /// directly in the HTML has been loaded and code injected with
  /// [WebViewController.evaluateJavascript] can assume this.
  void onPageFinished(String url);

  /// Controls whether WebView debugging is enabled.
  ///
  /// Setting this to true enables [WebView debugging on Android](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/).
  ///
  /// WebView debugging is enabled by default in dev builds on iOS.
  ///
  /// To debug WebViews on iOS:
  /// - Enable developer options (Open Safari, go to Preferences -> Advanced and make sure "Show Develop Menu in Menubar" is on.)
  /// - From the Menu-bar (of Safari) select Develop -> iPhone Simulator -> <your webview page>
  ///
  /// By default `debuggingEnabled` is false.
  final bool debuggingEnabled;

  /// The value used for the HTTP User-Agent: request header.
  /// A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations.
  ///
  /// This only works on iOS.
  ///
  /// By default `gestureNavigationEnabled` is false.
  final bool gestureNavigationEnabled;

  ///
  /// When null the platform's webview default is used for the User-Agent header.
  ///
  /// When the [WebView] is rebuilt with a different `userAgent`, the page reloads and the request uses the new User Agent.
  ///
  /// When [WebViewController.goBack] is called after changing `userAgent` the previous `userAgent` value is used until the page is reloaded.
  ///
  /// This field is ignored on iOS versions prior to 9 as the platform does not support a custom
  /// user agent.
  ///
  /// By default `userAgent` is null.
  final String userAgent;

  /// Which restrictions apply on automatic media playback.
  ///
  /// This initial value is applied to the platform's webview upon creation. Any following
  /// changes to this parameter are ignored (as long as the state of the [WebView] is preserved).
  ///
  /// The default policy is [AutoMediaPlaybackPolicy.require_user_action_for_all_media_types].
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  void _assertJavascriptChannelNamesAreUnique() {
    if (javascriptChannels == null || javascriptChannels.isEmpty) {
      return;
    }
    assert(_extractChannelNames(javascriptChannels).length == javascriptChannels.length);
  }

  void _onWebViewPlatformCreated(WebViewPlatformController webViewPlatform) async {
    final WebViewController controller = WebViewController(this, webViewPlatform, _platformCallbacksHandler);
    await controller.setupJSBridge();
    _controller.complete(controller);
    onWebViewCreated(controller);
  }
}

/// The iframe element represents its nested browsing context.
///
/// The src attribute gives the URL of a page that the element's nested browsing
/// context is to contain. The attribute, if present, must be a valid non-empty
/// URL potentially surrounded by spaces. If the itemprop attribute is specified
/// on an iframe element, then the src attribute must also be specified.
///
/// DOM interface:
// [Exposed=Window]
// interface HTMLIFrameElement : HTMLElement {
//   [HTMLConstructor] constructor();
//
//   [CEReactions] attribute USVString src;
//   [CEReactions] attribute DOMString srcdoc;
//   [CEReactions] attribute DOMString name;
//   [SameObject, PutForwards=value] readonly attribute DOMTokenList sandbox;
//   [CEReactions] attribute DOMString allow;
//   [CEReactions] attribute boolean allowFullscreen;
//   [CEReactions] attribute boolean allowPaymentRequest;
//   [CEReactions] attribute DOMString width;
//   [CEReactions] attribute DOMString height;
//   [CEReactions] attribute DOMString referrerPolicy;
//   readonly attribute Document? contentDocument;
//   readonly attribute WindowProxy? contentWindow;
//   Document? getSVGDocument();
// };
class IFrameElement extends WebViewElement {
  IFrameElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager) : super(targetId, nativePtr, elementManager, tagName: IFRAME);

  @override
  void onWebViewCreated(WebViewController controller) {}

  @override
  void onFocus() {
    dispatchEvent(Event(EventType.focus));
  }

  bool _isFirstLoaded;
  @override
  void onPageStarted(String url) {
    if (_isFirstLoaded) {
      dispatchEvent(Event(EventType.unload));
    }
  }

  @override
  void onPageFinished(String url) {
    _isFirstLoaded = true;
    dispatchEvent(Event(EventType.load));
  }

  @override
  void onPostMessage(String message) {
    MessageEvent event = MessageEvent(message, origin: properties['url']);
    dispatchEvent(event);
  }

  Future<String> _postMessage(String message) {
    String escapedMessage = message?.replaceAll(RegExp('\"', multiLine: true), '\\"');
    String invoker = '''
      window.dispatchEvent(Object.assign(new CustomEvent('message'), {
        data: "${escapedMessage}",
        origin: 'kraken',
      }));
    '''
        .trim();
    // Wait until controller ready.
    return _controller.future.then((WebViewController controller) {
      return controller.evaluateJavascript(invoker);
    });
  }

  @override
  method(String name, List args) async {
    switch (name) {
      case 'postMessage':
        var firstArg = args[0];
        String message = firstArg?.toString();
        return await _postMessage(message);
      default:
        super.method(name, args);
    }
  }
}
