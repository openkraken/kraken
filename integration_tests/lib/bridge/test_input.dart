/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

export 'package:flutter/services.dart' show TextEditingValue, TextInputAction;

/// A testing stub for the system's onscreen keyboard.
///
/// Typical app tests will not need to use this class directly.
///
/// The [TestWidgetsFlutterBinding] class registers a [TestTextInput] instance
/// ([TestWidgetsFlutterBinding.testTextInput]) as a stub keyboard
/// implementation if its [TestWidgetsFlutterBinding.registerTestTextInput]
/// property returns true when a test starts, and unregisters it when the test
/// ends (unless it ends with a failure).
///
/// See [register], [unregister], and [isRegistered] for details.
///
/// The [enterText], [updateEditingValue], [receiveAction], and
/// [closeConnection] methods can be used even when the [TestTextInput] is not
/// registered. All other methods will assert if [isRegistered] is false.
///
/// See also:
///
/// * [WidgetTester.enterText], which uses this class to simulate keyboard input.
/// * [WidgetTester.showKeyboard], which uses this class to simulate showing the
///   popup keyboard and initializing its text.
class TestTextInput {
  /// Create a fake keyboard backend.
  ///
  /// The [onCleared] argument may be set to be notified of when the keyboard
  /// is dismissed.
  TestTextInput({ this.onCleared });

  /// Called when the keyboard goes away.
  ///
  /// To use the methods on this API that send fake keyboard messages (such as
  /// [updateEditingValue], [enterText], or [receiveAction]), the keyboard must
  /// first be requested, e.g. using [WidgetTester.showKeyboard].
  final VoidCallback? onCleared;

  /// Log for method calls.
  ///
  /// For all registered channels, handled calls are added to the list. Can
  /// be cleaned using `log.clear()`.
  final List<MethodCall> log = <MethodCall>[];

  /// Installs this object as a mock handler for [SystemChannels.textInput].
  ///
  /// Called by the binding at the top of a test when
  /// [TestWidgetsFlutterBinding.registerTestTextInput] is true.
  void register() => SystemChannels.textInput.setMockMethodCallHandler(_handleTextInputCall);

  /// Removes this object as a mock handler for [SystemChannels.textInput].
  ///
  /// After calling this method, the channel will exchange messages with the
  /// Flutter engine instead of the stub.
  ///
  /// Called by the binding at the end of a (successful) test when
  /// [TestWidgetsFlutterBinding.registerTestTextInput] is true.
  void unregister() => SystemChannels.textInput.setMockMethodCallHandler(null);

  /// Whether this [TestTextInput] is registered with [SystemChannels.textInput].
  ///
  /// The binding uses the [register] and [unregister] methods to control this
  /// value when [TestWidgetsFlutterBinding.registerTestTextInput] is true.
  bool get isRegistered => SystemChannels.textInput.checkMockMethodCallHandler(_handleTextInputCall);

  int? _client;

  /// Whether there are any active clients listening to text input.
  bool get hasAnyClients {
    assert(isRegistered);
    return _client != null && _client! > 0;
  }

  /// The last set of arguments supplied to the `TextInput.setClient` and
  /// `TextInput.updateConfig` methods of this stub implementation.
  Map<String, dynamic>? setClientArgs;

  /// The last set of arguments that [TextInputConnection.setEditingState] sent
  /// to this stub implementation (i.e. the arguments set to
  /// `TextInput.setEditingState`).
  ///
  /// This is a map representation of a [TextEditingValue] object. For example,
  /// it will have a `text` entry whose value matches the most recent
  /// [TextEditingValue.text] that was sent to the embedder.
  Map<String, dynamic>? editingState;

  /// Whether the onscreen keyboard is visible to the user.
  ///
  /// Specifically, this reflects the last call to `TextInput.show` or
  /// `TextInput.hide` received by the stub implementation.
  bool get isVisible {
    assert(isRegistered);
    return _isVisible;
  }
  bool _isVisible = false;

  /// Resets any internal state of this object.
  ///
  /// This method is invoked by the testing framework between tests. It should
  /// not ordinarily be called by tests directly.
  void reset() {
    log.clear();
    _client = null;
    setClientArgs = null;
    editingState = null;
    _isVisible = false;
  }

