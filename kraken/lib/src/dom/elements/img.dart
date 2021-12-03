/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:ui' as ui show Image;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';

// FIXME: should be inline default.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

// The HTMLImageElement.
class ImageElement extends Element {
  // The render box to draw image.
  RenderImage? _renderImage;

  // The image source url.
  String? get _source => getProperty('src');

  ImageProvider? _imageProvider;

  ImageStream? _imageStream;

  ImageInfo? _imageInfo;

  late ImageStreamListener _renderStreamListener;

  double? _propertyWidth;
  double? _propertyHeight;

  ui.Image? get image => _imageInfo?.image;

  /// Number of image frame, used to identify multi frame image after loaded.
  int _frameCount = 0;

  bool _isInLazyLoading = false;

  bool get _shouldLazyLoading => properties['loading'] == 'lazy';

  ImageElement(EventTargetContext context)
      : super(
      context,
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
    if (_renderImage != null && _renderImage!.width != null) {
      return _renderImage!.width!;
    }

    if (renderBoxModel != null && renderBoxModel!.hasSize) {
      return renderBoxModel!.clientWidth;
    }

    // Fallback to natural width, if image is not on screen.
    return naturalWidth;
  }

  double get height {
    if (_renderImage != null && _renderImage!.height != null) {
      return _renderImage!.height!;
    }

    if (renderBoxModel != null && renderBoxModel!.hasSize) {
      return renderBoxModel!.clientHeight;
    }

    // Fallback to natural height, if image is not on screen.
    return naturalHeight;
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

    double? width = renderStyle.width.isAuto ? _propertyWidth : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? _propertyHeight : renderStyle.height.computedValue;

    if (renderStyle.width.isAuto && _propertyWidth != null) {
      // The intrinsic width of the image in pixels. Must be an integer without a unit.
      renderStyle.width = CSSLengthValue(_propertyWidth, CSSLengthType.PX);
    }
    if (renderStyle.height.isAuto && _propertyHeight != null) {
      // The intrinsic height of the image, in pixels. Must be an integer without a unit.
      renderStyle.height = CSSLengthValue(_propertyHeight, CSSLengthType.PX);
    }

    if (width == null && height == null) {
      width = naturalWidth;
      height = naturalHeight;
    } else if (width != null && height == null && naturalWidth != 0) {
      height = width * naturalHeight / naturalWidth;
    } else if (width == null && height != null && naturalHeight != 0) {
      width = height * naturalWidth / naturalHeight;
    }

    if (height == null || !height.isFinite) {
      height = 0.0;
    }

    if (width == null || !width.isFinite) {
      width = 0.0;
    }

    _renderImage?.width = width;
    _renderImage?.height = height;
    renderBoxModel!.intrinsicWidth = naturalWidth;
    renderBoxModel!.intrinsicHeight = naturalHeight;

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderBoxModel!.intrinsicRatio = null;
    } else {
      renderBoxModel!.intrinsicRatio = naturalHeight / naturalWidth;
    }
  }

  RenderImage createRenderImageBox() {
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    BoxFit objectFit = renderStyle.objectFit;
    Alignment objectPosition = renderStyle.objectPosition;

    return RenderImage(
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
      Uri base = Uri.parse(ownerDocument.controller.href);
      Uri resolvedUri = ownerDocument.controller.uriParser!.resolve(base, Uri.parse(_source!));

      ImageProvider? imageProvider = _imageProvider ?? CSSUrl.parseUrl(resolvedUri,
          cache: properties['caching'], contextId: ownerDocument.contextId);

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
        return _renderImage?.width ?? 0;
      case HEIGHT:
        return _renderImage?.height ?? 0;
      case 'naturalWidth':
        return naturalWidth;
      case 'naturalHeight':
        return naturalHeight;
    }

    return super.getProperty(key);
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH || property == HEIGHT) {
      _resize();
    } else if (property == OBJECT_FIT && _renderImage != null) {
      _renderImage!.fit = renderBoxModel!.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _renderImage != null) {
      _renderImage!.alignment = renderBoxModel!.renderStyle.objectPosition;
    }
  }
}

