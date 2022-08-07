/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';

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
typedef OnControllerCreated = void Function(WebFController controller);

/// Delegate methods of widget
class WidgetDelegate {
  final GetContext getContext;
  final RequestFocus requestFocus;
  final GetTargetPlatform getTargetPlatform;
  final GetCursorColor getCursorColor;
  final GetSelectionColor getSelectionColor;
  final GetCursorRadius getCursorRadius;
  final GetTextSelectionControls getTextSelectionControls;

  const WidgetDelegate(
    this.getContext,
    this.requestFocus,
    this.getTargetPlatform,
    this.getCursorColor,
    this.getSelectionColor,
    this.getCursorRadius,
    this.getTextSelectionControls,
  );
}

// Widget involves actions of text control elements(input, textarea).
class WebFTextControl extends StatefulWidget {
  WebFTextControl(this.parentContext);

  final BuildContext parentContext;

  @override
  _WebFTextControlState createState() => _WebFTextControlState();
}

class _WebFTextControlState extends State<WebFTextControl> with _FindElementFromContextMixin {
  @override
  void initState() {
    super.initState();
    _initActionMap();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: FocusableActionDetector(
            actions: _actionMap,
            focusNode: _focusNode,
            onFocusChange: _handleFocusChange,
            child: WebFRenderObjectWidget(
              widget.parentContext.widget as WebF,
              widgetDelegate,
            )));
  }

  final FocusNode _focusNode = FocusNode();

  Map<Type, Action<Intent>>? _actionMap;

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

  FocusableActionDetector createTextControlDetector(WebFRenderObjectWidget child) {
    return FocusableActionDetector(
        actions: _actionMap, focusNode: _focusNode, onFocusChange: _handleFocusChange, child: child);
  }

  void _initActionMap() {
    _actionMap = <Type, Action<Intent>>{
      // Action of focus.
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handlePreviousFocus),

      DoNothingAndStopPropagationTextIntent: DoNothingAction(consumesKey: false),
      ReplaceTextIntent: _replaceTextAction,
      UpdateSelectionIntent: _updateSelectionAction,
      DirectionalFocusIntent: DirectionalFocusAction.forTextField(),

      // Delete
      DeleteCharacterIntent:
          _makeOverridable(_DeleteTextAction<DeleteCharacterIntent>(context, TextBoundaryType.characterBoundary)),
      DeleteToNextWordBoundaryIntent: _makeOverridable(
          _DeleteTextAction<DeleteToNextWordBoundaryIntent>(context, TextBoundaryType.nextWordBoundary)),
      DeleteToLineBreakIntent:
          _makeOverridable(_DeleteTextAction<DeleteToLineBreakIntent>(context, TextBoundaryType.lineBreak)),

      // Extend/Move Selection
      ExtendSelectionByCharacterIntent: _makeOverridable(_UpdateTextSelectionAction<ExtendSelectionByCharacterIntent>(
          context, TextBoundaryType.characterBoundary, false)),
      ExtendSelectionToNextWordBoundaryIntent: _makeOverridable(
          _UpdateTextSelectionAction<ExtendSelectionToNextWordBoundaryIntent>(
              context, TextBoundaryType.nextWordBoundary, true)),
      ExtendSelectionToLineBreakIntent: _makeOverridable(
          _UpdateTextSelectionAction<ExtendSelectionToLineBreakIntent>(context, TextBoundaryType.lineBreak, true)),
      ExtendSelectionVerticallyToAdjacentLineIntent: _makeOverridable(_adjacentLineAction),
      ExtendSelectionToDocumentBoundaryIntent: _makeOverridable(
          _UpdateTextSelectionAction<ExtendSelectionToDocumentBoundaryIntent>(
              context, TextBoundaryType.documentBoundary, true)),
      ExtendSelectionToNextWordBoundaryOrCaretLocationIntent:
          _makeOverridable(_ExtendSelectionOrCaretPositionAction(context, TextBoundaryType.nextWordBoundary)),

      // Copy Paste
      SelectAllTextIntent: _makeOverridable(_SelectAllAction(context)),
      CopySelectionTextIntent: _makeOverridable(_CopySelectionAction(context)),
      PasteTextIntent: _makeOverridable(_PasteAction(context)),
    };
  }

  Action<T> _makeOverridable<T extends Intent>(Action<T> defaultAction) {
    return Action<T>.overridable(context: context, defaultAction: defaultAction);
  }

  void _replaceText(ReplaceTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement != null) {
      focusedElement.textSelectionDelegate.userUpdateTextEditingValue(
        intent.currentTextEditingValue.replaced(intent.replacementRange, intent.replacementText),
        intent.cause,
      );
    }
  }

  late final Action<ReplaceTextIntent> _replaceTextAction = CallbackAction<ReplaceTextIntent>(onInvoke: _replaceText);

  void _updateSelection(UpdateSelectionIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement != null) {
      focusedElement.textSelectionDelegate.userUpdateTextEditingValue(
        intent.currentTextEditingValue.copyWith(selection: intent.newSelection),
        intent.cause,
      );
    }
  }

  late final Action<UpdateSelectionIntent> _updateSelectionAction =
      CallbackAction<UpdateSelectionIntent>(onInvoke: _updateSelection);

  late final _UpdateTextSelectionToAdjacentLineAction<ExtendSelectionVerticallyToAdjacentLineIntent>
      _adjacentLineAction =
      _UpdateTextSelectionToAdjacentLineAction<ExtendSelectionVerticallyToAdjacentLineIntent>(context);

  // Handle focus action usually by pressing the [Tab] hotkey.
  void _handleNextFocus(NextFocusIntent intent) {
    dom.Element rootElement = _findRootElement(context);
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(context, focusableElements);
      // None focusable element is focused, focus the first focusable element.
      if (focusedElement == null) {
        _focusNode.requestFocus();
        (focusableElements[0] as dom.TextFormControlElement).focus();

        // Some focusable element is focused, focus the next element, if it is the last focusable element,
        // then focus the next widget.
      } else {
        int idx = focusableElements.indexOf(focusedElement);
        if (idx == focusableElements.length - 1) {
          _focusNode.nextFocus();
          (focusableElements[focusableElements.length - 1] as dom.TextFormControlElement).blur();
        } else {
          _focusNode.requestFocus();
          (focusableElements[idx] as dom.TextFormControlElement).blur();
          (focusableElements[idx + 1] as dom.TextFormControlElement).focus();
        }
      }

      // None focusable element exists, focus the next widget.
    } else {
      _focusNode.nextFocus();
    }
  }

  // Handle focus action usually by pressing the [Shift]+[Tab] hotkey in the reverse direction.
  void _handlePreviousFocus(PreviousFocusIntent intent) {
    dom.Element rootElement = _findRootElement(context);
    List<dom.TextFormControlElement> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.TextFormControlElement? focusedElement = _findFocusedElement(context, focusableElements);
      // None editable is focused, focus the last editable.
      if (focusedElement == null) {
        _focusNode.requestFocus();
        (focusableElements[focusableElements.length - 1]).focus();

        // Some editable is focused, focus the previous editable, if it is the first editable,
        // then focus the previous widget.
      } else {
        int idx = focusableElements.indexOf(focusedElement);
        if (idx == 0) {
          _focusNode.previousFocus();
          (focusableElements[0]).blur();
        } else {
          _focusNode.requestFocus();
          (focusableElements[idx]).blur();
          (focusableElements[idx - 1]).focus();
        }
      }
      // None editable exists, focus the previous widget.
    } else {
      _focusNode.previousFocus();
    }
  }

  // Handle focus change of _focusNode.
  void _handleFocusChange(bool focused) {
    dom.Element rootElement = _findRootElement(context);
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(context, focusableElements);
      // Currently only input element is focusable.
      if (focused) {
        if (rootElement.ownerDocument.focusedElement == null) {
          (focusableElements[0] as dom.TextFormControlElement).focus();
        }
      } else {
        if (focusedElement != null) {
          (focusedElement as dom.TextFormControlElement).blur();
        }
      }
    }
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
}

