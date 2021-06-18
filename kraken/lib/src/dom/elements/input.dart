/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' hide RenderEditable;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

const String INPUT = 'INPUT';
const String VALUE = 'value';

const TextInputType TEXT_INPUT_TYPE_NUMBER = TextInputType.numberWithOptions(signed: true);

final Pointer<NativeFunction<GetInputWidth>> nativeGetInputWidth = Pointer.fromFunction(InputElement.getInputWidth, 0.0);
final Pointer<NativeFunction<GetInputHeight>> nativeGetInputHeight = Pointer.fromFunction(InputElement.getInputHeight, 0.0);
final Pointer<NativeFunction<InputElementMethodVoidCallback>> nativeInputMethodFocus = Pointer.fromFunction(InputElement.callMethodFocus);
final Pointer<NativeFunction<InputElementMethodVoidCallback>> nativeInputMethodBlur = Pointer.fromFunction(InputElement.callMethodBlur);

/// https://www.w3.org/TR/css-sizing-3/#intrinsic-sizes
/// For boxes without a preferred aspect ratio:
/// If the available space is definite in the appropriate dimension, use the stretch fit into that size in that dimension.
///
/// Otherwise, if the box has a <length> as its computed minimum size (min-width/min-height) in that dimension, use that size.
//
/// Otherwise, use 300px for the width and/or 150px for the height as needed.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  WIDTH: '150px',
  BORDER: '1px solid #767676',
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
  TextEditingValue _textEditingValue = TextEditingValue();

  @override
  TextEditingValue get textEditingValue => _textEditingValue;

  @override
  set textEditingValue(TextEditingValue value) {
    _textEditingValue = value;
  }

  @override
  void bringIntoView(TextPosition position) {
    // TODO: implement bringIntoView
    print('call bringIntoView $position');
  }

  @override
  void hideToolbar([bool hideHandles = true]) {
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

  @override
  void userUpdateTextEditingValue(TextEditingValue value, SelectionChangedCause cause) {
    _textEditingValue = value;
  }
}

class InputElement extends Element implements TextInputClient, TickerProvider {
  static InputElement? focusInputElement;

  static void clearFocus() {
    if (InputElement.focusInputElement != null) {
      InputElement.focusInputElement!.blur();
    }

    InputElement.focusInputElement = null;
  }

  static void setFocus(InputElement inputElement) {
    clearFocus();
    InputElement.focusInputElement = inputElement;
    inputElement.focus();
  }

  static SplayTreeMap<int, InputElement> _nativeMap = SplayTreeMap();

  static InputElement getInputElementOfNativePtr(Pointer<NativeInputElement> nativePtr) {
    InputElement? element = _nativeMap[nativePtr.address];
    if (element == null) throw FlutterError('Can not get element from nativeElement: $nativePtr');
    return element;
  }

  // el.width
  static double getInputWidth(Pointer<NativeInputElement> nativeInputElement) {
    // @TODO: Apply algorithm of input element property width.
    return 0.0;
  }

  // el.height
  static double getInputHeight(Pointer<NativeInputElement> nativeInputElement) {
    // @TODO: Apply algorithm of input element property height.
    return 0.0;
  }

  static void callMethodFocus(Pointer<NativeInputElement> nativeInputElement) {
    InputElement inputElement = getInputElementOfNativePtr(nativeInputElement);
    InputElement.setFocus(inputElement);
  }

  static void callMethodBlur(Pointer<NativeInputElement> nativeInputElement) {
    InputElement inputElement = getInputElementOfNativePtr(nativeInputElement);
    if (inputElement == InputElement.focusInputElement) {
      InputElement.clearFocus();
    }
  }

  static String obscuringCharacter = '•';

  final Pointer<NativeInputElement> nativeInputElement;
  Timer? _cursorTimer;
  bool _targetCursorVisibility = false;
  final ValueNotifier<bool> _cursorVisibilityNotifier = ValueNotifier<bool>(false);
  AnimationController? _cursorBlinkOpacityController;
  int _obscureShowCharTicksPending = 0;

