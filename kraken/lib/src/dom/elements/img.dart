/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/bridge.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:collection';

const String IMAGE = 'IMG';

final RegExp _numExp = RegExp(r"^\d+");

bool _isNumberString(String str) {
  return _numExp.hasMatch(str);
}

// FIXME: shoud be inline default
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

final Pointer<NativeFunction<GetImageWidth>> nativeGetImageWidth =  Pointer.fromFunction(ImageElement.getImageWidth, 0.0);
final Pointer<NativeFunction<GetImageHeight>> nativeGetImageHeight =  Pointer.fromFunction(ImageElement.getImageHeight, 0.0);
final Pointer<NativeFunction<GetImageWidth>> nativeGetImageNaturalWidth =  Pointer.fromFunction(ImageElement.getImageNaturalWidth, 0.0);
final Pointer<NativeFunction<GetImageHeight>> nativeGetImageNaturalHeight =  Pointer.fromFunction(ImageElement.getImageNaturalHeight, 0.0);

class ImageElement extends Element {
  String _source;
  ImageProvider _image;
  RenderImage _imageBox;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  double _propertyWidth;
  double _propertyHeight;
  ImageStreamListener _initImageListener;
  ImageStreamListener _renderStreamListener;

  /// Number of image frame, used to identify gif after image loaded
  int _frameNumber = 0;

  bool _isInLazyLoading = false;

  bool get _shouldLazyLoading {
    return properties['loading'] == 'lazy';
  }

  // Whether is multiframe image
  bool isMultiframe = false;

  static SplayTreeMap<int, ImageElement> _nativeMap = SplayTreeMap();

  static Element getImageElementOfNativePtr(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement element = _nativeMap[nativeImageElement.address];
    assert(element != null, 'Can not get element from nativeElement: $nativeImageElement');
    return element;
  }

  static double getImageWidth(Pointer<NativeImgElement> nativeImageElement) {
    ImageElement imageElement = getImageElementOfNativePtr(nativeImageElement);
    return imageElement.width;
  }

  static double getImageHeight(Pointer<NativeImgElement> nativeImageElement) {
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

  final Pointer<NativeImgElement> nativeImgElement;

  ImageElement(int targetId, this.nativeImgElement, ElementManager elementManager)
      : super(
        targetId,
        nativeImgElement.ref.nativeElement,
        elementManager,
        isIntrinsicBox: true,
        tagName: IMAGE,
        defaultStyle: _defaultStyle) {
    _renderStreamListener = ImageStreamListener(_renderImageStream);
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
    _renderImage();
    _resize();
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _removeStreamListener();
    _image = null;
    _imageBox = null;
    _imageStream = null;
    _nativeMap.remove(nativeImgElement.address);
  }

  double get width {
    if (_imageBox != null) {
      return _imageBox.width;
    }

    if (renderBoxModel != null && renderBoxModel.hasSize) {
      return renderBoxModel.clientWidth;
    }

    return 0.0;
  }

  double get height {
    if (_imageBox != null) {
      return _imageBox.height;
    }

    if (renderBoxModel != null && renderBoxModel.hasSize) {
      return renderBoxModel.clientHeight;
    }

    return 0.0;
  }

  double get naturalWidth {
    if (_imageInfo != null && _imageInfo.image != null) {
      return _imageInfo.image.width.toDouble();
    }
    return 0.0;
  }

  double get naturalHeight {
    if (_imageInfo != null && _imageInfo.image != null) {
      return _imageInfo.image.height.toDouble();
    }
    return 0.0;
  }

  void _renderImage() {
    if (_isInLazyLoading) return;
    // Image dimensions(width/height) should specified for performance when lazy-load.
    if (_shouldLazyLoading) {
      _isInLazyLoading = true;
      renderBoxModel.addIntersectionChangeListener(_handleIntersectionChange);
    } else {
      _constructImageChild();
    }
  }

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
    renderBoxModel.removeIntersectionChangeListener(_handleIntersectionChange);
  }

  void _removeImage() {
    _removeStreamListener();
    _image = null;
    _imageBox.image = null;
  }

  void _constructImageChild() {
    _imageBox = createRenderImageBox();

    if (childNodes.isEmpty) {
      addChild(_imageBox);
    }
  }

