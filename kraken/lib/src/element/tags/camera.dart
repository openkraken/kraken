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

bool camerasDetected = false;
List<CameraDescription> cameras = [];

Future<void> detectCameras() async {
  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();
  camerasDetected = true;
}

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
    if (child.parentData is! CameraParentData) {
      child.parentData = CameraParentData();
    }
  }

  @override
  void performResize() {
    size = constraints.smallest;
    assert(size.isFinite);
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
  RenderCameraBox renderCameraBox;
  bool enableAudio = false;

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
    initCameraController()
      .then((_) async {
        print('initCameraController initizeld.');
      });
  }

  Future<void> initCameraController() async {
    if (!camerasDetected) await detectCameras();
    if (cameras.isEmpty) {
      throw FlutterError('No avaiable camera in your device.');
    }

    CameraDescription cameraDescription = cameras.first;

    if (controller != null) await controller.dispose();

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      renderCameraBox?.markNeedsPaint();
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (renderCameraBox != null) renderLayoutElement.remove(renderCameraBox);
    renderCameraBox = RenderCameraBox(
      child: TextureBox(textureId: controller.getTextureId()),
      additionalConstraints: BoxConstraints(
        minWidth: 0,
        maxWidth: style.width,
        minHeight: 0,
        maxHeight: style.height,
      ),
    );
    print('textureId: ${controller.getTextureId()}');
    addChild(renderCameraBox);

    renderCameraBox.markNeedsPaint();
  }

  @override
  method(String name, List args) {
    if (controller == null) {
      return;
    }

    switch (name) {
      case 'play':
        break;
    }
  }
}