enum TextBoundaryType {
  characterBoundary,
  nextWordBoundary,
  lineBreak,
  documentBoundary,
}

mixin _FindElementFromContextMixin {
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
  dom.Element _findRootElement(BuildContext context) {
    RenderObject? _rootRenderObject = context.findRenderObject();
    RenderViewportBox? renderViewportBox = _findRenderViewportBox(_rootRenderObject!);
    WebFController controller = (renderViewportBox as RenderObjectWithControllerMixin).controller!;
    dom.Element documentElement = controller.view.document.documentElement!;
    return documentElement;
  }

  // Find all the focusable elements in the element tree.
  List<dom.TextFormControlElement> _findFocusableElements(dom.Element element) {
    List<dom.TextFormControlElement> result = [];
    traverseElement(element, (dom.Element child) {
      // Currently only input element is focusable.
      if (child is dom.TextFormControlElement) {
        result.add(child);
      }
    });
    return result;
  }

  // Find the focused element in the element tree.
  dom.TextFormControlElement? _findFocusedElement(BuildContext context, [List<dom.Element>? focusableElements]) {
    dom.TextFormControlElement? result;
    if (focusableElements == null) {
      dom.Element rootElement = _findRootElement(context);
      focusableElements = _findFocusableElements(rootElement);
    }

    if (focusableElements.isNotEmpty) {
      // Currently only TextFormControlElement is focusable.
      for (dom.Element element in focusableElements) {
        RenderEditable? renderEditable = (element as dom.TextFormControlElement).renderEditable;
        if (renderEditable != null && renderEditable.hasFocus) {
          result = element;
          break;
        }
      }
    }
    return result;
  }
}

