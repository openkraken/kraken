/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


import 'dart:core';
import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

// https://drafts.csswg.org/web-animations/#enumdef-animationplaystate
enum AnimationPlayState { idle, running, paused, finished }

// https://drafts.csswg.org/web-animations/#the-animationreplacestate-enumeration
enum AnimationReplaceState { active, removed, persisted }

enum AnimationEffectPhase { none, before, active, after }

// https://drafts.csswg.org/web-animations/#enumdef-fillmode
enum FillMode { none, forwards, backwards, both, auto }
// https://drafts.csswg.org/web-animations/#enumdef-playbackdirection
enum PlaybackDirection { normal, reverse, alternate, alternateReverse }

Curve? _parseEasing(String? function) {
  if (function == null) return null;

  switch (function) {
    case LINEAR:
      return Curves.linear;
    case EASE:
      return Curves.ease;
    case EASE_IN:
      return Curves.easeIn;
    case EASE_OUT:
      return Curves.easeOut;
    case EASE_IN_OUT:
      return Curves.easeInOut;
    case STEP_START:
      return Threshold(0);
    case STEP_END:
      return Threshold(1);
  }
  List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(function);
  if (methods.isNotEmpty) {
    CSSFunctionalNotation method = methods.first;
    if (method.name == 'steps') {
      if (method.args.isNotEmpty) {
        var step = int.tryParse(method.args[0]);
        var isStart = false;
        if (method.args.length == 2) {
          isStart = method.args[1] == 'start';
        }
        return CSSStepCurve(step, isStart);
      }
    } else if (method.name == 'cubic-bezier') {
      if (method.args.length == 4) {
        var first = double.tryParse(method.args[0])!;
        var sec = double.tryParse(method.args[1])!;
        var third = double.tryParse(method.args[2])!;
        var forth = double.tryParse(method.args[3])!;
        return Cubic(first, sec, third, forth);
      }
    }
  }
  return null;
}

class AnimationTimeline {
  List<Animation> _animations = [];
  double? _currentTime;
  late Ticker _ticker;

  AnimationTimeline() {
    _ticker = Ticker(_onTick);
  }

  double? get currentTime {
    return _currentTime;
  }

  List<Animation> getAnimations() {
    return _getActiveAnimations();
  }

  void _onTick(Duration timeStamp) {
    _currentTime = timeStamp.inMicroseconds / 1000;
    _animations = _getActiveAnimations();
    if (_animations.isEmpty) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    } else {
      for (int i = 0; i < _animations.length; i++) {
        _animations[i]._tick(_currentTime);
      }
    }
  }

  List<Animation> _getActiveAnimations() {
    List<Animation> activeAnimations = [];

    for (Animation animation in _animations) {
      AnimationPlayState playState = animation.playState;
      if (playState != AnimationPlayState.finished && playState != AnimationPlayState.idle) {
        activeAnimations.add(animation);
      }
    }
    return activeAnimations;
  }

  void _addAnimation(Animation animation) {
    if (!_animations.contains(animation)) {
      _animations.add(animation);
    }

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }
}

AnimationTimeline _documentTimeline = AnimationTimeline();

class Animation {
  double? _startTime;
  double _currentTime = 0;
  double _playbackRate = 1;

  bool _isPaused = false;

  // Whether the keyframeEffect is in effect or not after the timing update.
  bool _inEffect = false;
  bool _inTimeline = true;
  bool _isIdle = true;
  bool _isCurrentTimePending = false;

  bool _finishedFlag = true;

  // The target effect, as an object based on the AnimationEffect interface, to assign to the animation.
  // Although in the future other effects such as SequenceEffects or GroupEffects might be possible,
  // the only kind of effect currently available is KeyframeEffect.
  // This can be null (which is the default) to indicate that there should be no effect applied.
  KeyframeEffect? _effect;
  AnimationTimeline? _timeline;
  AnimationReplaceState? _replaceState;

  Function? onfinish;
  Function? oncancel;
  Function? onremove;

  // For transitionstart event
  Function? onstart;

