import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

// Required for PluginUtilities.
import 'dart:ui';
import 'package:flutter/material.dart';

typedef StreamController CreateStreamController();
typedef void TimeChangeHandler(Duration duration);
typedef void SeekHandler(bool finished);
typedef void ErrorHandler(String message);
typedef void AudioPlayerStateChangeHandler(AudioPlayerState state);

/// This enum is meant to be used as a parameter of [setReleaseMode] method.
///
/// It represents the behaviour of [AudioPlayer] when an audio is finished or
/// stopped.
enum ReleaseMode {
  /// Releases all resources, just like calling [release] method.
  ///
  /// In Android, the media player is quite resource-intensive, and this will
  /// let it go. Data will be buffered again when needed (if it's a remote file,
  /// it will be downloaded again).
  /// In iOS and macOS, works just like [stop] method.
  ///
  /// This is the default behaviour.
  RELEASE,

  /// Keeps buffered data and plays again after completion, creating a loop.
  /// Notice that calling [stop] method is not enough to release the resources
  /// when this mode is being used.
  LOOP,

  /// Stops audio playback but keep all resources intact.
  /// Use this if you intend to play again later.
  STOP
}

/// Self explanatory. Indicates the state of the audio player.
enum AudioPlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  COMPLETED,
}

/// This enum is meant to be used as a parameter of the [AudioPlayer]'s
/// constructor. It represents the general mode of the [AudioPlayer].
///
// In iOS and macOS, both modes have the same backend implementation.
enum PlayerMode {
  /// Ideal for long media files or streams.
  MEDIA_PLAYER,

  /// Ideal for short audio files, since it reduces the impacts on visuals or
  /// UI performance.
  ///
  /// In this mode the backend won't fire any duration or position updates.
  /// Also, it is not possible to use the seek method to set the audio a
  /// specific position.
  LOW_LATENCY
}

// When we start the background service isolate, we only ever enter it once.
// To communicate between the native plugin and this entrypoint, we'll use
// MethodChannels to open a persistent communication channel to trigger
// callbacks.

/// Not implemented on macOS.
void _backgroundCallbackDispatcher() {
  const MethodChannel _channel =
      MethodChannel('xyz.luan/audioplayers_callback');

  // Setup Flutter state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // Reference to the onAudioChangeBackgroundEvent callback.
  Function(AudioPlayerState) onAudioChangeBackgroundEvent;

  // This is where the magic happens and we handle background events from the
  // native portion of the plugin. Here we message the audio notification data
  // which we then pass to the provided callback.
  _channel.setMethodCallHandler((MethodCall call) async {
    Function _performCallbackLookup() {
      final CallbackHandle handle = CallbackHandle.fromRawHandle(
          call.arguments['updateHandleMonitorKey']);

      // PluginUtilities.getCallbackFromHandle performs a lookup based on the
      // handle we retrieved earlier.
      final Function closure = PluginUtilities.getCallbackFromHandle(handle);

      if (closure == null) {
        print('Fatal Error: Callback lookup failed!');
        // exit(-1);
      }
      return closure;
    }

    final Map<dynamic, dynamic> callArgs = call.arguments as Map;
    if (call.method == 'audio.onNotificationBackgroundPlayerStateChanged') {
      onAudioChangeBackgroundEvent ??= _performCallbackLookup();
      final String playerState = callArgs['value'];
      if (playerState == 'playing') {
        onAudioChangeBackgroundEvent(AudioPlayerState.PLAYING);
      } else if (playerState == 'paused') {
        onAudioChangeBackgroundEvent(AudioPlayerState.PAUSED);
      } else if (playerState == 'completed') {
        onAudioChangeBackgroundEvent(AudioPlayerState.COMPLETED);
      }
    } else {
      assert(false, "No handler defined for method type: '${call.method}'");
    }
  });
}

/// This represents a single AudioPlayer, which can play one audio at a time.
/// To play several audios at the same time, you must create several instances
/// of this class.
///
/// It holds methods to play, loop, pause, stop, seek the audio, and some useful
/// hooks for handlers and callbacks.
class AudioPlayer {
  static final MethodChannel _channel =
      const MethodChannel('xyz.luan/audioplayers')
        ..setMethodCallHandler(platformCallHandler);

  static final _uuid = Uuid();

  final StreamController<AudioPlayerState> _playerStateController =
      StreamController<AudioPlayerState>.broadcast();

  final StreamController<AudioPlayerState> _notificationPlayerStateController =
      StreamController<AudioPlayerState>.broadcast();

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  final StreamController<void> _completionController =
      StreamController<void>.broadcast();

