/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/painting.dart';
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

  ImageProvider? _cachedImageProvider;
  dynamic _imageProviderKey;

  ImageStream? _cachedImageStream;
  ImageInfo? _cachedImageInfo;
  Uri? _resolvedUri;

  // Width and height set through property.
  double? _propertyWidth;
  double? _propertyHeight;

  // Width and height set through style.
  double? _styleWidth;
  double? _styleHeight;

  ui.Image? get image => _cachedImageInfo?.image;

  /// Number of image frame, used to identify multi frame image after loaded.
  int _frameCount = 0;

  bool _isListeningStream = false;
  bool _isInLazyLoading = false;
  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // A boolean value which indicates whether or not the image has completely loaded.
  bool complete = false;

  bool get _shouldLazyLoading => properties['loading'] == 'lazy';
  ImageStreamCompleterHandle? _completerHandle;

  ImageElement(EventTargetContext? context)
      : super(
      context,
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

    _cachedImageStream?.addListener(_getListener());
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
    _cachedImageProvider?.evict();
    _cachedImageProvider = null;
    _imageProviderKey = null;
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

  // Read the original image width of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.0.
  double get naturalWidth {
    ImageProvider? imageProvider = _cachedImageProvider;
    if (imageProvider is KrakenResizeImage) {
      Size? size = KrakenResizeImage.getImageNaturalSize(_imageProviderKey);
      if (size != null) {
        return size.width;
      }
    }
    return image?.width.toDouble() ?? 0;
  }

  // Read the original image height of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.0.
  double get naturalHeight {
    ImageProvider? imageProvider = _cachedImageProvider;
    if (imageProvider is KrakenResizeImage) {
      Size? size = KrakenResizeImage.getImageNaturalSize(_imageProviderKey);
      if (size != null) {
        return size.height;
      }
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

    // Try to update image size if image already resolved.
    // Set size to RenderImage is needs, to avoid makeNeedsLayout when update image.
    _renderImage?.width = width;
    _renderImage?.height = height;

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderStyle.intrinsicRatio = null;
    } else {
      renderStyle.intrinsicRatio = naturalHeight / naturalWidth;
    }
  }

  KrakenRenderImage _createRenderImageBox() {
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    BoxFit objectFit = renderStyle.objectFit;
    Alignment objectPosition = renderStyle.objectPosition;

    return KrakenRenderImage(
      image: _cachedImageInfo?.image,
      fit: objectFit,
      alignment: objectPosition,
    );
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (key == 'src') {
      _stopListeningStream(keepStreamAlive: true);
    } else if (key == 'loading' && _isInLazyLoading && _cachedImageProvider == null) {
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

    if (keepStreamAlive && _completerHandle == null && _cachedImageStream?.completer != null) {
      _completerHandle = _cachedImageStream!.completer!.keepAlive();
    }

    _cachedImageStream?.removeListener(_getListener());
    _isListeningStream = false;
  }

  Uri? _resolveSrc() {
    String? src = properties['src'];
    if (src != null && src.isNotEmpty) {
      Uri base = Uri.parse(ownerDocument.controller.href);
      return ownerDocument.controller.uriParser!.resolve(base, Uri.parse(src));
    }
    return null;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_cachedImageStream?.key == newStream.key) return;

    if (_isListeningStream) {
      _cachedImageStream?.removeListener(_getListener());
    }

    _frameCount = 0;
    _cachedImageStream = newStream;

    if (_isListeningStream) {
      _cachedImageStream!.addListener(_getListener());
    }
  }

  // Obtain image resource from resolvedUri, and create an ImageStream that loads the image streams.
  // If imageElement has propertySize or width,height properties on renderStyle,
  // The image will be encoded into a small size for better rasterization performance.
  void _resolveImage(Uri? resolvedUri, { bool updateImageProvider = false }) async {
    if (resolvedUri == null) return;

    // Try to make sure that this image can be encoded into a smaller size.
    int? cachedWidth = width > 0 && width.isFinite ? (width * ui.window.devicePixelRatio).toInt() : null;
    int? cachedHeight = height > 0 && height.isFinite ? (height * ui.window.devicePixelRatio).toInt() : null;

    ImageProvider? provider = _cachedImageProvider;
    if (updateImageProvider || provider == null) {
      // When cachedWidth or cachedHeight is not null, KrakenResizeImage will be returned.
      provider = _cachedImageProvider = getImageProvider(resolvedUri, cachedWidth: cachedWidth, cachedHeight: cachedHeight);
    }
    if (provider == null) return;

    // Cached the key of imageProvider to read naturalSize of the image.
    _imageProviderKey = await provider.obtainKey(ImageConfiguration.empty);
    final ImageStream newStream = provider.resolve(ImageConfiguration.empty);
    _updateSourceStream(newStream);
  }

  void _replaceImage({required ImageInfo? info}) {
    _cachedImageInfo = info;
  }

  // Attach image to renderImage box.
  void _attachImage() {
    assert(isRendererAttached);
    assert(_renderImage != null);
    if (_cachedImageInfo == null) return;
    _renderImage!.image = image?.clone();
  }


  // Callback when image are loaded, encoded and available to use.
  // This callback may fire multiple times when image have multiple frames (such as an animated GIF).
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

    // Multi frame image should wrap a repaint boundary for better composite performance.
    if (_frameCount > 2) {
      forceToRepaintBoundary = true;
    }

    _attachImage();
    _resizeImage();
  }

  // Prefetches an image into the image cache. When the imageElement is attached to the renderTree, the imageProvider can directly
  // obtain the cached imageStream from imageCache instead of obtaining resources from I/O.
  void _precacheImage() async {
    final ImageConfiguration config = ImageConfiguration.empty;
    final Uri? resolvedUri = _resolvedUri = _resolveSrc();
    if (resolvedUri == null) return;
    final ImageProvider? provider = _cachedImageProvider = getImageProvider(resolvedUri);
    if (provider == null) return;
    _imageProviderKey = await provider.obtainKey(ImageConfiguration.empty);
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
    if (key == 'src' && propertyChanged) {
      final Uri? resolvedUri = _resolvedUri =  _resolveSrc();
      // Update image source if image already attached except image is lazy loading.
      if (isRendererAttached && !_isInLazyLoading) {
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
    if (property == WIDTH || property == HEIGHT) {
      if (property == WIDTH) {
        double? resolveStyleWidth = renderStyle.width.value == null && renderStyle.width.isNotAuto
          ? null : renderStyle.width.computedValue;
        // To avoid resolved auto, which computed value is infinity, we can not calculate
        // infinite double as valid number, mark null to let width/height resized by decode
        // size.
        _styleWidth = resolveStyleWidth == double.infinity ? null : resolveStyleWidth;
      } else if (property == HEIGHT) {
        double? resolveStyleHeight = renderStyle.height.value == null && renderStyle.height.isNotAuto
          ? null : renderStyle.height.computedValue;
        _styleHeight = resolveStyleHeight == double.infinity ? null : resolveStyleHeight;
      }
      // Resize image
      _resolveImage(_resolvedUri, updateImageProvider: true);
    } else if (property == OBJECT_FIT && _renderImage != null) {
      _renderImage!.fit = renderBoxModel!.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _renderImage != null) {
      _renderImage!.alignment = renderBoxModel!.renderStyle.objectPosition;
    }
  }
}