  Animation(KeyframeEffect effect, [AnimationTimeline? timeline]) {
    if (timeline == null) {
      _timeline = _documentTimeline;
    }
    _effect = effect;
  }

  void _setInEffect(bool flag) {
    if (_inEffect == false && flag == true && onstart != null) {
      onstart!();
    }
    _inEffect = flag;
  }

  double? get currentTime {
    if (_isIdle || _isCurrentTimePending) return null;
    return _currentTime;
  }

  set currentTime(double? newTime) {
    if (newTime == null) return;

    if (!_isPaused && _startTime != null) {
      _startTime = _timeline!.currentTime! - newTime / _playbackRate;
    }

    _isCurrentTimePending = false;
    if (_currentTime == newTime)
      return;

    if (_isIdle) {
      _isIdle = false;
      _isPaused = true;
    }
    _tickCurrentTime(newTime, true);
  }

  _tickCurrentTime(double newTime, [bool ignoreLimit = false]) {

    if (newTime != _currentTime) {
      _currentTime = newTime;
      if (_isFinished && !ignoreLimit) {
        _currentTime = _playbackRate > 0 ? _totalDuration : 0;
      }
      _ensureAlive();
      _effect!._runIteration(_currentTime);
    }
  }

  AnimationEffect? get effect {
    return _effect;
  }

  set effect(AnimationEffect? effect) {
    _effect = effect as KeyframeEffect?;
  }

  AnimationTimeline? get timeline {
    return _timeline;
  }

  set timeline(AnimationTimeline? timeline) {
    _timeline = timeline;
  }

  double get playbackRate {
    return _playbackRate;
  }

  set playbackRate(double value) {
    if (value == _playbackRate) return;

    _effect!._playbackRate = value;

    _playbackRate = value;

    double? oldCurrentTime = currentTime;
    _startTime = null;
    if (playState != AnimationPlayState.paused && playState != AnimationPlayState.idle) {
      _finishedFlag = false;
      _isIdle = false;
      _ensureAlive();
    }
    if (oldCurrentTime != null) {
      currentTime = oldCurrentTime;
    }
  }

  double? get startTime {
    return _startTime;
  }

  set startTime(double? value) {
    if (value == null) return;

    if (_isPaused || _isIdle) return;
    _startTime = value;
    _tickCurrentTime((_timeline!.currentTime! - _startTime!) * playbackRate);
  }

  AnimationPlayState get playState {
    if (_isIdle)
      // The current time of the animation is unresolved and there are no pending tasks.
      return AnimationPlayState.idle;
    if (_isPaused)
      // The animation was suspended and the Animation.currentTime property is not updating.
      return AnimationPlayState.paused;
    if (_isFinished)
      // The animation has reached one of its boundaries and the Animation.currentTime property is not updating.
      return AnimationPlayState.finished;
    return AnimationPlayState.running;
  }

  AnimationReplaceState? get replaceState {
    return _replaceState;
  }

  // Indicates whether the animation is currently waiting for an asynchronous operation such as initiating playback or pausing a running animation.
  bool get pending {
    return (_startTime == null && !_isPaused && playbackRate != 0) || _isCurrentTimePending;
  }

  bool get _isFinished {
    return !_isIdle && (_playbackRate > 0 && _currentTime >= _totalDuration ||
        _playbackRate < 0 && _currentTime <= 0);
  }

  double get _totalDuration {
    return _effect!._getTotalDuration();
  }

  // To set the the playback rate for an in-flight animation such that it smoothly updates,
  // use the asynchronous updatePlaybackRate() method.
  void updatePlaybackRate() {
    // @TODO
  }

  void cancel() {
    if (!_inEffect)
      return;
    _inEffect = false;
    _isIdle = true;
    _isPaused = false;
    _finishedFlag = true;
    _currentTime = 0;
    _startTime = null;
    _effect!._calculateTiming(null);

    if (oncancel != null) {
      var event = AnimationPlaybackEvent(EVENT_CANCEL);
      event.timelineTime = _timeline!.currentTime;
      oncancel!(event);
    }
  }

