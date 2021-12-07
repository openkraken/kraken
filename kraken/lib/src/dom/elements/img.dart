/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ffi';
import 'dart:ui' as ui show Image;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';
const String NATURAL_WIDTH = 'naturalWidth';
const String NATURAL_HEIGHT = 'naturalHeight';

// FIXME: should be inline default.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

// The HTMLImageElement.
class ImageElement extends Element {
  // The render box to draw image.
  KrakenRenderImage? _renderImage;

  // The image source url.
  String? get _source => getProperty('src');

  ImageProvider? _imageProvider;

  ImageStream? _imageStream;

  ImageInfo? _imageInfo;

  late ImageStreamListener _renderStreamListener;

  double? _propertyWidth;
  double? _propertyHeight;

  double? _styleWidth;
  double? _styleHeight;

  ui.Image? get image => _imageInfo?.image;

  /// Number of image frame, used to identify multi frame image after loaded.
  int _frameCount = 0;

  bool _isInLazyLoading = false;

  bool get _shouldLazyLoading => properties['loading'] == 'lazy';

  ImageElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager)
      : super(
      targetId,
      nativeEventTarget,
      elementManager,
      isIntrinsicBox: true,
      defaultStyle: _defaultStyle) {
    _renderStreamListener = ImageStreamListener(_renderImageStream, onError: _onImageError);
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    // Should add image box after style has applied to ensure intersection observer
    // attached to correct renderBoxModel
    if (!_isInLazyLoading || _renderImage == null) {
      // Image dimensions (width or height) should specified for performance when lazy-load.
      if (_shouldLazyLoading) {
        _isInLazyLoading = true;

        // When detach renderer, all listeners will be cleared.
        renderBoxModel!.addIntersectionChangeListener(_handleIntersectionChange);
      } else {
        _constructImageChild();
        _loadImage();
      }
    }
    _resize();
  }

  @override
  void didDetachRenderer() async {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);

    _resetImage();

    // Unlink image render box, which has been detached.
    _renderImage = null;
  }

  void _resetImage() {
    _imageInfo = null;

    // @NOTE: Evict image cache, make multi frame image can replay.
    // https://github.com/flutter/flutter/issues/51775
    _imageProvider?.evict();
    _imageProvider = null;

    _renderImage?.image = null;
  }

  @override
  void dispose() {
    super.dispose();

    _imageProvider?.evict();
    _imageProvider = null;

    _imageStream?.removeListener(_renderStreamListener);
    _imageStream = null;

    _renderImage = null;
  }

  double get width {
    double? width = _styleWidth ?? _propertyWidth;

    if (width == null) {
      width = naturalWidth;
      double? height = _styleHeight ?? _propertyHeight;

      if (height != null && naturalHeight != 0) {
        width = height * naturalWidth / naturalHeight;
      }
    }

    return width;
  }

  double get height {
    double? height = _styleHeight ?? _propertyHeight;

    if (height == null) {
      height = naturalHeight;
      double? width = _styleWidth ?? _propertyWidth;

      if (width != null && naturalWidth != 0) {
        height = width * naturalHeight / naturalWidth;
      }
    }

    return height;
  }

  double get naturalWidth => image?.width.toDouble() ?? 0;
  double get naturalHeight => image?.height.toDouble() ?? 0;

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    // When appear
    if (entry.isIntersecting) {
      // Once appear remove the listener
      _resetLazyLoading();
      _constructImageChild();
      _loadImage();
    }
  }

  void _resetLazyLoading() {
    _isInLazyLoading = false;
    renderBoxModel!.removeIntersectionChangeListener(_handleIntersectionChange);
  }

  void _constructImageChild() {
    _renderImage = createRenderImageBox();

    if (childNodes.isEmpty) {
      addChild(_renderImage!);
    }
  }

  void _dispatchLoadEvent() {
    dispatchEvent(Event(EVENT_LOAD));
  }

  void _handleEventAfterImageLoaded() {
    // `load` event is a simple event.
    if (isConnected) {
      // If image in tree, make sure the image-box has been layout, using addPostFrameCallback.
      SchedulerBinding.instance!.scheduleFrame();
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        _dispatchLoadEvent();
      });
    } else {
      // If not in tree, dispatch the event directly.
      _dispatchLoadEvent();
    }
  }

  void _renderImageStream(ImageInfo imageInfo, bool synchronousCall) {
    _frameCount++;
    _imageInfo = imageInfo;

    // Only trigger load once.
    if (!_loaded) {
      _loaded = true;

      if (synchronousCall) {
        // `synchronousCall` happens when caches image and calling `addListener`.
        scheduleMicrotask(_handleEventAfterImageLoaded);
      } else {
        _handleEventAfterImageLoaded();
      }
    }

    if (isRendererAttached) {
      // Multi frame image should convert to repaint boundary.
      if (_frameCount > 2) {
        forceToRepaintBoundary = true;
      }
      _resize();
      _renderImage?.image = image;
    }
  }

  // Mark if the same src loaded.
  bool _loaded = false;

  void _onImageError(Object exception, StackTrace? stackTrace) {
    dispatchEvent(Event(EVENT_ERROR));
  }

  void _resize() {
    if (!isRendererAttached) {
      return;
    }

    if (_styleWidth == null && _propertyWidth != null) {
      // The intrinsic width of the image in pixels. Must be an integer without a unit.
      renderStyle.width = CSSLengthValue(_propertyWidth, CSSLengthType.PX);
    }
    if (_styleHeight == null && _propertyHeight != null) {
      // The intrinsic height of the image, in pixels. Must be an integer without a unit.
      renderStyle.height = CSSLengthValue(_propertyHeight, CSSLengthType.PX);
    }

    renderStyle.intrinsicWidth = naturalWidth;
    renderStyle.intrinsicHeight = naturalHeight;

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderStyle.intrinsicRatio = null;
    } else {
      renderStyle.intrinsicRatio = naturalHeight / naturalWidth;
    }
  }

  KrakenRenderImage createRenderImageBox() {
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    BoxFit objectFit = renderStyle.objectFit;
    Alignment objectPosition = renderStyle.objectPosition;

    return KrakenRenderImage(
      image: _imageInfo?.image,
      fit: objectFit,
      alignment: objectPosition,
    );
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (key == 'src') {
      _resetImage();
      _loaded = false;
    } else if (key == 'loading' && _isInLazyLoading && _imageProvider == null) {
      _resetLazyLoading();
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    bool propertyChanged = properties[key] != value;
    super.setProperty(key, value);
    // Reset frame number to zero when image needs to reload
    _frameCount = 0;
    if (key == 'src' && propertyChanged && !_shouldLazyLoading) {
      // Loads the image immediately.
      _loaded = false;
      _loadImage();
    } else if (key == 'loading' && _isInLazyLoading) {
      // Should reset lazy when value change.
      _resetLazyLoading();
    } else if (key == WIDTH) {
      _propertyWidth = CSSNumber.parseNumber(value);
      _resize();
    } else if (key == HEIGHT) {
      _propertyHeight = CSSNumber.parseNumber(value);
      _resize();
    }
  }

  void _loadImage() {
    _resetImage();

    if (_source != null && _source!.isNotEmpty) {
      Uri base = Uri.parse(elementManager.controller.href);
      Uri resolvedUri = elementManager.controller.uriParser!.resolve(base, Uri.parse(_source!));

      ImageProvider? imageProvider = _imageProvider ?? CSSUrl.parseUrl(resolvedUri,
          cache: properties['caching'], contextId: elementManager.contextId);

      if (imageProvider != null) {
        _imageProvider = imageProvider;
        _imageStream = imageProvider
            .resolve(ImageConfiguration.empty)
            ..addListener(_renderStreamListener);
      }
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case WIDTH:
        return width;
      case HEIGHT:
        return height;
      case NATURAL_WIDTH:
        return naturalWidth;
      case NATURAL_HEIGHT:
        return naturalHeight;
    }

    return super.getProperty(key);
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.value == null && renderStyle.width.isNotAuto
        ? null : renderStyle.width.computedValue;
      _resize();
    } else if (property == HEIGHT) {
      _styleHeight = renderStyle.height.value == null && renderStyle.height.isNotAuto
        ? null : renderStyle.height.computedValue;
      _resize();
    } else if (property == OBJECT_FIT && _renderImage != null) {
      _renderImage!.fit = renderBoxModel!.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _renderImage != null) {
      _renderImage!.alignment = renderBoxModel!.renderStyle.objectPosition;
    }
  }
}

