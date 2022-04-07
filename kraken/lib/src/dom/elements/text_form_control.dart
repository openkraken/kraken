/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show TextSelectionOverlay, TextSelectionControls, ClipboardStatusNotifier;
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/widget.dart';

const String VALUE = 'value';
const String DEFAULT_VALUE = 'defaultValue';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
  BACKGROUND_COLOR: '#fff',
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
  final TextFormControlElement _textFormControlElement;
  EditableTextDelegate(this._textFormControlElement);

  TextEditingValue _textEditingValue = TextEditingValue();

  @override
  TextEditingValue get textEditingValue => _textEditingValue;

  @override
  set textEditingValue(TextEditingValue value) {
    // Deprecated, update the lasted value in the userUpdateTextEditingValue.
  }

  @override
  void bringIntoView(TextPosition position) {
    RenderEditable renderEditable = _textFormControlElement.renderEditable!;
    KrakenScrollable _scrollable = _textFormControlElement._scrollable;
    final Rect localRect = renderEditable.getLocalRectForCaret(position);
    final RevealedOffset targetOffset = _textFormControlElement._getOffsetToRevealCaret(localRect);
    _scrollable.position!.jumpTo(targetOffset.offset);
    renderEditable.showOnScreen(rect: targetOffset.rect);
  }

  /// Shows the selection toolbar at the location of the current cursor.
  ///
  /// Returns `false` if a toolbar couldn't be shown, such as when the toolbar
  /// is already shown, or when no text selection currently exists.
  bool showToolbar() {
    TextSelectionOverlay? _selectionOverlay = _textFormControlElement._selectionOverlay;
    // Web is using native dom elements to enable clipboard functionality of the
    // toolbar: copy, paste, select, cut. It might also provide additional
    // functionality depending on the browser (such as translate). Due to this
    // we should not show a Flutter toolbar for the editable text elements.
    if (kIsWeb) {
      return false;
    }

    if (_selectionOverlay == null || _selectionOverlay.toolbarIsVisible) {
      return false;
    }
    _selectionOverlay.showToolbar();
    return true;
  }

  @override
  void hideToolbar([bool hideHandles = true]) {
    TextSelectionOverlay? _selectionOverlay = _textFormControlElement._selectionOverlay;
    if (_selectionOverlay == null) {
      return;
    }

    if (hideHandles) {
      // Hide the handles and the toolbar.
      _selectionOverlay.hide();
    } else {
      if (_selectionOverlay.toolbarIsVisible) {
        // Hide only the toolbar but not the handles.
        _selectionOverlay.hideToolbar();
      }
    }
  }

  /// Toggles the visibility of the toolbar.
  void toggleToolbar() {
    TextSelectionOverlay? _selectionOverlay = _textFormControlElement._selectionOverlay;
    assert(_selectionOverlay != null);
    if (_selectionOverlay!.toolbarIsVisible) {
      hideToolbar();
    } else {
      showToolbar();
    }
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
    _textFormControlElement._formatAndSetValue(value, userInteraction: true, cause: cause);
  }

  @override
  void copySelection(SelectionChangedCause cause) {
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar(false);

      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        // Collapse the selection and hide the toolbar and handles.
          userUpdateTextEditingValue(
            TextEditingValue(
              text: textEditingValue.text,
              selection: TextSelection.collapsed(offset: textEditingValue.selection.end),
            ),
            SelectionChangedCause.toolbar,
          );
          break;
      }
    }
  }

  @override
  void cutSelection(SelectionChangedCause cause) {
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  void selectAll(SelectionChangedCause cause) async {
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
    }
  }
}

class TextFormControlElement extends Element implements TextInputClient, TickerProvider {

  TextFormControlElement(context, {
    this.isMultiline = false,
    this.defaultStyle,
    this.isReplacedElement,
  }) : super(context, defaultStyle: _defaultStyle, isReplacedElement: true) {
    _textSelectionDelegate = EditableTextDelegate(this);
    _textInputType = isMultiline ? TextInputType.multiline : TextInputType.text;
    _scrollable = KrakenScrollable(
      axisDirection: isMultiline ? AxisDirection.down : AxisDirection.right
    );
    scrollOffset = _scrollable.position;
  }

  // The [TextEditableActionTarget] used to apply actions.
  // See also widgets/text_control.dart
  Object? textEditingActionTarget;

  bool isMultiline;
  int? get _maxLines {
    if (isMultiline) {
      return null;
    } else {
      return 1;
    }
  }
  Timer? _cursorTimer;
  bool _targetCursorVisibility = false;
  final ValueNotifier<bool> _cursorVisibilityNotifier = ValueNotifier<bool>(false);
  AnimationController? _cursorBlinkOpacityController;
  int _obscureShowCharTicksPending = 0;

