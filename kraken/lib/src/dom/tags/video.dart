/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'dart:async';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken_video_player/kraken_video_player.dart';

import 'media.dart';

const String VIDEO = 'VIDEO';

const Map<String, dynamic> _defaultStyle = {
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
};

class VideoElement extends MediaElement {
  VideoElement(int targetId, Pointer<NativeVideoElement> nativePtr, ElementManager elementManager)
      : super(
          targetId,
          nativePtr.ref.nativeMediaElement,
          elementManager,
          VIDEO,
          defaultStyle: _defaultStyle,
        );

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    renderVideo();
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _textureBox = null;

    if (controller != null) {
      controller.dispose().then((_) {
        controller = null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void renderVideo() {
    _textureBox = TextureBox(textureId: 0);
    if (childNodes.isEmpty) {
      addChild(_textureBox);
    }
  }

  TextureBox _textureBox;
  VideoPlayerController controller;

  String _src;

  String get src => _src;

  set src(String value) {
    if (_src != value) {
      bool needDispose = _src != null;
      _src = value;

      if (needDispose) {
        controller.dispose().then((_) {
          _removeVideoBox();
          _createVideoBox();
        });
      } else {
        _createVideoBox();
      }
    }
  }

  Future<int> createVideoPlayer(String src) {
    Completer<int> completer = Completer();

    if (src.startsWith('//') || src.startsWith('http://') || src.startsWith('https://')) {
      controller = VideoPlayerController.network(src.startsWith('//') ? 'https:' + src : src);
    } else if (src.startsWith('file://')) {
      controller = VideoPlayerController.file(src);
    } else {
      // Fallback to asset video
      controller = VideoPlayerController.asset(src);
    }

    _src = src;

    controller.setLooping(properties.containsKey('loop'));
    controller.onCanPlay = onCanPlay;
    controller.onCanPlayThrough = onCanPlayThrough;
    controller.onPlay = onPlay;
    controller.onPause = onPause;
    controller.onSeeked = onSeeked;
    controller.onSeeking = onSeeking;
    controller.onEnded = onEnded;
    controller.onError = onError;
    controller.initialize().then((int textureId) {
      if (properties.containsKey('muted')) {
        controller.setMuted(true);
      }

      completer.complete(textureId);
    });

    return completer.future;
  }

  void addVideoBox(int textureId) {
    if (properties['src'] == null) {
      return;
    }

    TextureBox box = TextureBox(textureId: textureId);

    addChild(box);

    if (properties.containsKey('autoplay')) {
      controller.play();
    }
  }

  void _createVideoBox() {
    createVideoPlayer(_src).then(addVideoBox);
  }

  void _removeVideoBox() {
    (renderBoxModel as RenderIntrinsic).child = null;
  }

  onCanPlay() async {
    Event event = Event(EVENT_CAN_PLAY, EventInit());
    dispatchEvent(event);
  }

  onCanPlayThrough() async {
    Event event = Event(EVENT_CAN_PLAY_THROUGH, EventInit());
    dispatchEvent(event);
  }

  onEnded() async {
    Event event = Event(EVENT_ENDED, EventInit());
    dispatchEvent(event);
  }

  onError(int code, String error) {
    Event event = MediaError(code, error);
    dispatchEvent(event);
  }

  onPause() async {
    Event event = Event(EVENT_PAUSE, EventInit());
    dispatchEvent(event);
  }

  onPlay() async {
    Event event = Event(EVENT_PLAY, EventInit());
    dispatchEvent(event);
  }

  onSeeked() async {
    Event event = Event(EVENT_SEEKED, EventInit());
    dispatchEvent(event);
  }

  onSeeking() async {
    Event event = Event(EVENT_SEEKING, EventInit());
    dispatchEvent(event);
  }

  onVolumeChange() async {
    Event event = Event(EVENT_VOLUME_CHANGE, EventInit());
    dispatchEvent(event);
  }

  @override
  void play() {
    controller.play();
  }

  @override
  void pause() {
    controller.pause();
  }

  @override
  void fastSeek(double duration) {
    controller.seekTo(Duration(seconds: duration.toInt()));
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    if (key == 'src') {
      src = value.toString();
    } else if (key == 'loop') {
      controller.setLooping(value == 'true' ? true : false);
    } else if (key == 'currentTime') {
      controller.seekTo(Duration(seconds: int.parse(value)));
    }
  }

  @override
  dynamic getProperty(String key) {
    switch (key) {
      case 'loop':
        return controller.value.isLooping;
      case 'currentTime':
        return controller.value.position.inSeconds;
      case 'src':
        return _src;
      case 'videoWidth':
        return controller.value.size.width;
      case 'videoHeight':
        return controller.value.size.height;
    }

    return super.getProperty(key);
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    switch (key) {
      case 'loop':
        controller.setLooping(false);
        break;
      case 'muted':
        controller.setMuted(false);
        break;
    }
  }
}
