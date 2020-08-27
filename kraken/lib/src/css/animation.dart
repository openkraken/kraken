import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';
import 'package:kraken/src/css/values/keywords.dart';
import 'package:kraken/src/element/event.dart';
import 'package:flutter/scheduler.dart';
import 'dart:core';

// https://drafts.csswg.org/web-animations/#enumdef-animationplaystate
enum AnimationPlayState { idle, running, paused, finished }

// https://drafts.csswg.org/web-animations/#the-animationreplacestate-enumeration
enum AnimationReplaceState { active, removed, persisted }

class AnimationTimeline {
  List<Animation> _animations = [];
  double _currentTime;
  Ticker _ticker;

  AnimationTimeline() {
    _ticker = Ticker(_onTick);
  }

  double get currentTime {
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
    _animations.forEach((Animation animation) {
      AnimationPlayState playState = animation.playState;
      if (playState != AnimationPlayState.finished && playState != AnimationPlayState.idle) {
        activeAnimations.add(animation);
      } else {
        animation._tick(_currentTime);
      }
    });
    return activeAnimations;
  }

  void _addAnimation(Animation animation) {
    if (_animations.indexOf(animation) == -1) {
      _animations.add(animation);
    }

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }
}

AnimationTimeline _documentTimeline = AnimationTimeline();

class Animation {
  double _startTime;
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
  KeyframeEffect _effect;
  AnimationTimeline _timeline;
  AnimationPlayState _playState;
  AnimationReplaceState _replaceState;

  Function onfinish;
  Function oncancel;
  Function onremove;

  Animation(KeyframeEffect effect, [AnimationTimeline timeline]) {

    if (timeline == null) {
      _timeline = _documentTimeline;
    }

    _effect = effect;

    double activeDuration = effect._calculateActiveDuration();
    _Phase phase = effect._calculatePhase(activeDuration, _currentTime);
    double activeTime = effect._calculateActiveTime(activeDuration, _currentTime, phase);

    _inEffect = activeTime != null;
  }

  double get currentTime {
    if (_isIdle || _isCurrentTimePending) return null;
    return _currentTime;
  }

