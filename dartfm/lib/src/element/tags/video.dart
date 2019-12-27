/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken_video_player/kraken_video_player.dart';

const String VIDEO = 'VIDEO';
const String DEFAULT_WIDTH = '300px';
const String DEFAULT_HEIGHT = '150px';

class VideoElement extends Element {
  VideoPlayerController controller;
  String _src;

  static void setDefaultPropsStyle(Map<String, dynamic> props) {
    if (props['style'] == null) {
      props['style'] = Map<String, dynamic>();
    }

    if (props['style']['width'] == null) {
      props['style']['width'] = DEFAULT_WIDTH;
    }

    if (props['style']['height'] == null) {
      props['style']['height'] = DEFAULT_HEIGHT;
    }
  }

  VideoElement(int nodeId, Map<String, dynamic> props, List<String> events)
      : super(
          nodeId: nodeId,
          defaultDisplay: 'block',
          tagName: VIDEO,
          properties: props,
          events: events,
        ) {
    RegExp exp = new RegExp(r"^(http|https)://");

    if (props['src'] == null) {
      TextureBox box = TextureBox(textureId: 0);
      addChild(box);
      return;
    }

    if (!exp.hasMatch(props['src'])) {
      throw new Exception('video url\'s prefix should be http:// or https://');
    }

    controller = VideoPlayerController.network(props['src']);
    _src = props['src'];

    controller.setLooping(props['loop'] ?? false);

    controller.onCanPlay = onCanPlay;
    controller.onCanPlayThrough = onCanPlayThrough;
    controller.onPlay = onPlay;
    controller.onPause = onPause;
    controller.onSeeked = onSeeked;
    controller.onSeeking = onSeeking;
    controller.onEnded = onEnded;
    controller.onError = onError;
    controller.initialize().then((int textureId) {
      controller.setMuted(props['muted'] ?? false);
      TextureBox box = TextureBox(textureId: textureId);
      addChild(box);

      if (props['autoPlay'] == true) {
        controller.play();
      }
    });
  }

  Future<Map<String, dynamic>> getVideoDetail() async {
    final Completer<Map<String, dynamic>> detailCompleter = Completer<Map<String, dynamic>>();
    RendererBinding.instance.addPostFrameCallback((Duration timeout) {
      var value = controller.value;
      var duration = value.duration;

      if (renderLayoutElement.firstChild != null) {
        Size size = (renderLayoutElement.firstChild as RenderBox).size;
        detailCompleter.complete({
          'videoWidth': size.width,
          'videoHeight': size.height,
          'src': _src,
          'duration': '${duration.inSeconds}',
          'volume': value.volume,
          'position': value.position.inSeconds,
          'paused': !value.isPlaying,
        });
      }
    });
    return detailCompleter.future;
  }

  onCanPlay() async {
    Event event = Event('canplay', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onCanPlayThrough() async {
    Event event = Event('canplaythrough', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onEnded() async {
    Event event = Event('ended', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onError(int code, String error) {
    Event event = Event('error', EventInit());
    event.detail = {
      'code': code,
      'message': error
    };
    dispatchEvent(event);
  }

  onPause() async {
    Event event = Event('pause', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onPlay() async {
    Event event = Event('play', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onSeeked() async {
    Event event = Event('seeked', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onSeeking() async {
    Event event = Event('seeking', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  onVolumeChange() async {
    Event event = Event('volumechange', EventInit());
    event.detail = await getVideoDetail();
    dispatchEvent(event);
  }

  @override
  dynamic method(String name, List<dynamic> args) {
    if (controller == null) {
      return;
    }

    switch(name) {
      case 'play':
        controller.play();
        break;
      case 'pause':
        controller.pause();
        break;
      case 'muted':
        controller.setMuted(args[0]);
    }
  }
}
