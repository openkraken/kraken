/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';

const Map<String, dynamic> _defaultStyle = {'display': 'inline-block'};

class ImageElement extends Element {
  ImageProvider image;
  RenderImage imageBox;
  ImageStream imageStream;
  List<ImageStreamListener> imageListeners;
  ImageInfo _imageInfo;

  ImageElement(int targetId)
      : super(targetId: targetId, defaultStyle: _defaultStyle, allowChildren: false, tagName: IMAGE) {
    _renderImage();
  }

  bool _hasLazyLoading = false;

  void _renderImage() {
    if (_hasLazyLoading) return;
    String loading = properties['loading'];
    // Image dimensions(width/height) should specified for performance when lazyload
    if (loading == 'lazy') {
      _hasLazyLoading = true;
      renderIntersectionObserver.addListener(_handleIntersectionChange);
    } else {
      _constructImageChild();
      _setImage();
    }
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    // When appear
    if (entry.isIntersecting) {
      _setImage();
      // Once appear remove the listener
      _resetLazyLoading();
    }
  }

  void _resetLazyLoading() {
    _hasLazyLoading = false;
    renderIntersectionObserver.removeListener(_handleIntersectionChange);
  }

  void _removeImage() {
    _removeStreamListener();
    image = null;
    imageBox.image = null;
  }

  void _constructImageChild() {
    imageBox = getRenderImageBox(style, image);

    if (childNodes.isEmpty) {
      addChild(imageBox);
    }
  }

  void _handleEventAfterImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    dispatchEvent(Event('load'));
  }

  void _initImageInfo(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    imageBox.image = _imageInfo?.image;
    _handleEventAfterImageLoaded(imageInfo, synchronousCall);
    _removeStreamListener();
    _resize();
  }

  void _resize() {
    double realWidth = (_imageInfo?.image?.width ?? 0.0) + 0.0;
    double realHeight = (_imageInfo?.image?.height ?? 0.0) + 0.0;
    double width = 0.0;
    double height = 0.0;
    bool containWidth = style.contains('width');
    bool containHeight = style.contains('height');
    if (!containWidth && !containHeight) {
      width = realWidth;
      height = realHeight;
    } else {
      CSSSizedConstraints sizedConstraints = CSSSizingMixin.getConstraints(style);
      if (containWidth && containHeight) {
        width = sizedConstraints.width;
        height = sizedConstraints.height;
      } else if (containWidth) {
        width = sizedConstraints.width;
        height = width * realHeight / realWidth;
      } else if (containHeight) {
        height = sizedConstraints.height;
        width = height * realWidth / realHeight;
      }
    }
    imageBox?.width = width;
    imageBox?.height = height;
  }

  void _removeStreamListener() {
    imageListeners?.forEach((ImageStreamListener imageListener) {
      imageStream?.removeListener(imageListener);
    });
    imageStream = null;
    imageListeners = null;
  }

  BoxFit _getBoxFit(String fit) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;

      case 'cover':
        return BoxFit.cover;

      case 'none':
        return BoxFit.none;

      case 'scaleDown':
      case 'scale-down':
        return BoxFit.scaleDown;

      case 'fitWidth':
      case 'fit-width':
        return BoxFit.fitWidth;

      case 'fitHeight':
      case 'fit-height':
        return BoxFit.fitHeight;

      case 'fill':
      default:
        return BoxFit.fill;
    }
  }

  Alignment _getAlignment(String position) {
    // Syntax: object-position: <position>
    // position: From one to four values that define the 2D position of the element. Relative or absolute offsets can be used.
    // <position> = [ [ left | center | right ] || [ top | center | bottom ] | [ left | center | right | <length-percentage> ] [ top | center | bottom | <length-percentage> ]? | [ [ left | right ] <length-percentage> ] && [ [ top | bottom ] <length-percentage> ] ]
    List<String> splitted = CSSSizingMixin.getShortedProperties(position);
    if (splitted.length == 1) {
      double value = _getAlignmentValueFromString(splitted.first);
      return Alignment(value, value);
    } else if (splitted.length > 1) {
      return Alignment(_getAlignmentValueFromString(splitted[0]), _getAlignmentValueFromString(splitted[1]));
    } else {
      // The default value for object-position is 50% 50%
      return Alignment.center;
    }
  }

  double _getAlignmentValueFromString(String value) {
    assert(value != null);

    // Support percentage
    if (value.endsWith('%')) {
      // 0% equal to -1.0
      // 50% equal to 0.0
      // 100% equal to 1.0
      return double.tryParse(value.substring(0, value.length - 1)) / 50 - 1;
    }

    switch (value) {
      case 'top':
      case 'left':
        return -1;

      case 'bottom':
      case 'right':
        return 1;

      case 'center':
      default:
        return 0;
    }
  }

  RenderImage getRenderImageBox(CSSStyleDeclaration style, ImageProvider image) {
    BoxFit fit = _getBoxFit(style['objectFit']);
    Alignment alignment = _getAlignment(style['objectPosition']);
    return RenderImage(
      image: _imageInfo?.image,
      fit: fit,
      alignment: alignment,
    );
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (key == 'src') {
      _removeImage();
    } else if (key == 'loading' && _hasLazyLoading && image == null) {
      _resetLazyLoading();
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);

    if (key == 'src') {
      _setImage();
    } else if (key == 'loading' && _hasLazyLoading) {
      // Should reset lazy when value change
      _resetLazyLoading();
    }
  }

  void _setImage() {
    String src = properties['src'];
    if (src != null && src.isNotEmpty) {
      _removeStreamListener();
      image = CSSUrl(src, cache: properties['caching']).computedValue;
      imageStream = image.resolve(ImageConfiguration.empty);
      // Store listeners for remove listener.
      imageListeners = [
        ImageStreamListener(_initImageInfo),
      ];
      imageListeners.forEach((ImageStreamListener imageListener) {
        imageStream.addListener(imageListener);
      });
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case 'width':
        {
          return this._imageInfo != null ? this._imageInfo.image.width : 0;
        }
      case 'height':
        {
          return this._imageInfo != null ? this._imageInfo.image.height : 0;
        }
    }

    return super.getProperty(key);
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    if (key == 'width' || key == 'height') {
      _resize();
    } else if (key == 'objectFit') {
      imageBox.fit = _getBoxFit(value);
    } else if (key == 'objectPosition') {
      imageBox.alignment = _getAlignment(value);
    }
  }
}
