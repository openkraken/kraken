/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/rendering.dart';


const String IMAGE = 'IMG';
const String NATURAL_WIDTH = 'naturalWidth';
const String NATURAL_HEIGHT = 'naturalHeight';
const String LOADING = 'loading';
const String SCALING = 'scaling';
const String LAZY = 'lazy';
const String SCALE = 'scale';

// FIXME: should be inline default.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

// The HTMLImageElement.
class ImageElement extends Element {
  // The render box to draw image.
  KrakenRenderImage? _renderImage;

  ui.ImageDescriptor? _currentImageDescriptor;
  ImageProvider? _currentImageProvider;

  ImageStream? _cachedImageStream;
  ImageInfo? _cachedImageInfo;

  _ImageRequest? _currentRequest;
  _ImageRequest? _pendingRequest;

  // Current image source.
  Uri? _resolvedUri;

  // Current image data([ui.Image]).
  ui.Image? get image => _cachedImageInfo?.image;

  /// Number of image frame, used to identify multi frame image after loaded.
  int _frameCount = 0;

  bool _isListeningStream = false;

  bool get _isInLazyLoading {
    RenderReplaced? renderReplaced;
    if (renderBoxModel != null) {
      renderReplaced = renderBoxModel as RenderReplaced;
    }
    return renderReplaced != null && renderReplaced.isInLazyRendering;
  }

  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // A boolean value which indicates whether or not the image has completely loaded.
  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // The IDL attribute complete must return true if any of the following conditions is true:
  // 1. Both the src attribute and the srcset attribute are omitted.
  // 2. The srcset attribute is omitted and the src attribute's value is the empty string.
  // 3. The img element's current request's state is completely available and its pending request is null.
  // 4. The img element's current request's state is broken and its pending request is null.
  bool get complete {
    // @TODO: Implement the srcset.
    if (src.isEmpty) return true;
    if (_currentRequest != null && _currentRequest!.available && _pendingRequest == null) return true;
    if (_currentRequest != null && _currentRequest!.state == _ImageRequestState.broken && _pendingRequest == null) return true;
    return true;
  }

  // The attribute directs the user agent to fetch a resource immediately or to defer fetching
  // until some conditions associated with the element are met, according to the attribute's
  // current state.
  // https://html.spec.whatwg.org/multipage/urls-and-fetching.html#lazy-loading-attributes
  bool get _shouldLazyLoading => getAttribute(LOADING) == LAZY;

  // Custom attribute defined by Kraken, used to scale the origin image down to fit the box model
  // to reduce the image size which will save the image painting time significantly when the image
  // size is too large.
  //
  // Note this attribute should be set with caution cause scaling the image size will invalidate
  // the image cache when width or height is changed and add more images to the cache.
  // So the best practice to improve image painting performance is scaling the image manually before
  // used in source code rather than relying Kraken to do the scaling job.
  bool get _shouldScaling => getAttribute(SCALING) == SCALE;

  ImageStreamCompleterHandle? _completerHandle;

