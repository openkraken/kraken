/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// properties
const String DISPLAY = 'display';
const String POSITION = 'position';
const String OPACITY = 'opacity';
const String Z_INDEX = 'zIndex';
const String CONTENT_VISIBILITY = 'contentVisibility';
const String BOX_SHADOW = 'boxShadow';
const String COLOR = 'color';

const String WIDTH = 'width';
const String HEIGHT = 'height';
const String MIN_HEIGHT = 'minHeight';
const String MAX_HEIGHT = 'maxHeight';
const String MIN_WIDTH = 'minWidth';
const String MAX_WIDTH = 'maxWidth';

const String OVERFLOW = 'overflow';
const String OVERFLOW_X = 'overflowX';
const String OVERFLOW_Y = 'overflowY';

const String PADDING = 'padding';
const String PADDING_LEFT = 'paddingLeft';
const String PADDING_TOP = 'paddingTop';
const String PADDING_RIGHT = 'paddingRight';
const String PADDING_BOTTOM = 'paddingBottom';

const String MARGIN = 'margin';
const String MARGIN_LEFT = 'marginLeft';
const String MARGIN_TOP = 'marginTop';
const String MARGIN_RIGHT = 'marginRight';
const String MARGIN_BOTTOM = 'marginBottom';

const String BACKGROUND = 'background';
const String BACKGROUND_ATTACHMENT = 'backgroundAttachment';
const String BACKGROUND_REPEAT = 'backgroundRepeat';
const String BACKGROUND_POSITION = 'backgroundPosition';
const String BACKGROUND_IMAGE = 'backgroundImage';
const String BACKGROUND_SIZE = 'backgroundSize';
const String BACKGROUND_COLOR = 'backgroundColor';

const String BORDER = 'border';
const String BORDER_TOP = 'borderTop';
const String BORDER_RIGHT = 'borderRight';
const String BORDER_BOTTOM = 'borderBottom';
const String BORDER_LEFT = 'borderLeft';
const String BORDER_WIDTH = 'borderWidth';
const String BORDER_TOP_WIDTH = 'borderTopWidth';
const String BORDER_RIGHT_WIDTH = 'borderRightWidth';
const String BORDER_BOTTOM_WIDTH = 'borderBottomWidth';
const String BORDER_LEFT_WIDTH = 'borderLeftWidth';
const String BORDER_STYLE = 'borderStyle';
const String BORDER_TOP_STYLE = 'borderTopStyle';
const String BORDER_RIGHT_STYLE = 'borderRightStyle';
const String BORDER_BOTTOM_STYLE = 'borderBottomStyle';
const String BORDER_LEFT_STYLE = 'borderLeftStyle';
const String BORDER_COLOR = 'borderColor';
const String BORDER_TOP_COLOR = 'borderTopColor';
const String BORDER_RIGHT_COLOR = 'borderRightColor';
const String BORDER_BOTTOM_COLOR = 'borderBottomColor';
const String BORDER_LEFT_COLOR = 'borderLeftColor';

const String BORDER_RADIUS = 'borderRadius';
const String BORDER_TOP_LEFT_RADIUS = 'borderTopLeftRadius';
const String BORDER_TOP_RIGHT_RADIUS = 'borderTopRightRadius';
const String BORDER_BOTTOM_RIGHT_RADIUS = 'borderBottomRightRadius';
const String BORDER_BOTTOM_LEFT_RADIUS = 'borderBottomLeftRadius';

const String FONT = 'font';
const String FONT_STYLE = 'fontStyle';
const String FONT_WEIGHT = 'fontWeight';
const String FONT_SIZE = 'fontSize';
const String LINE_HEIGHT = 'lineHeight';
const String FONT_FAMILY = 'fontFamily';
const String VERTICAL_ALIGN = 'verticalAlign';
const String TEXT_OVERFLOW = 'textOverflow';
const String TEXT_DECORATION = 'textDecoration';
const String TEXT_DECORATION_LINE = 'textDecorationLine';
const String TEXT_DECORATION_COLOR = 'textDecorationColor';
const String TEXT_DECORATION_STYLE = 'textDecorationStyle';
const String TEXT_SHADOW = 'textShadow';
const String LETTER_SPACING = 'letterSpacing';
const String WORD_SPACING = 'wordSpacing';
const String WHITE_SPACE = 'whiteSpace';

