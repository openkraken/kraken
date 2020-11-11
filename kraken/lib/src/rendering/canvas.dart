/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart' show CanvasRenderingContext2D;

class CanvasPainter extends CustomPainter {
  CanvasRenderingContext2D context;

  PictureRecorder _pictureRecorder;
  Picture _picture;
  Canvas _canvas;

  bool get _shouldPaintContextActions => context != null && context.actionCount > 0;
  bool get _shouldPaintCustomPicture => _picture != null && _picture.approximateBytesUsed > 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (context != null) {
      if (_shouldPaintContextActions) {
        _pictureRecorder = PictureRecorder();
        _canvas = Canvas(_pictureRecorder);
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
        canvas.drawPicture(_picture);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => false;
}