  ImageElement([BindingContext? context])
      : super(
      context,
      isReplacedElement: true,
      defaultStyle: _defaultStyle) {
  }

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'src': return src;
      case 'loading': return loading;
      case 'width': return width;
      case 'height': return height;
      case 'scaling': return scaling;
      case 'naturalWidth': return naturalWidth;
      case 'naturalHeight': return naturalHeight;
      case 'complete': return complete;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'src': src = castToType<String>(value); break;
      case 'loading': loading = castToType<String>(value); break;
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
      case 'scaling': scaling = castToType<String>(value); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'src': src = attributeToProperty<String>(value); break;
      case 'loading': loading = attributeToProperty<String>(value); break;
      case 'width': width = attributeToProperty<int>(value); break;
      case 'height': height = attributeToProperty<int>(value); break;
      case 'scaling': scaling = attributeToProperty<String>(value); break;
    }
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
        RenderReplaced renderReplaced = renderBoxModel! as RenderReplaced;
        renderReplaced.isInLazyRendering = true;

        // When detach renderer, all listeners will be cleared.
        renderReplaced.addIntersectionChangeListener(_handleIntersectionChange);
      } else {
        _loadImage();
      }
    }
  }

  void _loadImage() {
    _constructImage();
    // Try to attach image if image is cached.
    _attachImage();
    _decode();
    _listenToStream();
  }

  @override
  void didDetachRenderer() async {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);

    _stopListeningStream(keepStreamAlive: true);

    _currentImageProvider?.evict();
    _currentImageProvider = null;

    _cachedImageInfo?.dispose();
    _cachedImageInfo = null;

    _renderImage?.dispose();
    _renderImage = null;

  }

  ImageStreamListener? _imageStreamListener;
  ImageStreamListener get _listener => _imageStreamListener ??= ImageStreamListener(_handleImageFrame, onError: _onImageError);

  void _listenToStream() {
    if (_isListeningStream)
      return;

    _cachedImageStream?.addListener(_listener);
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningStream = true;
  }

  @override
  void dispose() {
    super.dispose();
    _stopListeningStream();
    _completerHandle?.dispose();
    _completerHandle = null;
    _replaceImage(info: null);
    _currentImageProvider?.evict();
    _currentImageProvider = null;
  }

  // Width and height set through style declaration.
  double? get _styleWidth {
    String width = style.getPropertyValue(WIDTH);
    if (width.isNotEmpty) {
      CSSLengthValue len = CSSLength.parseLength(width, renderStyle, WIDTH);
      return len.computedValue;
    }
  }

  double? get _styleHeight {
    String height = style.getPropertyValue(HEIGHT);
    if (height.isNotEmpty) {
      CSSLengthValue len = CSSLength.parseLength(height, renderStyle, HEIGHT);
      return len.computedValue;
    }
  }

  // Width and height set through attributes.
  double? get _attrWidth {
    if (hasAttribute(WIDTH)) {
      return CSSLength.toDouble(getAttribute(WIDTH));
    }
  }

  double? get _attrHeight {
    if (hasAttribute(HEIGHT)) {
      return CSSLength.toDouble(getAttribute(HEIGHT));
    }
  }

  int get width {
    // Width calc priority: style > attr > intrinsic.
    final double borderBoxWidth = _styleWidth
      ?? _attrWidth
      ?? renderStyle.getWidthByIntrinsicRatio();

    return borderBoxWidth.round();
  }

  int get height {
    // Height calc priority: style > attr > intrinsic.
    final double borderBoxHeight = _styleHeight
      ?? _attrHeight
      ?? renderStyle.getHeightByIntrinsicRatio();

    return borderBoxHeight.round();
  }

  // Read the original image width of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int get naturalWidth => _currentImageDescriptor?.width ?? 0;

  // Read the original image height of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int get naturalHeight => _currentImageDescriptor?.height ?? 0;

  void _handleIntersectionChange(IntersectionObserverEntry entry) {
    // When appear
    if (entry.isIntersecting) {
      // Once appear remove the listener
      _removeIntersectionChangeListener();
      _loadImage();
    }
  }

  void _removeIntersectionChangeListener() {
    renderBoxModel!.removeIntersectionChangeListener(_handleIntersectionChange);
  }

  void _constructImage() {
    RenderImage image = _renderImage = _createRenderImageBox();
    addChild(image);
  }

  void _dispatchLoadEvent() {
    dispatchEvent(Event(EVENT_LOAD));
  }

  void _dispatchErrorEvent() {
    dispatchEvent(Event(EVENT_ERROR));
  }

  void _onImageError(Object exception, StackTrace? stackTrace) {
    print('$exception\n$stackTrace');
    dispatchEvent(Event(EVENT_ERROR));
  }

  void _resizeImage() {
    // Only need to resize image after image is fully loaded.
    if (!complete) return;

    if (_styleWidth == null && _attrWidth != null) {
      // The intrinsic width of the image in pixels. Must be an integer without a unit.
      renderStyle.width = CSSLengthValue(_attrWidth, CSSLengthType.PX);
    }
    if (_styleHeight == null && _attrHeight != null) {
      // The intrinsic height of the image, in pixels. Must be an integer without a unit.
      renderStyle.height = CSSLengthValue(_attrHeight, CSSLengthType.PX);
    }

    renderStyle.intrinsicWidth = naturalWidth.toDouble();
    renderStyle.intrinsicHeight = naturalHeight.toDouble();

    // Try to update image size if image already resolved.
    // Set size to RenderImage is needs, to avoid makeNeedsLayout when update image.
    _renderImage?.width = width.toDouble();
    _renderImage?.height = height.toDouble();

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderStyle.intrinsicRatio = null;
    } else {
      renderStyle.intrinsicRatio = naturalHeight / naturalWidth;
    }
  }

  KrakenRenderImage _createRenderImageBox() {
    return KrakenRenderImage(
      image: _cachedImageInfo?.image,
      fit: renderStyle.objectFit,
      alignment: renderStyle.objectPosition,
    );
  }

  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    if (key == 'src') {
      _stopListeningStream(keepStreamAlive: true);
    } else if (key == 'loading' && _isInLazyLoading && _currentImageProvider == null) {
      _removeIntersectionChangeListener();
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

    _cachedImageStream?.removeListener(_listener);
    _imageStreamListener = null;
    _isListeningStream = false;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_cachedImageStream?.key == newStream.key) return;

    if (_isListeningStream) {
      _cachedImageStream?.removeListener(_listener);
    }

    _frameCount = 0;
    _cachedImageStream = newStream;

    if (_isListeningStream) {
      _cachedImageStream!.addListener(_listener);
    }
  }

  // https://html.spec.whatwg.org/multipage/images.html#decoding-images
  // Create an ImageStream that decodes the obtained image.
  // If imageElement has property size or width/height property on [renderStyle],
  // The image will be encoded into a small size for better rasterization performance.
  void _decode({ bool updateImageProvider = false }) {
    _ImageRequest? request = _currentRequest;
    if (request != null && request.available) {
      ImageProvider? provider = _currentImageProvider;
      if (updateImageProvider || provider == null) {
        // Image should be resized based on different ratio according to object-fit value.
        BoxFit objectFit = renderStyle.objectFit;
        provider = _currentImageProvider = BoxFitImage(descriptor: _currentImageDescriptor!, boxFit: objectFit);
      }

      // Try to make sure that this image can be encoded into a smaller size.
      int? cachedWidth = width > 0 && width.isFinite ? (width * ui.window.devicePixelRatio).toInt() : null;
      int? cachedHeight = height > 0 && height.isFinite ? (height * ui.window.devicePixelRatio).toInt() : null;
      ImageConfiguration imageConfiguration = _shouldScaling && cachedWidth != null && cachedHeight != null
          ? ImageConfiguration(size: Size(cachedWidth.toDouble(), cachedHeight.toDouble()))
          : ImageConfiguration.empty;
      _updateSourceStream(provider.resolve(imageConfiguration));
    }
  }

  void _replaceImage({required ImageInfo? info}) {
    _cachedImageInfo?.dispose();
    _cachedImageInfo = info;

    if (_currentRequest?.state != _ImageRequestState.completelyAvailable) {
      _currentRequest?.state = _ImageRequestState.completelyAvailable;
      scheduleMicrotask(() => _dispatchLoadEvent());
    }
  }

  // Attach image to renderImage box.
  void _attachImage() {
    assert(isRendererAttached);
    assert(_renderImage != null);
    if (_cachedImageInfo == null) return;
    _renderImage!.image = _cachedImageInfo!.image.clone();
  }

  // Callback when image are loaded, encoded and available to use.
  // This callback may fire multiple times when image have multiple frames (such as an animated GIF).
  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _replaceImage(info: imageInfo);
    _frameCount++;

    // Multi frame image should wrap a repaint boundary for better composite performance.
    if (_frameCount > 2) {
      forceToRepaintBoundary = true;
    }

    if (renderBoxModel != null) {
      RenderReplaced renderReplaced = renderBoxModel! as RenderReplaced;
      renderReplaced.isInLazyRendering = false;
    }

    // Image may be detached when image frame loaded.
    if (!isRendererAttached) return;

    _attachImage();
    _resizeImage();
  }

  String get scaling => getAttribute(SCALING) ?? '';
  set scaling(String value) {
    internalSetAttribute(SCALING, value);
  }

  String get src => _resolvedUri?.toString() ?? '';
  set src(String value) {
    internalSetAttribute('src', value);
    _resolveResourceUri(value);

    _updateImageData();
  }

  // https://html.spec.whatwg.org/multipage/images.html#update-the-image-data
  void _updateImageData() async {
    await _obtainImage();

    // Update image source if image already attached except image is lazy loading.
    if (!_isInLazyLoading) {
      _listenToStream();
      _decode(updateImageProvider: true);
    }
  }

  // To load the resource, and dispatch load event.
  // https://html.spec.whatwg.org/multipage/images.html#when-to-obtain-images
  Future<_ImageRequest> _obtainImage() async {
    _ImageRequest request = _currentRequest = _ImageRequest(currentUri: _resolvedUri!);
    try {
      _currentImageDescriptor = await request._obtainImage(contextId);
    } catch (error) {
      _dispatchErrorEvent();
    } finally {
      return request;
    }
  }

  String get loading => getAttribute(LOADING) ?? '';
  set loading(String value) {
    internalSetAttribute(SCALING, value);
    if (_isInLazyLoading) {
      _removeIntersectionChangeListener();
    }
  }

  set width(int value) {
    if (value.isNegative) value = 0;
    internalSetAttribute(WIDTH, value.toString());
    if (_shouldScaling) {
      _decode(updateImageProvider: true);
    } else {
      _resizeImage();
    }
  }

  set height(int value) {
    if (value.isNegative) value = 0;
    internalSetAttribute(HEIGHT, value.toString());
    if (_shouldScaling) {
      _decode(updateImageProvider: true);
    } else {
      _resizeImage();
    }
  }

  void _resolveResourceUri(String src) {
    String base = ownerDocument.controller.url;
    try {
      _resolvedUri = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(src));
    } catch (_) {
      // Ignoring the failure of resolving, but to remove the resolved hyperlink.
      _resolvedUri = null;
    }
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH || property == HEIGHT) {
      // Resize image
      if (_shouldScaling) {
        _decode(updateImageProvider: true);
      } else {
        _resizeImage();
      }
    } else if (property == OBJECT_FIT && _renderImage != null) {
      _renderImage!.fit = renderBoxModel!.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _renderImage != null) {
      _renderImage!.alignment = renderBoxModel!.renderStyle.objectPosition;
    }
  }
}

