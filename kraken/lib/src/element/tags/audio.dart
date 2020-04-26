import 'package:kraken/element.dart';
import 'package:kraken_audioplayers/kraken_audioplayers.dart';

const String AUDIO = 'AUDIO';

class AudioElement extends Element {
  AudioPlayer audioPlayer;
  String audioSrc;

  AudioElement(
    int targetId,
    Map<String, dynamic> props,
    List<String> events
  ) : super(
    targetId: targetId,
    defaultDisplay: 'block',
    allowChildren: false,
    tagName: AUDIO,
    properties: props,
    events: events,
  ) {
    initAudioPlayer();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();

    RegExp exp = RegExp(r'^(http|https)://');
    if (properties['src'] != null && !exp.hasMatch(properties['src'])) {
      throw Exception('audio url\'s prefix should be http:// or https://');
    }
    audioSrc = properties['src'];
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
