/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/gestures.dart';

const String DIRECTION_UP = 'up';
const String DIRECTION_DOWN = 'down';
const String DIRECTION_LEFT = 'left';
const String DIRECTION_RIGHT = 'right';

/// Like [kSwipeSlop], but for more precise pointers like mice and trackpads.
const double kPrecisePointerSwipeSlop = kPrecisePointerHitSlop * 2.0; // Logical pixels

/// The distance a touch has to travel for the framework to be confident that
/// the gesture is a swipe gesture.
const double kSwipeSlop = kTouchSlop * 2.0; // Logical pixels


