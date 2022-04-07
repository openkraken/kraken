/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/services/text_layout_metrics.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/css.dart';

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
typedef OnControllerCreated = void Function(KrakenController controller);

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

// Widget involves actions of text control elements(input, textarea).
class KrakenTextControl extends StatefulWidget {
  KrakenTextControl(this.parentContext);

  final BuildContext parentContext;

  @override
  _KrakenTextControlState createState() => _KrakenTextControlState();
}

class _KrakenTextControlState extends State<KrakenTextControl> {
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
            child: KrakenRenderObjectWidget(
              widget.parentContext.widget as Kraken,
              widgetDelegate,
            )
        )
    );
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

  FocusableActionDetector createTextControlDetector(KrakenRenderObjectWidget child) {
    return FocusableActionDetector(
        actions: _actionMap,
        focusNode: _focusNode,
        onFocusChange: _handleFocusChange,
        child: child
    );
  }

  void _initActionMap() {
    _actionMap = <Type, Action<Intent>>{
      // Action of focus.
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handlePreviousFocus),

      // Action to delete text.
      DeleteTextIntent: CallbackAction<DeleteTextIntent>(onInvoke: _handleDeleteText),
      DeleteByWordTextIntent: CallbackAction<DeleteByWordTextIntent>(onInvoke: _handleDeleteByWordText),
      DeleteByLineTextIntent: CallbackAction<DeleteByLineTextIntent>(onInvoke: _handleDeleteByLineText),
      DeleteForwardTextIntent: CallbackAction<DeleteForwardTextIntent>(onInvoke: _handleDeleteForwardText),
      DeleteForwardByWordTextIntent: CallbackAction<DeleteForwardByWordTextIntent>(onInvoke: _handleDeleteForwardByWordText),
      DeleteForwardByLineTextIntent: CallbackAction<DeleteForwardByLineTextIntent>(onInvoke: _handleDeleteForwardByLineText),

      // Action of hot keys control/command + (X, C, V, A).
      SelectAllTextIntent: CallbackAction<SelectAllTextIntent>(onInvoke: _handleSelectAllText),
      CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(onInvoke: _handleCopySelectionText),
      CutSelectionTextIntent: CallbackAction<CutSelectionTextIntent>(onInvoke: _handleCutSelectionText),
      PasteTextIntent: CallbackAction<PasteTextIntent>(onInvoke: _handlePasteText),

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
      ExtendSelectionLeftByWordTextIntent: CallbackAction<ExtendSelectionLeftByWordTextIntent>(onInvoke: _handleExtendSelectionLeftByWordText),
      ExtendSelectionLeftByLineTextIntent: CallbackAction<ExtendSelectionLeftByLineTextIntent>(onInvoke: _handleExtendSelectionLeftByLineText),
      ExtendSelectionLeftByWordAndStopAtReversalTextIntent: CallbackAction<ExtendSelectionLeftByWordAndStopAtReversalTextIntent>(onInvoke: _handleExtendSelectionLeftByWordAndStopAtReversalText),
      ExtendSelectionRightByWordTextIntent: CallbackAction<ExtendSelectionRightByWordTextIntent>(onInvoke: _handleExtendSelectionRightByWordText),
      ExtendSelectionRightByLineTextIntent: CallbackAction<ExtendSelectionRightByLineTextIntent>(onInvoke: _handleExtendSelectionRightByLineText),
      ExtendSelectionRightByWordAndStopAtReversalTextIntent: CallbackAction<ExtendSelectionRightByWordAndStopAtReversalTextIntent>(onInvoke: _handleExtendSelectionRightByWordAndStopAtReversalText),

      ExpandSelectionToEndTextIntent: CallbackAction<ExpandSelectionToEndTextIntent>(onInvoke: _handleExtendSelectionToEndText),
      ExpandSelectionToStartTextIntent: CallbackAction<ExpandSelectionToStartTextIntent>(onInvoke: _handleExtendSelectionToStartText),
      ExpandSelectionLeftByLineTextIntent: CallbackAction<ExpandSelectionLeftByLineTextIntent>(onInvoke: _handleExpandSelectionLeftByLineText),
      ExpandSelectionRightByLineTextIntent: CallbackAction<ExpandSelectionRightByLineTextIntent>(onInvoke: _handleExpandSelectionRightByLineText),
    };
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
    dom.Element rootElement = _findRootElement();
    List<dom.TextFormControlElement> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.TextFormControlElement? focusedElement = _findFocusedElement(focusableElements);
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

  void _handleDeleteText(DeleteTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .delete(SelectionChangedCause.keyboard);
    }
  }

  void _handleDeleteByWordText(DeleteByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .deleteByWord(SelectionChangedCause.keyboard, false);
    }
  }

  void _handleDeleteByLineText(DeleteByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .deleteByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleDeleteForwardText(DeleteForwardTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .deleteForward(SelectionChangedCause.keyboard);
    }
  }

  void _handleDeleteForwardByWordText(DeleteForwardByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .deleteForwardByWord(SelectionChangedCause.keyboard, false);
    }
  }

  void _handleDeleteForwardByLineText(DeleteForwardByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .deleteForwardByLine(SelectionChangedCause.keyboard);
    }
  }


  void _handleSelectAllText(SelectAllTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .selectAll(SelectionChangedCause.keyboard);
    }
  }

  void _handleCopySelectionText(CopySelectionTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .copySelection(SelectionChangedCause.keyboard);
    }
  }

  void _handleCutSelectionText(CutSelectionTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .cutSelection(SelectionChangedCause.keyboard);
    }
  }

  void _handlePasteText(PasteTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .pasteText(SelectionChangedCause.keyboard);
    }
  }

  void _handleMoveSelectionRightByLineText(MoveSelectionRightByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionRightByLine(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionLeftByLineText(MoveSelectionLeftByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionLeftByLine(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionRightByWordText(MoveSelectionRightByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionRightByWord(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionLeftByWordText(MoveSelectionLeftByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionLeftByWord(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionUpText(MoveSelectionUpTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionUp(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionDownText(MoveSelectionDownTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionDown(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionLeftText(MoveSelectionLeftTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionLeft(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionRightText(MoveSelectionRightTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionRight(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionToEndText(MoveSelectionToEndTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionToEnd(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleMoveSelectionToStartText(MoveSelectionToStartTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .moveSelectionToStart(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleExtendSelectionLeftText(ExtendSelectionLeftTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionLeft(SelectionChangedCause.keyboard);
      // Make caret visible while moving cursor.
      focusedElement.scrollToCaret();
    }
  }

  void _handleExtendSelectionRightText(ExtendSelectionRightTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionRight(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionUpText(ExtendSelectionUpTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionUp(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionDownText(ExtendSelectionDownTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionDown(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionToEndText(ExpandSelectionToEndTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .expandSelectionToEnd(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionToStartText(ExpandSelectionToStartTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .expandSelectionToStart(SelectionChangedCause.keyboard);
    }
  }

  void _handleExpandSelectionLeftByLineText(ExpandSelectionLeftByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .expandSelectionLeftByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExpandSelectionRightByLineText(ExpandSelectionRightByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .expandSelectionRightByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionLeftByWordText(ExtendSelectionLeftByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionLeftByWord(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionLeftByLineText(ExtendSelectionLeftByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionLeftByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionLeftByWordAndStopAtReversalText(ExtendSelectionLeftByWordAndStopAtReversalTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionLeftByWord(SelectionChangedCause.keyboard, false, true);
    }
  }

  void _handleExtendSelectionRightByWordText(ExtendSelectionRightByWordTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionRightByWord(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightByLineText(ExtendSelectionRightByLineTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionRightByLine(SelectionChangedCause.keyboard);
    }
  }

  void _handleExtendSelectionRightByWordAndStopAtReversalText(ExtendSelectionRightByWordAndStopAtReversalTextIntent intent) {
    dom.TextFormControlElement? focusedElement = _findFocusedElement();
    if (focusedElement != null) {
      _ElementTextEditingActionTarget
        .fromElement(focusedElement)
        .extendSelectionRightByWord(SelectionChangedCause.keyboard, false, true);
    }
  }

  // Handle focus change of _focusNode.
  void _handleFocusChange(bool focused) {
    dom.Element rootElement = _findRootElement();
    List<dom.Element> focusableElements = _findFocusableElements(rootElement);
    if (focusableElements.isNotEmpty) {
      dom.Element? focusedElement = _findFocusedElement(focusableElements);
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
  dom.TextFormControlElement? _findFocusedElement([List<dom.Element>? focusableElements]) {
    dom.TextFormControlElement? result;
    if (focusableElements == null) {
      dom.Element rootElement = _findRootElement();
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

class _ElementTextEditingActionTarget extends TextEditingActionTarget {
  factory _ElementTextEditingActionTarget.fromElement(dom.TextFormControlElement element) {
    return (element.textEditingActionTarget as _ElementTextEditingActionTarget?)
        ?? _ElementTextEditingActionTarget._(element);
  }

  _ElementTextEditingActionTarget._(this.element) {
    element.textEditingActionTarget = this;
  }

  dom.TextFormControlElement element;

  RenderEditable? get _renderEditable => element.renderEditable;

  @override
  void debugAssertLayoutUpToDate() {
    RenderEditable? editable = _renderEditable;
    assert(editable != null);
    editable!.debugAssertLayoutUpToDate();
  }

  @override
  bool get obscureText => element.obscureText;

  @override
  bool get readOnly => element.readOnly;

  @override
  bool get selectionEnabled => _renderEditable?.selectionEnabled ?? false;

  @override
  void setTextEditingValue(TextEditingValue newValue, SelectionChangedCause cause) {
    if (newValue == textEditingValue) {
      return;
    }

    RenderEditable? renderEditable = _renderEditable;
    if (renderEditable != null) {
      renderEditable.textSelectionDelegate.userUpdateTextEditingValue(newValue, cause);
    }
  }

  @override
  TextEditingValue get textEditingValue => element.currentTextEditingValue;

  @override
  TextLayoutMetrics get textLayoutMetrics => _renderEditable!;
}
