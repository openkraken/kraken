/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

/// Fps callback.
typedef FpsCallback = void Function(List<FpsInfo> fps);

class Fps {
  Fps._();

  static Fps? _instance;

  static Fps get instance {
    _instance ??= Fps._();
    return _instance!;
  }

  bool _started = false;
  final List<FpsCallback> _fpsCallbacks = [];

  void addFpsCallback(FpsCallback fpsCallback) {
    _fpsCallbacks.add(fpsCallback);
  }

  void start() async {
    if (!_started) {
      _started = true;

      ElementsBinding.instance!.addTimingsCallback((List<FrameTiming> timings) {
        if (_fpsCallbacks.isNotEmpty) {
          List<FpsInfo> fps = timings.map<FpsInfo>((timing) => FpsInfo(timing)).toList();
          for (var callback in _fpsCallbacks) {
            callback(fps);
          }
        }
      });
    }
  }

  void stop() {
    _started = false;
  }
}

class FpsInfo {
  final FrameTiming frameTiming;

  FpsInfo(this.frameTiming);

  int get fps => 1000 ~/ totalSpan;

  /// The duration in milliseconds to build the frame on the UI thread.
  double get uiSpan => _formatMS(frameTiming.buildDuration);

  /// The duration in milliseconds to rasterize the frame on the GPU thread.
  double get gpuSpan => _formatMS(frameTiming.rasterDuration);

  /// The duration in milliseconds during a lifetime of a frame.
  double get totalSpan => _formatMS(frameTiming.totalSpan);

  double _formatMS(Duration duration) => (duration.inMicroseconds * 0.001);

  @override
  String toString() {
    return 'Max: ${fps}fps, UI: ${uiSpan.toStringAsFixed(2)}ms, GPU: ${gpuSpan.toStringAsFixed(2)}ms, Total: ${totalSpan.toStringAsFixed(2)}ms';
  }
}

class RenderFpsOverlay extends RenderBox {
  RenderFpsOverlay() : super() {
    Fps.instance.addFpsCallback((List<FpsInfo> fps) {
      for (FpsInfo fpsInfo in fps) {
        _fpsInfo = fpsInfo;
        markNeedsPaint();
      }
    });
    Fps.instance.start();
  }

  FpsInfo? _fpsInfo;

  TextPainter _getTextPainter(String text, Color color) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: 14.0,
    );
    TextSpan span = TextSpan(text: text, style: textStyle);
    TextAlign _textAlign = TextAlign.start;
    TextDirection _textDirection = TextDirection.ltr;
    TextPainter textPainter = TextPainter(
      text: span,
      textAlign: _textAlign,
      textDirection: _textDirection,
    );

    return textPainter;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void performResize() {
    size = constraints.constrain(Size(double.infinity, 14.0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(needsCompositing);
    Canvas canvas = context.canvas;
    if (_fpsInfo != null) {
      TextPainter textPainter = _getTextPainter(_fpsInfo.toString(), CSSColor.parseColor('red')!);
      textPainter.layout();
      textPainter.paint(canvas, Offset.zero);
    }
  }
}