// -------------------------------  Text Actions -------------------------------
class _DeleteTextAction<T extends DirectionalTextEditingIntent> extends ContextAction<T>
    with _FindElementFromContextMixin {
  _DeleteTextAction(this.context, this.textBoundaryType);

  BuildContext context;
  TextBoundaryType textBoundaryType;
  dom.EditableTextDelegate? delegate;

  TextRange _expandNonCollapsedRange(TextEditingValue value, bool obscureText) {
    final TextRange selection = value.selection;
    assert(selection.isValid);
    assert(!selection.isCollapsed);
    final dom.TextBoundary atomicBoundary = obscureText ? dom.CodeUnitBoundary(value) : dom.CharacterBoundary(value);

    return TextRange(
      start: atomicBoundary.getLeadingTextBoundaryAt(TextPosition(offset: selection.start)).offset,
      end: atomicBoundary.getTrailingTextBoundaryAt(TextPosition(offset: selection.end - 1)).offset,
    );
  }

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    dom.TextBoundary Function(T intent) getTextBoundariesForIntent;

    switch (textBoundaryType) {
      case TextBoundaryType.characterBoundary:
        getTextBoundariesForIntent = _delegate.characterBoundary;
        break;
      case TextBoundaryType.nextWordBoundary:
        getTextBoundariesForIntent = _delegate.nextWordBoundary;
        break;
      case TextBoundaryType.lineBreak:
        getTextBoundariesForIntent = _delegate.linebreak;
        break;
      case TextBoundaryType.documentBoundary:
        getTextBoundariesForIntent = _delegate.documentBoundary;
        break;
    }

    final TextSelection selection = _delegate.value.selection;
    assert(selection.isValid);

    if (!selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(_delegate.value, '', _expandNonCollapsedRange(_delegate.value, _delegate.element.obscureText),
            SelectionChangedCause.keyboard),
      );
    }

    final dom.TextBoundary textBoundary = getTextBoundariesForIntent(intent);
    if (!textBoundary.textEditingValue.selection.isValid) {
      return null;
    }
    if (!textBoundary.textEditingValue.selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(
            _delegate.value,
            '',
            _expandNonCollapsedRange(textBoundary.textEditingValue, _delegate.element.obscureText),
            SelectionChangedCause.keyboard),
      );
    }

    return Actions.invoke(
      context!,
      ReplaceTextIntent(
        textBoundary.textEditingValue,
        '',
        textBoundary.getTextBoundaryAt(textBoundary.textEditingValue.selection.base),
        SelectionChangedCause.keyboard,
      ),
    );
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    dom.EditableTextDelegate _delegate = delegate!;
    return !_delegate.element.readOnly && _delegate.value.selection.isValid;
  }
}