  set currentTime(double newTime) {
    if (newTime == null) return;

    if (!_isPaused && _startTime != null) {
      _startTime = _timeline.currentTime - newTime / _playbackRate;
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

  _tickCurrentTime(newTime, [ignoreLimit = false]) {
    if (newTime != _currentTime) {
      _currentTime = newTime;
      if (_isFinished && !ignoreLimit)
        _currentTime = _playbackRate > 0 ? _totalDuration : 0;

      _ensureAlive();
      _effect._runIteration(_currentTime);
    }
  }

  AnimationEffect get effect {
    return _effect;
  }

  set effect(AnimationEffect effect) {
    _effect = effect;
  }

  AnimationTimeline get timeline {
    return _timeline;
  }

  set timeline(AnimationTimeline timeline) {
    _timeline = timeline;
  }

  double get playbackRate {
    return _playbackRate;
  }

  set playbackRate(double value) {
    if (value == _playbackRate) return;

    _effect._playbackRate = value;

    _playbackRate = value;

    double oldCurrentTime = currentTime;
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

  double get startTime {
    return _startTime;
  }

  set startTime(double value) {
    if (value == null) return;

    if (_isPaused || _isIdle) return;
    _startTime = value;
    _tickCurrentTime((_timeline.currentTime - _startTime) * playbackRate);
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

  // Indicates whether the animation is currently waiting for an asynchronous operation such as initiating playback or pausing a running animation.
  bool get pending {
    return (_startTime == null && !_isPaused && playbackRate != 0) || _isCurrentTimePending;
  }

  bool get _isFinished {
    return !_isIdle && (_playbackRate > 0 && _currentTime >= _totalDuration ||
        _playbackRate < 0 && _currentTime <= 0);
  }

  double get _totalDuration {
    return _effect._getTotalDuration();
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
    _effect._updateCurrentTime(null);

    if (oncancel != null) {
      var event = new AnimationPlaybackEvent('cancel');
      event.timelineTime = _timeline.currentTime;
      oncancel(event);
    }
  }

  void finish() {
    if (_isIdle)
      return;
    currentTime = _playbackRate > 0 ? _totalDuration : 0;
    _startTime = _totalDuration - currentTime;
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
      _inEffect = _effect._updateCurrentTime(-1);
    } else {
      _inEffect = _effect._updateCurrentTime(currentTime);
    }
    if (!_inTimeline && (_inEffect || !_finishedFlag)) {
      _inTimeline = true;
    }
    timeline._addAnimation(this);
  }

  void _rewind() {
    if (_playbackRate >= 0) {
      _currentTime = 0;
    } else {
      _currentTime = _totalDuration;
    }
  }

  void _tick(double timelineTime) {
    if (!_isIdle && !_isPaused) {
      if (_startTime == null) {
        startTime = timelineTime - _currentTime / playbackRate;
      } else if (!_isFinished) {
        _tickCurrentTime((timelineTime - _startTime) * playbackRate);
      }
    }
    _isCurrentTimePending = false;
    _fireEvents(timelineTime);
  }

  void _fireEvents(double timelineTime) {
    if (_isFinished) {
      if (!_finishedFlag) {
        AnimationPlaybackEvent event = new AnimationPlaybackEvent('finish');
        event.currentTime = currentTime;
        event.timelineTime = timelineTime;
        if (onfinish != null) onfinish(event);
        _finishedFlag = true;
      }
    } else {
      _finishedFlag = false;
    }
  }
}

class AnimationPlaybackEvent extends Event {
  AnimationPlaybackEvent(String type) : super(type);

  num currentTime;
  num timelineTime;
}

class Keyframe {
  String property;
  String value;
  double offset;
  String easing;
  Keyframe(this.property, this.value, this.offset, [this.easing]);
}

_defaultParse(value) {
  return value;
}

_defaultLerp(start, end, double progress){
  return progress < 0.5 ? start : end;
}

class _Interpolation {
  double startOffset;
  double endOffset;
  Curve easing;
  String property;
  var begin;
  var end;
  Function lerp;
  _Interpolation(this.property, this.startOffset, this.endOffset, this.easing, this.begin, this.end, this.lerp);
}

List<_Interpolation> _makeInterpolations(Map<String, List<Keyframe>> propertySpecificKeyframeGroups) {
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

      String left = keyframes[startIndex].value;
      String right = keyframes[endIndex].value;

      if (left == INITIAL)
        left = LonghandPropertyInitialValues[property];
      if (right == INITIAL)
        right = LonghandPropertyInitialValues[property];

      if (left == right) continue;

      List handlers = AnimationPropertyHandlers[property];
      if (handlers == null) {
        handlers = [_defaultParse, _defaultLerp];
      }
      Function parseProperty = handlers[0];
      
      _Interpolation interpolation = _Interpolation(
        property, 
        startOffset,
        endOffset,
        _parseEasing(keyframes[startIndex].easing),
        parseProperty(left),
        parseProperty(right),
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

Curve _parseEasing(String function) {
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
  if (methods != null && methods.length > 0) {
    CSSFunctionalNotation method = methods.first;
    if (method != null) {
      if (method.name == 'steps') {
        if (method.args.length >= 1) {
          var step = int.tryParse(method.args[0]);
          var isStart = false;
          if (method.args.length == 2) {
            isStart = method.args[1] == 'start';
          }
          return CSSStepCurve(step, isStart);
        }
      } else if (method.name == 'cubic-bezier') {
        if (method.args.length == 4) {
          var first = double.tryParse(method.args[0]);
          var sec = double.tryParse(method.args[1]);
          var third = double.tryParse(method.args[2]);
          var forth = double.tryParse(method.args[3]);
          return Cubic(first, sec, third, forth);
        }
      }
    }
  }
  return null;
}

enum _Phase {
  none,
  before,
  after,
  active
}

class KeyframeEffect extends AnimationEffect {
  Element target;
  List<_Interpolation> _interpolations;
  double _iterationProgress;
  double _playbackRate = 1;

  KeyframeEffect(this.target, List<Keyframe> keyframes, EffectTiming options) {

    timing = options == null ? EffectTiming() : options;

    if (keyframes != null) {
      var propertySpecificKeyframeGroups = _makePropertySpecificKeyframeGroups(keyframes);
      _interpolations = _makeInterpolations(propertySpecificKeyframeGroups);
    }
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
        propertySpecificKeyframeGroups[property].add(keyframe);
      }
    }

    return propertySpecificKeyframeGroups;
  }

  bool _updateCurrentTime(double currentTime) {
    double activeDuration = _calculateActiveDuration();
    _iterationProgress =  _calculateIterationProgress(activeDuration, currentTime);
    return _iterationProgress != null;
  }

  void _runIteration(double localTime) {
    if (_iterationProgress == null) return;

    for (int i = 0; i < _interpolations.length; i++) {
      _Interpolation interpolation = _interpolations[i];
      double startOffset = interpolation.startOffset;
      double endOffet = interpolation.endOffset;
      Curve easingCurve = interpolation.easing;
      String property = interpolation.property;
      double offsetFraction = _iterationProgress - startOffset;
      double localDuration = endOffet - startOffset;
      double scaledLocalTime = localDuration == 0 ? 0 : easingCurve.transform(offsetFraction / localDuration);
      
      String value = interpolation.lerp(interpolation.begin, interpolation.end, scaledLocalTime);
      target.setStyle(property, value);
    }
  }

  double _getTotalDuration() {
    double activeDuration = _calculateActiveDuration();
    return timing.delay + activeDuration + timing.endDelay;
  }

  double _calculateActiveDuration() {
    return (_repeatedDuration(timing) / _playbackRate).abs();
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-active-duration
  double _repeatedDuration(EffectTiming timing) {
    if (timing.duration == 0 || timing.iterations == 0) {
      return 0;
    }
    return timing.duration * timing.iterations;
  }

  // https://drafts.csswg.org/web-animations/#animation-effect-phases-and-states
  _Phase _calculatePhase(double activeDuration, double localTime) {
    if (localTime == null) {
      return _Phase.none;
    }

    var endTime = timing.delay + activeDuration + timing.endDelay;
    if (localTime < min<double>(timing.delay, endTime)) {
      return _Phase.before;
    }
    if (localTime >= min<double>(timing.delay + activeDuration, endTime)) {
      return _Phase.after;
    }

    return _Phase.active;
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-active-time
  // ignore: missing_return
  double _calculateActiveTime(double activeDuration, double localTime, _Phase phase) {
    FillMode fillMode = timing.fill;
    switch (phase) {
      case _Phase.before:
        if (fillMode == FillMode.backwards || fillMode == FillMode.both)
          return 0.0;
        return null;
      case _Phase.active:
        return localTime - timing.delay;
      case _Phase.after:
        if (fillMode == FillMode.forwards || fillMode == FillMode.both)
          return activeDuration;
        return null;
      case _Phase.none:
        return null;
    }
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-overall-progress
  double _calculateOverallProgress(_Phase phase, double activeTime) {
    double iterationStart = timing.iterationStart;
    double overallProgress = iterationStart;
    double iterationDuration = timing.duration;
    double iterations = timing.iterations;
    if (iterationDuration == 0) {
      if (phase != _Phase.before) {
        overallProgress += iterations;
      }
    } else {
      overallProgress += activeTime / iterationDuration;
    }
    return overallProgress;
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-simple-iteration-progress
  double _calculateSimpleIterationProgress(double overallProgress, _Phase phase, double activeTime) {
    double iterationStart = timing.iterationStart;
    double iterations = timing.iterations;
    double iterationDuration = timing.duration;
    double simpleIterationProgress = (overallProgress == double.infinity) ? iterationStart % 1 : overallProgress % 1;
    if (simpleIterationProgress == 0 && phase == _Phase.after && iterations != 0 &&
        (activeTime != 0 || iterationDuration == 0)) {
      simpleIterationProgress = 1;
    }
    return simpleIterationProgress;
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-current-iteration
  double _calculateCurrentIteration(_Phase phase, double simpleIterationProgress, double overallProgress) {
    double iterations = timing.iterations;
    if (phase == _Phase.after && iterations == double.infinity) {
      return double.infinity;
    }
    if (simpleIterationProgress == 1) {
      return overallProgress.floor().toDouble() - 1;
    }
    return overallProgress.floor().toDouble();
  }

  // https://drafts.csswg.org/web-animations/#calculating-the-directed-progress
  double _calculateDirectedProgress(double currentIteration, double simpleIterationProgress) {
    PlaybackDirection playbackDirection = timing.direction;
    PlaybackDirection currentDirection = playbackDirection;
    if (playbackDirection != PlaybackDirection.normal && playbackDirection != PlaybackDirection.reverse) {
      var d = currentIteration;
      if (playbackDirection == PlaybackDirection.alternateReverse) {
        d += 1;
      }
      currentDirection = PlaybackDirection.normal;
      if (d != double.infinity && d % 2 != 0) {
        currentDirection = PlaybackDirection.reverse;
      }
    }
    if (currentDirection == PlaybackDirection.normal) {
      return simpleIterationProgress;
    }
    return 1 - simpleIterationProgress;
  }

  double _calculateIterationProgress(double activeDuration, double localTime) {
    _Phase phase = _calculatePhase(activeDuration, localTime);
    double activeTime = _calculateActiveTime(activeDuration, localTime, phase);

    if (activeTime == null)
      return null;

    double overallProgress = _calculateOverallProgress(phase, activeTime);
    double simpleIterationProgress = _calculateSimpleIterationProgress(overallProgress, phase, activeTime);
    double currentIteration = _calculateCurrentIteration(phase, simpleIterationProgress, overallProgress);
    double directedProgress = _calculateDirectedProgress(currentIteration, simpleIterationProgress);

    // https://drafts.csswg.org/web-animations/#calculating-the-transformed-progress
    // https://drafts.csswg.org/web-animations/#calculating-the-iteration-progress
    Curve easingCurve = timing._getEasingCurve();
    return easingCurve.transform(directedProgress);
  }

}

class AnimationEffect {
  EffectTiming timing;

  Map getComputedTiming() {
    throw new UnsupportedError('Not supported');
  }

  EffectTiming getTiming() {
    return timing;
  }

  updateTiming(Map<String, dynamic> optionalEffectTiming) {
    optionalEffectTiming.forEach((key, value) {
      switch (key) {
        case 'duration':
          timing.duration = value;
          break;
        case 'delay':
          timing.delay = value;
          break;
        case 'easing':
          timing.easing = value;
          break;
        case 'direction':
          timing.direction = value;
          break;
        case 'endDelay':
          timing.endDelay = value;
          break;
        case 'fill':
          timing.fill = value;
          break;
        case 'iterationStart':
          timing.iterationStart = value;
          break;
        case 'iterations':
          timing.iterations = value;
          break;
      }
    });
  }
}


// https://drafts.csswg.org/web-animations/#enumdef-fillmode
enum FillMode { none, forwards, backwards, both, auto }
// https://drafts.csswg.org/web-animations/#enumdef-playbackdirection
enum PlaybackDirection { normal, reverse, alternate, alternateReverse }

class EffectTiming {
  // The number of milliseconds each iteration of the animation takes to complete.
  // Defaults to 0. Although this is technically optional,
  // keep in mind that your animation will not run if this value is 0.
  double _duration;
  // The number of milliseconds to delay the start of the animation.
  // Defaults to 0.
  double _delay;
  // The rate of the animation's change over time.
  // Accepts the pre-defined values "linear", "ease", "ease-in", "ease-out", and "ease-in-out",
  // or a custom "cubic-bezier" value like "cubic-bezier(0.42, 0, 0.58, 1)".
  // Defaults to "linear".
  String _easing;
  Curve _easingCurve;
  // Whether the animation runs forwards (normal), backwards (reverse),
  // switches direction after each iteration (alternate),
  // or runs backwards and switches direction after each iteration (alternate-reverse).
  // Defaults to "normal".
  PlaybackDirection _direction;
  // The number of milliseconds to delay after the end of an animation.
  // This is primarily of use when sequencing animations based on the end time of another animation.
  // Defaults to 0.
  double _endDelay;
  // Dictates whether the animation's effects should be reflected by the element(s) prior to playing ("backwards"),
  // retained after the animation has completed playing ("forwards"), or both. Defaults to "none".
  FillMode _fill;
  // Describes at what point in the iteration the animation should start.
  // 0.5 would indicate starting halfway through the first iteration for example,
  // and with this value set, an animation with 2 iterations would end halfway through a third iteration.
  // Defaults to 0.0.
  double _iterationStart;
  // The number of times the animation should repeat.
  // Defaults to 1, and can also take a value of Infinity to make it repeat for as long as the element exists.
  double _iterations;

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

  double get delay {
    return _delay;
  }

  set delay(double value) {
    _delay = value;
  }

  PlaybackDirection get direction {
    return _direction;
  }

  set direction(PlaybackDirection value) {
    _direction = value;
  }

  double get duration {
    return _duration;
  }

  set duration(double value) {
    _duration = value;
  }

  String get easing {
    return _easing;
  }

  set easing(String value) {
    _easingCurve = _parseEasing(value);
    _easing = value;
  }

  Curve _getEasingCurve() {
    return _easingCurve;
  }

  double get endDelay {
    return _endDelay;
  }

  set endDelay(double value) {
    _endDelay = value;
  }

  FillMode get fill {
    return _fill;
  }

  set fill(FillMode value) {
    _fill = value;
  }

  double get iterationStart {
    return _iterationStart;
  }

  set iterationStart(double value) {
    _iterationStart = value;
  }

  double get iterations {
    return _iterations;
  }

  set iterations(double value) {
    _iterations = value;
  }
}

