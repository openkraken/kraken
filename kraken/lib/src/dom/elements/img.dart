/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/painting.dart';
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
  ImageProvider? _imageProvider;

  ImageStream? _imageStream;

  ImageInfo? _imageInfo;
  Uri? _resolvedUri;

  double? _propertyWidth;
  double? _propertyHeight;

  ui.Image? get image => _imageInfo?.image;

  /// Number of image frame, used to identify multi frame image after loaded.
  int _frameCount = 0;

  bool _isListeningStream = false;
  bool _isInLazyLoading = false;
  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // A boolean value which indicates whether or not the image has completely loaded.
  bool complete = false;

  bool get _shouldLazyLoading => properties['loading'] == 'lazy';
  ImageStreamCompleterHandle? _completerHandle;

  ImageElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager)
      : super(
      targetId,
      nativeEventTarget,
      elementManager,
      isIntrinsicBox: true,
      defaultStyle: _defaultStyle) {
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
        _loadImage();
      }
    }
  }

  void _loadImage() {
    _constructImage();
    // Try to attach image if image is cached.
    _attachImage();
    _resizeImage();
    _resolveImage(_resolvedUri);
    _listenToStream();
  }

  @override
  void didDetachRenderer() async {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);

    _stopListeningStream(keepStreamAlive: true);
  }

  ImageStreamListener? _imageStreamListener;
  ImageStreamListener _getListener() {
    _imageStreamListener ??= ImageStreamListener(
      _handleImageFrame,
      onError: _onImageError
    );
    return _imageStreamListener!;
  }

  void _listenToStream() {
    if (_isListeningStream)
      return;

    _imageStream?.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningStream = true;
  }

  @override
  void dispose() {
    super.dispose();
    _stopListeningStream();
    _completerHandle?.dispose();
    _replaceImage(info: null);
    _imageProvider?.evict();
    _imageProvider = null;
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

  double get naturalWidth {
    ImageProvider? imageProvider = _imageProvider;
    if (imageProvider is KrakenResizeImage) {
      return imageProvider.naturalWidth.toDouble();
    }
    return image?.width.toDouble() ?? 0;
  }
  double get naturalHeight {
    ImageProvider? imageProvider = _imageProvider;
    if (imageProvider is KrakenResizeImage) {
      return imageProvider.naturalHeight.toDouble();
    }
    return image?.height.toDouble() ?? 0;
  }

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    // When appear
    if (entry.isIntersecting) {
      // Once appear remove the listener
      _resetLazyLoading();
      _loadImage();
    }
  }

  void _resetLazyLoading() {
    _isInLazyLoading = false;
    renderBoxModel!.removeIntersectionChangeListener(_handleIntersectionChange);
  }

  void _constructImage() {
    RenderImage image = _renderImage = _createRenderImageBox();
    addChild(image);
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

  void _onImageError(Object exception, StackTrace? stackTrace) {
    dispatchEvent(Event(EVENT_ERROR));
  }

  void _resizeImage() {
    assert(isRendererAttached);

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

    // Try to update image size if image already resolved.
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

  RenderImage _createRenderImageBox() {
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
      _stopListeningStream(keepStreamAlive: true);
    } else if (key == 'loading' && _isInLazyLoading && _imageProvider == null) {
      _resetLazyLoading();
      _stopListeningStream(keepStreamAlive: true);
    }
  }

  /// Stops listening to the image stream, if this state object has attached a
  /// listener.
  ///
  /// If the listener from this state is the last listener on the stream, the
  /// stream will be disposed. To keep the stream alive, set `keepStreamAlive`
  /// to true, which create [ImageStreamCompleterHandle] to keep the completer
  /// alive.
  void _stopListeningStream({bool keepStreamAlive = false}) {
    if (!_isListeningStream)
      return;

    if (keepStreamAlive && _completerHandle == null && _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }

    _imageStream?.removeListener(_getListener());
    _isListeningStream = false;
  }

  Uri? _resolveSrc() {
    String? src = properties['src'];
    if (src != null && src.isNotEmpty) {
      Uri base = Uri.parse(elementManager.controller.href);
      return elementManager.controller.uriParser!.resolve(base, Uri.parse(src));
    }
    return null;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) return;

    if (_isListeningStream) {
      _imageStream?.removeListener(_getListener());
    }

    _frameCount = 0;
    _imageStream = newStream;

    if (_isListeningStream) {
      _imageStream!.addListener(_getListener());
    }
  }

  void _resolveImage(Uri? resolvedUri, { bool updateImageProvider = false }) {
    if (resolvedUri == null) return;

    double? width = null;
    double? height = null;

    if (isRendererAttached) {
      width = renderStyle.width.isAuto ? _propertyWidth : renderStyle.width.computedValue;
      height = renderStyle.height.isAuto ? _propertyHeight : renderStyle.height.computedValue;
    } else {
      width = _propertyWidth;
      height = _propertyHeight;
    }

    int? cachedWidth = (width != null && width > 0) ? (width * ui.window.devicePixelRatio).toInt() : null;
    int? cachedHeight = (height != null && height > 0) ? (height * ui.window.devicePixelRatio).toInt() : null;

    ImageProvider? provider = _imageProvider;
    if (updateImageProvider || provider == null) {
      provider = _imageProvider = getImageProvider(resolvedUri, cachedWidth: cachedWidth, cachedHeight: cachedHeight);
    }
    if (provider == null) return;
    final ImageStream newStream = provider.resolve(ImageConfiguration.empty);
    _updateSourceStream(newStream);
  }

  void _replaceImage({required ImageInfo? info}) {
    _imageInfo = info;
  }

  void _attachImage() {
    assert(isRendererAttached);
    assert(_renderImage != null);
    if (_imageInfo == null) return;
    _renderImage!.image = image?.clone();
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _replaceImage(info: imageInfo);
    _frameCount++;

    if (!complete) {
      complete = true;
      if (synchronousCall) {
        // `synchronousCall` happens when caches image and calling `addListener`.
        scheduleMicrotask(_handleEventAfterImageLoaded);
      } else {
        _handleEventAfterImageLoaded();
      }
    }

    // Multi frame image should convert to repaint boundary.
    if (_frameCount > 2) {
      forceToRepaintBoundary = true;
    }

    _attachImage();
    _resizeImage();
  }

  // Prefetches an image into the image cache.
  void _precacheImage() {
    final ImageConfiguration config = ImageConfiguration.empty;
    final Uri? resolvedUri = _resolvedUri = _resolveSrc();
    if (resolvedUri == null) return;
    final ImageProvider? provider = _imageProvider = getImageProvider(resolvedUri);
    if (provider == null) return;
    _frameCount = 0;
    final ImageStream stream = provider.resolve(config);
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo? imageInfo, bool sync) {
        _replaceImage(info: imageInfo);
        _frameCount++;

        if (!complete && !_shouldLazyLoading) {
          complete = true;
          if (sync) {
            // `synchronousCall` happens when caches image and calling `addListener`.
            scheduleMicrotask(_handleEventAfterImageLoaded);
          } else {
            _handleEventAfterImageLoaded();
          }
        }
        stream.removeListener(listener!);
      },
      onError: _onImageError
    );
    stream.addListener(listener);
  }

  @override
  void setProperty(String key, dynamic value) {
    bool propertyChanged = properties[key] != value;
    super.setProperty(key, value);
    // Reset frame number to zero when image needs to reload
    if (key == 'src' && propertyChanged) {
      final Uri? resolvedUri = _resolvedUri =  _resolveSrc();
      // Update image source if image already attached.
      if (isRendererAttached) {
        _resolveImage(resolvedUri, updateImageProvider: true);
      } else {
        _precacheImage();
      }
    } else if (key == 'loading' && propertyChanged && _isInLazyLoading) {
      _resetLazyLoading();
    } else if (key == WIDTH) {
      _propertyWidth = CSSNumber.parseNumber(value);
      _resolveImage(_resolvedUri, updateImageProvider: true);
    } else if (key == HEIGHT) {
      _propertyHeight = CSSNumber.parseNumber(value);
      _resolveImage(_resolvedUri, updateImageProvider: true);
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
      // Resize renderBox
      if (isRendererAttached) _resizeImage();
      // Resize image
      _resolveImage(_resolvedUri, updateImageProvider: true);
    } else if (property == OBJECT_FIT && _renderImage != null) {
      _renderImage!.fit = renderBoxModel!.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _renderImage != null) {
      _renderImage!.alignment = renderBoxModel!.renderStyle.objectPosition;
    }
  }
}

