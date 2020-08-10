/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

const String STRONG = 'STRONG';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE, FONT_WEIGHT: BOLD};

class StrongElement extends Element {
  StrongElement(int targetId, ElementManager elementManager)
      : super(targetId, elementManager, tagName: STRONG, defaultStyle: _defaultStyle);
}