  late KrakenScrollable _scrollable;

  ViewportOffset get scrollOffset => _scrollOffset;
  late ViewportOffset _scrollOffset = ViewportOffset.zero();
  set scrollOffset(ViewportOffset? value) {
    if (value == null) return;
    if (value == _scrollOffset) return;
    _scrollOffset = value;
    _scrollOffset.removeListener(_scrollXListener);
    _scrollOffset.addListener(_scrollXListener);
    renderTextControlLeaderLayer?.markNeedsLayout();
  }

  void _scrollXListener() {
    renderTextControlLeaderLayer?.markNeedsPaint();
  }

  bool obscureText = false;
  bool autoCorrect = true;
  late EditableTextDelegate _textSelectionDelegate;
  TextSpan? _actualText;
  RenderTextControlLeaderLayer? renderTextControlLeaderLayer;

  final LayerLink _toolbarLayerLink = LayerLink();
  RenderEditable? renderEditable;
  TextInputConnection? _textInputConnection;

  // This value is an eyeball estimation of the time it takes for the iOS cursor
  // to ease in and out.
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  String get placeholderText => attributes['placeholder'] ?? '';

  TextSpan get placeholderTextSpan {
    // TODO: support ::placeholder pseudo element
    return _buildTextSpan(
      text: placeholderText,
      // The color of placeholder.
      color: Color.fromARGB(255, 169, 169, 169)
    );
  }

  TextInputConfiguration? _textInputConfiguration;

  Map<String, dynamic>? defaultStyle;

  // Is element an replaced element.
  bool? isReplacedElement = false;

  String _getValue() {
    TextEditingValue value = _textSelectionDelegate._textEditingValue;
    return value.text;
  }

  static String obscuringCharacter = '•';

  int get width => int.tryParse(getAttribute('width') ?? '') ?? 0;
  set width(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('width', value.toString());
  }

  int get height => int.tryParse(getAttribute('height') ?? '') ?? 0;
  set height(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('height', value.toString());
  }

  // Whether value has been changed by user.
  // https://www.w3.org/TR/2010/WD-html5-20101019/the-input-element.html#concept-input-value-dirty-flag
  bool hasDirtyValue = false;

  String get value => _getValue();

  set value(String? text) {
    setValue(text);
    hasDirtyValue = true;
  }

  String _defaultValue = '';
  String get defaultValue => _defaultValue;

  set defaultValue(String? text) {
    text ??= '';
    _defaultValue = text;
    // Only set value when dirty flag is false.
    if (!hasDirtyValue) {
      setValue(text);
    }
  }

  String sanitizeValue(String? text) {
    text ??= '';
    if (text.length > _maxLength) {
      // Slice to max length.
      text = text.substring(0, _maxLength);
    }
    return text;
  }

  String setValue(String? text) {
    String newValue = sanitizeValue(text);
    TextRange composing = _textSelectionDelegate._textEditingValue.composing;
    TextSelection selection = TextSelection.collapsed(offset: newValue.length);
    TextEditingValue newTextEditingValue = TextEditingValue(
      text: newValue,
      selection: selection,
      composing: composing,
    );
    _formatAndSetValue(newTextEditingValue);
    return newValue;
  }

  String get accept => getAttribute('accept') ?? '';
  set accept(String value) {
    internalSetAttribute('accept', value);
  }

  String get autocomplete => getAttribute('autocomplete') ?? '';
  set autocomplete(String value) {
    internalSetAttribute('autocomplete', value);
  }

  bool get autofocus => hasAttribute('autofocus');
  set autofocus(bool value) {
    if (value) {
      internalSetAttribute('autofocus', '');
    } else {
      removeAttribute('autofocus');
    }
  }

  bool get required => hasAttribute('required');
  set required(bool value) {
    if (value) {
      internalSetAttribute('required', '');
    } else {
      removeAttribute('required');
    }
  }

  bool get readOnly => hasAttribute('readonly');
  set readOnly(bool value) {
    if (value) {
      internalSetAttribute('readonly', '');
    } else {
      removeAttribute('readonly');
    }
  }

  String get pattern => getAttribute('pattern') ?? '';
  set pattern(String value) {
    internalSetAttribute('pattern', value);
  }

  String get step => getAttribute('step') ?? '';
  set step(String value) {
    internalSetAttribute('step', value);
  }

  String get name => getAttribute('name') ?? '';
  set name(String value) {
    internalSetAttribute('name', value);
  }

