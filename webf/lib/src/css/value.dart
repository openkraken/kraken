/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

// https://github.com/WebKit/webkit/blob/master/Source/WebCore/css/CSSProperties.json
Map CSSInitialValues = {
  BACKGROUND_COLOR: TRANSPARENT,
  BACKGROUND_POSITION: '0% 0%',
  BORDER_BOTTOM_COLOR: CURRENT_COLOR,
  BORDER_LEFT_COLOR: CURRENT_COLOR,
  BORDER_RIGHT_COLOR: CURRENT_COLOR,
  BORDER_TOP_COLOR: CURRENT_COLOR,
  BORDER_BOTTOM_LEFT_RADIUS: ZERO,
  BORDER_BOTTOM_RIGHT_RADIUS: ZERO,
  BORDER_TOP_LEFT_RADIUS: ZERO,
  BORDER_TOP_RIGHT_RADIUS: ZERO,
  BORDER_BOTTOM_WIDTH: '3px',
  BORDER_RIGHT_WIDTH: '3px',
  BORDER_LEFT_WIDTH: '3px',
  BORDER_TOP_WIDTH: '3px',
  // Depends on user agent.
  COLOR: CSSColor.INITIAL_COLOR,
  FONT_SIZE: '100%',
  FONT_WEIGHT: '400',
  LINE_HEIGHT: '120%',
  LETTER_SPACING: NORMAL,
  PADDING_BOTTOM: ZERO,
  PADDING_LEFT: ZERO,
  PADDING_RIGHT: ZERO,
  PADDING_TOP: ZERO,
  MARGIN_BOTTOM: ZERO,
  MARGIN_LEFT: ZERO,
  MARGIN_RIGHT: ZERO,
  MARGIN_TOP: ZERO,
  HEIGHT: AUTO,
  WIDTH: AUTO,
  MAX_HEIGHT: NONE,
  MAX_WIDTH: NONE,
  MIN_HEIGHT: ZERO,
  MIN_WIDTH: ZERO,
  OPACITY: '1.0',
  LEFT: AUTO,
  BOTTOM: AUTO,
  RIGHT: AUTO,
  TOP: AUTO,
  TEXT_SHADOW: '0px 0px 0px transparent',
  TRANSFORM: 'matrix3d(${CSSMatrix.initial.storage.join(',')})',
  TRANSFORM_ORIGIN: '50% 50% 0',
  VERTICAL_ALIGN: ZERO,
  VISIBILITY: VISIBLE,
  WORD_SPACING: NORMAL,
  Z_INDEX: AUTO
};

// https://drafts.css-houdini.org/css-properties-values-api/#dependency-cycles
class CSSValue {
  String propertyName;
  RenderStyle renderStyle;
  CSSValue(this.propertyName, this.renderStyle);
}
