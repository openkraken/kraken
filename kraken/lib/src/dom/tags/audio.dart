import 'dart:ui';
import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken_audioplayers/kraken_audioplayers.dart';

import 'media.dart';

const String AUDIO = 'AUDIO';

const Map<String, dynamic> _defaultStyle = {
};

class AudioElement extends MediaElement {
  AudioPlayer audioPlayer;
  String audioSrc;
  RenderConstrainedBox _sizedBox;

  static double defaultWidth = 300.0;
  static double defaultHeight = 150.0;

  final Pointer<NativeAudioElement> nativeAudioElement;

  AudioElement(int targetId, this.nativeAudioElement, ElementManager elementManager)
      : super(targetId, nativeAudioElement.ref.nativeMediaElement, elementManager, AUDIO, defaultStyle: _defaultStyle);

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    initAudioPlayer();
    initSizedBox();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    audioPlayer = null;
    _sizedBox = null;
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
  void play() {
    audioPlayer?.play(audioSrc);
  }

  @override
  void pause() {
    audioPlayer.pause();
  }

  @override
  void fastSeek(double duration) {
    audioPlayer.seek(Duration(seconds: duration.toInt()));
  }

  void _stylePropertyChanged(String property, String original, String present, bool inAnimation) {
    switch (property) {
      case WIDTH:
      case HEIGHT:
        _updateSizedBox();
        break;
    }
  }

  void _updateSizedBox() {
    double w = style.contains(WIDTH) ? CSSLength.toDisplayPortValue(style[WIDTH]) : null;
    double h = style.contains(HEIGHT) ? CSSLength.toDisplayPortValue(style[HEIGHT]) : null;
    _sizedBox.additionalConstraints = BoxConstraints.tight(Size(w ?? defaultWidth, h ?? defaultHeight));
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      audioSrc = value;
    }
  }
}
