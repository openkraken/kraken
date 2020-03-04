/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken_video_player/kraken_video_player.dart';

const String VIDEO = 'VIDEO';

class VideoParentData extends ContainerBoxParentData<RenderBox> {}

class RenderVideoBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, VideoParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, VideoParentData> {
  RenderVideoBox({
    this.child,
    this.additionalConstraints,
  }) : assert(child != null) {
    add(child);
  }

  RenderBox child;
  BoxConstraints additionalConstraints;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! VideoParentData) {
      child.parentData = VideoParentData();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child.layout(additionalConstraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}

class VideoElement extends Element {
  VideoPlayerController controller;
  String _src;

  static const String DEFAULT_WIDTH = '300px';
  static const String DEFAULT_HEIGHT = '150px';

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

  VideoElement(this.nodeId, this.props, this.events)
      : super(
          nodeId: nodeId,
          defaultDisplay: 'block',
          tagName: VIDEO,
          properties: props,
          events: events,
        ) {
    addVideoBox();
  }

  int nodeId;
  Map<String, dynamic> props;
  List<String> events;

  void addVideoBox() {
    RegExp exp = RegExp(r"^(http|https)://");

    if (props['src'] == null) {
      TextureBox box = TextureBox(textureId: 0);
      addChild(box);
      return;
    }

    if (!exp.hasMatch(props['src'])) {
      throw Exception('video url\'s prefix should be http:// or https://');
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

      // @TODO get video's original dimension if width or height not specified as web
      BoxConstraints additionalConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: getDisplayPortedLength(props['style']['width']),
        minHeight: 0,
        maxHeight: getDisplayPortedLength(props['style']['height']),
      );
      RenderVideoBox videoBox = RenderVideoBox(
        additionalConstraints: additionalConstraints,
        child: box,
      );
      addChild(videoBox);

      if (props['autoPlay'] == true) {
        controller.play();
      }
    });
  }

  void removeVideoBox() {
    renderLayoutElement.removeAll();
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
    event.detail = {'code': code, 'message': error};
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

    switch (name) {
      case 'play':
        controller.play();
        break;
      case 'pause':
        controller.pause();
        break;
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src' || key == '.style.width' || key == '.style.height') {
      removeVideoBox();
      addVideoBox();
    }
  }
}
