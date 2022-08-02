/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'module_manager.dart';

typedef WebFNavigationDecisionHandler = Future<WebFNavigationActionPolicy> Function(WebFNavigationAction action);
typedef WebFNavigationErrorHandler = void Function(Object error, Object stack);

enum WebFNavigationActionPolicy {
  // allow kraken to perform navigate.
  allow,

  // cancel kraken default's navigate action.
  cancel
}

// https://www.w3.org/TR/navigation-timing-2/#sec-performance-navigation-types
enum WebFNavigationType {
  // Navigation where the history handling behavior is set to "default"
  // or "replace" and the navigation was not initiated by a prerender hint.
  navigate,

  // Navigation where the history handling behavior is set to "reload".
  reload,

  // Navigation where the history handling behavior is set to "entry update".
  backForward,

  // Navigation initiated by a prerender hint.
  prerender
}

class NavigationModule extends BaseModule {
  @override
  String get name => 'Navigation';

  NavigationModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  // Navigate kraken page to target Url.
  Future<void> goTo(String targetUrl) async {
    String? sourceUrl = moduleManager!.controller.url;

    Uri targetUri = Uri.parse(targetUrl);
    Uri sourceUri = Uri.parse(sourceUrl);

    await moduleManager!.controller.view.handleNavigationAction(
        sourceUrl, targetUrl, targetUri == sourceUri ? WebFNavigationType.reload : WebFNavigationType.navigate);
  }

  @override
  String invoke(String method, params, callback) {
    if (method == 'goTo') {
      assert(params is String, 'URL must be string.');
      goTo(params);
    }

    return '';
  }
}

class WebFNavigationAction {
  WebFNavigationAction(this.source, this.target, this.navigationType);

  // The current source url.
  String? source;

  // The target source url.
  String target;

  // The navigation type.
  WebFNavigationType navigationType;

  @override
  String toString() => 'WebFNavigationType(source:$source, target:$target, navigationType:$navigationType)';
}

Future<WebFNavigationActionPolicy> defaultDecisionHandler(WebFNavigationAction action) async {
  return WebFNavigationActionPolicy.allow;
}

class WebFNavigationDelegate {
  // Called when an error occurs during navigation.
  WebFNavigationErrorHandler? errorHandler;

  WebFNavigationDecisionHandler _decisionHandler = defaultDecisionHandler;

  void setDecisionHandler(WebFNavigationDecisionHandler handler) {
    _decisionHandler = handler;
  }

  Future<WebFNavigationActionPolicy> dispatchDecisionHandler(WebFNavigationAction action) async {
    return await _decisionHandler(action);
  }
}