const String FLEX = 'flex';
const String FLEX_GROW = 'flexGrow';
const String FLEX_SHRINK = 'flexShrink';
const String FLEX_BASIS = 'flexBasis';
const String FLEX_FLOW = 'flexFlow';
const String FLEX_DIRECTION = 'flexDirection';
const String FLEX_WRAP = 'flexWrap';

const String JUSTIFY_CONTENT = 'justifyContent';
const String TEXT_ALIGN = 'textAlign';
const String ALIGN_ITEMS = 'alignItems';
const String ALIGN_SELF = 'alignSelf';
const String ALIGN_CONTENT = 'alignContent';

const String TRANSFORM = 'transform';
const String TRANSFORM_ORIGIN = 'transformOrigin';

const String TRANSITION = 'transition';
const String TRANSITION_PROPERTY = 'transitionProperty';
const String TRANSITION_DURATION = 'transitionDuration';
const String TRANSITION_TIMING_FUNCTION = 'transitionTimingFunction';
const String TRANSITION_DELAY = 'transitionDelay';

const String ANIMATION = 'animation';
const String ANIMATION_NAME = 'animationName';
const String ANIMATION_DURATION = 'animationDuration';
const String ANIMATION_TIMING_FUNCTION = 'animationTimingFunction';
const String ANIMATION_DELAY = 'animationDelay';
const String ANIMATION_ITERATION_COUNT = 'animationIterationCount';
const String ANIMATION_DIRECTION = 'animationDirection';
const String ANIMATION_FILL_MODE = 'animationFillMode';
const String ANIMATION_PLAY_STATE = 'animationPlayState';


const String OBJECT_FIT = 'objectFit';
const String OBJECT_POSITION = 'objectPosition';

// values
const String NORMAL = 'normal';

// Border
const String THIN = 'thin'; // A thin border.
const String MEDIUM = 'medium'; // A medium border.
const String THICK = 'thick'; // A thick border.

// Font absolute size keyword: [ xx-small | x-small | small | medium | large | x-large | xx-large ]
const String XX_SMALL = 'xx-small';
const String X_SMALL = 'x-small';
const String SMALL =  'small';
const String LARGE =  'large';
const String X_LARGE =  'x-large';
const String XX_LARGE =  'xx-large';
// Font relative size keyword
const String SMALLER =  'smaller';
const String LARGER =  'larger';

const String SOLID = 'solid';
const String NONE = 'none';

// Display
const String INLINE = 'inline';
const String BLOCK = 'block';
const String INLINE_BLOCK = 'inline-block';
const String INLINE_FLEX = 'inline-flex';

// Position
const String RELATIVE = 'relative';
const String ABSOLUTE = 'absolute';
const String FIXED = 'fixed';
const String STICKY = 'sticky';
const String STATIC = 'static';

const String LEFT = 'left';
const String RIGHT = 'right';
const String TOP = 'top';
const String BOTTOM = 'bottom';
const String AUTO = 'auto';

// Flex
const String ROW = 'row';
const String COLUMN = 'column';
const String STRETCH = 'stretch';
const String WRAP = 'wrap';
const String WRAP_REVERSE = 'wrap-reverse';

const String PRE = 'pre';

const String LIGHTER = 'lighter';
const String BOLD = 'bold';
const String BOLDER = 'bolder';

// Transition
const String ALL = 'all';
const String LINEAR = 'linear';
const String EASE = 'ease';
const String EASE_IN = 'ease-in';
const String EASE_OUT = 'ease-out';
const String EASE_IN_OUT= 'ease-in-out';
const String STEP_START = 'step-start';
const String STEP_END = 'step-end';

// Shadow
const String INSET = 'inset';

// Background
const String REPEAT_X = 'repeat-x';
const String REPEAT_Y = 'repeat-y';
const String REPEAT = 'repeat';
const String NO_REPEAT = 'no-repeat';

const String CONTAIN = 'contain';
const String COVER = 'cover';
const String FIT_WIDTH = 'fit-width';
const String FIT_HEIGTH = 'fit-height';
const String SCALE_DOWN = 'scale-down';
const String FILL = 'fill';

const String SCROLL = 'scroll';
const String LOCAL = 'local';
