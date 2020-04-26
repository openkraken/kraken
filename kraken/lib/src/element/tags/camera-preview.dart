/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:kraken_camera/camera.dart';

const String CAMERA = 'CAMERA-PREVIEW';

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

class CameraPreviewElement extends Element {
  static const String DEFAULT_WIDTH = '300px';
  static const String DEFAULT_HEIGHT = '150px';

  bool enableAudio = false;
  bool isFallback = false;
  RenderConstrainedBox sizedBox;
  CameraDescription cameraDescription;
  TextureBox renderTextureBox;
  CameraController controller;
  List<VoidCallback> detectedFunc = [];

  void waitUntilReady(VoidCallback fn) {
    detectedFunc.add(fn);
  }

  void _invokeReady() {
    for (VoidCallback fn in detectedFunc) fn();
    detectedFunc = [];
  }

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
    double _aspectRatio = 1.0;
    if (width != null && height != null) {
      _aspectRatio = width / height;
    } else if (controller != null) {
      _aspectRatio = controller.value.aspectRatio;
    }

    // sensorOrientation can be [0, 90, 180, 270],
    // while 90 / 270 is reverted to width and height.
    if ((cameraDescription?.sensorOrientation ?? 0 / 90) % 2 == 1) {
      _aspectRatio = 1 / _aspectRatio;
    }
    return _aspectRatio;
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
      _invokeReady();
      sizedBox.child = RenderAspectRatio(
        aspectRatio: aspectRatio,
        child: textureBox
      );
    }
  }

  void _initCameraWithLens(String lens) async {
    cameraDescription = await detectCamera(lens);
    if (cameraDescription == null) {
      isFallback = true;
      _invokeReady();
      sizedBox.child = buildFallbackView('Camera Fallback View');
    } else {
      await _initCamera();
    }
  }


  RenderBox buildFallbackView(String description) {
    assert(description != null);

    TextStyle style = getTextStyle(StyleDeclaration()).copyWith(backgroundColor: WebColor.white);
    return RenderFallbackViewBox(
      child: RenderParagraph(
        TextSpan(text: description, style: style),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  void afterConstruct() {
    var props = properties;
    _initCameraWithLens(props['lens']);

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

  CameraPreviewElement(int targetId, Map<String, dynamic> props, List<String> events)
      : super(
          targetId: targetId,
          defaultDisplay: 'block',
          tagName: CAMERA,
          properties: props,
          events: events,
        ) {
    sizedBox = RenderConstrainedBox(
      additionalConstraints: BoxConstraints.loose(Size(
        Length.toDisplayPortValue(DEFAULT_WIDTH),
        Length.toDisplayPortValue(DEFAULT_HEIGHT),
      )),
    );

    style.addStyleChangeListener('width', _widthChangedListener);
    style.addStyleChangeListener('height', _heightChangedListener);
    addChild(sizedBox);
  }

  Future<TextureBox> createCameraTextureBox(CameraDescription cameraDescription) async{
    this.cameraDescription = cameraDescription;
    await _createCameraController();
    return TextureBox(textureId: controller.textureId);
  }

  Future<void> _createCameraController({
    ResolutionPreset resoluton = ResolutionPreset.medium,
    bool enableAudio = false,
  }) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      resoluton,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (isConnected) {
        renderLayoutBox.markNeedsPaint();
      }
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (err) {
      print('Error while initializing camera controller: $err');
    }
  }

  @override
  void setProperty(String key, value) async {
    super.setProperty(key, value);

    if (isFallback || controller != null) {
      _setProperty(key, value);
    } else {
      waitUntilReady(() {
        _setProperty(key, value);
      });
    }
  }

  void _widthChangedListener(String key, String original, String present) {
    // Trigger width setter to invoke rerender.
    width = Length.toDisplayPortValue(present);
  }

  void _heightChangedListener(String key, String original, String present) {
    // Trigger height setter to invoke rerender.
    height = Length.toDisplayPortValue(present);
  }

  void _setProperty(String key, value) {
    if (key == 'resolution-preset') {
      resolutionPreset = getResolutionPreset(value);
    } else if (key == 'width') {
      // <camera-preview width="300" />
      // Width and height is united with pixel.
      value = value.toString() + 'px';
      width = Length.toDisplayPortValue(value);
    } else if (key == 'height') {
      value = value.toString() + 'px';
      height = Length.toDisplayPortValue(value);
    } else if (key == 'lens') {
      _initCameraWithLens(value);
    } else if (key == 'sensor-orientation') {
      _updateSensorOrientation(value);
    }
  }

  void _updateSensorOrientation(value) async {
    int sensorOrientation = Number(value.toString()).toInt();
    cameraDescription = cameraDescription.copyWith(
      sensorOrientation: sensorOrientation
    );
    await _initCamera();
  }
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
