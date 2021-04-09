/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart' show CanvasRenderingContext2D;

class CanvasPainter extends CustomPainter {
  CanvasRenderingContext2D context;

  bool _shouldRepaint = false;
  PictureRecorder _pictureRecorder;
  Picture _picture;
  Canvas _canvas;

  bool get _shouldPaintContextActions => context != null && context.actionCount > 0;
  bool get _shouldPaintCustomPicture => _picture != null && _picture.approximateBytesUsed > 0;

  // Notice: Canvas is stateless, change scaleX or scaleY will case dropping drawn content.
  /// https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
  double _scaleX = 1.0;
  double get scaleX => _scaleX;
  set scaleX(double value) {
    if (value != null && value != _scaleX) {
      _scaleX = value;
      _resetPaintingContext();
    }
  }

  double _scaleY = 1.0;
  double get scaleY => _scaleY;
  set scaleY(double value) {
    if (value != null && value != _scaleY) {
      _scaleY = value;
      _resetPaintingContext();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (context != null) {
      if (_shouldPaintContextActions) {
        _pictureRecorder = PictureRecorder();
        _canvas = Canvas(_pictureRecorder);

        if (_scaleX != 1.0 || _scaleY != 1.0) {
          _canvas.scale(_scaleX, _scaleY);
        }
      }

      if (_shouldPaintCustomPicture) {
        canvas.drawPicture(_picture);
      }

      if (_shouldPaintContextActions) {
        context.performAction(_canvas, size);

        /// After calling this function, both the picture recorder
        /// and the canvas objects are invalid and cannot be used further.
        _picture = _pictureRecorder.endRecording();
        context.clearActionRecords();
        // FIXME: That make clearRect not work in next frame action
        canvas.drawPicture(_picture);
      }
    }
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
    _picture?.dispose();
    _picture = null;
    _shouldRepaint = true;
  }

  void dispose() {
    if (_pictureRecorder != null) {
      if (_pictureRecorder.isRecording) {
        _pictureRecorder.endRecording().dispose();
      }
      _pictureRecorder = null;
    }

    _picture?.dispose();
    _picture = null;
    _canvas = null;
  }
}
