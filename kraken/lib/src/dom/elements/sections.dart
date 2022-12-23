/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

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
  AddressElement([BindingContext? context])
      : super(context, defaultStyle: _addressDefaultStyle);
}

class ArticleElement extends Element {
  ArticleElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class AsideElement extends Element {
  AsideElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class FooterElement extends Element {
  FooterElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class HeaderElement extends Element {
  HeaderElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class MainElement extends Element {
  MainElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class NavElement extends Element {
  NavElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}

class SectionElement extends Element {
  SectionElement([BindingContext? context])
      : super(context, defaultStyle: _defaultStyle);
}
