/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

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
  AddressElement(EventTargetContext? context)
      : super(context, defaultStyle: _addressDefaultStyle);
}

class ArticleElement extends Element {
  ArticleElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class AsideElement extends Element {
  AsideElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class FooterElement extends Element {
  FooterElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class HeaderElement extends Element {
  HeaderElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class MainElement extends Element {
  MainElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class NavElement extends Element {
  NavElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}

class SectionElement extends Element {
  SectionElement(EventTargetContext? context)
      : super(context, defaultStyle: _defaultStyle);
}