// https://html.spec.whatwg.org/multipage/images.html#images-processing-model
enum _ImageRequestState {
  // The user agent hasn't obtained any image data, or has obtained some or
  // all of the image data but hasn't yet decoded enough of the image to get
  // the image dimensions.
  unavailable,

  // The user agent has obtained some of the image data and at least the
  // image dimensions are available.
  partiallyAvailable,

  // The user agent has obtained all of the image data and at least the image
  // dimensions are available.
  completelyAvailable,

  // The user agent has obtained all of the image data that it can, but it
  // cannot even decode the image enough to get the image dimensions (e.g.
  // the image is corrupted, or the format is not supported, or no data
  // could be obtained).
  broken,
}

// https://html.spec.whatwg.org/multipage/images.html#image-request
class _ImageRequest {
  _ImageRequest({
    required this.currentUri,
    this.state = _ImageRequestState.unavailable,
  });

  /// The request uri.
  Uri currentUri;

  /// Current state of image request.
  _ImageRequestState state;

  /// When an image request's state is either partially available or completely available,
  /// the image request is said to be available.
  bool get available => state == _ImageRequestState.completelyAvailable
      || state == _ImageRequestState.partiallyAvailable;

  Future<ui.ImageDescriptor> _obtainImage(int? contextId) async {
    final KrakenBundle bundle = KrakenBundle.fromUrl(currentUri.toString());
    await bundle.resolve(contextId);

    if (!bundle.isResolved) {
      throw FlutterError('Failed to load $currentUri');
    }

    final Uint8List data = bundle.data!;

    // Free the bundle memory.
    bundle.dispose();

    // Decode size of raw image.
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data);
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(buffer);

    // State available at least the image dimensions are available.
    if (descriptor.width != 0 && descriptor.height != 0) {
      state = _ImageRequestState.partiallyAvailable;
    } else {
      state = _ImageRequestState.broken;
    }

    buffer.dispose();
    return descriptor;
  }
}
