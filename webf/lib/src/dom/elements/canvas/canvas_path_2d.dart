/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

// ignore: non_constant_identifier_names
final double _2pi = 2 * math.pi;
final double _pi = math.pi;
final double _piOver2 = math.pi / 2;

class Path2D {
  Path _path = Path();

  get path {
    return _path;
  }

  final List<double> _points = [];

  void _setPoint(x, y) {
    _points.add(x);
    _points.add(y);
  }

  // Syncs _points from native
  void _syncCurrentPoint() {
    PathMetrics metrics = _path.computeMetrics();
    PathMetric metric = metrics.last;
    Tangent? tangent = metric.getTangentForOffset(metric.length);
    Offset position = tangent!.position;
    _setPoint(position.dx, position.dy);
  }

  Offset _getCurrentPoint() {
    return Offset(_points[_points.length - 2], _points[_points.length - 1]);
  }

  bool _hasCurrentPoint() {
    return _points.isNotEmpty;
  }

  // https://github.com/chromium/chromium/blob/99314be8152e688bafbbf9a615536bdbb289ea87/third_party/blink/renderer/modules/canvas/canvas2d/canvas_path.cc#L236
  List<double> _canonicalizeAngle(double startAngle, double endAngle) {
    // Make 0 <= startAngle < 2*PI
    double newStartAngle = startAngle % _2pi;

    if (newStartAngle < 0) {
      newStartAngle += _2pi;
      // Check for possible catastrophic cancellation in cases where
      // newStartAngle was a tiny negative number (c.f. crbug.com/503422)
      if (newStartAngle >= _2pi) newStartAngle -= _2pi;
    }

    double delta = newStartAngle - startAngle;
    startAngle = newStartAngle;
    endAngle = endAngle + delta;

    assert(newStartAngle >= 0);
    assert(newStartAngle < _2pi);

    return [startAngle, endAngle];
  }

  double _adjustEndAngle(double startAngle, double endAngle, bool anticlockwise) {
    double newEndAngle = endAngle;
    /* http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-arc
    * If the anticlockwise argument is false and endAngle-startAngle is equal
    * to or greater than 2pi, or,
    * if the anticlockwise argument is true and startAngle-endAngle is equal to
    * or greater than 2pi,
    * then the arc is the whole circumference of this ellipse, and the point at
    * startAngle along this circle's circumference, measured in radians clockwise
    * from the ellipse's semi-major axis, acts as both the start point and the
    * end point.
    */
    if (!anticlockwise && endAngle - startAngle >= _2pi) {
      newEndAngle = startAngle + _2pi;
    } else if (anticlockwise && startAngle - endAngle >= _2pi) {
      newEndAngle = startAngle - _2pi;

      /*
      * Otherwise, the arc is the path along the circumference of this ellipse
      * from the start point to the end point, going anti-clockwise if the
      * anticlockwise argument is true, and clockwise otherwise.
      * Since the _points are on the ellipse, as opposed to being simply angles
      * from zero, the arc can never cover an angle greater than 2pi radians.
      */
      /* NOTE: When startAngle = 0, endAngle = 2Pi and anticlockwise = true, the
      * spec does not indicate clearly.
      * We draw the entire circle, because some web sites use arc(x, y, r, 0,
      * 2*Math.PI, true) to draw circle.
      * We preserve backward-compatibility.
      */
    } else if (!anticlockwise && startAngle > endAngle) {
      newEndAngle = startAngle + (_2pi - (startAngle - endAngle) % _2pi);
    } else if (anticlockwise && startAngle < endAngle) {
      newEndAngle = startAngle - (_2pi - (endAngle - startAngle) % _2pi);
    }

    assert((endAngle - startAngle).abs() <= _2pi);
    assert((anticlockwise && (startAngle >= newEndAngle)) || (!anticlockwise && (newEndAngle >= startAngle)));
    return newEndAngle;
  }

  void closePath() {
    _path.close();
  }

  void addPath(Path2D path, {Float64List? matrix4}) {
    _path.addPath(path._path, Offset.zero, matrix4: matrix4);
    _syncCurrentPoint();
  }

  /// Adds a cubic bezier segment that curves from the current point
  /// to the given point (x3,y3), using the control _points (x1,y1) and
  /// (x2,y2).
  void bezierCurveTo(double cp1x, double cp1y, double cp2x, double cp2y, double x, double y) {
    if (!_hasCurrentPoint()) moveTo(cp1x, cp1y);

    _path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
    _setPoint(cp1x, cp1y);
    _setPoint(cp2x, cp2y);
    _setPoint(x, y);
  }

  void quadraticCurveTo(double cpx, double cpy, double x, double y) {
    if (!_hasCurrentPoint()) moveTo(cpx, cpy);

    _path.quadraticBezierTo(cpx, cpy, x, y);
    _setPoint(cpx, cpy);
    _setPoint(x, y);
  }

  void rect(double x, double y, double width, double height) {
    Rect rect = Rect.fromLTWH(x, y, width, height);
    _path.addRect(rect);
    _setPoint(rect.left, rect.top);
    _setPoint(rect.right, rect.top);
    _setPoint(rect.right, rect.bottom);
    _setPoint(rect.left, rect.bottom);
  }

