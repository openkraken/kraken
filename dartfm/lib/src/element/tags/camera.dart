/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken_video_player/kraken_video_player.dart';
import 'package:camera/camera.dart';

const String CAMERA = 'CAMERA';

class CameraParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCameraBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CameraParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CameraParentData> {
  RenderCameraBox({
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

class CameraElement extends Element {
  CameraController controller;
  String _src;

  static String DEFAULT_WIDTH = '300px';
  static String DEFAULT_HEIGHT = '150px';

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

  CameraElement(int nodeId, Map<String, dynamic> props, List<String> events)
      : super(
          nodeId: nodeId,
          defaultDisplay: 'block',
          tagName: CAMERA,
          properties: props,
          events: events,
        ) {
    RegExp exp = RegExp(r"^(http|https)://");
    test();
    if (props['src'] == null) {
      TextureBox box = TextureBox(textureId: 0);
      addChild(box);
      return;
    }

    if (!exp.hasMatch(props['src'])) {
      throw Exception('video url\'s prefix should be http:// or https://');
    }

//    controller = VideoPlayerController.network(props['src']);
    _src = props['src'];

//    controller.setLooping(props['loop'] ?? false);

//    controller.onCanPlay = onCanPlay;
//    controller.onCanPlayThrough = onCanPlayThrough;
//    controller.onPlay = onPlay;
//    controller.onPause = onPause;
//    controller.onSeeked = onSeeked;
//    controller.onSeeking = onSeeking;
//    controller.onEnded = onEnded;
//    controller.onError = onError;
//    controller.initialize().then((int textureId) {
//      controller.setMuted(props['muted'] ?? false);
//      TextureBox box = TextureBox(textureId: textureId);
//
//      // @TODO get video's original dimension if width or height not specified as web
//      BoxConstraints additionalConstraints = BoxConstraints(
//        minWidth: 0,
//        maxWidth: getDisplayPortedLength(props['style']['width']),
//        minHeight: 0,
//        maxHeight: getDisplayPortedLength(props['style']['height']),
//      );
//      RenderCameraBox renderCameraBox = RenderCameraBox(
//        additionalConstraints: additionalConstraints,
//        child: box,
//      );
//      addChild(renderCameraBox);
//
//      if (props['autoPlay'] == true) {
//        controller.play();
//      }
//    });
  }

  Future<void> test() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    print('cameras $cameras');
  }

  @override
  dynamic method(String name, List<dynamic> args) {
    if (controller == null) {
      return;
    }

    switch (name) {
      case 'play':
//        controller.play();
        break;
    }
  }
}
