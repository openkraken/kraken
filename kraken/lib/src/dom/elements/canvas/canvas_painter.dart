// /*
//  * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
//  * Author: Kraken Team.
//  */
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/rendering.dart';
// import 'canvas_context_2d.dart';
//
// class CanvasPainter extends CustomPainter {
//   CanvasPainter({required Listenable repaint}): super(repaint: repaint);
//   CanvasRenderingContext2D? context;
//
//   bool _shouldRepaint = false;
//   PictureRecorder? _pictureRecorder;
//   Picture? _picture;
//   Canvas? _canvas;
//
//   bool get _shouldPainting => context != null && context!.actionCount > 0;
//   bool get _hasSnapshot => context != null && _picture != null && _picture!.approximateBytesUsed > 0;
//
//   // Notice: Canvas is stateless, change scaleX or scaleY will case dropping drawn content.
//   /// https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
//   double _scaleX = 1.0;
//   double get scaleX => _scaleX;
//   set scaleX(double? value) {
//     if (value != null && value != _scaleX) {
//       _scaleX = value;
//       _resetPaintingContext();
//     }
//   }
//
//   double _scaleY = 1.0;
//   double get scaleY => _scaleY;
//   set scaleY(double? value) {
//     if (value != null && value != _scaleY) {
//       _scaleY = value;
//       _resetPaintingContext();
//     }
//   }
//
//   final Paint _saveLayerPaint = Paint();
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (_hasSnapshot && !_shouldPainting) {
//       return canvas.drawPicture(_picture!);
//     }
//
//     _pictureRecorder = PictureRecorder();
//     _canvas = Canvas(_pictureRecorder!);
//
//     if (_scaleX != 1.0 || _scaleY != 1.0) {
//       _canvas!.scale(_scaleX, _scaleY);
//     }
//
//     // This lets you create composite effects, for example making a group of drawing commands semi-transparent.
//     // Without using saveLayer, each part of the group would be painted individually,
//     // so where they overlap would be darker than where they do not. By using saveLayer to group them together,
//     // they can be drawn with an opaque color at first,
//     // and then the entire group can be made transparent using the saveLayer's paint.
//     _canvas!.saveLayer(null, _saveLayerPaint);
//
//     // Paint last content
//     if (_hasSnapshot) {
//       _canvas!.drawPicture(_picture!);
//     }
//
//     // Paint new actions
//     if (_shouldPainting) {
//       context!.performActions(_canvas!, size);
//     }
//
//     // Must pair each call to save()/saveLayer() with a later matching call to restore().
//     _canvas!.restore();
//
//     // After calling this function, both the picture recorder
//     // and the canvas objects are invalid and cannot be used further.
//     _picture = _pictureRecorder!.endRecording();
//
//     canvas.drawPicture(_picture!);
//
//   }
//
//   @override
//   bool shouldRepaint(CanvasPainter oldDelegate) {
//     if (_shouldRepaint) {
//       _shouldRepaint = false;
//       return true;
//     }
//     return false;
//   }
//
//   void _resetPaintingContext() {
//     _picture?.dispose();
//     _picture = null;
//     _shouldRepaint = true;
//   }
//
//   void dispose() {
//     if (_pictureRecorder != null) {
//       if (_pictureRecorder!.isRecording) {
//         _pictureRecorder!.endRecording().dispose();
//       }
//       _pictureRecorder = null;
//     }
//
//     _picture?.dispose();
//     _picture = null;
//     _canvas = null;
//   }
// }
