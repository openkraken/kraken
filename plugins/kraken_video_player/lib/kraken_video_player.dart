// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'video_player_platform_interface.dart';
export 'video_player_platform_interface.dart'
  show DurationRange, DataSourceType, VideoFormat;

const int MEDIA_ERR_ABORTED = 1;
const int MEDIA_ERR_NETWORK = 2;
const int MEDIA_ERR_DECODE = 3;
const int MEDIA_ERR_SRC_NOT_SUPPORTED = 4;

// This will clear all open videos on the platform when a full restart is
// performed.
// ignore: unused_element
final VideoPlayerPlatform _ = VideoPlayerPlatform.instance..init();

/// The duration, current position, buffering state, error state and settings
/// of a [VideoPlayerController].
class VideoPlayerValue {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  VideoPlayerValue({
    @required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.isMuted = false,
    this.volume = 1.0,
    this.errorDescription,
  });

  /// Returns an instance with a `null` [Duration].
  VideoPlayerValue.uninitialized() : this(duration: null);

  /// Returns an instance with a `null` [Duration] and the given
  /// [errorDescription].
  VideoPlayerValue.erroneous(String errorDescription)
    : this(duration: null, errorDescription: errorDescription);

  /// The total duration of the video.
  ///
  /// Is null when [initialized] is false.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final List<DurationRange> buffered;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// Ture is the video is muted
  final bool isMuted;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// The current volume of the playback.
  final double volume;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errorDescription;

  /// The [size] of the currently loaded video.
  ///
  /// Is null when [initialized] is false.
  final Size size;

  /// Indicates whether or not the video has been loaded and is ready to play.
  bool get initialized => duration != null;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height] when size is non-null, or `1.0.` when
  /// it is.
  double get aspectRatio => size != null ? size.width / size.height : 1.0;

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWidth].
  VideoPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    bool isMuted,
    double volume,
    String errorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
      'duration: $duration, '
      'size: $size, '
      'position: $position, '
      'buffered: [${buffered.join(', ')}], '
      'isPlaying: $isPlaying, '
      'isLooping: $isLooping, '
      'isBuffering: $isBuffering'
      'volume: $volume, '
      'errorDescription: $errorDescription)';
  }
}