  final StreamController<bool> _seekCompleteController =
      StreamController<bool>.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  /// Reference [Map] with all the players created by the application.
  ///
  /// This is used to exchange messages with the [MethodChannel]
  /// (there is only one).
  static final players = Map<String, AudioPlayer>();

  /// Enables more verbose logging.
  static bool logEnabled = false;

  AudioPlayerState _audioPlayerState;

  AudioPlayerState get state => _audioPlayerState;

  set state(AudioPlayerState state) {
    _playerStateController.add(state);
    // ignore: deprecated_member_use_from_same_package
    audioPlayerStateChangeHandler?.call(state);
    _audioPlayerState = state;
  }

  set notificationState(AudioPlayerState state) {
    _notificationPlayerStateController.add(state);
    _audioPlayerState = state;
  }

  /// Stream of changes on player state.
  Stream<AudioPlayerState> get onPlayerStateChanged =>
      _playerStateController.stream;

  /// Stream of changes on player state coming from notification area in iOS.
  Stream<AudioPlayerState> get onNotificationPlayerStateChanged =>
      _notificationPlayerStateController.stream;

  /// Stream of changes on audio position.
  ///
  /// Roughly fires every 200 milliseconds. Will continuously update the
  /// position of the playback if the status is [AudioPlayerState.PLAYING].
  ///
  /// You can use it on a progress bar, for instance.
  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  /// Stream of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  Stream<Duration> get onDurationChanged => _durationController.stream;

  /// Stream of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.LOOP] also sends events to this stream.
  Stream<void> get onPlayerCompletion => _completionController.stream;

  /// Stream of seek completions.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  Stream<void> get onSeekComplete => _seekCompleteController.stream;

  /// Stream of player errors.
  ///
  /// Events are sent when an unexpected error is thrown in the native code.
  Stream<String> get onPlayerError => _errorController.stream;

  /// Handler of changes on player state.
  @deprecated
  AudioPlayerStateChangeHandler audioPlayerStateChangeHandler;

  /// Handler of changes on player position.
  ///
  /// Will continuously update the position of the playback if the status is
  /// [AudioPlayerState.PLAYING].
  ///
  /// You can use it on a progress bar, for instance.
  ///
  /// This is deprecated. Use [onAudioPositionChanged] instead.
  @deprecated
  TimeChangeHandler positionHandler;

  /// Handler of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  ///
  /// This is deprecated. Use [onDurationChanged] instead.
  @deprecated
  TimeChangeHandler durationHandler;

  /// Handler of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.LOOP] also sends events to this stream.
  ///
  /// This is deprecated. Use [onPlayerCompletion] instead.
  @deprecated
  VoidCallback completionHandler;

  /// Handler of seek completion.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  ///
  /// This is deprecated. Use [onSeekComplete] instead.
  @deprecated
  SeekHandler seekCompleteHandler;

  /// Handler of player errors.
  ///
  /// Events are sent when an unexpected error is thrown in the native code.
  ///
  /// This is deprecated. Use [onPlayerError] instead.
  @deprecated
  ErrorHandler errorHandler;

  /// An unique ID generated for this instance of [AudioPlayer].
  ///
  /// This is used to properly exchange messages with the [MethodChannel].
  String playerId;

  /// Current mode of the audio player. Can be updated at any time, but is going
  /// to take effect only at the next time you play the audio.
  PlayerMode mode;

  /// Creates a new instance and assigns an unique id to it.
  AudioPlayer({this.mode = PlayerMode.MEDIA_PLAYER, this.playerId}) {
    this.mode ??= PlayerMode.MEDIA_PLAYER;
    this.playerId ??= _uuid.v4();
    players[playerId] = this;
  }

  Future<int> _invokeMethod(
    String method, [
    Map<String, dynamic> arguments,
  ]) {
    arguments ??= const {};

    final Map<String, dynamic> withPlayerId = Map.of(arguments)
      ..['playerId'] = playerId
      ..['mode'] = mode.toString();

    return _channel
        .invokeMethod(method, withPlayerId)
        .then((result) => (result as int));
  }

  /// this should be called after initiating AudioPlayer only if you want to
  /// listen for notification changes in the background. Not implemented on macOS
  void startHeadlessService() {
    if (this == null || playerId.isEmpty) {
      return;
    }
    // Start the headless audio service. The parameter here is a handle to
    // a callback managed by the Flutter engine, which allows for us to pass
    // references to our callbacks between isolates.
    final CallbackHandle handle =
        PluginUtilities.getCallbackHandle(_backgroundCallbackDispatcher);
    assert(handle != null, 'Unable to lookup callback.');
    _invokeMethod('startHeadlessService', {
      'handleKey': <dynamic>[handle.toRawHandle()]
    });

    return;
  }

