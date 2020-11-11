import 'dart:ui';
import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken_audioplayers/kraken_audioplayers.dart';

const String AUDIO = 'AUDIO';

class AudioElement extends Element {
  AudioPlayer audioPlayer;
  String audioSrc;
  RenderConstrainedBox _sizedBox;

  static double defaultWidth = 300.0;
  static double defaultHeight = 150.0;

  AudioElement(int targetId, Pointer<NativeEventTarget> nativePtr, ElementManager elementManager)
      : super(targetId, nativePtr, elementManager, isIntrinsicBox: true, tagName: AUDIO);

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
  void method(String name, List args) {
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