class _UpdateTextSelectionAction<T extends DirectionalCaretMovementIntent> extends ContextAction<T>
    with _FindElementFromContextMixin {
  _UpdateTextSelectionAction(this.context, this.textBoundaryType, this.ignoreNonCollapsedSelection);

  BuildContext context;
  TextBoundaryType textBoundaryType;
  dom.EditableTextDelegate? delegate;
  final bool ignoreNonCollapsedSelection;

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    dom.TextBoundary Function(T intent) getTextBoundariesForIntent;

    switch (textBoundaryType) {
      case TextBoundaryType.characterBoundary:
        getTextBoundariesForIntent = _delegate.characterBoundary;
        break;
      case TextBoundaryType.nextWordBoundary:
        getTextBoundariesForIntent = _delegate.nextWordBoundary;
        break;
      case TextBoundaryType.lineBreak:
        getTextBoundariesForIntent = _delegate.linebreak;
        break;
      case TextBoundaryType.documentBoundary:
        getTextBoundariesForIntent = _delegate.documentBoundary;
        break;
    }

    final TextSelection selection = _delegate.value.selection;
    assert(selection.isValid);

    final bool collapseSelection = intent.collapseSelection;
    // Collapse to the logical start/end.
    TextSelection _collapse(TextSelection selection) {
      assert(selection.isValid);
      assert(!selection.isCollapsed);
      return selection.copyWith(
        baseOffset: intent.forward ? selection.end : selection.start,
        extentOffset: intent.forward ? selection.end : selection.start,
      );
    }

    if (!selection.isCollapsed && !ignoreNonCollapsedSelection && collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(_delegate.value, _collapse(selection), SelectionChangedCause.keyboard),
      );
    }

    final dom.TextBoundary textBoundary = getTextBoundariesForIntent(intent);
    final TextSelection textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }
    if (!textBoundarySelection.isCollapsed && !ignoreNonCollapsedSelection && collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(_delegate.value, _collapse(textBoundarySelection), SelectionChangedCause.keyboard),
      );
    }

    final TextPosition extent = textBoundarySelection.extent;
    final TextPosition newExtent =
        intent.forward ? textBoundary.getTrailingTextBoundaryAt(extent) : textBoundary.getLeadingTextBoundaryAt(extent);

    final TextSelection newSelection =
        collapseSelection ? TextSelection.fromPosition(newExtent) : textBoundarySelection.extendTo(newExtent);

    // If collapseAtReversal is true and would have an effect, collapse it.
    if (!selection.isCollapsed &&
        intent.collapseAtReversal &&
        (selection.baseOffset < selection.extentOffset != newSelection.baseOffset < newSelection.extentOffset)) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(
          _delegate.value,
          TextSelection.fromPosition(selection.base),
          SelectionChangedCause.keyboard,
        ),
      );
    }

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection, SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    dom.EditableTextDelegate _delegate = delegate!;
    return _delegate.value.selection.isValid;
  }
}

class _ExtendSelectionOrCaretPositionAction
    extends ContextAction<ExtendSelectionToNextWordBoundaryOrCaretLocationIntent> with _FindElementFromContextMixin {
  _ExtendSelectionOrCaretPositionAction(this.context, this.textBoundaryType);

  BuildContext context;
  TextBoundaryType textBoundaryType;
  dom.EditableTextDelegate? delegate;

  @override
  Object? invoke(ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    dom.TextBoundary Function(ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent) getTextBoundariesForIntent;

    switch (textBoundaryType) {
      case TextBoundaryType.characterBoundary:
        getTextBoundariesForIntent = _delegate.characterBoundary;
        break;
      case TextBoundaryType.nextWordBoundary:
        getTextBoundariesForIntent = _delegate.nextWordBoundary;
        break;
      case TextBoundaryType.lineBreak:
        getTextBoundariesForIntent = _delegate.linebreak;
        break;
      case TextBoundaryType.documentBoundary:
        getTextBoundariesForIntent = _delegate.documentBoundary;
        break;
    }

    final TextSelection selection = _delegate.value.selection;
    assert(selection.isValid);

    final dom.TextBoundary textBoundary = getTextBoundariesForIntent(intent);
    final TextSelection textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }

    final TextPosition extent = textBoundarySelection.extent;
    final TextPosition newExtent =
        intent.forward ? textBoundary.getTrailingTextBoundaryAt(extent) : textBoundary.getLeadingTextBoundaryAt(extent);

    final TextSelection newSelection = (newExtent.offset - textBoundarySelection.baseOffset) *
                (textBoundarySelection.extentOffset - textBoundarySelection.baseOffset) <
            0
        ? textBoundarySelection.copyWith(
            extentOffset: textBoundarySelection.baseOffset,
            affinity: textBoundarySelection.extentOffset > textBoundarySelection.baseOffset
                ? TextAffinity.downstream
                : TextAffinity.upstream,
          )
        : textBoundarySelection.extendTo(newExtent);

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection, SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    dom.EditableTextDelegate _delegate = delegate!;
    return _delegate.value.selection.isValid;
  }
}

