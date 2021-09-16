/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:ui' as ui show Image;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

const String IMAGE = 'IMG';

final RegExp _numExp = RegExp(r'^\d+');

// FIXME: should be inline default.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

final Pointer<NativeFunction<GetImageWidth>> nativeGetImageWidth =  Pointer.fromFunction(ImageElement.getImageWidth, 0.0);
final Pointer<NativeFunction<GetImageHeight>> nativeGetImageHeight =  Pointer.fromFunction(ImageElement.getImageHeight, 0.0);
final Pointer<NativeFunction<GetImageWidth>> nativeGetImageNaturalWidth =  Pointer.fromFunction(ImageElement.getImageNaturalWidth, 0.0);
final Pointer<NativeFunction<GetImageHeight>> nativeGetImageNaturalHeight =  Pointer.fromFunction(ImageElement.getImageNaturalHeight, 0.0);

// The HTMLImageElement.
class ImageElement extends Element {
  static final SplayTreeMap<int, ImageElement> _nativeMap = SplayTreeMap();

  static ImageElement getImageElementOfNativePtr(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement? element = _nativeMap[nativeImageElement.address];
    if (element == null) throw FlutterError('Can not get element from nativeElement: $nativeImageElement');
    return element;
  }

  static double? getImageWidth(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement imageElement = getImageElementOfNativePtr(nativeImageElement);
    return imageElement.width;
  }

  static double? getImageHeight(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement imageElement = getImageElementOfNativePtr(nativeImageElement);
    return imageElement.height;
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/naturalWidth
  static double getImageNaturalWidth(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement imageElement = getImageElementOfNativePtr(nativeImageElement);
    return imageElement.naturalWidth;
  }

  static double getImageNaturalHeight(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement imageElement = getImageElementOfNativePtr(nativeImageElement);
    return imageElement.naturalHeight;
  }

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

  final Pointer<NativeImgElement> nativeImgElement;

  ImageElement(int targetId, this.nativeImgElement, ElementManager elementManager)
      : super(
      targetId,
      nativeImgElement.ref.nativeElement,
      elementManager,
      isIntrinsicBox: true,
      tagName: IMAGE,
      defaultStyle: _defaultStyle) {
    _renderStreamListener = ImageStreamListener(_renderImageStream, onError: _onImageError);
    _nativeMap[nativeImgElement.address] = this;

    nativeImgElement.ref.getImageWidth = nativeGetImageWidth;
    nativeImgElement.ref.getImageHeight = nativeGetImageHeight;
    nativeImgElement.ref.getImageNaturalWidth = nativeGetImageNaturalWidth;
    nativeImgElement.ref.getImageNaturalHeight = nativeGetImageNaturalHeight;
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

    _removeStreamListener();
    _renderImage?.image = null;
  }

  @override
  void dispose() {
    super.dispose();

    _imageProvider?.evict();
    _imageProvider = null;

    _removeStreamListener();

    _renderImage = null;

    _nativeMap.remove(nativeImgElement.address);
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

  void _handleEventAfterImageLoaded() {
    // `load` event is a simple event.
    if (isConnected) {
      // If image in tree, make sure the image-box has been layout, using addPostFrameCallback.
      SchedulerBinding.instance!.scheduleFrame();
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        dispatchEvent(Event(EVENT_LOAD));
      });
    } else {
      // If not in tree, dispatch the event directly.
      dispatchEvent(Event(EVENT_LOAD));
    }
  }

  // Multi frame image should convert to repaint boundary.
  @override
  bool get shouldConvertToRepaintBoundary => _frameCount > 2 || super.shouldConvertToRepaintBoundary;

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

    // @HACK Flutter image cache will cause image steam listener to trigger twice when page reload
    // so use two frames to tell multi frame image from static image, note this optimization will fail
    // at multi frame image with only two frames which is not common.
    if (shouldConvertToRepaintBoundary) {
      convertToRepaintBoundary();
    } else {
      convertToNonRepaintBoundary();
    }

    _resize();
    _renderImage?.image = image;
  }

  // Mark if the same src loaded.
  bool _loaded = false;

  void _onImageError(Object exception, StackTrace? stackTrace) {
    // @TODO: Native side support error event.
    // https://github.com/openkraken/kraken/issues/686
    // dispatchEvent(Event(EVENT_ERROR));
  }

  // Delay image size setting to next frame to make sure image has been layouted
  // to wait for percentage size to be calculated correctly in the case of image has been cached
  bool _hasImageLayoutCallbackPending = false;
  void _handleImageResizeAfterLayout() {
    if (_hasImageLayoutCallbackPending) return;
    _hasImageLayoutCallbackPending = true;
    SchedulerBinding.instance!.scheduleFrame();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _hasImageLayoutCallbackPending = false;
      _resize();
    });
  }

  void _resize() {
    if (!isRendererAttached) {
      return;
    }

    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    // Waiting for size computed after layout stage
    if (style.contains(WIDTH) && renderStyle.width == null ||
        style.contains(HEIGHT) && renderStyle.height == null) {
      return _handleImageResizeAfterLayout();
    }

    double? width = renderStyle.width ?? _propertyWidth;
    double? height = renderStyle.height ?? _propertyHeight;

    if (renderStyle.width == null && _propertyWidth != null) {
      renderBoxModel!.renderStyle.updateSizing(WIDTH, _propertyWidth);
    }
    if (renderStyle.height == null && _propertyHeight != null) {
      renderBoxModel!.renderStyle.updateSizing(HEIGHT, _propertyHeight);
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

  void _removeStreamListener() {
    _imageStream?.removeListener(_renderStreamListener);
    _imageStream = null;
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
    double? rootFontSize;
    double? fontSize;
    if (renderBoxModel != null) {
      rootFontSize = renderBoxModel!.elementDelegate.getRootElementFontSize();
      fontSize = renderBoxModel!.renderStyle.fontSize;
    }

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
      if (value is String && _isNumber(value)) {
        value += 'px';
      }

      _propertyWidth = CSSLength.toDisplayPortValue(
        value,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      );
      _resize();
    } else if (key == HEIGHT) {
      if (value is String && _isNumber(value)) {
        value += 'px';
      }

      _propertyHeight = CSSLength.toDisplayPortValue(
        value,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      );
      _resize();
    }
  }

  void _loadImage() {
    _resetImage();

    if (_source != null) {
      _removeStreamListener();

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
        return _renderImage?.width ?? 0;
      case HEIGHT:
        return _renderImage?.height ?? 0;
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

// Return true if the input string only contain numbers.
bool _isNumber(String input) {
  return _numExp.hasMatch(input);
}
