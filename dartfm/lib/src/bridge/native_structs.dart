import 'dart:ffi';
import 'package:flutter/painting.dart';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

class ScreenSize extends Struct {
  @Double()
  double width;

  @Double()
  double height;

  factory ScreenSize.allocate(double width, double height) =>
      allocate<ScreenSize>().ref
        ..width = width
        ..height = height;

  static Pointer<ScreenSize> fromSize(Size size) {
    Pointer<ScreenSize> screen = createScreen(
        size.width / window.devicePixelRatio,
        size.height / window.devicePixelRatio);
    return screen;
  }
}
