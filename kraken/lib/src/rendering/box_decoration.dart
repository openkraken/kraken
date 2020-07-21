import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:meta/meta.dart';

/// Paints a [Decoration] either before or after its child paints.
/// Provide Border and Background render box.
class RenderDecorateElementBox extends RenderProxyBox {
  /// Creates a decorated box.
  ///
  /// The [decoration], [position], and [configuration] arguments must not be
  /// null. By default the decoration paints behind the child.
  ///
  /// The [ImageConfiguration] will be passed to the decoration (with the size
  /// filled in) to let it resolve images.
  RenderDecorateElementBox({
    @required Decoration decoration,
    EdgeInsets borderEdge = EdgeInsets.zero,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
    RenderBox child,
  })  : assert(decoration != null),
        assert(position != null),
        assert(configuration != null),
        _decoration = decoration,
        _borderEdge = borderEdge,
        _position = position,
        _configuration = configuration,
        super(child);

  BoxPainter _painter;

  /// BorderSize to deflate.
  EdgeInsets _borderEdge;
  EdgeInsets get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets newValue) {
    _borderEdge = newValue;
    if (_decoration != null && _decoration is BoxDecoration) {
      Gradient gradient = (_decoration as BoxDecoration).gradient;
      if (gradient is BorderGradientMixin) {
        gradient.borderEdge = newValue;
      }
    }
    markNeedsLayout();
  }

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    assert(value != null);
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  /// Whether to paint the box decoration behind or in front of the child.
  DecorationPosition get position => _position;
  DecorationPosition _position;
  set position(DecorationPosition value) {
    assert(value != null);
    if (value == _position) return;
    _position = value;
    markNeedsPaint();
  }

  /// The settings to pass to the decoration when painting, so that it can
  /// resolve images appropriately. See [ImageProvider.resolve] and
  /// [BoxPainter.paint].
  ///
  /// The [ImageConfiguration.textDirection] field is also used by
  /// direction-sensitive [Decoration]s for painting and hit-testing.
  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    assert(value != null);
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child != null) {
      // Clamp border size for child box.
      BoxConstraints childConstrains = constraints.deflate(borderEdge);
      child.layout(childConstrains, parentUsesSize: true);
      size = borderEdge.inflateSize(child.size);
    } else {
      performResize();
    }
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
    // Since we're disposing of our painter, we won't receive change
    // notifications. We mark ourselves as needing paint so that we will
    // resubscribe to change notifications. If we didn't do this, then, for
    // example, animated GIFs would stop animating when a DecoratedBox gets
    // moved around the tree due to GlobalKey reparenting.
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    return _decoration.hitTest(size, position, textDirection: configuration.textDirection);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    final ImageConfiguration filledConfiguration = configuration.copyWith(size: size);
    if (position == DecorationPosition.background) {
      int debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());
      _painter.paint(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('${_decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription('Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', _painter, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }
    Offset contentOffset = offset.translate(borderEdge.left, borderEdge.top);
    super.paint(context, contentOffset);
    if (position == DecorationPosition.foreground) {
      _painter.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(_decoration.toDiagnosticsNode(name: 'decoration'));
    properties.add(DiagnosticsProperty<ImageConfiguration>('configuration', configuration));
  }
}
