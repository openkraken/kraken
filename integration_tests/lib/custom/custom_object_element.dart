/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken_video_player/video_player.dart';

class CustomObjectElement implements ObjectElementClient {
  ObjectElementHost objectElementHost;

  CustomObjectElement(this.objectElementHost);

  VideoPlayerController? controller;

  String? _src;

  String? get src => _src;

  set src(String? value) {
    if (_src != value) {
      bool needDispose = _src != null;
      _src = value;

      if (needDispose && controller != null) {
        controller!.dispose().then((_) {
          _createVideoBox();
        });
      } else {
        _createVideoBox();
      }
    }
  }

  Future<int> createVideoPlayer(String src) {
    Completer<int> completer = new Completer();

    if (src.startsWith('//') ||
        src.startsWith('http://') ||
        src.startsWith('https://')) {
      controller = VideoPlayerController.network(
          src.startsWith('//') ? 'https:' + src : src);
    } else if (src.startsWith('file://')) {
      controller = VideoPlayerController.file(src);
    } else {
      // Fallback to asset video
      controller = VideoPlayerController.asset(src);
    }

    _src = src;

    controller!.initialize().then((int textureId) {
      completer.complete(textureId);
    });

    return completer.future;
  }

  void addVideoBox(int textureId) {
    TextureBox box = TextureBox(textureId: textureId);
    objectElementHost.updateChildTextureBox(box);
    controller?.play();
  }

  void _createVideoBox() {
    createVideoPlayer(_src!).then((textureId) {
      addVideoBox(textureId);
      _dispatchCustomEvent();
    });
  }

  void _dispatchCustomEvent() {
    CustomEvent event = CustomEvent('customevent', CustomEventInit(detail: 'hello world'));
    objectElementHost.dispatchEvent(event);
  }

  @override
  method(String name, List args) {
    if (controller == null) {
      return;
    }

    switch (name) {
      case 'play':
        controller!.play();
        break;
      case 'pause':
        controller!.pause();
        break;
    }
  }

  @override
  void setProperty(String key, value) {
    if (key == 'src') {
      src = value.toString();
    } else if (key == 'data') {
      src = value.toString();
    } else if (key == 'loop') {
      controller!.setLooping(value == 'true' ? true : false);
    } else if (key == 'currentTime') {
      controller!.seekTo(Duration(seconds: int.parse(value)));
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case 'loop':
        return controller!.value.isLooping;
      case 'currentTime':
        return controller!.value.position.inSeconds;
      case 'src':
        return _src;
      case 'videoWidth':
        return controller!.value.size!.width;
      case 'videoHeight':
        return controller!.value.size!.height;
    }
  }

  @override
  void removeProperty(String key) {}

  @override
  void setStyle(key, value) {
  }

  @override
  Future<dynamic> initElementClient(Map<String, dynamic> properties) async {
    return null;
  }

  @override
  void dispose() {
    objectElementHost.updateChildTextureBox(null);
    controller?.pause();
    controller?.dispose();
    controller = null;
  }

  @override
  void didAttachRenderer() {}

  @override
  void didDetachRenderer() {
    controller?.pause();
    controller?.dispose();
    controller = null;
  }

  @override
  void willAttachRenderer() {
  }

  @override
  void willDetachRenderer() {
  }
}

ObjectElementClient customObjectElementFactory(ObjectElementHost host) {
  return CustomObjectElement(host);
}
