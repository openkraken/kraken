import 'dart:math' show max;
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Returns a sequence containing the specified [Layer] and all of its
/// ancestors.  The returned sequence is in [parent, child] order.
Iterable<Layer> _getLayerChain(Layer start) {
  final layerChain = <Layer>[];
  for (var layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

/// Returns the accumulated transform from the specified sequence of [Layer]s.
/// The sequence must be in [parent, child] order.  The sequence must not be
/// null.
Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
  assert(layerChain != null);

  final transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    var parent = layerChain.first;
    for (final child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}

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

typedef IntersectionChangeCallback = void Function(IntersectionObserverEntry info);

// The [RenderObject] corresponding to the element.
class RenderIntersectionObserver extends RenderProxyBox {
  RenderIntersectionObserver({
    RenderBox child,
  }) : super(child);

  IntersectionChangeCallback _onIntersectionChange;

  /**
   * A list of event handlers
   */
  List<IntersectionChangeCallback> _listeners;

  void addListener(IntersectionChangeCallback callback) {
    // Init things
    if (_listeners == null) {
      _listeners = List();
      _onIntersectionChange = _dispatchChange;
    }
    _listeners.add(callback);
  }

  void removeListener(IntersectionChangeCallback callback) {
    for (int i = 0; i < _listeners.length; i += 1) {
      if (_listeners[i] == callback) {
        _listeners.removeAt(i);
        break;
      }
    }
    if (_listeners.isEmpty) {
      _listeners = null;
      _onIntersectionChange = null;
    }
  }

  void _dispatchChange(IntersectionObserverEntry info) {
    _listeners.forEach((IntersectionChangeCallback callback) {
      callback(info);
    });
  }

  // See [RenderProxyBox.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => _onIntersectionChange != null;

  IntersectionObserverLayer _layer;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (_onIntersectionChange == null) {
      super.paint(context, offset);
      return;
    }

    if (_layer == null) {
      _layer = IntersectionObserverLayer(
        elementSize: semanticBounds.size, paintOffset: offset, onIntersectionChange: _onIntersectionChange);
    } else {
      _layer.elementSize = semanticBounds.size;
      _layer.paintOffset = offset;
    }

    context.pushLayer(_layer, super.paint, offset);
  }
}

class IntersectionObserverLayer extends ContainerLayer {
  IntersectionObserverLayer(
      {@required this.elementSize, @required this.paintOffset, @required this.onIntersectionChange})
      : assert(paintOffset != null),
        assert(elementSize != null),
        assert(onIntersectionChange != null),
        _layerOffset = Offset.zero;

  /// The size of the corresponding element.
  Size elementSize;

  Offset paintOffset;

  /// Last known layer offset supplied to [addToScene].  Never null.
  Offset _layerOffset;

  final IntersectionChangeCallback onIntersectionChange;

  /// Keeps track of the last known visibility state of a element.
  ///
  /// This is used to suppress extraneous callbacks when visibility hasn't
  /// changed.  Stores entries only for visible element objects;
  /// entries for non-visible ones are actively removed.
  IntersectionObserverEntry _lastIntersectionInfo;

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
      ..add(DiagnosticsProperty<Rect>('elementRect', _computeElementBounds()))
      ..add(DiagnosticsProperty<Rect>('clipRect', _computeClipRect()));
  }

  bool _isScheduled = false;
  _scheduleIntersectionObservationUpdate() {

    if (!_isScheduled) {
      _isScheduled = true;
      scheduleMicrotask(() {
        _processCallbacks();
        _isScheduled = false;
      });
    }
  }

  /// Computes the bounds for the corresponding element in
  /// global coordinates.
  Rect _computeElementBounds() {
    final r = _localRectToGlobal(this, Offset.zero & elementSize);
    return r.shift(paintOffset + _layerOffset);
  }

  /// Computes the accumulated clipping bounds, in global coordinates.
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    var clipRect = Offset.zero & RendererBinding.instance.renderView.size;

    ContainerLayer parentLayer = parent;
    while (parentLayer != null) {
      Rect curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath.getBounds();
      }

      if (curClipRect != null) {
        // This is O(n^2) WRT the depth of the tree since `_localRectToGlobal`
        // also walks up the tree.  In practice there probably will be a small
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
    assert(info != null);

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

  /// Executes visibility callbacks for all updated.
  void _processCallbacks() {
    if (!attached) {
      _fireCallback(IntersectionObserverEntry(size: _lastIntersectionInfo?.size));
      return;
    }

    Rect elementBounds = _computeElementBounds();

    final info = IntersectionObserverEntry.fromRects(boundingClientRect: elementBounds, rootBounds: _computeClipRect());
    _fireCallback(info);
  }
}

@immutable
class IntersectionObserverEntry {
  const IntersectionObserverEntry({Rect boundingClientRect, Rect intersectionRect, Rect rootBounds, Size size})
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
    @required Rect boundingClientRect,
    @required Rect rootBounds,
  }) {
    assert(boundingClientRect != null);
    assert(rootBounds  != null);

    // Compute the intersection in the element's local coordinates.
    final intersectionRect =
        boundingClientRect.overlaps(rootBounds) ? boundingClientRect.intersect(rootBounds).shift(-boundingClientRect.topLeft) : Rect.zero;

    return IntersectionObserverEntry(
      boundingClientRect: boundingClientRect,
      intersectionRect: intersectionRect,
      rootBounds: rootBounds,
      size: boundingClientRect.size
    );
  }

  // A Boolean value which is true if the target element intersects with the intersection observer's root.
  // If this is true, then, the IntersectionObserverEntry describes a transition into a state of intersection; 
  // if it's false, then you know the transition is from intersecting to not-intersecting.
  bool get isIntersecting {
    if (boundingClientRect.right < rootBounds.left || rootBounds.right < boundingClientRect.left)
      return false;
    if (boundingClientRect.bottom < rootBounds.top || rootBounds.bottom < boundingClientRect.top)
      return false;
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
    assert(info != null);
    return size == info.size && intersectionRect == info.intersectionRect;
  }
}

/// The tolerance used to determine whether two floating-point values are
/// approximately equal.
const _kDefaultTolerance = 0.01;

/// Computes the area of a rectangle of the specified dimensions.
double _area(Size size) {
  assert(size != null);
  assert(size.width >= 0);
  assert(size.height >= 0);
  return size.width * size.height;
}

/// Returns whether two floating-point values are approximately equal.
bool _floatNear(double f1, double f2) {
  final absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance || (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}
