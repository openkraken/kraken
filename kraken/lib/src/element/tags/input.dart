/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

const String INPUT = 'INPUT';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  WIDTH: '150px',
};

typedef ValueChanged<T> = void Function(T value);
// The time it takes for the cursor to fade from fully opaque to fully
// transparent and vice versa. A full cursor blink, from transparent to opaque
// to transparent, is twice this duration.
const Duration _kCursorBlinkHalfPeriod = Duration(milliseconds: 500);

// The time the cursor is static in opacity before animating to become
// transparent.
const Duration _kCursorBlinkWaitForStart = Duration(milliseconds: 150);

const TextSelection blurSelection = TextSelection.collapsed(offset: -1);

class EditableTextDelegate implements TextSelectionDelegate {
  @override
  TextEditingValue textEditingValue;

  @override
  void bringIntoView(TextPosition position) {
    // TODO: implement bringIntoView
    print('call bringIntoView $position');
  }

  @override
  void hideToolbar() {
    // TODO: implement hideToolbar
    print('call hideToolbar');
  }

  @override
  bool get copyEnabled => true;

  @override
  bool get cutEnabled => true;

  @override
  bool get pasteEnabled => true;

  @override
  bool get selectAllEnabled => true;
}

class InputElement extends Element implements TextInputClient, TickerProvider {
  Timer _cursorTimer;
  bool _targetCursorVisibility = false;
  final ValueNotifier<bool> _cursorVisibilityNotifier = ValueNotifier<bool>(true);
  AnimationController _cursorBlinkOpacityController;
  int _obscureShowCharTicksPending = 0;

  TextInputType inputType = TextInputType.text;
  TextAlign textAlign;
  TextDirection textDirection;
  int minLines;
  int maxLines;

  ViewportOffset offset = ViewportOffset.zero();
  bool obscureText = false;
  TextSelectionDelegate textSelectionDelegate = EditableTextDelegate();
  TextSpan textSpan;
  TextSpan placeholderTextSpan;
  TextStyle placeholderTextStyle;
  RenderEditable renderEditable;
  TextInputConnection textInputConnection;

  // This value is an eyeball estimation of the time it takes for the iOS cursor
  // to ease in and out.
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  String _placeholder;
  String get placeholder => _placeholder;
  set placeholder(String text) {
    _placeholder = text;
    placeholderTextStyle ??= getTextStyle(style.copyWith({
      'color': 'grey',
    }));
    placeholderTextSpan = TextSpan(
      text: _placeholder,
      style: placeholderTextStyle,
    );
  }

  TextInputConfiguration textInputConfiguration;

  InputElement(
    int targetId, {
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.minLines = 1,
    this.maxLines = 1,
  }) : super(targetId: targetId, tagName: INPUT, defaultStyle: _defaultStyle, isIntrinsicBox: true) {
    textInputConfiguration = TextInputConfiguration(
      inputType: inputType,
      obscureText: false,
      autocorrect: false,
      inputAction: TextInputAction.done, // newline to multilines
      textCapitalization: TextCapitalization.none,
      keyboardAppearance: Brightness.light,
    );
    textSpan = buildTextSpan();
    placeholder = getPlaceholderText();
    renderEditable = createRenderObject();
    addChild(renderEditable);
    textSelectionDelegate.textEditingValue = TextEditingValue(text: textSpan.text);

    _cursorBlinkOpacityController = AnimationController(vsync: this, duration: _fadeDuration);
    _cursorBlinkOpacityController.addListener(_onCursorColorTick);

    setBoxConstraints();
  }

