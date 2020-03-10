import 'package:kraken/element.dart';
import 'package:kraken_audioplayers/kraken_audioplayers.dart';

const String AUDIO = 'AUDIO';

class AudioElement extends Element {
  AudioPlayer audioPlayer;
  String audioSrc;

  AudioElement(
    this.nodeId,
    this.props,
    this.events
  ) : super(
    nodeId: nodeId,
    defaultDisplay: 'block',
    tagName: AUDIO,
    properties: props,
    events: events,
  ) {
    initAudioPlayer();
  }

  int nodeId;
  Map<String, dynamic> props;
  List<String> events;

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();

    RegExp exp = RegExp(r"^(http|https)://");
    if (props['src'] != null && !exp.hasMatch(props['src'])) {
      throw Exception('audio url\'s prefix should be http:// or https://');
    }
    audioSrc = props['src'];
  }

  @override
  dynamic method(String name, List<dynamic> args) {
    if (audioPlayer == null) {
      return;
    }

    switch (name) {
      case 'play':
        audioPlayer.play(audioSrc);
        break;
      case 'pause':
        audioPlayer.pause();
        break;
      case 'fastSeek':
        int duration = args[0] * 1000;
        audioPlayer.seek(Duration(milliseconds: duration));
        break;
    }

    return 'foo';
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (key == 'src') {
      audioSrc = value;
    }
  }
}
