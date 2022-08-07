/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

const Color _kHighlightedRenderObjectFillColor = Color.fromARGB(128, 128, 128, 255);
const Color _kHighlightedRenderObjectBorderColor = Color.fromARGB(128, 64, 64, 128);

class InspectorOverlayLayer extends Layer {
  /// Creates a layer that displays the inspector overlay.
  InspectorOverlayLayer({required this.overlayRect}) {
    bool inDebugMode = kDebugMode || kProfileMode;
    if (inDebugMode == false) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('The inspector should never be used in production mode due to the '
            'negative performance impact.'),
      ]);
    }
  }

  /// The rectangle in this layer's coordinate system that the overlay should
  /// occupy.
  ///
  /// The scene must be explicitly recomposited after this property is changed
  /// (as described at [Layer]).
  final Rect overlayRect;

  late Picture _picture;

  @override
  void addToScene(SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    _picture = _buildPicture();
    builder.addPicture(layerOffset, _picture);
  }

  Picture _buildPicture() {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder, overlayRect);

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _kHighlightedRenderObjectFillColor;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _kHighlightedRenderObjectBorderColor;

    // Highlight the selected renderObject.
    canvas
      ..save()
      // ..transform(state.selected.transform.storage)
      ..drawRect(overlayRect, fillPaint)
      ..drawRect(overlayRect, borderPaint)
      ..restore();

    return recorder.endRecording();
  }
}