  bool get multiple => hasAttribute('multiple');
  set multiple(bool value) {
    if (value) {
      internalSetAttribute('multiple', '');
    } else {
      removeAttribute('multiple');
    }
  }

  bool get checked => hasAttribute('checked');
  set checked(bool value) {
    if (value) {
      internalSetAttribute('checked', '');
    } else {
      removeAttribute('checked');
    }
  }

  bool get disabled => hasAttribute('disabled');
  set disabled(bool value) {
    if (value) {
      internalSetAttribute('disabled', '');
    } else {
      removeAttribute('disabled');
    }
  }

  String get min => getAttribute('min') ?? '';
  set min(String value) {
    internalSetAttribute('min', value);
  }

  String get max => getAttribute('max') ?? '';
  set max(String value) {
    internalSetAttribute('max', value);
  }

  int get minLength => int.tryParse(getAttribute('minlength') ?? '') ?? -1; // Default to -1.
  set minLength(int value) {
    if (value.isNegative || value == 0) value = -1;
    internalSetAttribute('minlength', value.toString());
  }

  int get maxLength => int.tryParse(getAttribute('maxlength') ?? '') ?? -1; // Default to -1.
  set maxLength(int value) {
    if (value.isNegative || value == 0) value = -1;
    internalSetAttribute('maxlength', value.toString());
  }

  String get placeholder => getAttribute('placeholder') ?? '';
  set placeholder(String value) {
    internalSetAttribute('placeholder', value);
    // Update placeholder text.
    _rebuildTextSpan();
  }

  String get type => getAttribute('type') ?? '';
  set type(String value) {
    internalSetAttribute('type', value);
    _setType(value);
  }

  // Additional inputmode.
  String get inputMode => getAttribute('inputmode') ?? '';
  set inputMode(String value) {
    internalSetAttribute('inputmode', value);
    _setInputMode(value);
  }

  @override
  void focus() {
    if (ownerDocument.focusedElement != this) {
      // Blur current focused element.
      ownerDocument.focusedElement?.blur();
      // Focus kraken widget to get focus from other widgets.
      WidgetDelegate? widgetDelegate = ownerDocument.widgetDelegate;
      widgetDelegate?.requestFocus();
      ownerDocument.focusedElement = this;

      focusTextFormControl();
    }
  }

