/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/style.dart';


typedef ConsumeProperty = bool Function(String src);
const String BACKGROUND_ATTACHMENT = 'backgroundAttachment';
const String BACKGROUND_REPEAT = 'backgroundRepeat';
const String BACKGROUND_POSITION = 'backgroundPosition';
const String BACKGROUND_IMAGE = 'backgroundImage';
const String BACKGROUND_SIZE = 'backgroundSize';
const String BACKGROUND_COLOR = 'backgroundColor';
/// The [BackgroundMixin] mixin used to handle background shorthand and compute
/// to single value of background
mixin BackgroundMixin  {

  // default property
  Map<String, String> background = {
    BACKGROUND_REPEAT: 'repeat',
    BACKGROUND_ATTACHMENT: 'scroll',
    BACKGROUND_POSITION: 'left top',
    BACKGROUND_IMAGE: '',
    BACKGROUND_SIZE: 'auto',
    BACKGROUND_COLOR: 'transparent'
  };

  void initBackground(StyleDeclaration style) {
    if (style.contains('background')) {
      List<String> shorthand = style['background'].split(' ');
      background = _consumeBackground(shorthand);
    }
    if (style.contains(BACKGROUND_ATTACHMENT)) {
      background[BACKGROUND_ATTACHMENT] = style[BACKGROUND_ATTACHMENT];
    }
    if (style.contains(BACKGROUND_REPEAT)) {
      background[BACKGROUND_REPEAT] = style[BACKGROUND_REPEAT];
    }
    if (style.contains(BACKGROUND_SIZE)) {
      background[BACKGROUND_SIZE] = style[BACKGROUND_SIZE];
    }
    if (style.contains(BACKGROUND_POSITION)) {
      background[BACKGROUND_POSITION] = style[BACKGROUND_POSITION];
    }
    if (style.contains(BACKGROUND_COLOR)) {
      background[BACKGROUND_COLOR] = style[BACKGROUND_COLOR];
    }
    if (style.contains(BACKGROUND_IMAGE)) {
      background[BACKGROUND_IMAGE] = style[BACKGROUND_IMAGE];
    }
  }

  void updateBackground(String property, String value) {
    if (property == 'background') {
      List<String> shorthand = value.split(' ');
      background = _consumeBackground(shorthand);
    } else {
      background[property] = value;
    }
  }

  Map<String, String> _consumeBackground(List<String> shorthand) {
    int longhandCount = shorthand.length;
    Map<String, ConsumeProperty> propertyMap = {
      BACKGROUND_IMAGE: _consumeBackgroundImage,
      BACKGROUND_REPEAT: _consumeBackgroundRepeat,
      BACKGROUND_ATTACHMENT: _consumeBackgroundAttachment,
      'backgroundPositionAndSize': _consumeBackgroundPosition
    };
    // default property
    Map<String, String> background = {
      BACKGROUND_REPEAT: 'repeat',
      BACKGROUND_ATTACHMENT: 'scroll',
      BACKGROUND_POSITION: 'left top',
      BACKGROUND_IMAGE: '',
      BACKGROUND_SIZE: 'auto',
      BACKGROUND_COLOR: 'transparent'
    };
    bool broken = false;
    for (int i = 0; i < longhandCount; i++) {
      if (broken) {
        break;
      }
      String property = shorthand[i].trim();
      Iterable<String> keys = propertyMap.keys;
      // record the consumed property
      String consumedKey;
      for (String key in keys) {
        // position may be more than one(at most four), should special handle
        // size is follow position and split by /
        if (key == 'backgroundPositionAndSize') {
          if (property != '/' && property.contains('/')) {
            int index = property.indexOf('/');
            String position = property.substring(0, index);
            if (_consumeBackgroundPosition(position)) {
              background[BACKGROUND_POSITION] = position;
              String size = property.substring(index + 1);
              if (_consumeBackgroundSize(size)) {
                // size at most two value
                if (i + 1 < longhandCount &&
                  _consumeBackgroundSize(shorthand[i + 1].trim())) {
                  size = size + ' ' + shorthand[i + 1].trim();
                  i++;
                }
                background[BACKGROUND_SIZE] = size;
              } else {
                broken = true;
                break;
              }
              consumedKey = key;
            } else {
              broken = true;
              break;
            }
          } else if (_consumeBackgroundPosition(property)) {
            String position = property;
            String size;
            bool hasSize = false;
            // position at most four value
            for (int j = 1; j <= 4; j ++) {
              if (i + j < longhandCount) {
                String temp = shorthand[i + j].trim();
                if (temp == '/') {
                  i = i + j;
                  hasSize = true;
                  break;
                } else if (temp.contains('/')) {
                  i = i + j;
                  hasSize = true;
                  int index = temp.indexOf('/');
                  String positionTemp = temp.substring(0, index);
                  if (_consumeBackgroundPosition(positionTemp)) {
                    background[BACKGROUND_POSITION] = position;
                    size = property.substring(index + 1);
                    if (!_consumeBackgroundSize(size)) {
                      broken = true;
                    }
                  } else {
                    broken = true;
                  }
                  break;
                } else if (_consumeBackgroundPosition(temp)) {
                  position = position + ' ' + temp;
                } else {
                  i = i + j - 1;
                  break;
                }
              } else {
                break;
              }
            }
            // handle size when / follow, at most two value
            if (hasSize) {
              if (i + 1 < longhandCount) {
                String nextSize = shorthand[i + 1].trim();
                if (size == null) {
                  size = nextSize;
                  if (_consumeBackgroundSize(size)) {
                    i++;
                    if (i + 1 < longhandCount) {
                      if (_consumeBackgroundSize(shorthand[i + 1].trim())) {
                        size = size + ' ' + shorthand[i + 1].trim();
                        i++;
                      }
                    }
                    background[BACKGROUND_SIZE] = size;
                  } else {
                    broken = true;
                    break;
                  }
                } else if (_consumeBackgroundSize(nextSize)) {
                  size = size + ' ' + nextSize;
                  background[BACKGROUND_SIZE] = size;
                } else {
                  broken = true;
                  break;
                }
              } else {
                broken = true;
                break;
              }
            }
            consumedKey = key;
            break;
          }
        } else if (propertyMap[key](property)) {
          background[key] = property;
          consumedKey = key;
          break;
        }
      }
      // consumed the property when find
      if (consumedKey != null) {
        propertyMap.remove(consumedKey);
      } else if (i == longhandCount - 1) {
        background[BACKGROUND_COLOR] = property;
      }
    }
    // shorthand error don not set value
    if (!broken) {
      return background;
    }
    return null;
  }

  bool _consumeBackgroundRepeat(String src) {
    return 'repeat-x' == src || 'repeat-y' == src || 'repeat' == src ||
      'no-repeat' == src;
  }

  bool _consumeBackgroundAttachment(String src) {
    return 'fixed' == src || 'scroll' == src || 'local' == src;
  }

  bool _consumeBackgroundImage(String src) {
    return src.startsWith('url(') || src.startsWith('linear-gradient(') ||
      src.startsWith('repeating-linear-gradient(') ||
      src.startsWith('radial-gradient(') ||
      src.startsWith('repeating-radial-gradient(') ||
      src.startsWith('conic-gradient(');
  }

  bool _consumeBackgroundPosition(String src) {
    return src == 'center' || src == 'left' || src == 'right' ||
      Length.isLength(src) || Percentage.isPercentage(src) || src == 'top' ||
      src == 'bottom';
  }

  bool _consumeBackgroundSize(String src) {
    return src == 'auto' || src == 'contain' || src == 'cover' ||
      src == 'fit-width' || src == 'fit-height' || src == 'scale-down' ||
      src == 'fill' || Length.isLength(src) || Percentage.isPercentage(src);
  }
}
