/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart' show CanvasRenderingContext2D;

class CanvasPainter extends CustomPainter {
  CanvasRenderingContext2D context;

  PictureRecorder _customRecorder;
  Picture _customPicture;
  Canvas _customCanvas;

  void _startRecording() {
    _customRecorder = PictureRecorder();
    _customCanvas = Canvas(_customRecorder);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (context != null) {
      if (_customPicture != null) {
        canvas.drawPicture(_customPicture);
      }
      _startRecording();
      context.performAction(_customCanvas, size);

      /// After calling this function, both the picture recorder
      /// and the canvas objects are invalid and cannot be used further.
      _customPicture = _customRecorder.endRecording();
      context.clearActionRecords();
      canvas.drawPicture(_customPicture);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => false;
}