  @override
  void blur() {
    if (ownerDocument.focusedElement == this) {
      ownerDocument.focusedElement = null;

      blurTextFormControl();
    }
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    addEventListener(EVENT_TOUCH_START, _handleEditable);
    addEventListener(EVENT_TOUCH_MOVE, _handleEditable);
    addEventListener(EVENT_TOUCH_END, _handleEditable);
    addEventListener(EVENT_CLICK, _handleEditable);
    addEventListener(EVENT_DOUBLE_CLICK, _handleEditable);
    addEventListener(EVENT_LONG_PRESS, _handleEditable);

    AnimationController animationController = _cursorBlinkOpacityController = AnimationController(vsync: this, duration: _fadeDuration);
    animationController.addListener(_onCursorColorTick);

    addChild(createRenderBox());

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (autofocus) {
        focus();
      }
    });
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_onStyleChanged);
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();
    blur();
    _cursorTimer?.cancel();
    if (_textInputConnection != null && _textInputConnection!.attached) {
      _textInputConnection!.close();
    }
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();

    removeEventListener(EVENT_TOUCH_START, _handleEditable);
    removeEventListener(EVENT_TOUCH_MOVE, _handleEditable);
    removeEventListener(EVENT_TOUCH_END, _handleEditable);
    removeEventListener(EVENT_CLICK, _handleEditable);
    removeEventListener(EVENT_DOUBLE_CLICK, _handleEditable);
    removeEventListener(EVENT_LONG_PRESS, _handleEditable);

    _cursorBlinkOpacityController!.removeListener(_onCursorColorTick);
    _cursorBlinkOpacityController = null;
    renderEditable = null;
  }

  void _onStyleChanged(String property, String? original, String present) {
    // Need to rebuild text span when text related style changed.
    if (property == COLOR
      || property == FONT_WEIGHT
      || property == FONT_STYLE
      || property == FONT_FAMILY
      || property == FONT_SIZE
      || property == LINE_HEIGHT
      || property == LETTER_SPACING
      || property == WORD_SPACING
      || property == WHITE_SPACE
      || property == TEXT_DECORATION_LINE
      || property == TEXT_DECORATION_COLOR
      || property == TEXT_DECORATION_STYLE
      || property == TEXT_SHADOW
    ) {
      _rebuildTextSpan();
    }

    if (property == TEXT_ALIGN && renderEditable != null) {
      renderEditable!.textAlign = renderStyle.textAlign;
    }
  }

  void _rebuildTextSpan() {
    // Rebuilt text span, for style has changed.
    _actualText = _buildTextSpan(text: _actualText?.text);
    TextEditingValue value = TextEditingValue(text: _actualText!.text!);
    _textSelectionDelegate.userUpdateTextEditingValue(value, SelectionChangedCause.keyboard);
    TextSpan? text = obscureText ? _buildPasswordTextSpan(_actualText!.text!) : _actualText;
    if (renderEditable != null) {
      renderEditable!.text = _actualText!.text!.isEmpty
          ? placeholderTextSpan
          : text;
    }
  }

  TextSpan _buildTextSpan({ String? text, Color? color }) {
    return CSSTextMixin.createTextSpan(text ?? '', renderStyle,
      color: color,
      // For multiline editing, lineHeight works for inner text in the element,
      // so it needs to set line-height of textSpan for RenderEditable to use.
      height: isMultiline && renderStyle.lineHeight != CSSLengthValue.normal
      ? renderStyle.lineHeight.computedValue / renderStyle.fontSize.computedValue
      : null
    );
  }

  TextSpan _buildPasswordTextSpan(String text) {
    return CSSTextMixin.createTextSpan(obscuringCharacter * text.length, renderStyle);
  }

  Color cursorColor = CSSColor.initial;

  Color selectionColor = CSSColor.initial.withOpacity(0.4);

  Radius cursorRadius = const Radius.circular(2.0);

  Offset? _selectStartPosition;

  // Get the text size of text control form element by manually layout
  // cause RenderEditable does not expose textPainter.
  Size getTextSize() {
    TextPainter textPainter = TextPainter(
      text: renderEditable!.text,
      maxLines: _maxLines,
      textDirection: TextDirection.ltr
    );

    double maxWidth = isMultiline
      ? renderEditable!.size.width
      : double.infinity;

    textPainter.layout(maxWidth: maxWidth);

    return textPainter.size;
  }

  Size get avgCharSize {
    TextStyle textStyle = TextStyle(
      fontFamilyFallback: renderStyle.fontFamily,
      fontSize: renderStyle.fontSize.computedValue,
      textBaseline: CSSText.getTextBaseLine(),
      package: CSSText.getFontPackage(),
      locale: CSSText.getLocale(),
    );
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: '0',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr
    );
    painter.layout();

    List<LineMetrics> lineMetrics = painter.computeLineMetrics();

    return Size(lineMetrics[0].width, lineMetrics[0].height);
  }

  // The average width of characters in a font family.
  // Flutter does not expose avgCharWidth of font metrics, so it fallbacks to
  // so use width of '0' as WebKit did.
  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/rendering/RenderTextControl.cpp#L142
  double get avgCharWidth {
    return avgCharSize.width;
  }

  double get avgCharHeight {
    return avgCharSize.height;
  }

  Size? _textSize;

  void _handleEditable(Event event) {
    if (event.type == EVENT_TOUCH_START) {
      _hideSelectionOverlayIfNeeded();
      _textSelectionDelegate.hideToolbar(false);

      TouchList touches = (event as TouchEvent).touches;
      if (touches.length > 1) return;

      Touch touch = touches.item(0);
      _selectStartPosition = Offset(touch.screenX, touch.screenY);

      TouchEvent e = event;
      if (e.touches.length == 1) {
        Touch touch = e.touches[0];
        final TapDownDetails details = TapDownDetails(
          globalPosition: Offset(touch.screenX, touch.screenY),
          localPosition: Offset(touch.clientX, touch.clientY),
          kind: PointerDeviceKind.touch,
        );
        renderEditable!.handleTapDown(details);
        renderEditable!.selectPositionAt(
          from: _selectStartPosition!,
          cause: SelectionChangedCause.drag,
        );
        focus();
      }
      // Cache text size on touch start to be used in touch move and touch end.
      _textSize = getTextSize();
    } else if (event.type == EVENT_TOUCH_MOVE ||
      event.type == EVENT_TOUCH_END
    ) {
      TouchList touches = (event as TouchEvent).touches;
      if (touches.length > 1) return;

      Touch touch = touches.item(0);
      Offset _selectEndPosition = Offset(touch.screenX, touch.screenY);

      // Disable text selection and enable scrolling when text size is larger than
      // text form control element size.
      if ((!isMultiline && (_textSize!.width > renderEditable!.size.width))
       || (isMultiline && (_textSize!.height > renderEditable!.size.height))) {
        return;
      }

      bool isToolbarVisible = _selectionOverlay != null && _selectionOverlay!.toolbarIsVisible;
      // Only enable text selection when toolbar is visible.
      if (event.type == EVENT_TOUCH_MOVE && _selectStartPosition != _selectEndPosition && isToolbarVisible) {
        renderEditable!.selectPositionAt(
          from: _selectStartPosition!,
          to: _selectEndPosition,
          cause: SelectionChangedCause.drag,
        );
      }
    } else if (event.type == EVENT_CLICK) {
      renderEditable!.handleTap();
    } else if (event.type == EVENT_LONG_PRESS) {
      renderEditable!.handleLongPress();
      _textSelectionDelegate.showToolbar();
    } else if (event.type == EVENT_DOUBLE_CLICK) {
      renderEditable!.handleDoubleTap();
      _textSelectionDelegate.showToolbar();
    }
  }

  void focusTextFormControl() {
    if (isRendererAttached) {
      // Set focus that make it add keyboard listener
      renderEditable!.hasFocus = true;
      activeTextInput();
      dispatchEvent(Event(EVENT_FOCUS));
    }
  }

  void blurTextFormControl() {
    if (isRendererAttached) {
      // Set focus that make it remove keyboard listener
      renderEditable!.hasFocus = false;
      deactiveTextInput();
      dispatchEvent(Event(EVENT_BLUR));
      // Trigger change event if value has changed.
      _triggerChangeEvent();
    }
  }

  // Store the state at the begin of user input.
  String? _inputValueAtBegin;

  TextInputAction _textInputAction = TextInputAction.done;

  void activeTextInput() {
    _inputValueAtBegin = value;

    _textInputConfiguration ??= TextInputConfiguration(
      inputType: _textInputType,
      obscureText: obscureText,
      autocorrect: autoCorrect,
      inputAction: _textInputType == TextInputType.multiline
        ? TextInputAction.newline
        : _textInputAction,
      textCapitalization: TextCapitalization.none,
      keyboardAppearance: Brightness.light,
    );

    if (_textInputConnection == null || !_textInputConnection!.attached) {
      final TextEditingValue localValue = _value;
      _lastKnownRemoteTextEditingValue = localValue;

      _textInputConnection = TextInput.attach(this, _textInputConfiguration!);
      _textInputConnection!.setEditingState(localValue);
    }

    // FIXME: hide virtual keyword will make real keyboard could not input also
    if (!_hideVirtualKeyboard) {
      _textInputConnection!.show();
    }
    _startCursorTimer();
  }

  void deactiveTextInput() {
    // Clear range select when text input is not active.
    updateEditingValue(_value.copyWith(selection: TextSelection(baseOffset: 0, extentOffset: 0)));

    // Hide input handles and toolbar.
    _textSelectionDelegate.hideToolbar();

    _cursorVisibilityNotifier.value = false;
    if (_textInputConnection != null && _textInputConnection!.attached) {
      _textInputConnection!.close();
    }
    _stopCursorTimer();
  }

  bool get _hasFocus => ownerDocument.focusedElement == this;
  int get _maxLength {
    if (maxLength > 0) return maxLength;
    // The Number.MAX_SAFE_INTEGER constant represents the maximum safe integer in JavaScript (2^53 - 1).
    return 9007199254740992;
  }

  RenderEditable createRenderEditable() {
    _actualText ??= _buildTextSpan();
    TextSpan text = _actualText!;
    if (_actualText!.toPlainText().isEmpty) {
      text = placeholderTextSpan;
    } else if (obscureText) {
      text = _buildPasswordTextSpan(text.text!);
    }

    WidgetDelegate? widgetDelegate = ownerDocument.widgetDelegate;
    if (widgetDelegate != null) {
      cursorColor = widgetDelegate.getCursorColor();
      selectionColor = widgetDelegate.getSelectionColor();
      cursorRadius = widgetDelegate.getCursorRadius();
      _selectionControls = widgetDelegate.getTextSelectionControls();
    }

    renderEditable = RenderEditable(
      text: text,
      cursorColor: cursorColor,
      showCursor: _cursorVisibilityNotifier,
      maxLines: _maxLines,
      minLines: 1,
      expands: false,
      textScaleFactor: 1.0,
      textAlign: renderStyle.textAlign,
      textDirection: TextDirection.ltr,
      selection: blurSelection, // Default to blur
      selectionColor: selectionColor,
      offset: scrollOffset,
      readOnly: false,
      forceLine: true,
      onCaretChanged: _handleCaretChanged,
      obscureText: obscureText,
      cursorWidth: 2.0,
      cursorRadius: cursorRadius,
      cursorOffset: Offset.zero,
      enableInteractiveSelection: true,
      textSelectionDelegate: _textSelectionDelegate,
      devicePixelRatio: window.devicePixelRatio,
      startHandleLayerLink: _startHandleLayerLink,
      endHandleLayerLink: _endHandleLayerLink,
      ignorePointer: true,
    );
    return renderEditable!;
  }

  RenderTextControlLeaderLayer createRenderBox() {
    RenderEditable renderEditable = createRenderEditable();

    renderTextControlLeaderLayer = RenderTextControlLeaderLayer(
      link: _toolbarLayerLink,
      child: renderEditable,
      scrollable: _scrollable,
      isMultiline: isMultiline,
    );
    return renderTextControlLeaderLayer!;
  }

  @override
  void performAction(TextInputAction action) {
    switch (action) {
      case TextInputAction.newline:
        // If this is a multiline EditableText, do nothing for a "newline"
        // action; The newline is already inserted. Otherwise, finalize
        // editing.
        if (!isMultiline)
          blur();
        break;
      case TextInputAction.done:
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
    }
  }

  void _hideSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      _selectionOverlay!.hideHandles();
    }
  }

  bool get _hasInputConnection => _textInputConnection != null && _textInputConnection!.attached;
  TextEditingValue? _lastKnownRemoteTextEditingValue;

  void _updateRemoteEditingValueIfNeeded() {
    if (_batchEditDepth > 0 || !_hasInputConnection)
      return;
    final TextEditingValue localValue = _value;
    if (localValue == _lastKnownRemoteTextEditingValue)
      return;
    _textInputConnection!.setEditingState(localValue);
    _lastKnownRemoteTextEditingValue = localValue;
  }

  TextEditingValue get _value => _textSelectionDelegate._textEditingValue;
  set _value(TextEditingValue value) {
    _textSelectionDelegate._textEditingValue = value;
  }


  int _batchEditDepth = 0;
  /// Begins a new batch edit, within which new updates made to the text editing
  /// value will not be sent to the platform text input plugin.
  ///
  /// Batch edits nest. When the outermost batch edit finishes, [endBatchEdit]
  /// will attempt to send [currentTextEditingValue] to the text input plugin if
  /// it detected a change.
  void beginBatchEdit() {
    _batchEditDepth += 1;
  }

  /// Ends the current batch edit started by the last call to [beginBatchEdit],
  /// and send [currentTextEditingValue] to the text input plugin if needed.
  ///
  /// Throws an error in debug mode if this [EditableText] is not in a batch
  /// edit.
  void endBatchEdit() {
    _batchEditDepth -= 1;
    assert(
    _batchEditDepth >= 0,
    'Unbalanced call to endBatchEdit: beginBatchEdit must be called first.',
    );
    _updateRemoteEditingValueIfNeeded();
  }

  void _formatAndSetValue(TextEditingValue value, {
    bool userInteraction = false,
    SelectionChangedCause? cause,
  }) {
    if (userInteraction && value.text.length > _maxLength) return;

    final bool textChanged = _value.text != value.text
        || (!_value.composing.isCollapsed && value.composing.isCollapsed);
    final bool selectionChanged = _value.selection != value.selection;


    // Put all optional user callback invocations in a batch edit to prevent
    // sending multiple `TextInput.updateEditingValue` messages.
    beginBatchEdit();
    _value = value;

    // Changes made by the keyboard can sometimes be "out of band" for listening
    // components, so always send those events, even if we didn't think it
    // changed. Also, the user long pressing should always send a selection change
    // as well.
    if (selectionChanged ||
      (userInteraction &&
      (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.keyboard))) {
      _handleSelectionChanged(value.selection, cause);
    }

    if (textChanged) {
      _handleTextChanged(value.text, userInteraction, cause);
    }

    if (renderEditable != null) {
      renderEditable!.selection = value.selection;
    }

    endBatchEdit();
  }

  void _handleTextChanged(String text, bool userInteraction, SelectionChangedCause? cause) {
    if (renderEditable != null) {
      if (text.isEmpty) {
        renderEditable!.text = placeholderTextSpan;
      } else if (obscureText) {
        renderEditable!.text = _buildPasswordTextSpan(text);
      } else {
        _actualText = renderEditable!.text = _buildTextSpan(text: text);
      }
    } else {
      // Update text when element is not appended to dom yet.
      _actualText = _buildTextSpan(text: text);
    }

    if (userInteraction) {
      // TODO: return the string containing the input data that was added to the element,
      // which MAY be null if it doesn't apply.
      String inputData = '';
      // https://www.w3.org/TR/input-events-1/#interface-InputEvent-Attributes
      String inputType = '';
      InputEvent inputEvent = InputEvent(inputData, inputType: inputType);
      dispatchEvent(inputEvent);
      hasDirtyValue = true;
    }
  }

  TextSelectionOverlay? _selectionOverlay;

  TextSelectionControls? _selectionControls;

  bool _showSelectionHandles = false;

  final ClipboardStatusNotifier? _clipboardStatus = kIsWeb ? null : ClipboardStatusNotifier();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    // Show keyboard for selection change or user gestures.
    requestKeyboard();

    if (renderEditable == null) {
      return;
    }

    WidgetDelegate? widgetDelegate = ownerDocument.widgetDelegate;

    if (_selectionControls == null) {
      _selectionOverlay?.dispose();
      _selectionOverlay = null;
    } else if (widgetDelegate != null) {
      if (_selectionOverlay == null) {
        _selectionOverlay = TextSelectionOverlay(
          clipboardStatus: _clipboardStatus,
          context: widgetDelegate.getContext(),
          value: _value,
          toolbarLayerLink: _toolbarLayerLink,
          startHandleLayerLink: _startHandleLayerLink,
          endHandleLayerLink: _endHandleLayerLink,
          renderObject: renderEditable!,
          selectionControls: _selectionControls,
          selectionDelegate: _textSelectionDelegate,
          dragStartBehavior: DragStartBehavior.start,
          onSelectionHandleTapped: _handleSelectionHandleTapped,
        );
      } else {
        _selectionOverlay!.update(_value);
      }
      _onSelectionChanged(selection, cause);
      _selectionOverlay!.handlesVisible = _showSelectionHandles;
      _selectionOverlay!.showHandles();
    }

    // To keep the cursor from blinking while it moves, restart the timer here.
    if (_cursorTimer != null) {
      _stopCursorTimer(resetCharTicks: false);
      _startCursorTimer();
    }
  }

  void _onSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      _showSelectionHandles = willShowSelectionHandles;
    }

    WidgetDelegate? widgetDelegate = ownerDocument.widgetDelegate;
    if (widgetDelegate != null) {
      TargetPlatform platform = widgetDelegate.getTargetPlatform();
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          if (cause == SelectionChangedCause.longPress) {
            _textSelectionDelegate.bringIntoView(selection.base);
          }
          return;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        // Do nothing.
      }
    }

  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.keyboard)
      return false;

    if (cause == SelectionChangedCause.longPress || cause == SelectionChangedCause.drag)
      return true;

    if (_value.text.isNotEmpty)
      return true;

    return false;
  }

  /// Toggle the toolbar when a selection handle is tapped.
  void _handleSelectionHandleTapped() {
    if (_value.selection.isCollapsed) {
      _textSelectionDelegate.toggleToolbar();
    }
  }

  void requestKeyboard() {
    if (_hasFocus) {
      _textInputConnection!.show();
    }
  }

  @override
  void updateEditingValue(TextEditingValue value) {
     _lastKnownRemoteTextEditingValue = value;

    if (value == _value) {
      // This is possible, for example, when the numeric keyboard is input,
      // the engine will notify twice for the same value.
      // Track at https://github.com/flutter/flutter/issues/65811
      return;
    }

    if (value.text == _value.text && value.composing == _value.composing) {
      // `selection` is the only change.
      _handleSelectionChanged(value.selection, SelectionChangedCause.keyboard);
    } else {
      _showCaretOnScreen();
      _textSelectionDelegate.hideToolbar();
    }
    _formatAndSetValue(value, userInteraction: true, cause: SelectionChangedCause.keyboard);

    if (_hasInputConnection) {
      // To keep the cursor from blinking while typing, we want to restart the
      // cursor timer every time a new character is typed.
      _stopCursorTimer(resetCharTicks: false);
      _startCursorTimer();
    }
  }

  void _triggerChangeEvent() {
    String currentValue = _textSelectionDelegate._textEditingValue.text;
    if (_inputValueAtBegin != currentValue) {
      Event changeEvent = Event(EVENT_CHANGE);
      dispatchEvent(changeEvent);
    }
  }

  TextInputType _textInputType = TextInputType.text;

  TextInputType get textInputType => _textInputType;
  set textInputType(TextInputType value) {
    if (value != _textInputType) {
      _textInputType = value;
      if (_textInputConnection != null && _textInputConnection!.attached) {
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
        textInputType = TextInputType.numberWithOptions(signed: true);
        break;
      case 'tel':
        textInputType = TextInputType.phone;
        break;
      case 'email':
        textInputType = TextInputType.emailAddress;
        break;
      case 'password':
        textInputType = TextInputType.text;
        _enablePassword();
        break;
      // @TODO: more types.
    }
  }

  bool _hideVirtualKeyboard = false;
  void _setInputMode(String value) {
    switch (value) {
      case 'none':
        _hideVirtualKeyboard = true;
        // HACK: Set a diff value trigger update
        textInputType = TextInputType.name;
        break;
      case 'text':
        textInputType = TextInputType.text;
        break;
      case 'numeric':
        textInputType = TextInputType.numberWithOptions();
        break;
      case 'decimal':
        textInputType = TextInputType.numberWithOptions(decimal: true);
        break;
      case 'tel':
        textInputType = TextInputType.phone;
        break;
      case 'url':
        textInputType = TextInputType.url;
        break;
      case 'email':
        textInputType = TextInputType.emailAddress;
        break;
      case 'search':
        _textInputAction = TextInputAction.search;
        textInputType = TextInputType.text;
        break;
    }
  }

  void _enablePassword() {
    obscureText = true;
    if (renderEditable != null) {
      renderEditable!.obscureText = obscureText;
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
      if (currentCaretRect == null || renderEditable == null) {
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

      scrollToCaret();

      renderEditable!.showOnScreen(
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

  // Make input box scroll to the offset that the caret shown.
  void scrollToCaret() {
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      final RevealedOffset targetOffset = _getOffsetToRevealCaret(_currentCaretRect!);
      _scrollable.position!.animateTo(targetOffset.offset, duration: _caretAnimationDuration, curve: _caretAnimationCurve);
    });
  }

  // Finds the closest scroll offset to the current scroll offset that fully
  // reveals the given caret rect. If the given rect's main axis extent is too
  // large to be fully revealed in `renderEditable`, it will be centered along
  // the main axis.
  //
  // If this is a multiline EditableText (which means the Editable can only
  // scroll vertically), the given rect's height will first be extended to match
  // `renderEditable.preferredLineHeight`, before the target scroll offset is
  // calculated.
  RevealedOffset _getOffsetToRevealCaret(Rect rect) {
    final Size editableSize = renderEditable!.size;
    final double additionalOffset;
    final Offset unitOffset;

    if (!isMultiline) {
      additionalOffset = rect.width >= editableSize.width
      // Center `rect` if it's oversized.
        ? editableSize.width / 2 - rect.center.dx
      // Valid additional offsets range from (rect.right - size.width)
      // to (rect.left). Pick the closest one if out of range.
        : 0.0.clamp(rect.right - editableSize.width, rect.left);
      unitOffset = const Offset(1, 0);
    } else {
      // The caret is vertically centered within the line. Expand the caret's
      // height so that it spans the line because we're going to ensure that the
      // entire expanded caret is scrolled into view.
      final Rect expandedRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width,
        height: math.max(rect.height, renderEditable!.preferredLineHeight),
      );

      additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : 0.0.clamp(expandedRect.bottom - editableSize.height, expandedRect.top);
      unitOffset = const Offset(0, 1);
    }

    // No over scrolling when encountering tall fonts/scripts that extend past
    // the ascent.
    final double targetOffset = (additionalOffset + _scrollable.position!.pixels)
      .clamp(
      _scrollable.position!.minScrollExtent,
      _scrollable.position!.maxScrollExtent,
    );

    final double offsetDelta = _scrollable.position!.pixels - targetOffset;
    return RevealedOffset(rect: rect.shift(unitOffset * offsetDelta), offset: targetOffset);
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

    _cursorTimer ??= Timer.periodic(_kCursorBlinkWaitForStart, _cursorWaitForStart);
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
    Rect _startCaretRect = renderEditable!.getLocalRectForCaret(currentTextPosition);
    renderEditable!.setFloatingCursor(point.state, _startCaretRect.center, currentTextPosition);
  }

  void _onCursorColorTick() {
    renderEditable!.cursorColor = cursorColor.withOpacity(_cursorBlinkOpacityController!.value);
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
    if (_hasInputConnection) {
      _textInputConnection!.connectionClosedReceived();
      _textInputConnection = null;
      _lastKnownRemoteTextEditingValue = null;
    }
  }

  // Abstract class method added after flutter@1.15
  @override
  TextEditingValue get currentTextEditingValue => _textSelectionDelegate._textEditingValue;

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

  @override
  void dispose() {
    textEditingActionTarget = null;
    super.dispose();
  }
}