class _UpdateTextSelectionToAdjacentLineAction<T extends DirectionalCaretMovementIntent> extends ContextAction<T>
    with _FindElementFromContextMixin {
  _UpdateTextSelectionToAdjacentLineAction(this.context);

  BuildContext context;
  dom.EditableTextDelegate? delegate;

  VerticalCaretMovementRun? _verticalMovementRun;
  TextSelection? _runSelection;

  void stopCurrentVerticalRunIfSelectionChanges() {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;

    final TextSelection? runSelection = _runSelection;
    if (runSelection == null) {
      assert(_verticalMovementRun == null);
      return;
    }
    _runSelection = _delegate.value.selection;
    final TextSelection currentSelection = _delegate.value.selection;
    final bool continueCurrentRun = currentSelection.isValid &&
        currentSelection.isCollapsed &&
        currentSelection.baseOffset == runSelection.baseOffset &&
        currentSelection.extentOffset == runSelection.extentOffset;
    if (!continueCurrentRun) {
      _verticalMovementRun = null;
      _runSelection = null;
    }
  }

  @override
  void invoke(T intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;

    assert(_delegate.value.selection.isValid);

    final bool collapseSelection = intent.collapseSelection;
    final TextEditingValue value = _delegate.value;
    if (!value.selection.isValid) {
      return;
    }

    if (_verticalMovementRun?.isValid == false) {
      _verticalMovementRun = null;
      _runSelection = null;
    }

    final VerticalCaretMovementRun currentRun = _verticalMovementRun ??
        _delegate.renderEditable.startVerticalCaretMovement(_delegate.renderEditable.selection!.extent);

    final bool shouldMove = intent.forward ? currentRun.moveNext() : currentRun.movePrevious();
    final TextPosition newExtent = shouldMove
        ? currentRun.current
        : (intent.forward ? TextPosition(offset: _delegate.value.text.length) : const TextPosition(offset: 0));
    final TextSelection newSelection =
        collapseSelection ? TextSelection.fromPosition(newExtent) : value.selection.extendTo(newExtent);

    Actions.invoke(
      context!,
      UpdateSelectionIntent(value, newSelection, SelectionChangedCause.keyboard),
    );
    if (_delegate.value.selection == newSelection) {
      _verticalMovementRun = currentRun;
      _runSelection = newSelection;
    }
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    dom.EditableTextDelegate _delegate = delegate!;
    return _delegate.value.selection.isValid;
  }
}

class _SelectAllAction extends ContextAction<SelectAllTextIntent> with _FindElementFromContextMixin {
  _SelectAllAction(this.context);

  BuildContext context;
  dom.EditableTextDelegate? delegate;

  @override
  Object? invoke(SelectAllTextIntent intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    return Actions.invoke(
      context!,
      UpdateSelectionIntent(
        _delegate.value,
        TextSelection(baseOffset: 0, extentOffset: _delegate.value.text.length),
        intent.cause,
      ),
    );
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    return true;
  }
}

class _CopySelectionAction extends ContextAction<CopySelectionTextIntent> with _FindElementFromContextMixin {
  _CopySelectionAction(this.context);

  BuildContext context;
  dom.EditableTextDelegate? delegate;

  @override
  void invoke(CopySelectionTextIntent intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    if (intent.collapseSelection) {
      _delegate.cutSelection(intent.cause);
    } else {
      _delegate.copySelection(intent.cause);
    }
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    dom.EditableTextDelegate _delegate = delegate!;
    return _delegate.value.selection.isValid && !_delegate.value.selection.isCollapsed;
  }
}

class _PasteAction extends ContextAction<PasteTextIntent> with _FindElementFromContextMixin {
  _PasteAction(this.context);

  BuildContext context;
  dom.EditableTextDelegate? delegate;

  @override
  void invoke(PasteTextIntent intent, [BuildContext? context]) {
    if (delegate == null) return null;

    dom.EditableTextDelegate _delegate = delegate!;
    _delegate.pasteText(intent.cause);
  }

  @override
  bool get isActionEnabled {
    dom.TextFormControlElement? focusedElement = _findFocusedElement(context);
    if (focusedElement == null) {
      return false;
    }
    delegate = focusedElement.textSelectionDelegate;
    return true;
  }
}
