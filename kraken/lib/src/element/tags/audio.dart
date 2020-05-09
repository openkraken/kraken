import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken_audioplayers/kraken_audioplayers.dart';

const String AUDIO = 'AUDIO';

class AudioElement extends Element with StandaloneElementSizedMixin {
  AudioPlayer audioPlayer;
  String audioSrc;
  RenderConstrainedBox _sizedBox;

  static double defaultWidth = 300.0;
  static double defaultHeight = 150.0;

  AudioElement(int targetId, Map<String, dynamic> props, List<String> events)
      : super(
          targetId: targetId,
          defaultDisplay: 'inline-block',
          allowChildren: false,
          tagName: AUDIO,
          properties: props,
          events: events,
        ) {
    initAudioPlayer();
    initSizedBox();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();

    RegExp exp = RegExp(r'^(http|https)://');
    if (properties['src'] != null && !exp.hasMatch(properties['src'])) {
      throw Exception('audio url\'s prefix should be http:// or https://');
    }
    audioSrc = properties['src'];
  }

  void initSizedBox() {
    _sizedBox = RenderConstrainedBox(
      additionalConstraints: BoxConstraints.tight(Size(defaultWidth, defaultHeight)),
    );
    addChild(_sizedBox);
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    switch (key) {
      case WIDTH:
      case HEIGHT:
        _updateSizedBox();
        break;
    }
  }

  void _updateSizedBox() {
    double w = style.contains(WIDTH) ? CSSLength.toDisplayPortValue(style[WIDTH]) : null;
    double h = style.contains(HEIGHT) ? CSSLength.toDisplayPortValue(style[HEIGHT]) : null;
    _sizedBox.additionalConstraints = BoxConstraints.tight(
      Size(w ?? defaultWidth, h ?? defaultHeight)
    );
  }

  @override
  method(String name, List args) {
    switch (name) {
      case 'play':
        audioPlayer?.play(audioSrc);
        break;
      case 'pause':
        audioPlayer?.pause();
        break;
      case 'fastSeek':
        int duration = args[0] * 1000;
        audioPlayer?.seek(Duration(milliseconds: duration));
        break;
      default:
        super.method(name, args);
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      audioSrc = value;
    }
  }
}