  void setBoxConstraints() {
    bool containWidth = style.contains('width');
    bool containHeight = style.contains('height');
    BoxConstraints oldConstraints = renderConstrainedBox.additionalConstraints;
    double minWidth = oldConstraints.minWidth;
    double maxWidth = oldConstraints.maxWidth;
    double minHeight = oldConstraints.minHeight;
    double maxHeight = oldConstraints.maxHeight;

    if (containWidth) {
      minWidth = maxWidth = CSSStyleProperty.getDisplayPortValue(style['width']);
    }
    if (containHeight) {
      minHeight = maxHeight = CSSStyleProperty.getDisplayPortValue(style['height']);
    }
    renderConstrainedBox.additionalConstraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  TextSpan buildTextSpan({String text}) {
    text ??= properties['value'];
    return createTextSpanWithStyle(text ?? '', style);
  }

  String getPlaceholderText() {
    return properties['placeholder'] ?? '';
  }

  get cursorColor => CSSColor.initial;

  @override
  void handleClick(Event event) {
    activeTextInput();
    super.handleClick(event);
  }

  void activeTextInput() {
    if (textInputConnection == null) {
      final TextEditingValue localValue = textSelectionDelegate.textEditingValue;
      _lastKnownRemoteTextEditingValue = localValue;

      textInputConnection = TextInput.attach(this, textInputConfiguration);
      textInputConnection.setEditingState(localValue);
    }
    textInputConnection.show();
  }

  void onSelectionChanged(TextSelection selection, RenderEditable renderObject, SelectionChangedCause cause) {
    TextEditingValue value = textSelectionDelegate.textEditingValue.copyWith(
        selection: renderObject.text == placeholderTextSpan ? blurSelection : selection, composing: TextRange.empty);
    updateEditingValue(value);
  }

  RenderEditable createRenderObject() {
    TextSpan text = textSpan.toPlainText().length > 0 ? textSpan : placeholderTextSpan;
    return RenderEditable(
      text: text,
      cursorColor: cursorColor,
      showCursor: _cursorVisibilityNotifier,
      hasFocus: true,
      maxLines: maxLines,
      minLines: minLines,
      expands: false,
      textScaleFactor: 1.0,
      textAlign: textAlign,
      textDirection: textDirection,
      selection: blurSelection, // Default to blur
      offset: offset,
      forceLine: false,
      onSelectionChanged: onSelectionChanged,
      onCaretChanged: _handleCaretChanged,
      obscureText: obscureText,
      cursorWidth: 1.0,
      cursorRadius: Radius.zero,
      cursorOffset: Offset.zero,
      enableInteractiveSelection: true,
      textSelectionDelegate: textSelectionDelegate,
      devicePixelRatio: window.devicePixelRatio,
      startHandleLayerLink: LayerLink(),
      endHandleLayerLink: LayerLink(),
    );
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.done) {
      _triggerChangeEvent();
    }
  }

  void _hideSelectionOverlayIfNeeded() {
    // todo: selection overlay.
  }

  bool get _hasInputConnection => textInputConnection != null && textInputConnection.attached;
  TextEditingValue _lastKnownRemoteTextEditingValue;

  void _updateRemoteEditingValueIfNeeded() {
    if (!_hasInputConnection) return;
    final TextEditingValue localValue = textSelectionDelegate.textEditingValue;
    if (localValue == _lastKnownRemoteTextEditingValue) return;
    _lastKnownRemoteTextEditingValue = localValue;
    textInputConnection.setEditingState(localValue);
  }

  void _formatAndSetValue(TextEditingValue value) {
    final bool textChanged = textSelectionDelegate.textEditingValue?.text != value?.text;
    textSelectionDelegate.textEditingValue = value;

    if (textChanged) {
      _updateRemoteEditingValueIfNeeded();
      textSpan = buildTextSpan(text: value.text);
      if (value.text.length == 0) {
        renderEditable.text = placeholderTextSpan;
      } else {
        renderEditable.text = textSpan;
      }
    }

    renderEditable.selection = value.selection;
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    if (value.text != textSelectionDelegate.textEditingValue.text) {
      _hideSelectionOverlayIfNeeded();
      _showCaretOnScreen();
      _triggerInputEvent(value.text);
    }
    _lastKnownRemoteTextEditingValue = value;
    _formatAndSetValue(value);
    // To keep the cursor from blinking while typing, we want to restart the
    // cursor timer every time a new character is typed.
    _stopCursorTimer(resetCharTicks: false);
    _startCursorTimer();
  }

  void _triggerInputEvent(String text) {
    Event inputEvent = InputEvent(text);
    dispatchEvent(inputEvent);
  }