/// Controls a platform video player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  /// Constructs a [VideoPlayerController] playing a video from an asset.
  ///
  /// The name of the asset is given by the [dataSource] argument and must not be
  /// null. The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  VideoPlayerController.asset(this.dataSource, {this.package})
    : dataSourceType = DataSourceType.asset,
      formatHint = null,
      super(VideoPlayerValue(duration: null));

  /// Constructs a [VideoPlayerController] playing a video from obtained from
  /// the network.
  ///
  /// The URI for the video is given by the [dataSource] argument and must not be
  /// null.
  /// **Android only**: The [formatHint] option allows the caller to override
  /// the video format detection code.
  VideoPlayerController.network(this.dataSource, {this.formatHint})
    : dataSourceType = DataSourceType.network,
      package = null,
      super(VideoPlayerValue(duration: null));

  /// Constructs a [VideoPlayerController] playing a video from a file.
  ///
  /// This will load the file from the file-URI given by:
  /// `'file://${file.path}'`.
  VideoPlayerController.file(File file)
    : dataSource = 'file://${file.path}',
      dataSourceType = DataSourceType.file,
      package = null,
      formatHint = null,
      super(VideoPlayerValue(duration: null));

  /// VideoController Callbacks
  VoidCallback onCanPlay;
  VoidCallback onCanPlayThrough;
  VoidCallback onEnded;
  void Function(int, String) onError;
  VoidCallback onPause;
  VoidCallback onPlay;
  VoidCallback onSeeked;
  void Function() onSeeking;
  VoidCallback onVolumeChange;

  int _textureId;

  /// The URI to the video file. This will be in different formats depending on
  /// the [DataSourceType] of the original video.
  final String dataSource;

  /// **Android only**. Will override the platform's generic file format
  /// detection with whatever is set here.
  final VideoFormat formatHint;

  /// Describes the type of data source this [VideoPlayerController]
  /// is constructed with.
  final DataSourceType dataSourceType;

  /// Only set for [asset] videos. The package that the asset was loaded from.
  final String package;
  Timer _timer;
  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;

  /// Attempts to open the given [dataSource] and load metadata about the video.
  Future<int> initialize() async {
    _creatingCompleter = Completer<void>();

    DataSource dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.asset,
          asset: dataSource,
          package: package,
        );
        break;
      case DataSourceType.network:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.network,
          uri: dataSource,
          formatHint: formatHint,
        );
        break;
      case DataSourceType.file:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.file,
          uri: dataSource,
        );
        break;
    }
    _textureId =
    await VideoPlayerPlatform.instance.create(dataSourceDescription);
    _creatingCompleter.complete(null);
    final Completer<int> initializingCompleter = Completer<int>();

    void eventListener(VideoEvent event) {
      if (_isDisposed) {
        return;
      }

      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
          );
          initializingCompleter.complete(_textureId);
          _applyLooping();
          _applyVolume();
          _applyPlayPause();
          if (onCanPlay != null) onCanPlay();
          break;
        case VideoEventType.completed:
          if (onEnded != null) onEnded();
          value = value.copyWith(isPlaying: false, position: value.duration);
          _timer?.cancel();
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          if (onCanPlayThrough != null) onCanPlayThrough();
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.unknown:
          onError(MEDIA_ERR_ABORTED, 'unknown video error');
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      if (onError != null) onError(MEDIA_ERR_NETWORK, e.message);
      value = VideoPlayerValue.erroneous(e.message);
      _timer?.cancel();
    }

    _eventSubscription = VideoPlayerPlatform.instance
      .videoEventsFor(_textureId)
      .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        await VideoPlayerPlatform.instance.dispose(_textureId);
      }
    }
    _isDisposed = true;
    super.dispose();
  }

  /// Starts playing the video.
  ///
  /// This method returns a future that completes as soon as the "play" command
  /// has been sent to the platform, not when playback itself is totally
  /// finished.
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
    if (onPlay != null) onPlay();
  }

  /// Sets whether or not the video should loop after playing once. See also
  /// [VideoPlayerValue.isLooping].
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  /// Pauses the video.
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
    if (onPause != null) onPause();
  }

  Future<void> _applyLooping() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await VideoPlayerPlatform.instance.setLooping(_textureId, value.isLooping);
  }

  /// Sets whether or not video should be muted.
  ///
  /// This method doesn't affect volume value.
  ///
  /// See also [VideoPlayerValue.isMuted].
  Future<void> setMuted(bool muted) async {
    value = value.copyWith(isMuted: muted);
    await _applyMuted();
  }

  Future<void> _applyMuted() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await VideoPlayerPlatform.instance.setMuted(_textureId, value.isMuted);
  }

  Future<void> _applyPlayPause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    if (value.isPlaying) {
      await VideoPlayerPlatform.instance.play(_textureId);
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
          (Timer timer) async {
          if (_isDisposed) {
            return;
          }
          final Duration newPosition = await position;
          if (_isDisposed) {
            return;
          }
          value = value.copyWith(position: newPosition);
        },
      );
    } else {
      _timer?.cancel();
      await VideoPlayerPlatform.instance.pause(_textureId);
    }
  }

  Future<void> _applyVolume() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await VideoPlayerPlatform.instance.setVolume(_textureId, value.volume);
  }

  /// The position in the current video.
  Future<Duration> get position async {
    if (_isDisposed) {
      return null;
    }
    return await VideoPlayerPlatform.instance.getPosition(_textureId);
  }

  /// Sets the video's current timestamp to be at [moment]. The next
  /// time the video is played it will resume from the given [moment].
  ///
  /// If [moment] is outside of the video's full range it will be automatically
  /// and silently clamped.
  Future<void> seekTo(Duration position) async {
    if (_isDisposed) {
      return;
    }
    if (position > value.duration) {
      position = value.duration;
    } else if (position < const Duration()) {
      position = const Duration();
    }
    if (onSeeking != null) onSeeking();
    await VideoPlayerPlatform.instance.seekTo(_textureId, position);
    value = value.copyWith(position: position);
    if (onSeeked != null) onSeeked();
  }

  /// Sets the audio volume of [this].
  ///
  /// [volume] indicates a value between 0.0 (silent) and 1.0 (full volume) on a
  /// linear scale.
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
    if (onVolumeChange != null) onVolumeChange();
  }
}