  /// Start getting significant audio updates through `callback`.
  ///
  /// `callback` is invoked on a background isolate and will not have direct
  /// access to the state held by the main isolate (or any other isolate).
  Future<bool> monitorNotificationStateChanges(
      void Function(AudioPlayerState value) callback) async {
    if (callback == null) {
      throw ArgumentError.notNull('callback');
    }
    final CallbackHandle handle = PluginUtilities.getCallbackHandle(callback);

    await _invokeMethod('monitorNotificationStateChanges', {
      'handleMonitorKey': <dynamic>[handle.toRawHandle()]
    });

    return true;
  }

  /// Plays an audio.
  ///
  /// If [isLocal] is true, [url] must be a local file system path.
  /// If [isLocal] is false, [url] must be a remote URL.
  ///
  /// respectSilence and stayAwake are not implemented on macOS.
  Future<int> play(
    String url, {
    bool isLocal,
    double volume = 1.0,
    // position must be null by default to be compatible with radio streams
    Duration position,
    bool respectSilence = false,
    bool stayAwake = false,
  }) async {
    isLocal ??= url.startsWith("/") ||
        url.startsWith("file://") ||
        url.substring(1).startsWith(':\\');
    volume ??= 1.0;
    respectSilence ??= false;
    stayAwake ??= false;

    final int result = await _invokeMethod('play', {
      'url': url,
      'isLocal': isLocal,
      'volume': volume,
      'position': position?.inMilliseconds,
      'respectSilence': respectSilence,
      'stayAwake': stayAwake,
    });

    if (result == 1) {
      state = AudioPlayerState.PLAYING;
    }

    return result;
  }

  /// Pauses the audio that is currently playing.
  ///
  /// If you call [resume] later, the audio will resume from the point that it
  /// has been paused.
  Future<int> pause() async {
    final int result = await _invokeMethod('pause');

    if (result == 1) {
      state = AudioPlayerState.PAUSED;
    }

    return result;
  }

  /// Stops the audio that is currently playing.
  ///
  /// The position is going to be reset and you will no longer be able to resume
  /// from the last point.
  Future<int> stop() async {
    final int result = await _invokeMethod('stop');

    if (result == 1) {
      state = AudioPlayerState.STOPPED;
    }

    return result;
  }

  /// Resumes the audio that has been paused or stopped, just like calling
  /// [play], but without changing the parameters.
  Future<int> resume() async {
    final int result = await _invokeMethod('resume');

    if (result == 1) {
      state = AudioPlayerState.PLAYING;
    }

    return result;
  }

  /// Releases the resources associated with this media player.
  ///
  /// The resources are going to be fetched or buffered again as soon as you
  /// call [play] or [setUrl].
  Future<int> release() async {
    final int result = await _invokeMethod('release');

    if (result == 1) {
      state = AudioPlayerState.STOPPED;
    }

    return result;
  }

  /// Moves the cursor to the desired position.
  Future<int> seek(Duration position) {
    _positionController.add(position);
    return _invokeMethod('seek', {'position': position.inMilliseconds});
  }

  /// Sets the volume (amplitude).
  ///
  /// 0 is mute and 1 is the max volume. The values between 0 and 1 are linearly
  /// interpolated.
  Future<int> setVolume(double volume) {
    return _invokeMethod('setVolume', {'volume': volume});
  }

  /// Sets the release mode.
  ///
  /// Check [ReleaseMode]'s doc to understand the difference between the modes.
  Future<int> setReleaseMode(ReleaseMode releaseMode) {
    return _invokeMethod(
      'setReleaseMode',
      {'releaseMode': releaseMode.toString()},
    );
  }

  /// Sets the playback rate - call this after first calling play() or resume().
  ///
  /// iOS and macOS have limits between 0.5 and 2x
  /// Android SDK version should be 23 or higher.
  /// not sure if that's changed recently.
  Future<int> setPlaybackRate({double playbackRate = 1.0}) {
    return _invokeMethod('setPlaybackRate', {'playbackRate': playbackRate});
  }

