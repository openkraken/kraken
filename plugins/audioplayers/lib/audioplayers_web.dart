import 'dart:async';
import 'dart:html';
import 'dart:web_audio';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final AudioContext _audioCtx = AudioContext();

class WrappedPlayer {
  double startingPoint;
  double soughtPosition;
  double pausedAt = null;
  double currentVolume = 1.0;
  bool isPlaying = false;

  AudioBuffer currentBuffer;
  AudioBufferSourceNode currentNode;
  GainNode gainNode;

  void setBuffer(AudioBuffer buffer) {
    stop();
    currentBuffer = buffer;
    recreateNode();
    if (isPlaying) {
      resume();
    }
  }

  void setVolume(double volume) {
    currentVolume = volume;
    gainNode.gain.value = currentVolume;
  }

  void recreateNode() {
    currentNode = _audioCtx.createBufferSource();
    currentNode.buffer = currentBuffer;

    gainNode = _audioCtx.createGain();
    gainNode.gain.value = currentVolume;
    gainNode.connectNode(_audioCtx.destination);

    currentNode.connectNode(gainNode);
  }

  void start(double position) {
    isPlaying = true;
    if (currentBuffer == null) {
      return; // nothing to play yet
    }
    if (currentNode == null) {
      recreateNode();
    }
    startingPoint = _audioCtx.currentTime;
    soughtPosition = position;
    currentNode.start(startingPoint, soughtPosition);
  }

  void resume() {
    start(pausedAt ?? 0);
  }

  void pause() {
    pausedAt = _audioCtx.currentTime - startingPoint + soughtPosition;
    _cancel();
  }

  void stop() {
    pausedAt = 0;
    _cancel();
  }

  void _cancel() {
    isPlaying = false;
    currentNode?.stop();
    currentNode = null;
  }
}

class AudioplayersPlugin {
  // players by playerId
  Map<String, WrappedPlayer> players = {};

  // cache of pre-loaded buffers by URL
  Map<String, AudioBuffer> preloadedBuffers = {};

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'xyz.luan/audioplayers',
      const StandardMethodCodec(),
      registrar.messenger,
    );

    final AudioplayersPlugin instance = AudioplayersPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<AudioBuffer> loadAudio(String url) async {
    if (preloadedBuffers.containsKey(url)) {
      return preloadedBuffers[url];
    }

    final HttpRequest response =
        await HttpRequest.request(url, responseType: 'arraybuffer');
    final AudioBuffer buffer =
        await _audioCtx.decodeAudioData(response.response);
    return preloadedBuffers.putIfAbsent(url, () => buffer);
  }

  WrappedPlayer getOrCreatePlayer(String playerId) {
    return players.putIfAbsent(playerId, () => WrappedPlayer());
  }

  Future<WrappedPlayer> setUrl(String playerId, String url) async {
    final WrappedPlayer player = getOrCreatePlayer(playerId);
    final AudioBuffer buffer = await loadAudio(url);
    player.setBuffer(buffer);
    return player;
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    final method = call.method;
    final playerId = call.arguments['playerId'];
    switch (method) {
      case 'setUrl':
        {
          final String url = call.arguments['url'];
          await setUrl(playerId, url);
          return 1;
        }
      case 'play':
        {
          final String url = call.arguments['url'];
          final bool isLocal = call.arguments['isLocal'];
          double volume = call.arguments['volume'] ?? 1.0;
          final double position = call.arguments['position'] ?? 0;
          // web does not care for the `stayAwake` argument

          final player = await setUrl(playerId, url);
          player.setVolume(volume);
          player.start(position);

          return 1;
        }
      case 'pause':
        {
          getOrCreatePlayer(playerId).pause();
          return 1;
        }
      case 'stop':
        {
          getOrCreatePlayer(playerId).stop();
          return 1;
        }
      case 'resume':
        {
          getOrCreatePlayer(playerId).resume();
          return 1;
        }
      case 'setVolume':
        {
          double volume = call.arguments['volume'] ?? 1.0;
          getOrCreatePlayer(playerId).setVolume(volume);
          return 1;
        }
      case 'release':
      case 'seek':
      case 'setReleaseMode':
      case 'setPlaybackRate':
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "The audioplayers plugin for web doesn't implement the method '$method'",
        );
    }
  }
}
