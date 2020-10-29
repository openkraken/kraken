/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'dart:async';

const String IMAGE = 'IMG';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE_BLOCK};

bool _isNumber(String str) {
  RegExp regExp = RegExp(r"^\d+$");
  return regExp.hasMatch(str);
}

class ImageElement extends Element {
  ImageProvider image;
  RenderImage imageBox;
  ImageStream imageStream;
  List<ImageStreamListener> imageListeners;
  ImageInfo _imageInfo;

  double _propertyWidth;
  double _propertyHeight;

  ImageElement(int targetId, ElementManager elementManager)
      : super(
        targetId,
        elementManager,
        defaultStyle: _defaultStyle,
        isIntrinsicBox: true,
        tagName: IMAGE) {
    _renderImage();
  }

  bool _hasLazyLoading = false;

  void _renderImage() {
    if (_hasLazyLoading) return;
    String loading = properties['loading'];
    // Image dimensions(width/height) should specified for performance when lazy-load.
    if (loading == 'lazy') {
      _hasLazyLoading = true;
      renderBoxModel.addIntersectionChangeListener(_handleIntersectionChange);
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
    renderBoxModel.removeIntersectionChangeListener(_handleIntersectionChange);
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
    // img load event should trigger asynchronously to make sure load event had bind.
    Timer.run(() {
      dispatchEvent(Event('load'));
    });
  }

  void _initImageInfo(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    imageBox.image = _imageInfo?.image;
    _handleEventAfterImageLoaded(imageInfo, synchronousCall);
    _removeStreamListener();
    _resize();

    // Image size may affect parent layout,
    // make parent relayout after image init.
    imageBox.markNeedsLayoutForSizedByParentChange();
  }

  void _resize() {
    if (isRendererAttached) {
      double naturalWidth = (_imageInfo?.image?.width ?? 0.0) + 0.0;
      double naturalHeight = (_imageInfo?.image?.height ?? 0.0) + 0.0;
      double width = 0.0;
      double height = 0.0;
      bool containWidth = style.contains(WIDTH) || _propertyWidth != null;
      bool containHeight = style.contains(HEIGHT) || _propertyHeight != null;
      if (!containWidth && !containHeight) {
        width = naturalWidth;
        height = naturalHeight;
      } else {
        if (containWidth && containHeight) {
          width = renderBoxModel.width ?? _propertyWidth;
          height = renderBoxModel.height ?? _propertyHeight;
        } else if (containWidth) {
          width = renderBoxModel.width ?? _propertyWidth;
          if (naturalWidth != 0) {
            height = width * naturalHeight / naturalWidth;
          }
        } else if (containHeight) {
          height = renderBoxModel.height ?? _propertyHeight;
          if (naturalHeight != 0) {
            width = height * naturalWidth / naturalHeight;
          }
        }
      }

      if (!height.isFinite) {
        height = 0.0;
      }
      if (!width.isFinite) {
        width = 0.0;
      }

      imageBox?.width = width;
      imageBox?.height = height;
      renderBoxModel.intrinsicWidth = naturalWidth;
      renderBoxModel.intrinsicHeight = naturalHeight;

      if (naturalWidth == 0.0 || naturalHeight == 0.0) {
        renderBoxModel.intrinsicRatio = null;
      } else {
        renderBoxModel.intrinsicRatio = naturalHeight / naturalWidth;
      }
    }
  }

  void _removeStreamListener() {
    if (imageListeners != null) {
      for (ImageStreamListener imageListener in imageListeners) {
        imageStream?.removeListener(imageListener);
      }
    }
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

    if (position != null) {
      List<String> values = CSSStyleProperty.getPositionValues(position);
      return Alignment(_getAlignmentValueFromString(values[0]), _getAlignmentValueFromString(values[1]));
    }

    // The default value for object-position is 50% 50%
    return Alignment.center;
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
    BoxFit fit = _getBoxFit(style[OBJECT_FIT]);
    Alignment alignment = _getAlignment(style[OBJECT_POSITION]);
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
      // Should reset lazy when value change.
      _resetLazyLoading();
    } else if (key == 'width') {
      if (value is String && _isNumber(value)) {
        value += 'px';
      }

      _propertyWidth = CSSLength.toDisplayPortValue(value);
      _resize();
    } else if (key == HEIGHT) {
      if (value is String && _isNumber(value)) {
        value += 'px';
      }

      _propertyHeight = CSSLength.toDisplayPortValue(value);
      _resize();
    }
  }

  void _setImage() {
    String src = properties['src'];
    if (src != null && src.isNotEmpty) {
      _removeStreamListener();
      image = CSSUrl.parseUrl(src, cache: properties['caching']);
      imageStream = image.resolve(ImageConfiguration.empty);

      ImageStreamListener imageListener = ImageStreamListener(_initImageInfo);
      imageStream.addListener(imageListener);

      // Store listeners for remove listener.
      imageListeners = [
        imageListener,
      ];
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case WIDTH:
        return _imageInfo != null ? _imageInfo.image.width : 0;
      case HEIGHT:
        return _imageInfo != null ? _imageInfo.image.height : 0;
    }

    return super.getProperty(key);
  }

  @override
  void setStyle(String key, dynamic value) {
    super.setStyle(key, value);
    if (key == WIDTH || key == HEIGHT) {
      _resize();
    } else if (key == OBJECT_FIT) {
      imageBox.fit = _getBoxFit(value);
    } else if (key == OBJECT_POSITION) {
      imageBox.alignment = _getAlignment(value);
    }
  }
}
