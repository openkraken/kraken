/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/launcher.dart';

const String ANIMATION_PLAYER = 'ANIMATION-PLAYER';
const String ANIMATION_TYPE_FLARE = 'flare';

final Map<String, dynamic> _defaultStyle = {
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

final Pointer<NativeFunction<Native_PlayAnimation>> nativePlay = Pointer.fromFunction(AnimationPlayerElement._play);

// Ref: https://github.com/LottieFiles/lottie-player
class AnimationPlayerElement extends Element {
  static void _play(int contextId, int targetId, Pointer<NativeString> name, double mix, double mixSeconds) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget animationPlayerElement = controller.view.getEventTargetById(targetId);
    if (animationPlayerElement is AnimationPlayerElement) {
      animationPlayerElement.play(nativeStringToString(name), mix, mixSeconds);
    }
  }

  RenderObject _animationRenderObject;
  FlareControls _animationController;

  AnimationPlayerElement(int targetId, Pointer<NativeAnimationElement> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr.ref.nativeElement, elementManager, tagName: ANIMATION_PLAYER, defaultStyle: _defaultStyle, isIntrinsicBox: true, repaintSelf: true) {
    nativePtr.ref.play = nativePlay;
  }

  String get objectFit => style[OBJECT_FIT];

  // Default type to flare
  String get type => properties['type'] ?? ANIMATION_TYPE_FLARE;

  String get src => properties['src'];

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();

    _animationRenderObject = _createFlareRenderObject();
    if (_animationRenderObject != null) {
      addChild(_animationRenderObject);
    }
  }

  @override
  void didDetachRenderer() {
    _animationRenderObject = null;
  }

  void _updateRenderObject() {
    if (isConnected && isRendererAttached) {
      RenderObject prev = previousSibling?.renderer;

      detach();
      attachTo(parent, after: prev);
    }
  }

  void play(String name, [double mix = 1.0, double mixSeconds = 0.2]) {
    _animationController?.play(name, mix: mix, mixSeconds: mixSeconds);
  }

  void _updateObjectFit() {
    if (_animationRenderObject is FlareRenderObject) {
      FlareRenderObject renderBox = _animationRenderObject;
      renderBox?.fit = _getObjectFit();
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    _updateRenderObject();
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    if (key == OBJECT_FIT) {
      _updateObjectFit();
    }
  }

  BoxFit _getObjectFit() {
    switch (objectFit) {
      case 'fill':
        return BoxFit.fill;
        break;
      case 'cover':
        return BoxFit.cover;
        break;
      case 'fit-height':
        return BoxFit.fitHeight;
        break;
      case 'fit-width':
        return BoxFit.fitWidth;
        break;
      case 'scale-down':
        return BoxFit.scaleDown;
        break;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }

  FlareRenderObject _createFlareRenderObject() {
    if (src == null) {
      return null;
    }

    BoxFit boxFit = _getObjectFit();
    _animationController = FlareControls();

    return FlareRenderObject()
      ..assetProvider = AssetFlare(bundle: NetworkAssetBundle(Uri.parse(src)), name: '')
      ..fit = boxFit
      ..alignment = Alignment.center
      ..animationName = properties['name']
      ..shouldClip = false
      ..useIntrinsicSize = true
      ..controller = _animationController;
  }
}
