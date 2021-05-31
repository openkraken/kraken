// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#content_sectioning

const String ADDRESS = 'ADDRESS';
const String ARTICLE = 'ARTICLE';
const String ASIDE = 'ASIDE';
const String FOOTER = 'FOOTER';
const String HEADER = 'HEADER';
const String MAIN = 'MAIN';
const String NAV = 'NAV';
const String SECTION = 'SECTION';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

const Map<String, dynamic> _addressDefaultStyle = {
  DISPLAY: BLOCK,
  FONT_STYLE: ITALIC
};

class AddressElement extends Element {
  AddressElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: ADDRESS, defaultStyle: _addressDefaultStyle);
}

class ArticleElement extends Element {
  ArticleElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: ARTICLE, defaultStyle: _defaultStyle);
}

class AsideElement extends Element {
  AsideElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: ASIDE, defaultStyle: _defaultStyle);
}

class FooterElement extends Element {
  FooterElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: FOOTER, defaultStyle: _defaultStyle);
}

class HeaderElement extends Element {
  HeaderElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: HEADER, defaultStyle: _defaultStyle);
}

class MainElement extends Element {
  MainElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: MAIN, defaultStyle: _defaultStyle);
}

class NavElement extends Element {
  NavElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: NAV, defaultStyle: _defaultStyle);
}

class SectionElement extends Element {
  SectionElement(int targetId, Pointer<NativeElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, tagName: SECTION, defaultStyle: _defaultStyle);
}