  void finish() {
    if (_isIdle)
      return;
    currentTime = _playbackRate > 0 ? _totalDuration : 0;
    _startTime = _totalDuration - currentTime!;
    _isCurrentTimePending = false;
  }

  void play() {
    _isPaused = false;
    if (_isFinished || _isIdle) {
      _rewind();
      _startTime = null;
    }
    _finishedFlag = false;
    _isIdle = false;
    _ensureAlive();
  }

  void pause() {
    if (!_isFinished && !_isPaused && !_isIdle) {
      _isCurrentTimePending = true;
    } else if (_isIdle) {
      _rewind();
      _isIdle = false;
    }
    _startTime = null;
    _isPaused = true;
  }

  void reverse() {
    playbackRate *= -1;
    play();
  }

  void persist() {
    _replaceState = AnimationReplaceState.persisted;
  }

  void _ensureAlive() {
    // If an animation is playing backwards and is not fill backwards/both
    // then it should go out of effect when it reaches the start of its
    // active interval (currentTime == 0).
    if (playbackRate < 0 && currentTime == 0) {
      _effect!._calculateTiming(-1);
    } else {
      _effect!._calculateTiming(currentTime);
    }
    _setInEffect(_effect!._activeTime != null);

    if (!_inTimeline && (_inEffect || !_finishedFlag)) {
      _inTimeline = true;
    }
    timeline!._addAnimation(this);
  }

  void _rewind() {
    if (_playbackRate >= 0) {
      _currentTime = 0;
    } else {
      _currentTime = _totalDuration;
    }
  }

  void _tick(double? timelineTime) {
    if (!_isIdle && !_isPaused) {
      if (_startTime == null) {
        startTime = timelineTime! - _currentTime / playbackRate;
      } else if (!_isFinished) {
        _tickCurrentTime((timelineTime! - _startTime!) * playbackRate);
      }
    }
    _isCurrentTimePending = false;
    _fireEvents(timelineTime);
  }

  void _fireEvents(double? timelineTime) {
    if (_isFinished) {
      if (!_finishedFlag) {
        AnimationPlaybackEvent event = AnimationPlaybackEvent(EVENT_FINISH);
        event.currentTime = currentTime;
        event.timelineTime = timelineTime;
        if (onfinish != null) onfinish!(event);
        _finishedFlag = true;
      }
    } else {
      _finishedFlag = false;
    }
  }
}

class AnimationPlaybackEvent extends Event {
  AnimationPlaybackEvent(String type) : super(type);

  num? currentTime;
  num? timelineTime;
}

class Keyframe {
  String property;
  String value;
  double offset;
  String? easing;
  Keyframe(this.property, this.value, this.offset, [this.easing]);
}

class _Interpolation {
  double startOffset;
  double endOffset;
  Curve? easing;
  String property;
  var begin;
  var end;
  Function lerp;
  _Interpolation(this.property, this.startOffset, this.endOffset, this.easing, this.begin, this.end, this.lerp) {
    easing ??= Curves.linear;
  }

  @override
  String toString() => '_Interpolation('
      'startOffset: $startOffset, '
      'endOffset: $endOffset, '
      'easing: $easing, '
      'property: $property, '
      'begin: $begin, '
      'end: $end'
  ')';
}

class KeyframeEffect extends AnimationEffect {
  RenderStyle renderStyle;
  Element? target;
  late List<_Interpolation> _interpolations;
  double? _progress;
  double? _activeTime;
  late Map<String, List<Keyframe>> _propertySpecificKeyframeGroups;

  // Speed control.
  // The rate of play of an animation can be controlled by setting its playback rate.
  // For example, setting a playback rate of 2 will cause the animation’s current time to increase at twice the rate of its timeline.
  // Similarly, a playback rate of -1 will cause the animation’s current time to decrease at the same rate as the time values from its timeline increase.
  double _playbackRate = 1;

