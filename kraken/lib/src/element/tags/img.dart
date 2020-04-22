/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/style.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';

class ImgElement extends Element {
  ImageProvider image;
  RenderDecoratedBox imageBox;
  ImageStream imageStream;
  List<ImageStreamListener> imageListeners;
  ImageInfo _imageInfo;

  ImgElement(int nodeId, Map<String, dynamic> props, List<String> events)
      : super(
            nodeId: nodeId,
            defaultDisplay: 'inline-block',
            allowChildren: false,
            tagName: IMAGE,
            properties: props,
            events: events);

  void afterConstruct() {
    _renderImage();
  }

  bool get _hasWidthAndHeight {
    return style.contains('width') && style.contains('height');
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
      _setImageBox();
    }
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    // When appear
    if (entry.isIntersecting) {
      _setImageBox();
      // Once appear remove the listener
      _resetLazyLoading();
    }
  }

  void _resetLazyLoading() {
    _hasLazyLoading = false;
    renderIntersectionObserver.removeListener(_handleIntersectionChange);
  }

  void _setImageBox() {
    String src = properties['src'];
    if (src != null && src.isNotEmpty) {
      if (src.startsWith('//') || src.startsWith('http://') || src.startsWith('https://')) {
        src = src.startsWith('//') ? 'https:' + src : src;
        // @TODO: caching also works after image downloaded
        String caching = properties['caching'];
        if (caching == 'store' || caching == 'auto') {
          image = CachedNetworkImage(src);
        } else {
          image = NetworkImage(src);
        }
      } else if (src.startsWith('file://')) {
        image = FileImage(File.fromUri(Uri.parse(src)));
      } else {
        // Fallback to asset image
        image = AssetImage(src);
      }
      _constructImageChild();
    }
  }

  void _removeImageBox() {
    image = null;
    imageBox = null;
    renderPadding.child = null;
  }

  void _constructImageChild() {
    imageBox = getRenderDecoratedBox(style, image);

    imageStream = image.resolve(imageBox.configuration);
    // Store listeners for remove listener.
    imageListeners = [
      ImageStreamListener(_initImageInfo),
      ImageStreamListener(_handleEventAfterImageLoaded),
    ];
    imageListeners.forEach((ImageStreamListener imageListener) {
      imageStream.addListener(imageListener);
    });

    if (childNodes.isEmpty) {
      addChild(imageBox);
    }
  }

  void _handleEventAfterImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    dispatchEvent(Event('load'));
  }

  void _initImageInfo(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;

    if (!_hasWidthAndHeight) {
      _resize();
    }
  }

  void _resize() {
    // Not to resize while image is not loaded.
    if (_imageInfo == null) return;

    imageListeners?.forEach((ImageStreamListener imageListener) {
      imageStream.removeListener(imageListener);
    });
    imageListeners = null;

    BoxConstraints constraints;
    double realWidth = _imageInfo.image.width + 0.0;
    double realHeight = _imageInfo.image.height + 0.0;
    double width = 0.0;
    double height = 0.0;
    bool containWidth = style.contains('width');
    bool containHeight = style.contains('height');

    if (!containWidth && !containHeight) {
      constraints = BoxConstraints.tightFor(
        width: realWidth,
        height: realHeight,
      );
    } else {
      if (containWidth) {
        width = getDisplayPortedLength(style['width']);
        height = width * realHeight / realWidth;
      } else if (containHeight) {
        height = getDisplayPortedLength(style['height']);
        width = height * realWidth / realHeight;
      }
      constraints = BoxConstraints.tightFor(
        width: width,
        height: height,
      );
    }
    renderConstrainedBox.additionalConstraints = constraints;
  }

  BoxConstraints getBoxConstraintsFromStyle(StyleDeclaration style) {
    double width = getDisplayPortedLength(style['width']);
    double height = getDisplayPortedLength(style['height']);
    return BoxConstraints.tightFor(width: width, height: height);
  }

  BoxFit _getBoxFit(StyleDeclaration style) {
    String fit = style['objectFit'];
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

  Alignment _getAlignment(StyleDeclaration style) {
    // Syntax: object-position: <position>
    // position: From one to four values that define the 2D position of the element. Relative or absolute offsets can be used.
    // <position> = [ [ left | center | right ] || [ top | center | bottom ] | [ left | center | right | <length-percentage> ] [ top | center | bottom | <length-percentage> ]? | [ [ left | right ] <length-percentage> ] && [ [ top | bottom ] <length-percentage> ] ]
    String objectPosition = style['objectPosition'];
    List<String> splitted = baseGetShorttedProperties(objectPosition);
    if (splitted.length == 1) {
      double value = _getAlignmentValueFromString(splitted.first);
      return Alignment(value, value);
    } else if (splitted.length > 1) {
      return Alignment(
          _getAlignmentValueFromString(splitted[0]),
          _getAlignmentValueFromString(splitted[1])
      );
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


  RenderDecoratedBox getRenderDecoratedBox(StyleDeclaration style, ImageProvider image) {
    BoxFit fit = _getBoxFit(style);
    Alignment alignment = _getAlignment(style);
    return RenderDecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: fit,
          alignment: alignment,
        ),
      ),
      position: DecorationPosition.foreground,
    );
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (key == 'src') {
      _removeImageBox();
    } else if (key == 'loading' && _hasLazyLoading && image == null) {
      _resetLazyLoading();
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);

    if (key == 'src') {
      _renderImage();
    } else if (key == 'loading' && _hasLazyLoading) {
      // Should reset lazy when value change
      _resetLazyLoading();
      _renderImage();
    }
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    _resize();
  }
}
