import 'module_manager.dart';

typedef KrakenNavigationDecisionHandler = Future<KrakenNavigationActionPolicy> Function(KrakenNavigationAction action);
typedef KrakenNavigationErrorHandler = void Function(Object error, Object stack);

enum KrakenNavigationActionPolicy {
  // allow kraken to perform navigate.
  allow,

  // cancel kraken default's navigate action.
  cancel
}

// https://www.w3.org/TR/navigation-timing-2/#sec-performance-navigation-types
enum KrakenNavigationType {
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

  NavigationModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'goTo') {
      assert(params is String, 'URL must be string.');
      String url = params;
      String sourceUrl = moduleManager.controller.bundlePath ?? moduleManager.controller.bundleURL;

      Uri targetUri = Uri.parse(url);
      Uri sourceUri = Uri.parse(sourceUrl);

      if (targetUri.scheme != sourceUri.scheme ||
          targetUri.host != sourceUri.host ||
          targetUri.port != sourceUri.port ||
          targetUri.path != sourceUri.path ||
          targetUri.query != sourceUri.query) {
        moduleManager.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.reload);
      }
    }

    return '';
  }
}

class KrakenNavigationAction {
  KrakenNavigationAction(this.source, this.target, this.navigationType);

  // The current source url.
  String source;

  // The target source url.
  String target;

  // The navigation type.
  KrakenNavigationType navigationType;

  @override
  String toString() => 'KrakenNavigationType(source:$source, target:$target, navigationType:$navigationType)';
}

Future<KrakenNavigationActionPolicy> defaultDecisionHandler(KrakenNavigationAction action) async {
  return KrakenNavigationActionPolicy.allow;
}

class KrakenNavigationDelegate {
  // Called when an error occurs during navigation.
  KrakenNavigationErrorHandler errorHandler;

  KrakenNavigationDecisionHandler _decisionHandler = defaultDecisionHandler;

  void setDecisionHandler(KrakenNavigationDecisionHandler handler) {
    _decisionHandler = handler;
  }

  Future<KrakenNavigationActionPolicy> dispatchDecisionHandler(KrakenNavigationAction action) async {
    return await _decisionHandler(action);
  }
}
