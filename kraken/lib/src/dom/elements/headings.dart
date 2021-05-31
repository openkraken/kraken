// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

import 'dart:ffi';
import 'package:kraken/bridge.dart';

const String H1 = 'H1';
const String H2 = 'H2';
const String H3 = 'H3';
const String H4 = 'H4';
const String H5 = 'H5';
const String H6 = 'H6';

const Map<String, dynamic> _h1DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '32px',  // 2em
};

const Map<String, dynamic> _h2DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '24px', // 1.5em
};

const Map<String, dynamic> _h3DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '18.72px', // 1.33em
};

const Map<String, dynamic> _h4DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '16px', // 1em
};

const Map<String, dynamic> _h5DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '13.28px', // 0.83em;
};

const Map<String, dynamic> _h6DefaultStyle = {
  DISPLAY: BLOCK,
  FONT_WEIGHT: BOLD,
  FONT_SIZE: '10.72px', // 0.67em
};

class H1Element extends Element {
  H1Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H1, defaultStyle: _h1DefaultStyle);
}

class H2Element extends Element {
  H2Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H2, defaultStyle: _h2DefaultStyle);
}

class H3Element extends Element {
  H3Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H3, defaultStyle: _h3DefaultStyle);
}

class H4Element extends Element {
  H4Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H4, defaultStyle: _h4DefaultStyle);
}

class H5Element extends Element {
  H5Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H5, defaultStyle: _h5DefaultStyle);
}

class H6Element extends Element {
  H6Element(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: H6, defaultStyle: _h6DefaultStyle);
}
