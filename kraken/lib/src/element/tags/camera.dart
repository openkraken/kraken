/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:camera/camera.dart';

const String CAMERA = 'CAMERA';

bool camerasDetected = false;
List<CameraDescription> cameras = [];

Future<void> detectCameras() async {
  // Obtain a list of the available cameras on the device.
  try {
    cameras = await availableCameras();
  } on CameraException catch (_) {
    // No available camera devices, need to fallback.
  }
  camerasDetected = true;
}


class CameraElement extends Element with CameraPreviewMixin {
  static String DEFAULT_WIDTH = '300px';
  static String DEFAULT_HEIGHT = '150px';

  bool enableAudio = false;
  RenderConstrainedBox sizedBox;

  /// Element attribute width
  double _width = Length.toDisplayPortValue(DEFAULT_WIDTH);
  double get width => _width;
  set width(double newValue) {
    if (newValue != null) {
      _width = newValue;
      sizedBox.additionalConstraints = BoxConstraints.tight(Size(width, height));
    }
  }

  /// Element attribute height
  double _height = Length.toDisplayPortValue(DEFAULT_HEIGHT);
  double get height => _height;
  set height(double newValue) {
    if (newValue != null) {
      _height = newValue;
      sizedBox.additionalConstraints = BoxConstraints.tight(Size(width, height));
    }
  }

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
    sizedBox = RenderConstrainedBox(
      additionalConstraints: BoxConstraints.tight(Size(width, height)),
    );

    if (cameras.isEmpty) {
      sizedBox.child = buildFallbackView('Camera Fallback View');
    } else {
      createtCameraTextureBox(cameras.first)
        .then((TextureBox textureBox) {
          sizedBox.child = textureBox;
        });
    }
    addChild(sizedBox);
  }


  // @TODO: impl methods
  //  @override
  //  method(String name, List args) {
  //    if (controller == null) {
  //      return;
  //    }
  //  }
}

RenderBox buildFallbackView(String description) {
  assert(description != null);

  TextSpan text = TextSpan(
    text: description,
    style: const TextStyle(
      backgroundColor: WebColor.white,
      color: WebColor.black,
    ),
  );

  return RenderFallbackViewBox(
    child: RenderParagraph(
      text,
      textDirection: TextDirection.ltr,
    ),
  );
}