  KeyframeEffect(
    this.renderStyle,
    this.target,
    List<Keyframe> keyframes,
    EffectTiming? options
  ) {
    timing = options ?? EffectTiming();

    _propertySpecificKeyframeGroups = _makePropertySpecificKeyframeGroups(keyframes);
    _interpolations = _makeInterpolations(_propertySpecificKeyframeGroups, renderStyle);
  }

  static _defaultParse(value) {
    return value;
  }

  static _defaultLerp(start, end, double progress){
    return progress < 0.5 ? start : end;
  }

  static List<_Interpolation> _makeInterpolations(Map<String, List<Keyframe>> propertySpecificKeyframeGroups, RenderStyle? renderStyle) {
    List<_Interpolation> interpolations = [];

    propertySpecificKeyframeGroups.forEach((String property, List<Keyframe> keyframes) {
      for (int i = 0; i < keyframes.length - 1; i++) {
        int startIndex = i;
        int endIndex = i + 1;
        double startOffset = keyframes[startIndex].offset;
        double endOffset = keyframes[endIndex].offset;

        if (i == 0 && endOffset == 0) {
          endIndex = startIndex;
        }

        if (i == keyframes.length - 2 && startOffset == 1) {
          startIndex = endIndex;
        }

        String? left = keyframes[startIndex].value;
        String? right = keyframes[endIndex].value;
        if (left == INITIAL)
          left = CSSInitialValues[property];
        if (right == INITIAL)
          right = CSSInitialValues[property];

        if (left == right) continue;

        List? handlers = CSSTransitionHandlers[property];
        handlers ??= [_defaultParse, _defaultLerp];
        Function parseProperty = handlers[0];

        _Interpolation interpolation = _Interpolation(
          property,
          startOffset,
          endOffset,
          _parseEasing(keyframes[startIndex].easing),
          parseProperty(left, renderStyle, property),
          parseProperty(right, renderStyle, property),
          handlers[1]
        );

        interpolations.add(interpolation);
      }
    });

    interpolations.sort((_Interpolation leftInterpolation, _Interpolation rightInterpolation) {
      return leftInterpolation.startOffset - rightInterpolation.startOffset < 0 ? -1: 1;
    });

    return interpolations;
  }

  // [ { color: 'blue', left: '0px' },
  //   { color: 'green', left: '-20px' },
  //   { color: 'red', left: '100px' },
  //   { color: 'yellow', left: '50px'} ]
  // =>
  // { color: [ { value: 'blue' }, { value: 'green' }, { value: 'red' }, { value: 'yellow' } ],
  //   left: [ { value: '0px' }, { value: '-20px' }, { value: '100px' }, { value: '50px' } ] }
  static Map<String, List<Keyframe>> _makePropertySpecificKeyframeGroups(List<Keyframe> keyframes) {
    Map<String, List<Keyframe>> propertySpecificKeyframeGroups = {};

    for (var i = 0; i < keyframes.length; i++) {
      Keyframe keyframe = keyframes[i];
      String property = keyframe.property;

      if (propertySpecificKeyframeGroups[property] == null) {
        propertySpecificKeyframeGroups[property] = [keyframe];
      } else {
        propertySpecificKeyframeGroups[property]!.add(keyframe);
      }
    }

    return propertySpecificKeyframeGroups;
  }

  static final double _timeEpsilon = 0.00001;

  void _runIteration(double localTime) {
    if (_progress == null) {
      // If fill is backwards that will be null when animation finished
      _propertySpecificKeyframeGroups.forEach((String propertyName, value) {
        renderStyle.removeAnimationProperty(propertyName);
        String currentValue = renderStyle.target.style.getPropertyValue(propertyName);
        renderStyle.target.setRenderStyle(propertyName, currentValue);
      });
    } else {
      for (int i = 0; i < _interpolations.length; i++) {
        _Interpolation interpolation = _interpolations[i];
        double startOffset = interpolation.startOffset;
        double endOffset = interpolation.endOffset;
        Curve? easingCurve = interpolation.easing;
        String property = interpolation.property;
        double offsetFraction = _progress! - startOffset;
        double localDuration = endOffset - startOffset;
        double scaledLocalTime = localDuration == 0 ? 0 : easingCurve!.transform(offsetFraction / localDuration);

        if (1 - scaledLocalTime < _timeEpsilon) {
          scaledLocalTime = 1;
        }

        RenderBoxModel? renderBoxModel = target!.renderBoxModel;
        if (renderBoxModel != null && interpolation.begin != null && interpolation.end != null) {
          interpolation.lerp(interpolation.begin, interpolation.end, scaledLocalTime, property, renderBoxModel.renderStyle);
        }
      }
    }
  }

