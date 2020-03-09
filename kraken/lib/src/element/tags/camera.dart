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

Future<CameraDescription> detectCamera(String lens) async {
  if (lens == null) lens = 'back';

  if (!camerasDetected) {
    try {
      // Obtain a list of the available cameras on the device.
      cameras = await availableCameras();
    } on CameraException catch (err) {
      // No available camera devices, need to fallback.
      print('CameraException $err');
    }
    camerasDetected = true;
  }

  for (CameraDescription description in cameras) {
    if (description.lensDirection == parseCameraLensDirection(lens)) {
      return description;
    }
  }

  return null;
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
      sizedBox.additionalConstraints = BoxConstraints.loose(Size(width, height));
    }
  }

  /// Element attribute height
  double _height = Length.toDisplayPortValue(DEFAULT_HEIGHT);
  double get height => _height;
  set height(double newValue) {
    if (newValue != null) {
      _height = newValue;
      sizedBox.additionalConstraints = BoxConstraints.loose(Size(width, height));
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
      additionalConstraints: BoxConstraints.loose(Size(width, height)),
    );

    detectCamera(props['lens']).then((CameraDescription cameraDescription) {
      if (cameraDescription == null) {
        sizedBox.child = buildFallbackView('Camera Fallback View');
      } else {
        createtCameraTextureBox(cameraDescription)
          .then((TextureBox textureBox) {
            sizedBox.child = RenderAspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: textureBox
            );
          });
      }
    });

    addChild(sizedBox);
  }

  void _takePhoto(List args) {
    // @TODO takePhoto
  }

  // @TODO: impl methods
    @override
  method(String name, List args) {
    if (controller == null) {
      return;
    }

    switch (name) {
      case 'takePhoto': return _takePhoto(args);
    }
  }
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

/// Returns the resolution preset from string.
ResolutionPreset getResolutionPreset(String preset) {
  switch (preset) {
    case 'max':
      return ResolutionPreset.max;
    case 'ultraHigh':
      return ResolutionPreset.ultraHigh;
    case 'veryHigh':
      return ResolutionPreset.veryHigh;
    case 'high':
      return ResolutionPreset.high;
    case 'low':
      return ResolutionPreset.low;
    case 'medium':
    default:
      return ResolutionPreset.medium;
  }
}