  TextAlign textAlign;
  TextDirection textDirection;
  int minLines;
  int maxLines;

  bool _autoFocus = false;

  ViewportOffset offset = ViewportOffset.zero();
  bool obscureText = false;
  bool autoCorrect = false;
  TextSelectionDelegate textSelectionDelegate = EditableTextDelegate();
  TextSpan? _actualText;
  RenderEditable? _renderEditable;
  TextInputConnection? textInputConnection;

  // This value is an eyeball estimation of the time it takes for the iOS cursor
  // to ease in and out.
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  // Input text-overflow not follow text rules.
  TextOverflow get textOverflow {
    switch(style[TEXT_OVERFLOW]) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
      default:
        return TextOverflow.clip;
    }
  }

  String get placeholderText => properties['placeholder'] ?? '';

  TextSpan get placeholderTextSpan {
    // TODO: support ::placeholder pseudo element
    return _buildTextSpan(
      text: placeholderText,
    );
  }

  TextInputConfiguration? textInputConfiguration;

  InputElement(
    int targetId,
    this.nativeInputElement,
    ElementManager elementManager, {
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.minLines = 1,
    this.maxLines = 1,
  }) : super(targetId, nativeInputElement.ref.nativeElement, elementManager, tagName: INPUT, defaultStyle: _defaultStyle, isIntrinsicBox: true) {
    _nativeMap[nativeInputElement.address] = this;

    nativeInputElement.ref.getInputWidth = nativeGetInputWidth;
    nativeInputElement.ref.getInputHeight = nativeGetInputHeight;
    nativeInputElement.ref.focus = nativeInputMethodFocus;
    nativeInputElement.ref.blur = nativeInputMethodBlur;
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    // Make element listen to click event to trigger focus.
    addEvent(EVENT_CLICK);

    AnimationController animationController = _cursorBlinkOpacityController = AnimationController(vsync: this, duration: _fadeDuration);
    animationController.addListener(_onCursorColorTick);

    addChild(createRenderBox());

    if (properties.containsKey(VALUE)) {
      setProperty(VALUE, properties[VALUE]);
    }

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (_autoFocus) {
        InputElement.setFocus(this);
      }
    });
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();
    InputElement.clearFocus();
    _cursorTimer?.cancel();
    if (textInputConnection != null && textInputConnection!.attached) {
      textInputConnection!.close();
    }
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _cursorBlinkOpacityController!.removeListener(_onCursorColorTick);
    _cursorBlinkOpacityController = null;
    _renderEditable = null;
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);

    // @TODO: Filter style properties that used by text span.
    _rebuildTextSpan();
  }

  void _rebuildTextSpan() {
    // Rebuilt text span, for style has changed.
    _actualText = _buildTextSpan(text: _actualText?.text);
    TextEditingValue value = TextEditingValue(text: _actualText!.text!);
    textSelectionDelegate.userUpdateTextEditingValue(value, SelectionChangedCause.keyboard);
    TextSpan? text = obscureText ? _buildPasswordTextSpan(_actualText!.text!) : _actualText;
    if (_renderEditable != null) {
      _renderEditable!.text = _actualText!.text!.length == 0
          ? placeholderTextSpan
          : text;
      _renderEditable!.textOverflow = textOverflow;
    }
  }

  TextSpan _buildTextSpan({ String? text = '' }) {
    if (text == null || text.length == 0) {
      text = properties[VALUE] ?? '';
    }
    return CSSTextMixin.createTextSpan(text ?? '', parentElement: this);
  }

  TextSpan _buildPasswordTextSpan(String text) {
    return CSSTextMixin.createTextSpan(obscuringCharacter * text.length, parentElement: this);
  }

  Color get cursorColor => CSSColor.initial;

  @override
  void handlePointDown(PointerDownEvent pointEvent) {
    super.handlePointDown(pointEvent);
    InputElement.setFocus(this);
    // @TODO: selection.
  }

  @override
  void handlePointMove(PointerMoveEvent pointEvent) {
    super.handlePointMove(pointEvent);

    // @TODO: selection.
  }

  @override
  void handlePointUp(PointerUpEvent pointEvent) {
    super.handlePointUp(pointEvent);
    // @TODO: selection.
  }

  void focus() {
    if (isRendererAttached) {
      activeTextInput();
      dispatchEvent(Event('focus'));
    }
  }

  void blur() {
    if (isRendererAttached) {
      deactiveTextInput();
      dispatchEvent(Event('blur'));
    }
  }

  // Store the state at the begin of user input.
  String? _inputValueAtBegin;

  void activeTextInput() {
    _inputValueAtBegin = properties[VALUE];

    if (textInputConfiguration == null) {
      textInputConfiguration = TextInputConfiguration(
        inputType: _textInputType,
        obscureText: obscureText,
        autocorrect: autoCorrect,
        inputAction: TextInputAction.done, // newline to multilines
        textCapitalization: TextCapitalization.none,
        keyboardAppearance: Brightness.light,
      );
    }

    TextInputConnection? _textInputConnection = textInputConnection;
    if (_textInputConnection == null || !_textInputConnection.attached) {
      final TextEditingValue localValue = textSelectionDelegate.textEditingValue;
      _lastKnownRemoteTextEditingValue = localValue;

      _textInputConnection = textInputConnection = TextInput.attach(this, textInputConfiguration!);
      _textInputConnection.setEditingState(localValue);
    }
    _textInputConnection.show();
    _startCursorTimer();
    _renderEditable!.markNeedsTextLayout();
  }

  void deactiveTextInput() {
    _cursorVisibilityNotifier.value = false;
    if (textInputConnection != null && textInputConnection!.attached) {
      textInputConnection!.close();
    }
    _stopCursorTimer();
    _renderEditable!.markNeedsTextLayout();
  }

  void onSelectionChanged(TextSelection selection, RenderEditable renderObject, SelectionChangedCause cause) {
    TextEditingValue value = textSelectionDelegate.textEditingValue.copyWith(
        selection: renderObject.text == placeholderTextSpan ? blurSelection : selection, composing: TextRange.empty);
    updateEditingValue(value);
  }

  bool get multiLine => maxLines > 1;
  bool get _hasFocus => InputElement.focusInputElement == this;

  RenderEditable createRenderEditable() {
    if (_actualText == null) {
      _actualText = _buildTextSpan();
    }
    TextSpan text = _actualText!;
    if (_actualText!.toPlainText().length == 0) {
      text = placeholderTextSpan;
    } else if (obscureText) {
      text = _buildPasswordTextSpan(text.text!);
    }

    _renderEditable = RenderEditable(
      text: text,
      cursorColor: cursorColor,
      showCursor: _cursorVisibilityNotifier,
      hasFocus: _hasFocus,
      maxLines: maxLines,
      minLines: minLines,
      expands: false,
      textScaleFactor: 1.0,
      textAlign: textAlign,
      textDirection: textDirection,
      selection: blurSelection, // Default to blur
      offset: offset,
      readOnly: false,
      forceLine: true,
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
      textOverflow: textOverflow,
    );
    return _renderEditable!;
  }

  RenderBox createRenderBox() {
    assert(renderBoxModel is RenderIntrinsic);
    RenderEditable renderEditable = createRenderEditable();
    RenderIntrinsic renderIntrinsic = (renderBoxModel as RenderIntrinsic?)!;
    RenderStyle renderStyle = renderIntrinsic.renderStyle;
    // Make render editable vertically center.
    double dy = renderStyle.height == null
        ? 0
        : (renderStyle.height!
            - renderEditable.preferredLineHeight
            - renderIntrinsic.renderStyle.borderTop
            - renderIntrinsic.renderStyle.borderBottom) / 2;
    RenderOffsetBox renderOffsetBox = RenderOffsetBox(
      offset: Offset(0, dy),
      child: renderEditable,
    );
    return renderOffsetBox;
  }

  @override
  void performAction(TextInputAction action) {
    switch (action) {
      case TextInputAction.done:
        _triggerChangeEvent();
        blur();
        break;
      case TextInputAction.none:
        // TODO: Handle this case.
        break;
      case TextInputAction.unspecified:
        // TODO: Handle this case.
        break;
      case TextInputAction.go:
        // TODO: Handle this case.
        break;
      case TextInputAction.search:
        // TODO: Handle this case.
        break;
      case TextInputAction.send:
        // TODO: Handle this case.
        break;
      case TextInputAction.next:
        // TODO: Handle this case.
        break;
      case TextInputAction.previous:
        // TODO: Handle this case.
        break;
      case TextInputAction.continueAction:
        // TODO: Handle this case.
        break;
      case TextInputAction.join:
        // TODO: Handle this case.
        break;
      case TextInputAction.route:
        // TODO: Handle this case.
        break;
      case TextInputAction.emergencyCall:
        // TODO: Handle this case.
        break;
      case TextInputAction.newline:
        // TODO: Handle this case.
        break;
    }
  }

  void _hideSelectionOverlayIfNeeded() {
    // todo: selection overlay.
  }

  bool get _hasInputConnection => textInputConnection != null && textInputConnection!.attached;
  TextEditingValue? _lastKnownRemoteTextEditingValue;

  void _updateRemoteEditingValueIfNeeded() {
    if (!_hasInputConnection) return;
    final TextEditingValue localValue = textSelectionDelegate.textEditingValue;
    if (localValue == _lastKnownRemoteTextEditingValue) return;
    _lastKnownRemoteTextEditingValue = localValue;
    textInputConnection!.setEditingState(localValue);
  }

  void formatAndSetValue(TextEditingValue value, { bool shouldDispatchEvent = false }) {
    final bool textChanged = textSelectionDelegate.textEditingValue.text != value.text;
    textSelectionDelegate.userUpdateTextEditingValue(value, SelectionChangedCause.keyboard);

    if (textChanged) {
      _updateRemoteEditingValueIfNeeded();
      if (_renderEditable != null) {
        if (value.text.length == 0) {
          _renderEditable!.text = placeholderTextSpan;
        } else if (obscureText) {
          _renderEditable!.text = _buildPasswordTextSpan(value.text);
        } else {
          _actualText = _renderEditable!.text = _buildTextSpan(text: value.text);
        }
      }
      // Sync value to input element property
      properties[VALUE] = value.text;
      if (shouldDispatchEvent) {
        // TODO: return the string containing the data that was added to the element,
        // which MAY be null if it doesn't apply.
        String inputData = '';
        InputEvent inputEvent = InputEvent(inputData);
        dispatchEvent(inputEvent);
      }
    }

    if (_renderEditable != null) {
      _renderEditable!.selection = value.selection;
    }
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    if (value.text != textSelectionDelegate.textEditingValue.text) {
      _hideSelectionOverlayIfNeeded();
      _showCaretOnScreen();
    }
    _lastKnownRemoteTextEditingValue = value;
    formatAndSetValue(value, shouldDispatchEvent: true);
    // To keep the cursor from blinking while typing, we want to restart the
    // cursor timer every time a new character is typed.
    _stopCursorTimer(resetCharTicks: false);
    _startCursorTimer();
  }

  void _triggerChangeEvent() {
    String currentValue = textSelectionDelegate.textEditingValue.text;
    if (_inputValueAtBegin != currentValue) {
      Event changeEvent = Event(EVENT_CHANGE);
      dispatchEvent(changeEvent);
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    if (key == VALUE) {
      String text = value?.toString() ?? '';
      TextRange composing = textSelectionDelegate.textEditingValue.composing;
      TextSelection selection = TextSelection.collapsed(offset: text.length);
      TextEditingValue newTextEditingValue = TextEditingValue(
        text: text,
        selection: selection,
        composing: composing,
      );
      formatAndSetValue(newTextEditingValue);
    } else if (key == 'placeholder') {
      // Update placeholder text.
      _rebuildTextSpan();
    } else if (key == 'autofocus') {
      _autoFocus = value != null;
    } else if (key == 'type') {
      _setType(value);
    }
  }

  TextInputType _textInputType = TextInputType.text;
  TextInputType get textInputType => _textInputType;
  set textInputType(TextInputType value) {
    if (value != _textInputType) {
      _textInputType = value;
      if (textInputConnection != null && textInputConnection!.attached) {
        deactiveTextInput();
        activeTextInput();
      }
    }
  }

  void _setType(String value) {
    switch (value) {
      case 'text':
        textInputType = TextInputType.text;
        break;
      case 'number':
        textInputType = TEXT_INPUT_TYPE_NUMBER;
        break;
      case 'tel':
        textInputType = TextInputType.number;
        break;
      case 'password':
        textInputType = TextInputType.text;
        _enablePassword();
        break;
      // @TODO: more types.
    }
  }

  void _enablePassword() {
    obscureText = true;
    if (_renderEditable != null) {
      _renderEditable!.obscureText = obscureText;
    }
  }

  bool _showCaretOnScreenScheduled = false;
  Rect? _currentCaretRect;
  void _showCaretOnScreen() {
    if (_showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      _showCaretOnScreenScheduled = false;
      Rect? currentCaretRect = _currentCaretRect;
      if (currentCaretRect == null || _renderEditable == null) {
        return;
      }

      final Rect newCaretRect = currentCaretRect;
      // Enlarge newCaretRect by scrollPadding to ensure that caret
      // is not positioned directly at the edge after scrolling.
      final Rect inflatedRect = Rect.fromLTRB(
        newCaretRect.left,
        newCaretRect.top,
        newCaretRect.right,
        newCaretRect.bottom,
      );

      _renderEditable!.showOnScreen(
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
    _cursorBlinkOpacityController!.value = 0.0;
    if (resetCharTicks) _obscureShowCharTicksPending = 0;
    _cursorBlinkOpacityController!.stop();
    _cursorBlinkOpacityController!.value = 0.0;
  }

  void _startCursorTimer() {
    _targetCursorVisibility = true;
    _cursorBlinkOpacityController!.value = 1.0;
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
    _cursorBlinkOpacityController!.animateTo(targetOpacity, curve: Curves.easeOut);

    if (_obscureShowCharTicksPending > 0) {
      _obscureShowCharTicksPending--;
    }
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    final TextPosition currentTextPosition = TextPosition(offset: 1);
    Rect _startCaretRect = _renderEditable!.getLocalRectForCaret(currentTextPosition);
    _renderEditable!.setFloatingCursor(point.state, _startCaretRect.center, currentTextPosition);
  }

  void _onCursorColorTick() {
    _renderEditable!.cursorColor = cursorColor.withOpacity(_cursorBlinkOpacityController!.value);
    _cursorVisibilityNotifier.value = _cursorBlinkOpacityController!.value > 0;
  }

  Set<Ticker>? _tickers;

  @override
  Ticker createTicker(onTick) {
    _tickers ??= <Ticker>{};
    final Ticker result = Ticker(onTick, debugLabel: 'created by $this');
    _tickers!.add(result);
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

  @override
  // TODO: implement currentAutofillScope
  AutofillScope get currentAutofillScope => throw UnimplementedError();

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // TODO: implement performPrivateCommand
    print('PerformPrivateCommand $action $data');
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // TODO: implement showAutocorrectionPromptRect
    print('ShowAutocorrectionPromptRect start: $start, end: $end');
  }

  void dispose() {
    super.dispose();
    _nativeMap.remove(nativeInputElement.address);
  }
}

class RenderOffsetBox extends RenderProxyBox {
  RenderOffsetBox({
    RenderBox? child,
    Offset? offset
  }) : assert(offset != null),
        _offset = offset,
        super(child);

  Offset? _offset;
  Offset? get offset => _offset;
  set(Offset? value) {
    if (value != null && value != _offset) {
      _offset = value;
      markNeedsLayout();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_offset == null) {
      super.paint(context, offset);
    } else {
      final Offset transformedOffset = offset.translate(_offset!.dx, _offset!.dy);
      if (child != null) {
        context.paintChild(child!, transformedOffset);
      }
    }
  }
}
