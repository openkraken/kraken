/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

export 'package:flutter/gestures.dart'
    show
        DragDownDetails,
        DragStartDetails,
        DragUpdateDetails,
        DragEndDetails,
        GestureTapDownCallback,
        GestureTapUpCallback,
        GestureTapCallback,
        GestureTapCancelCallback,
        GestureLongPressCallback,
        GestureLongPressStartCallback,
        GestureLongPressMoveUpdateCallback,
        GestureLongPressUpCallback,
        GestureLongPressEndCallback,
        GestureDragDownCallback,
        GestureDragStartCallback,
        GestureDragUpdateCallback,
        GestureDragEndCallback,
        GestureDragCancelCallback,
        GestureScaleStartCallback,
        GestureScaleUpdateCallback,
        GestureScaleEndCallback,
        GestureForcePressStartCallback,
        GestureForcePressPeakCallback,
        GestureForcePressEndCallback,
        GestureForcePressUpdateCallback,
        LongPressStartDetails,
        LongPressMoveUpdateDetails,
        LongPressEndDetails,
        ScaleStartDetails,
        ScaleUpdateDetails,
        ScaleEndDetails,
        TapDownDetails,
        TapUpDetails,
        ForcePressDetails,
        Velocity;
export 'package:flutter/rendering.dart' show RenderSemanticsGestureHandler;

// Examples can assume:
// bool _lights;
// void setState(VoidCallback fn) { }
// String _last;

/// Factory for creating gesture recognizers.
///
/// `T` is the type of gesture recognizer this class manages.
///
/// Used by [RawGestureDetector.gestures].
@optionalTypeArgs
abstract class GestureRecognizerFactory<T extends GestureRecognizer?> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const GestureRecognizerFactory();

  /// Must return an instance of T.
  T constructor();

  /// Must configure the given instance (which will have been created by
  /// `constructor`).
  ///
  /// This normally means setting the callbacks.
  void initializer(T instance);
}

/// Signature for closures that implement [GestureRecognizerFactory.constructor].
typedef GestureRecognizerFactoryConstructor<T extends GestureRecognizer> = T Function();

/// Signature for closures that implement [GestureRecognizerFactory.initializer].
typedef GestureRecognizerFactoryInitializer<T extends GestureRecognizer> = void Function(T instance);

/// Factory for creating gesture recognizers that delegates to callbacks.
///
/// Used by [RawGestureDetector.gestures].
class GestureRecognizerFactoryWithHandlers<T extends GestureRecognizer> extends GestureRecognizerFactory<T> {
  /// Creates a gesture recognizer factory with the given callbacks.
  ///
  /// The arguments must not be null.
  const GestureRecognizerFactoryWithHandlers(this._constructor, this._initializer);

  final GestureRecognizerFactoryConstructor<T> _constructor;

  final GestureRecognizerFactoryInitializer<T> _initializer;

  @override
  T constructor() => _constructor();

  @override
  void initializer(T instance) => _initializer(instance);
}