  String _lastChangedTextString;
  void _triggerChangeEvent() {
    String currentText = textSelectionDelegate.textEditingValue?.text;
    if (_lastChangedTextString != currentText) {
      Event changeEvent = Event('change');
      dispatchEvent(changeEvent);
      _lastChangedTextString = currentText;
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    if (key == 'value' && value is String) {
      String text = value ?? '';

      TextEditingValue newTextEditingValue = textSelectionDelegate.textEditingValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _formatAndSetValue(newTextEditingValue);
    }
  }

  bool _showCaretOnScreenScheduled = false;
  Rect _currentCaretRect;
  void _showCaretOnScreen() {
    if (_showCaretOnScreenScheduled) {
      return;
    }
    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _showCaretOnScreenScheduled = false;
      if (_currentCaretRect == null) {
        return;
      }
      final Rect newCaretRect = _currentCaretRect;
      // Enlarge newCaretRect by scrollPadding to ensure that caret is not positioned directly at the edge after scrolling.
      final Rect inflatedRect = Rect.fromLTRB(
        newCaretRect.left,
        newCaretRect.top,
        newCaretRect.right,
        newCaretRect.bottom,
      );
      renderEditable.showOnScreen(
        rect: inflatedRect,
        duration: _caretAnimationDuration,
        curve: _caretAnimationCurve,
      );
    });
  }

  // Animation configuration for scrolling the caret back on screen.
  static const Duration _caretAnimationDuration = Duration(milliseconds: 100);
  static const Curve _caretAnimationCurve = Curves.fastOutSlowIn;

  bool _textChangedSinceLastCaretUpdate = false;
  void _handleCaretChanged(Rect caretRect) {
    _currentCaretRect = caretRect;
    // If the caret location has changed due to an update to the text or
    // selection, then scroll the caret into view.
    if (_textChangedSinceLastCaretUpdate) {
      _textChangedSinceLastCaretUpdate = false;
      _showCaretOnScreen();
    }
  }

  void _stopCursorTimer({bool resetCharTicks = true}) {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _targetCursorVisibility = false;
    _cursorBlinkOpacityController.value = 0.0;
    if (resetCharTicks) _obscureShowCharTicksPending = 0;
    _cursorBlinkOpacityController.stop();
    _cursorBlinkOpacityController.value = 0.0;
  }

  void _startCursorTimer() {
    _targetCursorVisibility = true;
    _cursorBlinkOpacityController.value = 1.0;
    _cursorTimer = Timer.periodic(_kCursorBlinkWaitForStart, _cursorWaitForStart);
  }

  void _cursorWaitForStart(Timer timer) {
    assert(_kCursorBlinkHalfPeriod > _fadeDuration);
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(_kCursorBlinkHalfPeriod, _cursorTick);
  }

  void _cursorTick(Timer timer) {
    _targetCursorVisibility = !_targetCursorVisibility;
    final double targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;
    // If we want to show the cursor, we will animate the opacity to the value
    // of 1.0, and likewise if we want to make it disappear, to 0.0. An easing
    // curve is used for the animation to mimic the aesthetics of the native
    // iOS cursor.
    //
    // These values and curves have been obtained through eyeballing, so are
    // likely not exactly the same as the values for native iOS.
    _cursorBlinkOpacityController.animateTo(targetOpacity, curve: Curves.easeOut);

    if (_obscureShowCharTicksPending > 0) {
      _obscureShowCharTicksPending--;
    }
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    final TextPosition currentTextPosition = TextPosition(offset: 1);
    Rect _startCaretRect = renderEditable.getLocalRectForCaret(currentTextPosition);
    renderEditable.setFloatingCursor(point.state, _startCaretRect.center, currentTextPosition);
  }

  void _onCursorColorTick() {
    renderEditable.cursorColor = cursorColor.withOpacity(_cursorBlinkOpacityController.value);
    _cursorVisibilityNotifier.value = _cursorBlinkOpacityController.value > 0;
  }

  Set<Ticker> _tickers;

  @override
  Ticker createTicker(onTick) {
    _tickers ??= <Ticker>{};
    final Ticker result = Ticker(onTick, debugLabel: 'created by $this');
    _tickers.add(result);
    return result;
  }

  @override
  void connectionClosed() {
    // TODO: implement connectionClosed
    print('TODO: impl connection closed.');
  }

  // Abstract class method added after flutter@1.15
  @override
  TextEditingValue get currentTextEditingValue => textSelectionDelegate.textEditingValue;
}
