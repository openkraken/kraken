/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';

class ImgElement extends Element {
  ImageProvider image;
  RenderDecoratedBox imageBox;
  RenderConstrainedBox imageConstrainedBox;
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
            events: events) {
    addImgBox();
  }

  void addImgBox() {
    String url = _getFormattedSourceURL(properties['src']);
    if (url.isNotEmpty) {
      if (properties['caching'] == 'store' || properties['caching'] == 'auto') {
        image = CacheImage(url);
      } else {
        image = NetworkImage(url);
      }
      _constructImageChild();
    }
  }

  void removeImgBox() {
    renderPadding.child = null;
  }

  void _constructImageChild() {
    imageBox = getRenderDecoratedBox(style, image);

    if (!determinBothWidthAndHeight) {
      imageStream = image.resolve(imageBox.configuration);
      imageListeners = [
        ImageStreamListener(initImageInfo),
        ImageStreamListener(handleEventAfterImageLoaded),
      ];
      imageListeners.forEach((ImageStreamListener imageListener) {
        imageStream.addListener(imageListener);
      });
    }

    if (childNodes.isEmpty) {
      addChild(imageBox);
    }
  }

  bool get determinBothWidthAndHeight {
    return style.contains('width') && style.contains('height');
  }

  String _getFormattedSourceURL(String url) {
    if (url == null) url = '';
    if (url.startsWith('//')) return 'https:' + url;
    return url;
  }

  void handleEventAfterImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    dispatchEvent(Event('load'));
  }

  void initImageInfo(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    _resize();
  }

  void _resize() {
    if (_imageInfo == null) {
      return;
    }
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

  RenderDecoratedBox getRenderDecoratedBox(StyleDeclaration style, ImageProvider image) {
    BoxFit fit = _getBoxFit(style);
    return RenderDecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: fit,
        ),
      ),
      position: DecorationPosition.foreground,
    );
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (key == 'src') {
      image = null;
      imageBox = null;
      imageConstrainedBox.child = null;
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      removeImgBox();
      addImgBox();
    }
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    _resize();
  }
}