  Future<dynamic> _handleTextInputCall(MethodCall methodCall) async {
    log.add(methodCall);
    switch (methodCall.method) {
      case 'TextInput.setClient':
        final List<dynamic> arguments = methodCall.arguments as List<dynamic>;
        _client = arguments[0] as int;
        setClientArgs = arguments[1] as Map<String, dynamic>;
        break;
      case 'TextInput.updateConfig':
        setClientArgs = methodCall.arguments as Map<String, dynamic>;
        break;
      case 'TextInput.clearClient':
        _client = null;
        _isVisible = false;
        onCleared?.call();
        break;
      case 'TextInput.setEditingState':
        editingState = methodCall.arguments as Map<String, dynamic>;
        break;
      case 'TextInput.show':
        _isVisible = true;
        break;
      case 'TextInput.hide':
        _isVisible = false;
        break;
    }
  }

  /// Simulates the user hiding the onscreen keyboard.
  ///
  /// This does nothing but set the internal flag.
  void hide() {
    assert(isRegistered);
    _isVisible = false;
  }

  /// Simulates the user changing the text of the focused text field, and resets
  /// the selection.
  ///
  /// Calling this method replaces the content of the connected input field with
  /// `text`, and places the caret at the end of the text.
  ///
  /// To update the UI under test after this method is invoked, use
  /// [WidgetTester.pump].
  ///
  /// This can be called even if the [TestTextInput] has not been [register]ed.
  ///
  /// If this is used to inject text when there is a real IME connection, for
  /// example when using the [integration_test] library, there is a risk that
  /// the real IME will become confused as to the current state of input.
  ///
  /// See also:
  ///
  ///  * [updateEditingValue], which takes a [TextEditingValue] so that one can
  ///    also change the selection.
  void enterText(String text) {
    updateEditingValue(TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ));
  }

  /// Simulates the user changing the [TextEditingValue] to the given value.
  ///
  /// To update the UI under test after this method is invoked, use
  /// [WidgetTester.pump].
  ///
  /// This can be called even if the [TestTextInput] has not been [register]ed.
  ///
  /// If this is used to inject text when there is a real IME connection, for
  /// example when using the [integration_test] library, there is a risk that
  /// the real IME will become confused as to the current state of input.
  ///
  /// See also:
  ///
  ///  * [enterText], which is similar but takes only a String and resets the
  ///    selection.
  void updateEditingValue(TextEditingValue value) {
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        MethodCall(
          'TextInputClient.updateEditingState',
          <dynamic>[_client ?? -1, value.toJSON()],
        ),
      ),
      (ByteData? data) { /* ignored */ },
    );
  }

  /// Simulates the user pressing one of the [TextInputAction] buttons.
  /// Does not check that the [TextInputAction] performed is an acceptable one
  /// based on the `inputAction` [setClientArgs].
  ///
  /// This can be called even if the [TestTextInput] has not been [register]ed.
  ///
  /// If this is used to inject an action when there is a real IME connection,
  /// for example when using the [integration_test] library, there is a risk
  /// that the real IME will become confused as to the current state of input.
  Future<void> receiveAction(TextInputAction action) async {
    return TestAsyncUtils.guard(() {
      final Completer<void> completer = Completer<void>();
      ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.textInput.name,
        SystemChannels.textInput.codec.encodeMethodCall(
          MethodCall(
            'TextInputClient.performAction',
            <dynamic>[_client ?? -1, action.toString()],
          ),
        ),
        (ByteData? data) {
          assert(data != null);
          try {
            // Decoding throws a PlatformException if the data represents an
            // error, and that's all we care about here.
            SystemChannels.textInput.codec.decodeEnvelope(data!);
            // If we reach here then no error was found. Complete without issue.
            completer.complete();
          } catch (error) {
            // An exception occurred as a result of receiveAction()'ing. Report
            // that error.
            completer.completeError(error);
          }
        },
      );
      return completer.future;
    });
  }

  /// Simulates the user closing the text input connection.
  ///
  /// For example:
  ///
  ///  * User pressed the home button and sent the application to background.
  ///  * User closed the virtual keyboard.
  ///
  /// This can be called even if the [TestTextInput] has not been [register]ed.
  ///
  /// If this is used to inject text when there is a real IME connection, for
  /// example when using the [integration_test] library, there is a risk that
  /// the real IME will become confused as to the current state of input.
  void closeConnection() {
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        MethodCall(
          'TextInputClient.onConnectionClosed',
           <dynamic>[_client ?? -1],
        ),
      ),
      (ByteData? data) { /* response from framework is discarded */ },
    );
  }
}

