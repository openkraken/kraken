/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:math' show max;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Returns a sequence containing the specified [Layer] and all of its
/// ancestors.  The returned sequence is in [parent, child] order.
Iterable<Layer> _getLayerChain(Layer start) {
  final layerChain = <Layer>[];
  for (Layer? layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

typedef IntersectionChangeCallback = void Function(
    IntersectionObserverEntry info);

mixin RenderIntersectionObserverMixin on RenderBox {
  IntersectionChangeCallback? _onIntersectionChange;
  IntersectionObserverLayer? intersectionObserverLayer;

  /// A list of event handlers
  List<IntersectionChangeCallback>? _listeners;

  void addIntersectionChangeListener(IntersectionChangeCallback callback) {
    // Init things
    if (_listeners == null) {
      _listeners = List.empty(growable: true);
      _onIntersectionChange = _dispatchChange;
    }
    // Avoid same listener added twice.
    if (!_listeners!.contains(callback)) {
      _listeners!.add(callback);
    }
  }

  void clearIntersectionChangeListeners() {
    _listeners?.clear();
    _listeners = null;
    _onIntersectionChange = null;
  }

  void removeIntersectionChangeListener(IntersectionChangeCallback callback) {
    if (_listeners == null) {
      _onIntersectionChange = null;
      return;
    }

    _listeners!.remove(callback);
    if (_listeners!.isEmpty) {
      _listeners = null;
      _onIntersectionChange = null;
    }
  }

  void _dispatchChange(IntersectionObserverEntry info) {
    // Not use for-in, and not cache length, due to callback call stack may
    // clear [_listeners], which case concurrent exception.
    for (int i = 0; i < (_listeners == null ? 0 : _listeners!.length); i++) {
      IntersectionChangeCallback callback = _listeners![i];
      callback(info);
    }
  }

  void paintIntersectionObserver(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    // Skip to next if not has intersection observer
    if (_onIntersectionChange == null) {
      callback(context, offset);
      return;
    }

    if (intersectionObserverLayer == null) {
      intersectionObserverLayer = IntersectionObserverLayer(
          elementSize: size,
          paintOffset: offset,
          onIntersectionChange: _onIntersectionChange!
      );
    } else {
      intersectionObserverLayer!.elementSize = semanticBounds.size;
      intersectionObserverLayer!.paintOffset = offset;
    }

    context.pushLayer(intersectionObserverLayer!, callback, offset);
  }
}

class IntersectionObserverLayer extends ContainerLayer {
  IntersectionObserverLayer(
      {required Size elementSize,
      required Offset paintOffset,
      required this.onIntersectionChange})
      : // TODO: This is zero for box element. For sliver element, this offset points to the start of the element which may be outside the viewport.
        _elementOffset = Offset.zero,
        _layerOffset = Offset.zero,
        _elementSize = elementSize,
        _paintOffset = paintOffset;

  /// The size of the corresponding element.
  Size _elementSize;

  static int _id = 0;
  int id = _id++;

  /// Keeps track of [IntersectionObserverLayer] objects that have been recently
  /// updated and that might need to report visibility changes.
  static final _updated = <int, IntersectionObserverLayer>{};

  /// 300ms delay compute layer offset
  static final Duration _updateInterval = Duration(milliseconds: 300);

  /// Offset to the start of the element, in local coordinates.
  final Offset _elementOffset;

  set elementSize(Size value) {
    if (value == _elementSize) return;
    _elementSize = value;
  }

  Offset _paintOffset;

  set paintOffset(Offset value) {
    if (value == _paintOffset) return;
    _paintOffset = value;
  }

  /// Last known layer offset supplied to [addToScene].  Never null.
  Offset _layerOffset;

  final IntersectionChangeCallback onIntersectionChange;

  /// Keeps track of the last known visibility state of a element.
  ///
  /// This is used to suppress extraneous callbacks when visibility hasn't
  /// changed.  Stores entries only for visible element objects;
  /// entries for non-visible ones are actively removed.
  IntersectionObserverEntry? _lastIntersectionInfo;

  /// Cache of layer transform to root layer.
  static final Map<int, Matrix4> _layerTransformCache = {};

  /// Converts a [Rect] in local coordinates of the specified [Layer] to a new
  /// [Rect] in global coordinates.
  Rect _localRectToGlobal(Layer layer, Rect localRect) {
    final layerChain = _getLayerChain(layer);

    // Skip the root layer which transforms from logical pixels to physical
    // device pixels.
    assert(layerChain.isNotEmpty);
    assert(layerChain.first is TransformLayer);
    final transform = _accumulateTransforms(layerChain.skip(1));
    return MatrixUtils.transformRect(transform, localRect);
  }

  /// Returns the accumulated transform from the specified sequence of [Layer]s.
  /// The sequence must be in [parent, child] order.  The sequence must not be
  /// null.
  Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
    Matrix4 transform = Matrix4.identity();
    if (layerChain.isNotEmpty) {
      var parent = layerChain.first;
      for (final child in layerChain) {
        Matrix4? cachedTransform = _layerTransformCache[child.hashCode];
        // Get the transform of parent layer to root layer directly if exists.
        if (cachedTransform != null) {
          transform = cachedTransform.clone();
        } else {
          (parent as ContainerLayer).applyTransform(child, transform);
          // Cache the transform of parent layer to root layer.
          _layerTransformCache[child.hashCode] = transform.clone();
        }
        parent = child;
      }
    }
    return transform;
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    _layerOffset = layerOffset;
    _scheduleIntersectionObservationUpdate();
    super.addToScene(builder, layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    _scheduleIntersectionObservationUpdate();
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    _scheduleIntersectionObservationUpdate();
  }

  /// See [Diagnosticable.debugFillProperties].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<Rect>('elementRect', _elementBounds))
      ..add(DiagnosticsProperty<Rect>('rootBounds', _rootBounds));
  }

  void _scheduleIntersectionObservationUpdate() {
    final isUpdateScheduled = _updated.isNotEmpty;
    _updated[id] = this;

    if (!isUpdateScheduled) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      Timer(_updateInterval, _handleUpdateTimer);
    }
  }

  /// [Timer] callback.  Defers visibility callbacks to execute after the next
  /// frame.
  static void _handleUpdateTimer() {
    // Ensure that work is done between frames so that calculations are
    // performed from a consistent state.  We use `scheduleTask<T>` here instead
    // of `addPostFrameCallback` or `scheduleFrameCallback` so that work will
    // be done even if a new frame isn't scheduled and without unnecessarily
    // scheduling a new frame.
    SchedulerBinding.instance!
        .scheduleTask<void>(_processCallbacks, Priority.touch);
  }

  /// Computes the bounds for the corresponding element in
  /// global coordinates.
  Rect _computeElementBounds() {
    final r = _localRectToGlobal(this, _elementOffset & _elementSize);
    return r.shift(_paintOffset + _layerOffset);
  }

  // https://github.com/google/flutter.widgets/blob/master/packages/visibility_detector/lib/src/visibility_detector_layer.dart#L130
  // Computes the accumulated clipping bounds, in global coordinates.
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    var clipRect = Offset.zero & RendererBinding.instance!.renderView.size;

    var parentLayer = parent;
    while (parentLayer != null) {
      Rect? curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect!.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath!.getBounds();
      }

      if (curClipRect != null) {
        // This is O(n^2) WRT the depth of the tree since `_localRectToGlobal`
        // also walks up the tree. In practice there probably will be a small
        // number of clipping layers in the chain, so it might not be a problem.
        // Alternatively we could cache transformations and clipping rectangles.
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  /// Invokes the visibility callback if [IntersectionObserverEntry] hasn't meaningfully
  /// changed since the last time we invoked it.
  void _fireCallback(IntersectionObserverEntry info) {
    final oldInfo = _lastIntersectionInfo;
    // If isIntersecting is true maybe not visible when element size is 0
    final isIntersecting = info.isIntersecting;

    if (oldInfo == null) {
      if (!isIntersecting) {
        return;
      }
    } else if (info.matchesIntersecting(oldInfo)) {
      return;
    }

    if (isIntersecting) {
      _lastIntersectionInfo = info;
    } else {
      // Track only visible items so that the maps don't grow unbounded.
      _lastIntersectionInfo = null;
    }
    // Notify visibility changed event
    onIntersectionChange(info);
  }

  Rect? _rootBounds;
  Rect? _elementBounds;
  int previousLayerHash = 0;

  /// Executes visibility callbacks for all updated.
  static void _processCallbacks() {
    for (final layer in _updated.values) {
      if (!layer.attached) {
        layer._fireCallback(IntersectionObserverEntry(size: Size.zero));
        continue;
      }

      Rect elementBounds = layer._computeElementBounds();
      Rect rootBounds = layer._computeClipRect();

      final info = IntersectionObserverEntry.fromRects(
          boundingClientRect: elementBounds, rootBounds: rootBounds);
      layer._fireCallback(info);
    }
    _updated.clear();
    _layerTransformCache.clear();
  }
}

@immutable
class IntersectionObserverEntry {
  const IntersectionObserverEntry(
      {Rect? boundingClientRect,
      Rect? intersectionRect,
      Rect? rootBounds,
      Size? size})
      : boundingClientRect = boundingClientRect ?? Rect.zero,
        intersectionRect = intersectionRect ?? Rect.zero,
        rootBounds = rootBounds ?? Rect.zero,
        size = size ?? Size.zero;

  /// Constructs a [IntersectionObserverEntry] from element bounds and a corresponding
  /// clipping rectangle.
  ///
  /// [boundingClientRect] and [rootBounds] are expected to be in the same coordinate
  /// system.
  factory IntersectionObserverEntry.fromRects({
    required Rect boundingClientRect,
    required Rect rootBounds,
  }) {

    // Compute the intersection in the element's local coordinates.
    final intersectionRect = boundingClientRect.overlaps(rootBounds)
        ? boundingClientRect
            .intersect(rootBounds)
            .shift(-boundingClientRect.topLeft)
        : Rect.zero;

    return IntersectionObserverEntry(
        boundingClientRect: boundingClientRect,
        intersectionRect: intersectionRect,
        rootBounds: rootBounds,
        size: boundingClientRect.size);
  }

  // A Boolean value which is true if the target element intersects with the intersection observer's root.
  // If this is true, then, the IntersectionObserverEntry describes a transition into a state of intersection;
  // if it's false, then you know the transition is from intersecting to not-intersecting.
  bool get isIntersecting {
    if (size == Size.zero) return false;

    if (boundingClientRect.right < rootBounds.left ||
        rootBounds.right < boundingClientRect.left) return false;
    if (boundingClientRect.bottom < rootBounds.top ||
        rootBounds.bottom < boundingClientRect.top) return false;
    return true;
  }

  /// The size of the element.
  final Size size;

  final Rect rootBounds;

  /// Returns the bounds rectangle of the target element.
  final Rect boundingClientRect;

  /// The visible portion of the element, in the element's local coordinates.
  ///
  /// The bounds are reported using the element's local coordinates to avoid
  /// expectations for the [IntersectionChangeCallback] to fire if the element's
  /// position changes but retains the same visibility.
  final Rect intersectionRect;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// element is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  double get intersectionRatio {
    final visibleArea = _area(intersectionRect.size);
    final maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      // Avoid division-by-zero.
      return 0;
    }

    var intersectionRatio = visibleArea / maxVisibleArea;

    if (_floatNear(intersectionRatio, 0)) {
      intersectionRatio = 0;
    } else if (_floatNear(intersectionRatio, 1)) {
      // The inexact nature of floating-point arithmetic means that sometimes
      // the visible area might never equal the maximum area (or could even
      // be slightly larger than the maximum).  Snap to the maximum.
      intersectionRatio = 1;
    }

    assert(intersectionRatio >= 0);
    assert(intersectionRatio <= 1);
    return intersectionRatio;
  }

  /// Returns true if the specified [IntersectionObserverEntry] object has equivalent
  /// visibility to this one.
  bool matchesIntersecting(IntersectionObserverEntry info) {
    // We don't override `operator ==` so that object equality can be separate
    // from whether two [IntersectionObserverEntry] objects are sufficiently similar
    // that we don't need to fire callbacks for both.  This could be pertinent
    // if other properties are added.
    return size == info.size && intersectionRect == info.intersectionRect;
  }
}

/// The tolerance used to determine whether two floating-point values are
/// approximately equal.
const _kDefaultTolerance = 0.01;

/// Computes the area of a rectangle of the specified dimensions.
double _area(Size size) {
  // Negative areas are considered empty.
  // Empty area considered square as zero.
  if (size.isEmpty) {
    return 0.0;
  }
  return size.width * size.height;
}

/// Returns whether two floating-point values are approximately equal.
bool _floatNear(double f1, double f2) {
  final absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance ||
      (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}
