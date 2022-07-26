/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'element_inspector.dart';

/// This class can be extended directly, to get default behaviors for all of the
/// handlers, or can used with the `implements` keyword, in which case all the
/// handlers must be implemented (and the analyzer will list those that have
/// been omitted).
abstract class ElementsBindingObserver {
  /// Called when the system tells the app to pop the current route.
  /// For example, on Android, this is called when the user presses
  /// the back button.
  ///
  /// Observers are notified in registration order until one returns
  /// true. If none return true, the application quits.
  ///
  /// Observers are expected to return true if they were able to
  /// handle the notification, for example by closing an active dialog
  /// box, and false otherwise.
  ///
  /// This method exposes the `popRoute` notification from
  /// [SystemChannels.navigation].
  Future<bool> didPopRoute() => Future<bool>.value(false);

  /// Called when the host tells the app to push a new route onto the
  /// navigator.
  ///
  /// Observers are expected to return true if they were able to
  /// handle the notification. Observers are notified in registration
  /// order until one returns true.
  ///
  /// This method exposes the `pushRoute` notification from
  /// [SystemChannels.navigation].
  Future<bool> didPushRoute(String route) => Future<bool>.value(false);

  /// Called when the application's dimensions change. For example,
  /// when a phone is rotated.
  ///
  /// This method exposes notifications from [Window.onMetricsChanged].
  ///
  /// In general, this is unnecessary as the layout system takes care of
  /// automatically recomputing the application geometry when the application
  /// size changes.
  void didChangeMetrics() {}

  /// Called when the platform's text scale factor changes.
  ///
  /// This typically happens as the result of the user changing system
  /// preferences, and it should affect all of the text sizes in the
  /// application.
  ///
  /// This method exposes notifications from [Window.onTextScaleFactorChanged].
  void didChangeTextScaleFactor() {}

  /// Called when the platform brightness changes.
  ///
  /// This method exposes notifications from [Window.onPlatformBrightnessChanged].
  void didChangePlatformBrightness() {}

  /// Called when the system tells the app that the user's locale has
  /// changed. For example, if the user changes the system language
  /// settings.
  ///
  /// This method exposes notifications from [Window.onLocaleChanged].
  void didChangeLocales(List<Locale> locale) {}

  /// Called when the system puts the app in the background or returns
  /// the app to the foreground.
  ///
  /// An example of implementing this method is provided in the class-level
  /// documentation for the [ElementsBindingObserver] class.
  ///
  /// This method exposes notifications from [SystemChannels.lifecycle].
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  /// Called when the system is running low on memory.
  ///
  /// This method exposes the `memoryPressure` notification from
  /// [SystemChannels.system].
  void didHaveMemoryPressure() {}

  /// Called when the system changes the set of currently active accessibility
  /// features.
  ///
  /// This method exposes notifications from [Window.onAccessibilityFeaturesChanged].
  void didChangeAccessibilityFeatures() {}
}