  double _getTotalDuration() {
    double activeDuration = _calculateActiveDuration();
    return timing!.delay! + activeDuration + timing!.endDelay!;
  }

  double _calculateActiveDuration() {
    // 3.8.2. Calculating the active duration
    // https://drafts.csswg.org/web-animations-1/#calculating-the-active-duration

    return (_repeatedDuration(timing!) / _playbackRate).abs();
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-active-duration
  double _repeatedDuration(EffectTiming timing) {
    // The active duration is calculated as follows:
    // active duration = iteration duration × iteration count
    // If either the iteration duration or iteration count are zero, the active duration is zero.
    if (timing.duration == 0 || timing.iterations == 0) {
      return 0;
    }
    return timing.duration! * timing.iterations!;
  }

  // https://drafts.csswg.org/web-animations/#animation-effect-phases-and-states
  AnimationEffectPhase _calculatePhase(double activeDuration, double? localTime) {

    bool animationIsBackwards = _playbackRate < 0;

    // (This should be the last statement, but it's more efficient to cache the local time and return right away if it's not resolved.)
    // Furthermore, it is often convenient to refer to the case when an animation effect is in none of the above phases
    // as being in the idle phase.
    if (localTime == null) {
      return AnimationEffectPhase.none;
    }

    // An animation effect is in the before phase if the animation effect’s local time is not unresolved and
    // either of the following conditions are met:
    //     1. the local time is less than the before-active boundary time, or
    //     2. the animation direction is ‘backwards’ and the local time is equal to the before-active boundary time.
    double endTime = max<double>(timing!.delay! + activeDuration + timing!.endDelay!, 0.0);
    double beforeActiveBoundaryTime = max<double>(min<double>(timing!.delay!, endTime), 0.0);

    if (localTime < beforeActiveBoundaryTime ||
      (animationIsBackwards && localTime == beforeActiveBoundaryTime)) {
      return AnimationEffectPhase.before;
    }

    // An animation effect is in the after phase if the animation effect’s local time is not unresolved and
    // either of the following conditions are met:
    //     1. the local time is greater than the active-after boundary time, or
    //     2. the animation direction is ‘forwards’ and the local time is equal to the active-after boundary time.
    double activeAfterBoundaryTime = max<double>(min<double>(timing!.delay! + activeDuration, endTime), 0.0);

    if (localTime > activeAfterBoundaryTime ||
      (!animationIsBackwards && localTime == activeAfterBoundaryTime)) {
      return AnimationEffectPhase.after;
    }

    // An animation effect is in the active phase if the animation effect’s local time is not unresolved and it is not
    // in either the before phase nor the after phase.
    // (No need to check, we've already established that local time was resolved).
    return AnimationEffectPhase.active;
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-active-time
  // ignore: missing_return
  double? _calculateActiveTime(double activeDuration, double? localTime, AnimationEffectPhase phase) {
    FillMode? fillMode = timing!.fill;
    switch (phase) {
      case AnimationEffectPhase.before:
        // If the fill mode is backwards or both, return the result of evaluating
        // max(local time - start delay, 0).
        if (fillMode == FillMode.backwards || fillMode == FillMode.both)
          return max<double>(localTime! - timing!.delay!, 0.0);
        // Otherwise, return an unresolved time value.
        return null;
      case AnimationEffectPhase.active:
        // If the animation effect is in the active phase, return the result of evaluating local time - start delay.
        return localTime! - timing!.delay!;
      // If the animation effect is in the after phase, the result depends on the first matching
      // condition from the following,
      case AnimationEffectPhase.after:
        // If the fill mode is forwards or both, return the result of evaluating
        // max(min(local time - start delay, active duration), 0).
        if (fillMode == FillMode.forwards || fillMode == FillMode.both)
          return max<double>(min<double>(localTime! - timing!.delay!, activeDuration), 0.0);
        // Otherwise (the local time is unresolved), return an unresolved time value.
        return null;
      case AnimationEffectPhase.none:
        return null;
    }
  }

  // 3.8.3.2. Calculating the overall progress
  // https://drafts.csswg.org/web-animations-1/#calculating-the-overall-progress
  double? _calculateOverallProgress(AnimationEffectPhase phase, double? activeTime) {
    // The overall progress describes the number of iterations that have completed (including partial iterations) and is defined as follows:

    // 1. If the active time is unresolved, return unresolved.
    if (activeTime == null)
      return null;

    // 2. Calculate an initial value for overall progress based on the first matching condition from below,
    double? overallProgress;
    double? iterationDuration = timing!.duration;
    if (iterationDuration == 0) {
      // If the iteration duration is zero, if the animation effect is in the before phase, let overall progress be zero,
      // otherwise, let it be equal to the iteration count.
      overallProgress = phase == AnimationEffectPhase.before ? 0 : timing!.iterations;
    } else {
      // Otherwise, let overall progress be the result of calculating active time / iteration duration.
      overallProgress = activeTime / iterationDuration!;
    }

    // 3. Return the result of calculating overall progress + iteration start.
    overallProgress = overallProgress! + timing!.iterationStart!;
    return overallProgress.abs();
  }

  // 3.8.3.3. Calculating the simple iteration progress
  // https://drafts.csswg.org/web-animations-1/#calculating-the-simple-iteration-progress
  double? _calculateSimpleIterationProgress(double? overallProgress, AnimationEffectPhase phase, double? activeTime, double activeDuration) {

    // The simple iteration progress is a fraction of the progress through the current iteration that
    // ignores transformations to the time introduced by the playback direction or timing functions
    // applied to the effect, and is calculated as follows:

    // 1. If the overall progress is unresolved, return unresolved.
    if (overallProgress == null)
      return null;

    double? iterationStart = timing!.iterationStart;
    double? iterations = timing!.iterations;
    // 2. If overall progress is infinity, let the simple iteration progress be iteration start % 1.0,
    // otherwise, let the simple iteration progress be overall progress % 1.0.
    double simpleIterationProgress = (overallProgress == double.infinity) ? iterationStart! % 1 : overallProgress % 1;

    // 3. If all of the following conditions are true,
    //
    // the simple iteration progress calculated above is zero, and
    // the animation effect is in the active phase or the after phase, and
    // the active time is equal to the active duration, and
    // the iteration count is not equal to zero.
    // let the simple iteration progress be 1.0.
    if (simpleIterationProgress == 0 &&
        (phase == AnimationEffectPhase.active || phase == AnimationEffectPhase.after) &&
        iterations != 0 &&
        activeTime == activeDuration) {
      simpleIterationProgress = 1;
    }
    return simpleIterationProgress;
  }

  // 3.8.4. Calculating the current iteration
  // https://drafts.csswg.org/web-animations-1/#calculating-the-current-iteration
  double? _calculateCurrentIteration(AnimationEffectPhase phase, double? activeTime, double? simpleIterationProgress, double? overallProgress) {
    // The current iteration can be calculated using the following steps:

    // 1. If the active time is unresolved, return unresolved.
    if (activeTime == null)
      return null;

    double? iterations = timing!.iterations;
    // 2. If the animation effect is in the after phase and the iteration count is infinity, return infinity.
    if (phase == AnimationEffectPhase.after && iterations == double.infinity) {
      return double.infinity;
    }

    // 3. If the simple iteration progress is 1.0, return floor(overall progress) - 1.
    if (simpleIterationProgress == 1) {
      return overallProgress!.floor().toDouble() - 1;
    }
    // 4. Otherwise, return floor(overall progress).
    return overallProgress!.floor().toDouble();
  }

  PlaybackDirection? _calculateCurrentDirection(double? currentIteration) {
    PlaybackDirection? playbackDirection = timing!.direction;
    PlaybackDirection? currentDirection = playbackDirection;
    if (playbackDirection != PlaybackDirection.normal && playbackDirection != PlaybackDirection.reverse) {
      var d = currentIteration;
      if (playbackDirection == PlaybackDirection.alternateReverse) {
        d = d! + 1;
      }
      currentDirection = PlaybackDirection.normal;
      if (d != double.infinity && d! % 2 != 0) {
        currentDirection = PlaybackDirection.reverse;
      }
    }
    return currentDirection;
  }

  // 3.9.1. Calculating the directed progress
  // https://drafts.csswg.org/web-animations-1/#calculating-the-directed-progress
  double? _calculateDirectedProgress(double? currentIteration, PlaybackDirection? currentDirection, double? simpleIterationProgress) {
    // The directed progress is calculated from the simple iteration progress using the following steps:


    // 1. If the simple iteration progress is unresolved, return unresolved.
    if (simpleIterationProgress == null)
      return null;

    // 2. Calculate the current direction (we implement this as a separate method).

    // 3. If the current direction is forwards then return the simple iteration progress.
    if (currentDirection == PlaybackDirection.normal) {
      return simpleIterationProgress;
    }

     // Otherwise, return 1.0 - simple iteration progress.
    return 1 - simpleIterationProgress;
  }

  // The smallest positive double value that is greater than zero.
  static final double _epsilon = 4.94065645841247E-324;
  // Permit 2-bits of quantization error. Threshold based on experimentation
  // with accuracy of fmod.
  static final double _calculationEpsilon = 2.0 * _epsilon;

  // 3.10.1. Calculating the transformed progress
  // https://drafts.csswg.org/web-animations-1/#calculating-the-transformed-progress
  double? _calculateTransformedProgress(AnimationEffectPhase phase, double? activeTime, double? directedProgress, PlaybackDirection? currentDirection) {
    // The transformed progress is calculated from the directed progress using the following steps:
    //
    // 1. If the directed progress is unresolved, return unresolved.
    if (directedProgress == null)
      return null;

    // Snap boundaries to correctly render step timing functions at 0 and 1.
    // (crbug.com/949373)
    if (phase == AnimationEffectPhase.after) {
      bool isCurrentDirectionForward = currentDirection == PlaybackDirection.normal;
      if (isCurrentDirectionForward && (directedProgress - 1).abs() <= _calculationEpsilon) {
        directedProgress = 1;
      } else if (!isCurrentDirectionForward && (activeTime! - 0).abs() <= _calculationEpsilon) {
        directedProgress = 0;
      }
    }

    // Return the result of evaluating the animation effect’s timing function
    // passing directed progress as the input progress value.
    Curve easingCurve = timing!._getEasingCurve()!;
    return easingCurve.transform(directedProgress);
  }

  void _calculateTiming(double? localTime) {
    double activeDuration = _calculateActiveDuration();
    AnimationEffectPhase phase = _calculatePhase(activeDuration, localTime);
    double? activeTime = _calculateActiveTime(activeDuration, localTime, phase);
    double? overallProgress = _calculateOverallProgress(phase, activeTime);
    double? simpleIterationProgress = _calculateSimpleIterationProgress(overallProgress, phase, activeTime, activeDuration);
    double? currentIteration = _calculateCurrentIteration(phase, activeTime, simpleIterationProgress, overallProgress);
    PlaybackDirection? currentDirection = _calculateCurrentDirection(currentIteration);
    double? directedProgress = _calculateDirectedProgress(currentIteration, currentDirection, simpleIterationProgress);
    double? progress = _calculateTransformedProgress(phase, activeTime, directedProgress, currentDirection);

    _activeTime = activeTime;
    _progress = progress;
  }
}

class AnimationEffect {
  EffectTiming? timing;

  Map getComputedTiming() {
    throw UnsupportedError('Not supported');
  }

  EffectTiming? getTiming() {
    return timing;
  }

  updateTiming(Map<String, dynamic> optionalEffectTiming) {
    optionalEffectTiming.forEach((key, value) {
      switch (key) {
        case 'duration':
          timing!.duration = value;
          break;
        case 'delay':
          timing!.delay = value;
          break;
        case 'easing':
          timing!.easing = value;
          break;
        case 'direction':
          timing!.direction = value;
          break;
        case 'endDelay':
          timing!.endDelay = value;
          break;
        case 'fill':
          timing!.fill = value;
          break;
        case 'iterationStart':
          timing!.iterationStart = value;
          break;
        case 'iterations':
          timing!.iterations = value;
          break;
      }
    });
  }
}

class EffectTiming {
  // The number of milliseconds each iteration of the animation takes to complete.
  // Defaults to 0. Although this is technically optional,
  // keep in mind that your animation will not run if this value is 0.
  double? _duration;
  // The number of milliseconds to delay the start of the animation.
  // Defaults to 0.
  double? _delay;
  // The rate of the animation's change over time.
  // Accepts the pre-defined values "linear", "ease", "ease-in", "ease-out", and "ease-in-out",
  // or a custom "cubic-bezier" value like "cubic-bezier(0.42, 0, 0.58, 1)".
  // Defaults to "linear".
  String? _easing;
  Curve? _easingCurve;
  // Whether the animation runs forwards (normal), backwards (reverse),
  // switches direction after each iteration (alternate),
  // or runs backwards and switches direction after each iteration (alternate-reverse).
  // Defaults to "normal".
  PlaybackDirection? _direction;
  // The number of milliseconds to delay after the end of an animation.
  // This is primarily of use when sequencing animations based on the end time of another animation.
  // Defaults to 0.
  double? _endDelay;
  // Dictates whether the animation's effects should be reflected by the element(s) prior to playing ("backwards"),
  // retained after the animation has completed playing ("forwards"), or both. Defaults to "none".
  FillMode? _fill;
  // Describes at what point in the iteration the animation should start.
  // 0.5 would indicate starting halfway through the first iteration for example,
  // and with this value set, an animation with 2 iterations would end halfway through a third iteration.
  // Defaults to 0.0.
  double? _iterationStart;
  // The number of times the animation should repeat.
  // Defaults to 1, and can also take a value of Infinity to make it repeat for as long as the element exists.
  double? _iterations;

  EffectTiming({
    double duration = 0,
    double delay = 0,
    double endDelay = 0,
    double iterationStart = 0,
    double iterations = 1,
    String easing = 'linear',
    PlaybackDirection direction = PlaybackDirection.normal,
    FillMode fill = FillMode.auto
  }) {
    _duration = duration;
    _delay = delay;
    _endDelay = endDelay;
    _iterationStart = iterationStart;
    _iterations = iterations;
    _easing = easing;
    _direction = direction;
    _fill = fill;

    if (_easing != null) {
      _easingCurve = _parseEasing(_easing);
    }
  }

  double? get delay {
    return _delay;
  }

  set delay(double? value) {
    _delay = value;
  }

  PlaybackDirection? get direction {
    return _direction;
  }

  set direction(PlaybackDirection? value) {
    _direction = value;
  }

  double? get duration {
    return _duration;
  }

  set duration(double? value) {
    _duration = value;
  }

  String? get easing {
    return _easing;
  }

  set easing(String? value) {
    _easingCurve = _parseEasing(value);
    _easing = value;
  }

  Curve? _getEasingCurve() {
    return _easingCurve;
  }

  double? get endDelay {
    return _endDelay;
  }

  set endDelay(double? value) {
    _endDelay = value;
  }

  FillMode? get fill {
    return _fill;
  }

  set fill(FillMode? value) {
    _fill = value;
  }

  double? get iterationStart {
    return _iterationStart;
  }

  set iterationStart(double? value) {
    _iterationStart = value;
  }

  double? get iterations {
    return _iterations;
  }

  set iterations(double? value) {
    _iterations = value;
  }
}

