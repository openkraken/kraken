/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui' as ui
    show
        LineMetrics,
        Gradient,
        Shader,
        TextBox,
        TextHeightBehavior;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

const String _kEllipsis = '\u2026';

/// Forked from Flutter RenderParagraph
/// Flutter's paragraph line-height calculation logic differs from web's
/// Use multiple line text painters to controll the leading of font in paint stage
/// A render object that displays a paragraph of text.
/// W3C line-height spec: https://www.w3.org/TR/css-inline-3/#inline-height
class KrakenRenderParagraph extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TextParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TextParentData>,
        RelayoutWhenSystemFontsChangeMixin {
  /// Creates a paragraph render object.
  ///
  /// The [text], [textAlign], [textDirection], [overflow], [softWrap], and
  /// [textScaleFactor] arguments must not be null.
  ///
  /// The [maxLines] property may be null (and indeed defaults to null), but if
  /// it is not null, it must be greater than zero.
  KrakenRenderParagraph(
    InlineSpan text, {
    TextAlign textAlign = TextAlign.start,
    required TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int? maxLines,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    ui.TextHeightBehavior? textHeightBehavior,
    List<RenderBox>? children,
  })  : assert(text.debugAssertIsValid()),
        assert(maxLines == null || maxLines > 0),
        _softWrap = softWrap,
        _overflow = overflow,
        _textPainter = TextPainter(
            text: text,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            locale: locale,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData)
      child.parentData = TextParentData();
  }

  final TextPainter _textPainter;

  /// The text painter of each line
  late List<TextPainter> _lineTextPainters;

  /// The line mertics of paragraph
  late List<ui.LineMetrics> _lineMetrics;

  /// The vertical offset of each line
  late List<double> _lineOffset;

  /// The line height of paragraph
  double? _lineHeight;
  double? get lineHeight => _lineHeight;
  set lineHeight(double? value) {
    if (lineHeight == value) return;
    _lineHeight = value;
  }

  /// The text to display.
  TextSpan get text => _textPainter.text as TextSpan;

  set text(TextSpan value) {
    switch (_textPainter.text!.compareTo(value)) {
      case RenderComparison.identical:
      case RenderComparison.metadata:
        return;
      case RenderComparison.paint:
      case RenderComparison.layout:
        _textPainter.text = value;
        _overflowShader = null;
        break;
    }
  }

  /// How the text should be aligned horizontally.
  TextAlign get textAlign => _textPainter.textAlign;

  set textAlign(TextAlign value) {
    if (_textPainter.textAlign == value) return;
    _textPainter.textAlign = value;
  }

  /// The directionality of the text.
  ///
  /// This decides how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// This must not be null.
  TextDirection get textDirection => _textPainter.textDirection!;

  set textDirection(TextDirection value) {
    if (_textPainter.textDirection == value) return;
    _textPainter.textDirection = value;
    markNeedsLayout();
  }

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  ///
  /// If [softWrap] is false, [overflow] and [textAlign] may have unexpected
  /// effects.
  bool get softWrap => _softWrap;
  bool _softWrap;

  set softWrap(bool value) {
    if (_softWrap == value) return;
    _softWrap = value;
    markNeedsLayout();
  }

  /// How visual overflow should be handled.
  TextOverflow get overflow => _overflow;
  TextOverflow _overflow;

  set overflow(TextOverflow value) {
    if (_overflow == value) return;
    _overflow = value;
    _textPainter.ellipsis = value == TextOverflow.ellipsis ? _kEllipsis : null;
  }

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  double get textScaleFactor => _textPainter.textScaleFactor;

  set textScaleFactor(double value) {
    if (_textPainter.textScaleFactor == value) return;
    _textPainter.textScaleFactor = value;
    _overflowShader = null;
  }

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary. If the text exceeds the given number of lines, it will be
  /// truncated according to [overflow] and [softWrap].
  int? get maxLines => _textPainter.maxLines;

  /// The value may be null. If it is not null, then it must be greater than
  /// zero.
  set maxLines(int? value) {
    assert(value == null || value > 0);
    if (_textPainter.maxLines == value) return;
    _textPainter.maxLines = value;
    _overflowShader = null;
  }

  /// Used by this paragraph's internal [TextPainter] to select a
  /// locale-specific font.
  ///
  /// In some cases the same Unicode character may be rendered differently
  /// depending
  /// on the locale. For example the '骨' character is rendered differently in
  /// the Chinese and Japanese locales. In these cases the [locale] may be used
  /// to select a locale-specific font.
  Locale? get locale => _textPainter.locale;

  /// The value may be null.
  set locale(Locale? value) {
    if (_textPainter.locale == value) return;
    _textPainter.locale = value;
    _overflowShader = null;
  }

  /// {@macro flutter.painting.textPainter.strutStyle}
  StrutStyle? get strutStyle => _textPainter.strutStyle;

  /// The value may be null.
  set strutStyle(StrutStyle? value) {
    if (_textPainter.strutStyle == value) return;
    _textPainter.strutStyle = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// {@macro flutter.widgets.basic.TextWidthBasis}
  TextWidthBasis get textWidthBasis => _textPainter.textWidthBasis;

  set textWidthBasis(TextWidthBasis value) {
    if (_textPainter.textWidthBasis == value) return;
    _textPainter.textWidthBasis = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// {@macro flutter.dart:ui.textHeightBehavior}
  ui.TextHeightBehavior? get textHeightBehavior =>
      _textPainter.textHeightBehavior;

  set textHeightBehavior(ui.TextHeightBehavior? value) {
    if (_textPainter.textHeightBehavior == value) return;
    _textPainter.textHeightBehavior = value;
    _overflowShader = null;
    markNeedsLayout();
  }
  /// Compute distance to baseline of first text line
  double computeDistanceToFirstLineBaseline() {
    double firstLineOffset = _lineOffset[0];
    ui.LineMetrics firstLineMetrics = _lineMetrics[0];

    // Use the baseline of the last line as paragraph baseline.
    return text.text == '' ? 0.0 : (firstLineOffset + firstLineMetrics.ascent);
  }

  /// Compute distance to baseline of last text line
  double computeDistanceToLastLineBaseline() {
    double lastLineOffset = _lineOffset[_lineOffset.length - 1];
    ui.LineMetrics lastLineMetrics = _lineMetrics[_lineMetrics.length - 1];

    // Use the baseline of the last line as paragraph baseline.
    return text.text == '' ? 0.0 : (lastLineOffset + lastLineMetrics.ascent);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    RenderBox? child = firstChild;
    while (child != null) {
      final TextParentData textParentData = child.parentData as TextParentData;
      final Matrix4 transform = Matrix4.translationValues(
        textParentData.offset.dx,
        textParentData.offset.dy,
        0.0,
      )..scale(
          textParentData.scale,
          textParentData.scale,
          textParentData.scale,
        );
      final bool isHit = result.addWithPaintTransform(
        transform: transform,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(() {
            final Offset manualPosition =
                (position - textParentData.offset) / textParentData.scale!;
            return (transformed.dx - manualPosition.dx).abs() <
                    precisionErrorTolerance &&
                (transformed.dy - manualPosition.dy).abs() <
                    precisionErrorTolerance;
          }());
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childAfter(child);
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is! PointerDownEvent) return;
    _layoutTextWithConstraints(constraints);
    final Offset offset = entry.localPosition;
    final TextPosition position = _textPainter.getPositionForOffset(offset);
    final InlineSpan? span = _textPainter.text!.getSpanForPosition(position);
    if (span == null) {
      return;
    }
    if (span is TextSpan) {
      final TextSpan textSpan = span;
      textSpan.recognizer?.addPointer(event);
    }
  }

  bool _needsClipping = false;
  ui.Shader? _overflowShader;

  /// Whether this paragraph currently has a [dart:ui.Shader] for its overflow
  /// effect.
  ///
  /// Used to test this object. Not for use in production.
  @visibleForTesting
  bool get debugHasOverflowShader => _overflowShader != null;

  void _layoutText({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final bool widthMatters = softWrap || overflow == TextOverflow.ellipsis;
    _textPainter.layout(
      minWidth: minWidth,
      maxWidth: widthMatters ? maxWidth : double.infinity,
    );
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    _textPainter.markNeedsLayout();
  }

  void _layoutTextWithConstraints(BoxConstraints constraints) {
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  // Get text of each line in the paragraph.
  List<String> _getLineTexts(TextPainter textPainter, TextSpan textSpan) {
    TextSelection selection =
        TextSelection(baseOffset: 0, extentOffset: textSpan.text!.length);
    List<TextBox> boxes = textPainter.getBoxesForSelection(selection);
    List<String> lineTexts = [];
    int start = 0;
    int end;
    int index = -1;
    // Loop through each text box
    for (TextBox box in boxes) {
      // Text include ideographic characters such as Chinese may be counted as seperated text box
      // if font-family not specified, it needs to filter text box not started from 0 such as following:
      // TextBox.fromLTRBD(14.0, 1.7, 39.1, 18.2, TextDirection.ltr)
      if (box.left != 0) {
        continue;
      }

      index += 1;
      if (index == 0) continue;
      // Go one logical pixel within the box and get the position
      // of the character in the string.
      end = textPainter
          .getPositionForOffset(Offset(box.left + 1, box.top + 1))
          .offset;
      // add the substring to the list of lines
      final line = textSpan.text!.substring(start, end);
      lineTexts.add(line);
      start = end;
    }
    // get the last substring
    final extra = textSpan.text!.substring(start);
    lineTexts.add(extra);

    return lineTexts;
  }

  // Compute line metrics and line offset according to line-height spec.
  // https://www.w3.org/TR/css-inline-3/#inline-height
  void _computeLineMetrics() {
    _lineMetrics = _textPainter.computeLineMetrics();
    // Leading of each line
    List<double> _lineLeading = [];

    _lineOffset = [];
    for (int i = 0; i < _lineMetrics.length; i++) {
      ui.LineMetrics lineMetric = _lineMetrics[i];
      // Do not add line height in the case of textOverflow ellipsis
      // cause height of line metric equals to 0.
      double leading = lineHeight != null && lineMetric.height != 0
        ? lineHeight! - lineMetric.height
        : 0;
      _lineLeading.add(leading);
      // Offset of previous line
      double preLineBottom = i > 0
        ? _lineOffset[i - 1] + _lineMetrics[i - 1].height + _lineLeading[i - 1] / 2
        : 0;
      double offset = preLineBottom + leading / 2;
      _lineOffset.add(offset);
    }
  }

  // Compute paragraph height according to line metrics.
  double _getParagraphHeight() {
    double paragraphHeight = 0;
    // Height of paragraph
    for (int i = 0; i < _lineMetrics.length; i++) {
      ui.LineMetrics lineMetric = _lineMetrics[i];
      // Do not add line height in the case of textOverflow ellipsis
      // cause height of line metric equals to 0.
      double height = lineHeight != null && lineMetric.height != 0 ?
      lineHeight! : lineMetric.height;
      paragraphHeight += height;
    }

    return paragraphHeight;
  }

  // Create and layout text painter of each line in the paragraph for later use
  // in the paint stage to adjust the vertical space between text painters according to
  // W3C line-height spec.
  void _relayoutMultiLineText() {
    final BoxConstraints constraints = this.constraints;
    // Get text of each line
    List<String> lineTexts = _getLineTexts(_textPainter, _textPainter.text as TextSpan);

    _lineTextPainters = [];
    // Create text painter of each line and layout
    for (int i = 0; i < lineTexts.length; i++) {
      String lineText = lineTexts[i];

      final TextSpan textSpan = TextSpan(
        text: lineText,
        style: text.style,
      );
      TextPainter _lineTextPainter = TextPainter(
          text: textSpan,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
          locale: locale,
          strutStyle: strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior);
      _lineTextPainters.add(_lineTextPainter);

      final bool widthMatters = softWrap || overflow == TextOverflow.ellipsis;
      _lineTextPainter.layout(
        minWidth: constraints.minWidth,
        maxWidth: widthMatters ? constraints.maxWidth : double.infinity,
      );
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    _layoutTextWithConstraints(constraints);
    _computeLineMetrics();

    // @FIXME: Layout twice will hurt performance, ideally this logic should be done
    // in flutter text engine.
    // Layout each line of the paragraph indivisually to
    // place each line according to W3C line-height rule.
    if (lineHeight != null) {
      _relayoutMultiLineText();
    }

    // We grab _textPainter.size and _textPainter.didExceedMaxLines here because
    // assigning to `size` will trigger us to validate our intrinsic sizes,
    // which will change _textPainter's layout because the intrinsic size
    // calculations are destructive. Other _textPainter state will also be
    // affected. See also RenderEditable which has a similar issue.
    final Size textSize = _textPainter.size;
    final bool textDidExceedMaxLines = _textPainter.didExceedMaxLines;

    double paragraphHeight = _getParagraphHeight();
    Size paragraphSize = Size(textSize.width, paragraphHeight);

    size = constraints.constrain(paragraphSize);

    final bool didOverflowHeight =
        size.height < textSize.height || textDidExceedMaxLines;
    final bool didOverflowWidth = size.width < textSize.width;
    // TODO(abarth): We're only measuring the sizes of the line boxes here. If*
    // the glyphs draw outside the line boxes, we might think that there isn't
    // visual overflow when there actually is visual overflow. This can become
    // a problem if we start having horizontal overflow and introduce a clip
    // that affects the actual (but undetected) vertical overflow.
    final bool hasVisualOverflow = didOverflowWidth || didOverflowHeight;
    if (hasVisualOverflow) {
      switch (_overflow) {
        case TextOverflow.visible:
          _needsClipping = false;
          _overflowShader = null;
          break;
        case TextOverflow.clip:
        case TextOverflow.ellipsis:
          _needsClipping = true;
          _overflowShader = null;
          break;
        case TextOverflow.fade:
          _needsClipping = true;
          final TextPainter fadeSizePainter = TextPainter(
            text: TextSpan(style: _textPainter.text!.style, text: '\u2026'),
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            locale: locale,
          )..layout();
          if (didOverflowWidth) {
            double fadeEnd, fadeStart;
            switch (textDirection) {
              case TextDirection.rtl:
                fadeEnd = 0.0;
                fadeStart = fadeSizePainter.width;
                break;
              case TextDirection.ltr:
                fadeEnd = size.width;
                fadeStart = fadeEnd - fadeSizePainter.width;
                break;
            }
            _overflowShader = ui.Gradient.linear(
              Offset(fadeStart, 0.0),
              Offset(fadeEnd, 0.0),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          } else {
            final double fadeEnd = size.height;
            final double fadeStart = fadeEnd - fadeSizePainter.height / 2.0;
            _overflowShader = ui.Gradient.linear(
              Offset(0.0, fadeStart),
              Offset(0.0, fadeEnd),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          }
          break;
      }
    } else {
      _needsClipping = false;
      _overflowShader = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(() {
      if (debugRepaintTextRainbowEnabled) {
        final Paint paint = Paint()..color = debugCurrentRepaintColor.toColor();
        context.canvas.drawRect(offset & size, paint);
      }
      return true;
    }());

    if (_needsClipping) {
      final Rect bounds = offset & size;
      if (_overflowShader != null) {
        // This layer limits what the shader below blends with to be just the
        // text (as opposed to the text and its background).
        context.canvas.saveLayer(bounds, Paint());
      } else {
        context.canvas.save();
      }
      context.canvas.clipRect(bounds);
    }

    if (lineHeight != null) {
      // Adjust text paint offset of each line according to line-height.
      for (int i = 0; i < _lineTextPainters.length; i++) {
        TextPainter _lineTextPainter = _lineTextPainters[i];
        Offset lineOffset = Offset(offset.dx, offset.dy + _lineOffset[i]);
        _lineTextPainter.paint(context.canvas, lineOffset);
      }
    } else {
      _textPainter.paint(context.canvas, offset);
    }

    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.translate(offset.dx, offset.dy);
        final Paint paint = Paint()
          ..blendMode = BlendMode.modulate
          ..shader = _overflowShader;
        context.canvas.drawRect(Offset.zero & size, paint);
      }
      context.canvas.restore();
    }
  }

  /// Returns the offset at which to paint the caret.
  ///
  /// Valid only after [layout].
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getOffsetForCaret(position, caretPrototype);
  }

  /// Returns a list of rects that bound the given selection.
  ///
  /// A given selection might have more than one rect if this text painter
  /// contains bidirectional text because logically contiguous text might not be
  /// visually contiguous.
  ///
  /// Valid only after [layout].
  List<ui.TextBox> getBoxesForSelection(TextSelection selection) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getBoxesForSelection(selection);
  }

  /// Returns the position within the text for the given pixel offset.
  ///
  /// Valid only after [layout].
  TextPosition getPositionForOffset(Offset offset) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getPositionForOffset(offset);
  }

  /// Returns the text range of the word at the given offset. Characters not
  /// part of a word, such as spaces, symbols, and punctuation, have word breaks
  /// on both sides. In such cases, this method will return a text range that
  /// contains the given text position.
  ///
  /// Word boundaries are defined more precisely in Unicode Standard Annex #29
  /// <http://www.unicode.org/reports/tr29/#Word_Boundaries>.
  ///
  /// Valid only after [layout].
  TextRange getWordBoundary(TextPosition position) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getWordBoundary(position);
  }

  /// Returns the size of the text as laid out.
  ///
  /// This can differ from [size] if the text overflowed or if the [constraints]
  /// provided by the parent [RenderObject] forced the layout to be bigger than
  /// necessary for the given [text].
  ///
  /// This returns the [TextPainter.size] of the underlying [TextPainter].
  ///
  /// Valid only after [layout].
  Size get textSize {
    assert(!debugNeedsLayout);
    return _textPainter.size;
  }

  /// Collected during [describeSemanticsConfiguration], used by
  /// [assembleSemanticsNode] and [_combineSemanticsInfo].
  List<InlineSpanSemanticsInformation>? _semanticsInfo;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    _semanticsInfo = text.getSemanticsInformation();

    if (_semanticsInfo!.any(
        (InlineSpanSemanticsInformation info) => info.recognizer != null)) {
      config.explicitChildNodes = true;
      config.isSemanticBoundary = true;
    } else {
      final StringBuffer buffer = StringBuffer();
      for (final InlineSpanSemanticsInformation info in _semanticsInfo!) {
        buffer.write(info.semanticsLabel ?? info.text);
      }
      config.label = buffer.toString();
      config.textDirection = textDirection;
    }
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      text.toDiagnosticsNode(
        name: 'text',
        style: DiagnosticsTreeStyle.transition,
      )
    ];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(FlagProperty(
      'softWrap',
      value: softWrap,
      ifTrue: 'wrapping at box width',
      ifFalse: 'no wrapping except at line break characters',
      showName: true,
    ));
    properties.add(EnumProperty<TextOverflow>('overflow', overflow));
    properties.add(DoubleProperty(
      'textScaleFactor',
      textScaleFactor,
      defaultValue: 1.0,
    ));
    properties.add(DiagnosticsProperty<Locale>(
      'locale',
      locale,
      defaultValue: null,
    ));
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
  }
}