  void _handleEventAfterImageLoaded() {
    // `load` event is a simple event.
    if (isConnected) {
      // If image in tree, make sure the image-box has been layout, using addPostFrameCallback.
      SchedulerBinding.instance.scheduleFrame();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        dispatchEvent(Event(EVENT_LOAD));
      });
    } else {
      // If not in tree, dispatch the event directly.
      dispatchEvent(Event(EVENT_LOAD));
    }
  }

  void _initImageInfo(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;

    if (synchronousCall) {
      // `synchronousCall` happens when caches image and calling `addListener`.
      scheduleMicrotask(_handleEventAfterImageLoaded);
    } else {
      _handleEventAfterImageLoaded();
    }

    // Only trigger `initImageListener` once.
    if (_initImageListener != null) {
      _imageStream?.removeListener(_initImageListener);
    }
  }

  void _renderImageStream(ImageInfo imageInfo, bool synchronousCall) {
    _frameNumber++;
    _imageInfo = imageInfo;
    _imageBox?.image = _imageInfo?.image;

    // @HACK Flutter image cache will cause image steam listener to trigger twice when page reload
    // so use two frames to tell multiframe image from static image, note this optimization will fail
    // at multiframe image with only two frames which is not common
    isMultiframe = _frameNumber > 2;

    if (shouldConvertToRepaintBoundary) {
      convertToRepaintBoundary();
    } else {
      convertToNonRepaintBoundary();
    }

    _resize();
  }

  // Delay image size setting to next frame to make sure image has been layouted
  // to wait for percentage size to be calculated correctly in the case of image has been cached
  bool _hasImageLayoutCallbackPending = false;
  void _handleImageResizeAfterLayout() {
    if (_hasImageLayoutCallbackPending) return;
    _hasImageLayoutCallbackPending = true;
    SchedulerBinding.instance.scheduleFrame();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _hasImageLayoutCallbackPending = false;
      _resize();
    });
  }

  void _resize() {
    if (!isRendererAttached) {
      return _handleImageResizeAfterLayout();
    }

    RenderStyle renderStyle = renderBoxModel.renderStyle;
    // Waiting for size computed after layout stage
    if (style.contains(WIDTH) && renderStyle.width == null ||
        style.contains(HEIGHT) && renderStyle.height == null) {
      return _handleImageResizeAfterLayout();
    }

    double width = renderStyle.width ?? _propertyWidth;
    double height = renderStyle.height ?? _propertyHeight;

    if (renderStyle.width == null && _propertyWidth != null) {
      renderBoxModel.renderStyle.updateSizing(WIDTH, _propertyWidth);
    }
    if (renderStyle.height == null && _propertyHeight != null) {
      renderBoxModel.renderStyle.updateSizing(HEIGHT, _propertyHeight);
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

    _imageBox?.width = width;
    _imageBox?.height = height;
    renderBoxModel.intrinsicWidth = naturalWidth;
    renderBoxModel.intrinsicHeight = naturalHeight;

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderBoxModel.intrinsicRatio = null;
    } else {
      renderBoxModel.intrinsicRatio = naturalHeight / naturalWidth;
    }
  }

  void _removeStreamListener() {
    _imageStream?.removeListener(_renderStreamListener);

    if (_initImageListener != null) {
      _imageStream?.removeListener(_initImageListener);
    }
    _imageStream = null;
  }

  RenderImage createRenderImageBox() {
    RenderStyle renderStyle = renderBoxModel.renderStyle;
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
      _removeImage();
    } else if (key == 'loading' && _isInLazyLoading && _image == null) {
      _resetLazyLoading();
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    double viewportWidth = elementManager.viewportWidth;
    double viewportHeight = elementManager.viewportHeight;
    Size viewportSize = Size(viewportWidth, viewportHeight);

    // Reset frame number to zero when image needs to reload
    _frameNumber = 0;
    if (key == 'src' && !_shouldLazyLoading) {
      // Loads the image immediately.
      _loadImage();
    } else if (key == 'loading' && _isInLazyLoading) {
      // Should reset lazy when value change.
      _resetLazyLoading();
    } else if (key == WIDTH) {
      if (value is String && _isNumberString(value)) {
        value += 'px';
      }

      _propertyWidth = CSSLength.toDisplayPortValue(value, viewportSize);
      _resize();
    } else if (key == HEIGHT) {
      if (value is String && _isNumberString(value)) {
        value += 'px';
      }

      _propertyHeight = CSSLength.toDisplayPortValue(value, viewportSize);
      _resize();
    }
  }

  void _loadImage() {
    String source = properties['src'];
    if (_source == null || _source != source) {
      _source = source;
      if (source != null && source.isNotEmpty) {
        _removeStreamListener();
        _image = CSSUrl.parseUrl(source, cache: properties['caching']);
        _imageStream = _image.resolve(ImageConfiguration.empty);
        _imageStream.addListener(_renderStreamListener);

        _initImageListener = ImageStreamListener(_initImageInfo);
        _imageStream.addListener(_initImageListener);
      }
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case WIDTH:
        if (_imageBox != null) {
          return _imageBox.width;
        }
        return 0;
      case HEIGHT:
        if (_imageBox != null) {
          return _imageBox.height;
        }
        return 0;
    }

    return super.getProperty(key);
  }

  void _stylePropertyChanged(String property, String original, String present) {
    if (property == WIDTH || property == HEIGHT) {
      _resize();
    } else if (property == OBJECT_FIT && _imageBox != null) {
      _imageBox.fit = renderBoxModel.renderStyle.objectFit;
    } else if (property == OBJECT_POSITION && _imageBox != null) {
      _imageBox.alignment = renderBoxModel.renderStyle.objectPosition;
    }
  }
}