  /// Sets the notification bar for lock screen and notification area in iOS for now.
  ///
  /// Specify atleast title
  Future<dynamic> setNotification(
      {String title,
      String albumTitle = '',
      String artist = '',
      String imageUrl = '',
      Duration forwardSkipInterval = const Duration(seconds: 30),
      Duration backwardSkipInterval = const Duration(seconds: 30),
      Duration duration,
      Duration elapsedTime}) {
    return _invokeMethod('setNotification', {
      'title': title,
      'albumTitle': albumTitle,
      'artist': artist,
      'imageUrl': imageUrl,
      'forwardSkipInterval': forwardSkipInterval?.inSeconds ?? 30,
      'backwardSkipInterval': backwardSkipInterval?.inSeconds ?? 30,
      'duration': duration?.inSeconds ?? 0,
      'elapsedTime': elapsedTime?.inSeconds ?? 0
    });
  }

  /// Sets the URL.
  ///
  /// Unlike [play], the playback will not resume.
  ///
  /// The resources will start being fetched or buffered as soon as you call
  /// this method.
  ///
  /// respectSilence is not implemented on macOS.
  Future<int> setUrl(String url,
      {bool isLocal: false, bool respectSilence = false}) {
    return _invokeMethod('setUrl',
        {'url': url, 'isLocal': isLocal, 'respectSilence': respectSilence});
  }

  /// Get audio duration after setting url.
  /// Use it in conjunction with setUrl.
  ///
  /// It will be available as soon as the audio duration is available
  /// (it might take a while to download or buffer it if file is not local).
  Future<int> getDuration() {
    return _invokeMethod('getDuration');
  }

  // Gets audio current playing position
  Future<int> getCurrentPosition() async {
    return _invokeMethod('getCurrentPosition');
  }

  static Future<void> platformCallHandler(MethodCall call) async {
    try {
      _doHandlePlatformCall(call);
    } catch (ex) {
      _log('Unexpected error: $ex');
    }
  }

  static Future<void> _doHandlePlatformCall(MethodCall call) async {
    final Map<dynamic, dynamic> callArgs = call.arguments as Map;
    _log('_platformCallHandler call ${call.method} $callArgs');

    final playerId = callArgs['playerId'] as String;
    final AudioPlayer player = players[playerId];

    if (!kReleaseMode && Platform.isAndroid && player == null) {
      final oldPlayer = AudioPlayer(playerId: playerId);
      await oldPlayer.release();
      oldPlayer.dispose();
      players.remove(playerId);
      return;
    }

    final value = callArgs['value'];

    switch (call.method) {
      case 'audio.onNotificationPlayerStateChanged':
        final bool isPlaying = value;
        player.notificationState =
            isPlaying ? AudioPlayerState.PLAYING : AudioPlayerState.PAUSED;
        break;
      case 'audio.onDuration':
        Duration newDuration = Duration(milliseconds: value);
        player._durationController.add(newDuration);
        // ignore: deprecated_member_use_from_same_package
        player.durationHandler?.call(newDuration);
        break;
      case 'audio.onCurrentPosition':
        Duration newDuration = Duration(milliseconds: value);
        player._positionController.add(newDuration);
        // ignore: deprecated_member_use_from_same_package
        player.positionHandler?.call(newDuration);
        break;
      case 'audio.onComplete':
        player.state = AudioPlayerState.COMPLETED;
        player._completionController.add(null);
        // ignore: deprecated_member_use_from_same_package
        player.completionHandler?.call();
        break;
      case 'audio.onSeekComplete':
        player._seekCompleteController.add(value);
        player.seekCompleteHandler?.call(value);
        break;
      case 'audio.onError':
        player.state = AudioPlayerState.STOPPED;
        player._errorController.add(value);
        // ignore: deprecated_member_use_from_same_package
        player.errorHandler?.call(value);
        break;
      default:
        _log('Unknown method ${call.method} ');
    }
  }

  static void _log(String param) {
    if (logEnabled) {
      print(param);
    }
  }

  /// Closes all [StreamController]s.
  ///
  /// You must call this method when your [AudioPlayer] instance is not going to
  /// be used anymore.
  Future<void> dispose() async {
    List<Future> futures = [];

    if (!_playerStateController.isClosed)
      futures.add(_playerStateController.close());
    if (!_notificationPlayerStateController.isClosed)
      futures.add(_notificationPlayerStateController.close());
    if (!_positionController.isClosed) futures.add(_positionController.close());
    if (!_durationController.isClosed) futures.add(_durationController.close());
    if (!_completionController.isClosed)
      futures.add(_completionController.close());
    if (!_seekCompleteController.isClosed)
      futures.add(_seekCompleteController.close());
    if (!_errorController.isClosed) futures.add(_errorController.close());

    await Future.wait(futures);
  }
}
