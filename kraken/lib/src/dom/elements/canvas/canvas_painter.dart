/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'canvas_context_2d.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({ required Listenable repaint }): super(repaint: repaint);

  CanvasRenderingContext2D? context;

  final Paint _saveLayerPaint = Paint();
  final Paint _snapshotPaint = Paint();

  // Cache the last paint image.
  Image? _snapshot;
  bool _shouldRepaint = false;

  bool get _shouldPainting => context != null && context!.actionCount > 0;
  bool get _hasSnapshot => context != null && _snapshot != null;

  // Notice: Canvas is stateless, change scaleX or scaleY will case dropping drawn content.
  /// https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
  double _scaleX = 1.0;
  double get scaleX => _scaleX;
  set scaleX(double? value) {
    if (value != null && value != _scaleX) {
      _scaleX = value;
      _resetPaintingContext();
    }
  }

  double _scaleY = 1.0;
  double get scaleY => _scaleY;
  set scaleY(double? value) {
    if (value != null && value != _scaleY) {
      _scaleY = value;
      _resetPaintingContext();
    }
  }

  @override
  void paint(Canvas canvas, Size size) async {
    if (_hasSnapshot && !_shouldPainting) {
      return canvas.drawImage(_snapshot!, Offset.zero, _snapshotPaint);
    }

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas recordCanvas = Canvas(pictureRecorder);

    if (_scaleX != 1.0 || _scaleY != 1.0) {
      recordCanvas.scale(_scaleX, _scaleY);
    }

    // This lets you create composite effects, for example making a group of drawing commands semi-transparent.
    // Without using saveLayer, each part of the group would be painted individually,
    // so where they overlap would be darker than where they do not. By using saveLayer to group them together,
    // they can be drawn with an opaque color at first,
    // and then the entire group can be made transparent using the saveLayer's paint.
    recordCanvas.saveLayer(null, _saveLayerPaint);

    // Paint last content
    if (_hasSnapshot) {
      recordCanvas.drawImage(_snapshot!, Offset.zero, _snapshotPaint);
      _disposeSnapshot();
    }

    // Paint new actions
    if (_shouldPainting) {
      context!.performActions(recordCanvas, size);
    }

    // Must pair each call to save()/saveLayer() with a later matching call to restore().
    recordCanvas.restore();

    // After calling this function, both the picture recorder
    // and the canvas objects are invalid and cannot be used further.
    final Picture picture = pictureRecorder.endRecording();
    canvas.drawPicture(picture);

    // Must flat picture to image, or raster will accept a growing command buffer.
    _snapshot = await picture.toImage(size.width.toInt(), size.height.toInt());
    // Dispose the used picture.
    picture.dispose();
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    if (_shouldRepaint) {
      _shouldRepaint = false;
      return true;
    }
    return false;
  }

  void _resetPaintingContext() {
    _disposeSnapshot();
    _shouldRepaint = true;
  }

  void _disposeSnapshot() {
    _snapshot?.dispose();
    _snapshot = null;
  }

  void dispose() {
    _disposeSnapshot();
  }
}