/// The glue between the elements layer and the Flutter engine.
mixin ElementsBinding
    on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, RendererBinding, SemanticsBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    window.onLocaleChanged = handleLocaleChanged;
    window.onAccessibilityFeaturesChanged = handleAccessibilityFeaturesChanged;
    SystemChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
  }

  /// The current [ElementsBinding], if one has been created.
  ///
  /// If you need the binding to be constructed before calling [runApp],
  /// you can ensure a Elements binding has been constructed by calling the
  /// `ElementsFlutterBinding.ensureInitialized()` function.
  static ElementsBinding? get instance => _instance;
  static ElementsBinding? _instance;

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
    if (!kReleaseMode) {
      ElementInspectorService.instance.initServiceExtensions(registerServiceExtension);
    }
  }

  final List<ElementsBindingObserver> _observers = <ElementsBindingObserver>[];

  /// Registers the given object as a binding observer. Binding
  /// observers are notified when various application events occur,
  /// for example when the system locale changes. Generally, one
  /// element in the element tree registers itself as a binding
  /// observer, and converts the system state into inherited elements.
  ///
  /// See also:
  ///
  ///  * [removeObserver], to release the resources reserved by this method.
  ///  * [ElementsBindingObserver], which has an example of using this method.
  void addObserver(ElementsBindingObserver observer) => _observers.add(observer);

  /// Unregisters the given observer. This should be used sparingly as
  /// it is relatively expensive (O(N) in the number of registered
  /// observers).
  ///
  /// See also:
  ///
  ///  * [addObserver], for the method that adds observers in the first place.
  ///  * [ElementsBindingObserver], which has an example of using this method.
  bool removeObserver(ElementsBindingObserver observer) => _observers.remove(observer);

  @override
  void handleMetricsChanged() {
    super.handleMetricsChanged();
    for (ElementsBindingObserver observer in _observers) observer.didChangeMetrics();
  }

  @override
  void handleTextScaleFactorChanged() {
    super.handleTextScaleFactorChanged();
    for (ElementsBindingObserver observer in _observers) observer.didChangeTextScaleFactor();
  }

  @override
  void handlePlatformBrightnessChanged() {
    super.handlePlatformBrightnessChanged();
    for (ElementsBindingObserver observer in _observers) observer.didChangePlatformBrightness();
  }

  @override
  void handleAccessibilityFeaturesChanged() {
    super.handleAccessibilityFeaturesChanged();
    for (ElementsBindingObserver observer in _observers) observer.didChangeAccessibilityFeatures();
  }

  /// Called when the system locale changes.
  ///
  /// Calls [dispatchLocaleChanged] to notify the binding observers.
  ///
  /// See [Window.onLocaleChanged].
  @protected
  @mustCallSuper
  void handleLocaleChanged() {
    dispatchLocalesChanged(window.locales);
  }

  /// Notify all the observers that the locale has changed (using
  /// [ElementsBindingObserver.didChangeLocales]), giving them the
  /// `locales` argument.
  ///
  /// This is called by [handleLocaleChanged] when the [Window.onLocaleChanged]
  /// notification is received.
  @protected
  @mustCallSuper
  void dispatchLocalesChanged(List<Locale> locales) {
    for (ElementsBindingObserver observer in _observers) observer.didChangeLocales(locales);
  }

  /// Notify all the observers that the active set of [AccessibilityFeatures]
  /// has changed (using [ElementsBindingObserver.didChangeAccessibilityFeatures]),
  /// giving them the `features` argument.
  ///
  /// This is called by [handleAccessibilityFeaturesChanged] when the
  /// [Window.onAccessibilityFeaturesChanged] notification is received.
  @protected
  @mustCallSuper
  void dispatchAccessibilityFeaturesChanged() {
    for (ElementsBindingObserver observer in _observers) observer.didChangeAccessibilityFeatures();
  }

  /// Called when the system pops the current route.
  ///
  /// This first notifies the binding observers (using
  /// [ElementsBindingObserver.didPopRoute]), in registration order, until one
  /// returns true, meaning that it was able to handle the request (e.g. by
  /// closing a dialog box). If none return true, then the application is shut
  /// down by calling [SystemNavigator.pop].
  ///
  /// This method exposes the `popRoute` notification from
  /// [SystemChannels.navigation].
  @protected
  Future<void> handlePopRoute() async {
    for (ElementsBindingObserver observer in List<ElementsBindingObserver>.from(_observers)) {
      if (await observer.didPopRoute()) return;
    }
    SystemNavigator.pop();
  }

  /// Called when the host tells the app to push a new route onto the
  /// navigator.
  ///
  /// This notifies the binding observers (using
  /// [ElementsBindingObserver.didPushRoute]), in registration order, until one
  /// returns true, meaning that it was able to handle the request (e.g. by
  /// opening a dialog box). If none return true, then nothing happens.
  ///
  /// This method exposes the `pushRoute` notification from
  /// [SystemChannels.navigation].
  @protected
  @mustCallSuper
  Future<void> handlePushRoute(String route) async {
    for (ElementsBindingObserver observer in List<ElementsBindingObserver>.from(_observers)) {
      if (await observer.didPushRoute(route)) return;
    }
  }

  Future<dynamic> _handleNavigationInvocation(MethodCall methodCall) {
    switch (methodCall.method) {
      case 'popRoute':
        return handlePopRoute();
      case 'pushRoute':
        return handlePushRoute(methodCall.arguments);
    }
    return Future<dynamic>.value();
  }

  @override
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    super.handleAppLifecycleStateChanged(state);
    for (ElementsBindingObserver observer in _observers) observer.didChangeAppLifecycleState(state);
  }

  /// Called when the operating system notifies the application of a memory
  /// pressure situation.
  ///
  /// Notifies all the observers using
  /// [ElementsBindingObserver.didHaveMemoryPressure].
  ///
  /// This method exposes the `memoryPressure` notification from
  /// [SystemChannels.system].
  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    for (ElementsBindingObserver observer in _observers) observer.didHaveMemoryPressure();
  }

  @override
  Future<void> handleSystemMessage(Object systemMessage) async {
    await super.handleSystemMessage(systemMessage);
  }

  // ignore: prefer_final_fields
  bool _needToReportFirstFrame = true;
  int _deferFirstFrameReportCount = 0;

  final Completer<void> _firstFrameCompleter = Completer<void>();

  /// Whether the Flutter engine has rasterized the first frame.
  ///
  /// {@macro flutter.frame_rasterized_vs_presented}
  ///
  /// See also:
  ///
  ///  * [waitUntilFirstFrameRasterized], the future when [firstFrameRasterized]
  ///    becomes true.
  bool get firstFrameRasterized => _firstFrameCompleter.isCompleted;

  /// A future that completes when the Flutter engine has rasterized the first
  /// frame.
  ///
  /// {@macro flutter.frame_rasterize_vs_presented}
  ///
  /// See also:
  ///
  ///  * [firstFrameRasterized], whether this future has completed or not.
  Future<void> get waitUntilFirstFrameRasterized => _firstFrameCompleter.future;

  /// Whether the first frame has finished building.
  ///
  /// Only useful in profile and debug builds; in release builds, this always
  /// return false. This can be deferred using [deferFirstFrameReport] and
  /// [allowFirstFrameReport]. The value is set at the end of the call to
  /// [drawFrame].
  ///
  /// This value can also be obtained over the VM service protocol as
  /// `ext.flutter.didSendFirstFrameEvent`.
  ///
  /// See also:
  ///
  ///  * [firstFrameRasterized], whether the first frame has finished rendering.
  bool get debugDidSendFirstFrameEvent => !_needToReportFirstFrame;

  /// Tell the framework not to report the frame it is building as a "useful"
  /// first frame until there is a corresponding call to [allowFirstFrameReport].
  void deferFirstFrameReport() {
    if (!kReleaseMode) {
      assert(_deferFirstFrameReportCount >= 0);
      _deferFirstFrameReportCount += 1;
    }
  }

  /// When called after [deferFirstFrameReport]: tell the framework to report
  /// the frame it is building as a "useful" first frame.
  ///
  /// This method may only be called once for each corresponding call
  /// to [deferFirstFrameReport].
  void allowFirstFrameReport() {
    if (!kReleaseMode) {
      assert(_deferFirstFrameReportCount >= 1);
      _deferFirstFrameReportCount -= 1;
    }
  }
}

/// A concrete binding for applications based on the elements framework.
///
/// This is the glue that binds the framework to the Flutter engine.
class ElementsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        ElementsBinding {
  /// Returns an instance of the [ElementsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [ElementsFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [ElementsBinding].
  static ElementsBinding ensureInitialized() {
    if (ElementsBinding.instance == null) ElementsFlutterBinding();
    return ElementsBinding.instance!;
  }
}
