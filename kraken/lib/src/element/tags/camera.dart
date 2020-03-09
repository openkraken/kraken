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
  CameraDescription cameraDescription;

  /// Element attribute width
  double _width;
  double get width => _width;
  set width(double newValue) {
    if (newValue != null) {
      _width = newValue;
      sizedBox.additionalConstraints = BoxConstraints.expand(
        width: width,
        height: height ?? width / aspectRatio,
      );
    }
  }

  /// Element attribute height
  double _height;
  double get height => _height;
  set height(double newValue) {
    if (newValue != null) {
      _height = newValue;
      sizedBox.additionalConstraints = BoxConstraints.expand(
        width: width ?? height * aspectRatio,
        height: height,
      );
    }
  }

  double get aspectRatio {
    if (width != null && height != null) {
      return width / height;
    } else if (controller != null) {
      return controller.value.aspectRatio;
    } else {
      return 1.0;
    }
  }

  ResolutionPreset _resolutionPreset;
  ResolutionPreset get resolutionPreset => _resolutionPreset;
  set resolutionPreset(ResolutionPreset value) {
    if (_resolutionPreset != value) {
      _resolutionPreset = value;
      _initCamera();
    }
  }

  void _initCamera () async {
    if (cameraDescription != null) {
      TextureBox textureBox = await createCameraTextureBox(cameraDescription);
      sizedBox.child = RenderAspectRatio(
        aspectRatio: aspectRatio,
        child: textureBox
      );
    }
  }

  void _initCameraWithLens(String lens) async {
    cameraDescription = await detectCamera(lens);
    if (cameraDescription == null) {
      sizedBox.child = buildFallbackView('Camera Fallback View');
    } else {
      this.cameraDescription = cameraDescription;
      await _initCamera();
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

    _initCameraWithLens(props['lens']);

    addChild(sizedBox);
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    if (key == 'resolution-preset') {
      resolutionPreset = getResolutionPreset(value);
    } else if (key == 'width') {
      width = Length.toDisplayPortValue(value);
    } else if (key == 'height') {
      height = Length.toDisplayPortValue(value);
    } else if (key == 'lens') {
      _initCameraWithLens(value);
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