  /// degenerateEllipse() handles a degenerated ellipse using several lines.
  ///
  /// Let's see a following example: line to ellipse to line.
  ///        _--^\
  ///       (     )
  /// -----(      )
  ///            )
  ///           /--------
  ///
  /// If radiusX becomes zero, the ellipse of the example is degenerated.
  ///         _
  ///        // P
  ///       //
  /// -----//
  ///      /
  ///     /--------
  ///
  /// To draw the above example, need to get P that is a local maximum point.
  /// Angles for P are 0.5Pi and 1.5Pi in the ellipse coordinates.
  ///
  /// If radiusY becomes zero, the result is as follows.
  /// -----__
  ///        --_
  ///          ----------
  ///            ``P
  /// Angles for P are 0 and Pi in the ellipse coordinates.
  ///
  /// To handle both cases, degenerateEllipse() lines to start angle, local maximum
  /// _points(every 0.5Pi), and end angle.
  /// NOTE: Before ellipse() calls this function, adjustEndAngle() is called, so
  /// endAngle - startAngle must be equal to or less than 2Pi.
  void _addDegenerateEllipse(double x, double y, double radiusX, double radiusY, double rotation, double startAngle,
      double endAngle, bool anticlockwise) {
    assert((endAngle - startAngle).abs() <= _2pi);
    assert(startAngle >= 0);
    assert(startAngle < _2pi);
    assert((anticlockwise && (startAngle - endAngle) >= 0) || (!anticlockwise && (endAngle - startAngle) >= 0));

    Matrix2 rotationMatrix = Matrix2.identity();
    rotationMatrix.setRotation(rotation);

    Vector2 point = rotationMatrix.transform(_getPointOnEllipse(radiusX, radiusY, startAngle));

    // First, if the object's path has any subpaths, then the method must add a
    // straight line from the last point in the subpath to the start point of the
    // arc.
    lineTo(x + point[0], y + point[1]);

    if ((radiusX == 0 && radiusY == 0) || startAngle == endAngle) return;

    if (!anticlockwise) {
      // start_angle - fmodf(start_angle, kPiOverTwoFloat) + kPiOverTwoFloat is
      // the one of (0, 0.5Pi, Pi, 1.5Pi, 2Pi) that is the closest to start_angle
      // on the clockwise direction.
      for (double angle = startAngle - (startAngle % _piOver2) + _piOver2; angle < endAngle; angle += _piOver2) {
        point = rotationMatrix.transform(_getPointOnEllipse(radiusX, radiusY, angle));
        lineTo(x + point[0], y + point[1]);
      }
    } else {
      for (double angle = startAngle - (startAngle % _piOver2); angle > endAngle; angle -= _piOver2) {
        point = rotationMatrix.transform(_getPointOnEllipse(radiusX, radiusY, angle));
        lineTo(x + point[0], y + point[1]);
      }
    }

    point = rotationMatrix.transform(_getPointOnEllipse(radiusX, radiusY, endAngle));
    lineTo(x + point[0], y + point[1]);
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/ellipse
  // https://github.com/chromium/chromium/blob/99314be8152e688bafbbf9a615536bdbb289ea87/third_party/blink/renderer/modules/canvas/canvas2d/canvas_path.cc#L378
  void ellipse(double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle,
      {bool anticlockwise = false}) {
    if (radiusX < 0 || radiusY < 0) {
      return;
    }

    List<double> normalizedAngles = _canonicalizeAngle(startAngle, endAngle);
    startAngle = normalizedAngles[0];
    endAngle = normalizedAngles[1];

    double adjustedEndAngle = _adjustEndAngle(startAngle, endAngle, anticlockwise);

    if (radiusX == 0 || radiusY == 0 || startAngle == adjustedEndAngle) {
      // The ellipse is empty but we still need to draw the connecting line to
      // start point.
      _addDegenerateEllipse(x, y, radiusX, radiusY, rotation, startAngle, adjustedEndAngle, anticlockwise);
      return;
    }

    _addRotateEllipse(x, y, radiusX, radiusY, rotation, startAngle, adjustedEndAngle);
  }

  // https://source.chromium.org/chromium/chromium/src/+/master:third_party/blink/renderer/platform/graphics/path.cc;l=403;drc=f6baa54c02fce19a1aeafbfeeebef9676fd9408b
  void _addRotateEllipse(
      double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle) {
    assert((endAngle - startAngle).abs() <= _2pi);
    assert(startAngle >= 0);
    assert(startAngle < _2pi);

    if (rotation == 0) {
      _addEllipse(x, y, radiusX, radiusY, startAngle, endAngle);
      return;
    }

    // Add an arc after the relevant transform.
    Matrix4 ellipseTransform = Matrix4.translationValues(x, y, 0);
    ellipseTransform.setRotationZ(rotation);

    Matrix4 inverseEllipseTransform = Matrix4.inverted(ellipseTransform);
    _path = _path.transform(inverseEllipseTransform.storage);
    _addEllipse(0, 0, radiusX, radiusY, startAngle, endAngle);
    _path = _path.transform(ellipseTransform.storage);

    _syncCurrentPoint();
  }

  Vector2 _getPointOnEllipse(double radiusX, double radiusY, double theta) {
    return Vector2(radiusX * math.cos(theta), radiusY * math.sin(theta));
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, {bool anticlockwise = false}) {
    if (radius < 0) {
      return;
    }
    if (radius == 0 || startAngle == endAngle) {
      // The arc is empty but we still need to draw the connecting line.
      return lineTo(x + radius * math.cos(startAngle), y + radius * math.sin(startAngle));
    }

    List<double> normalizedAngles = _canonicalizeAngle(startAngle, endAngle);
    startAngle = normalizedAngles[0];
    endAngle = normalizedAngles[1];

    _addArc(x, y, radius, startAngle, _adjustEndAngle(startAngle, endAngle, anticlockwise));

    _syncCurrentPoint();
  }

  void arcTo(double x1, double y1, double x2, double y2, double radius) {
    if (radius < 0) {
      return;
    }

    Offset p1 = Offset(x1, y1);
    Offset p2 = Offset(x2, y2);

    if (!_hasCurrentPoint()) {
      moveTo(x1, y1);
    } else if (p1 == _getCurrentPoint() || p1 == p2 || radius == 0) {
      lineTo(x1, y1);
    } else {
      _addArcTo(x1, y1, x2, y2, radius);
    }
  }

  // https://source.chromium.org/chromium/chromium/src/+/master:third_party/skia/src/core/SkPath.cpp;l=1340;drc=75a657f63c673633fa083c7321d82e5a1a3e0940
  void _addArcTo(double x1, double y1, double x2, double y2, double radius) {
    // TODO: inject moveTo if needed

    if (radius == 0) {
      return lineTo(x1, y1);
    }

    // need to know our prev pt so we can construct tangent vectors
    Offset start = _getCurrentPoint();

    // need double precision for these calcs.
    Offset befored = Offset(x1 - start.dx, y1 - start.dy);
    befored = befored * (1 / befored.distance);

    Offset afterd = Offset(x2 - x1, y2 - y1);
    afterd = afterd * (1 / afterd.distance);

    double cosh = befored.dx * afterd.dx + befored.dy * afterd.dy;
    double sinh = befored.dx * afterd.dy - befored.dy * afterd.dx;

    if (sinh == 0) {
      return lineTo(x1, y1);
    }

    double dist = (radius * (1 - cosh) / sinh).abs();
    double xx = x1 - dist * befored.dx;
    double yy = y1 - dist * befored.dy;
    // https://source.chromium.org/chromium/chromium/src/+/master:third_party/skia/src/core/SkPoint.cpp;l=38;drc=75a657f63c673633fa083c7321d82e5a1a3e0940
    double mag = math.sqrt(afterd.dx * afterd.dx + afterd.dy * afterd.dy);
    double scale = dist / mag;

    lineTo(xx, yy);

    double weight = math.sqrt(0.5 + cosh * 0.5);
    double cpx2 = x1 + afterd.dx * scale;
    double cpy2 = y1 + afterd.dy * scale;
    _path.conicTo(x1, y1, cpx2, cpy2, weight);

    _setPoint(x1, y1);
    _setPoint(cpx2, cpy2);
  }

  void _addArc(double x, double y, double radius, double startAngle, double endAngle) {
    _addEllipse(x, y, radius, radius, startAngle, endAngle);
  }

  void _addEllipse(double cx, double cy, double radiusX, double radiusY, double startAngle, double endAngle) {
    assert((endAngle - startAngle).abs() <= _2pi);
    assert(startAngle >= 0);
    assert(startAngle < _2pi);

    Rect oval = Rect.fromLTRB(cx - radiusX, cy - radiusY, cx + radiusX, cy + radiusY);
    double sweepAngle = endAngle - startAngle;

    // We can't use SkPath::addOval(), because addOval() makes a new sub-path.
    // addOval() calls moveTo() and close() internally.

    // Use 180 degree, not 360 degree, because SkPath::arcTo(oval, angle, 360, false) draws
    // nothing.
    if (sweepAngle == _2pi) {
      // SkPath::arcTo can't handle the sweepAngle that is equal to or greater
      // than 2Pi.
      _path.arcTo(oval, startAngle, _pi, false);
      _path.arcTo(oval, startAngle + _pi, _pi, false);
      return;
    } else if (sweepAngle == -_2pi) {
      _path.arcTo(oval, startAngle, -_pi, false);
      _path.arcTo(oval, startAngle - _pi, -_pi, false);
      return;
    }

    _path.arcTo(oval, startAngle, sweepAngle, false);
  }

  void moveTo(double x, double y) {
    _path.moveTo(x, y);
    _setPoint(x, y);
  }

  void lineTo(double x, double y) {
    if (!_hasCurrentPoint()) {
      moveTo(x, y);
    }
    _path.lineTo(x, y);
    _setPoint(x, y);
  }
}
