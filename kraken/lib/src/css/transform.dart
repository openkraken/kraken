


import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/
final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');

Color? _parseColor(String color, [Size? viewportSize]) {
  return CSSColor.parseColor(color);
}

void _updateColor(Color oldColor, Color newColor, double progress, String property, RenderStyle renderStyle) {
  int alphaDiff = newColor.alpha - oldColor.alpha;
  int redDiff = newColor.red - oldColor.red;
  int greenDiff = newColor.green - oldColor.green;
  int blueDiff = newColor.blue - oldColor.blue;

  int alpha = (alphaDiff * progress).toInt() + oldColor.alpha;
  int red = (redDiff * progress).toInt() + oldColor.red;
  int blue = (blueDiff * progress).toInt() + oldColor.blue;
  int green = (greenDiff * progress).toInt() + oldColor.green;
  Color color = Color.fromARGB(alpha, red, green, blue);
  switch (property) {
    case COLOR:
      renderStyle.color = color;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
    case TEXT_DECORATION_COLOR:
      renderStyle.textDecorationColor = color;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
    case BACKGROUND_COLOR:
      renderStyle.updateBackgroundColor(color);
      break;
    case BORDER_BOTTOM_COLOR:
    case BORDER_LEFT_COLOR:
    case BORDER_RIGHT_COLOR:
    case BORDER_TOP_COLOR:
    case BORDER_COLOR:
      renderStyle.updateBorder(property, borderColor: color);
      break;
  }
}

double? _parseLength(String _length, [Size? viewportSize]) {
  return CSSLength.parseLength(_length, viewportSize);
}

void _updateLength(double oldLength, double newLength, double progress, String property, RenderStyle renderStyle) {
  double length = oldLength * (1 - progress) + newLength * progress;

  switch (property) {
    case RIGHT:
    case TOP:
    case BOTTOM:
    case LEFT:
      renderStyle.updateOffset(property, length);
      break;
    case MARGIN_BOTTOM:
    case MARGIN_LEFT:
    case MARGIN_RIGHT:
    case MARGIN_TOP:
      renderStyle.updateMargin(property, length);
      break;
    case PADDING_BOTTOM:
    case PADDING_LEFT:
    case PADDING_RIGHT:
    case PADDING_TOP:
      renderStyle.updatePadding(property, length);
      break;
    case BORDER_BOTTOM_WIDTH:
    case BORDER_LEFT_WIDTH:
    case BORDER_RIGHT_WIDTH:
    case BORDER_TOP_WIDTH:
      renderStyle.updateBorder(property, borderWidth: length);
      break;
    case BORDER_BOTTOM_LEFT_RADIUS:
    case BORDER_BOTTOM_RIGHT_RADIUS:
    case BORDER_TOP_LEFT_RADIUS:
    case BORDER_TOP_RIGHT_RADIUS:
      renderStyle.updateBorderRadius(property, length.toString() + 'px');
      break;
    case FLEX_BASIS:
    case FONT_SIZE:
      renderStyle.fontSize = length;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
    case LETTER_SPACING:
      renderStyle.letterSpacing = length;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
    case WORD_SPACING:
      renderStyle.wordSpacing = length;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
    case HEIGHT:
    case WIDTH:
    case MAX_HEIGHT:
    case MAX_WIDTH:
    case MIN_HEIGHT:
    case MIN_WIDTH:
      renderStyle.updateSizing(property, length);
      break;
  }
}

FontWeight _parseFontWeight(String fontWeight, [Size? viewportSize]) {
  return CSSText.parseFontWeight(fontWeight);
}

void _updateFontWeight(FontWeight oldValue, FontWeight newValue, double progress, String property, RenderStyle renderStyle) {
  FontWeight? fontWeight = FontWeight.lerp(oldValue, newValue, progress);
  switch (property) {
    case FONT_WEIGHT:
      renderStyle.fontWeight = fontWeight;
      // Update style of children text nodes
      _updateChildTextNodes(renderStyle);
      break;
  }
}

double? _parseNumber(String number, [Size? viewportSize]) {
  return CSSNumber.parseNumber(number);
}

double _getNumber(double oldValue, double newValue, double progress) {
   return oldValue * (1 - progress) + newValue * progress;
}

void _updateNumber(double oldValue, double newValue, double progress, String property, RenderStyle renderStyle) {
  double number = _getNumber(oldValue, newValue, progress);
  switch (property) {
    case OPACITY:
      renderStyle.opacity = number;
      break;
    case Z_INDEX:
      renderStyle.zIndex = int.parse(number.toString());
      break;
    case FLEX_GROW:
      renderStyle.flexGrow = number;
      break;
    case FLEX_SHRINK:
      renderStyle.flexShrink = number;
      break;
  }
}

String _parseLineHeight(String lineHeight, [Size? viewportSize]) {
  return lineHeight;
}

void _updateLineHeight(String oldValue, String newValue, double progress, String property, RenderStyle renderStyle) {
  Size viewportSize = renderStyle.viewportSize;
  double? lineHeight;

  if (CSSLength.isLength(oldValue) && CSSLength.isLength(newValue)) {
    double left = CSSLength.parseLength(oldValue, viewportSize)!;
    double right = CSSLength.parseLength(newValue, viewportSize)!;
    lineHeight = _getNumber(left, right, progress);
  } else if (CSSNumber.isNumber(oldValue) && CSSNumber.isNumber(newValue)) {
    double left = CSSNumber.parseNumber(oldValue)!;
    double right = CSSNumber.parseNumber(newValue)!;
    lineHeight = _getNumber(left, right, progress);
  }

  switch (property) {
    case LINE_HEIGHT:
      renderStyle.lineHeight = lineHeight;
      break;
  }
}

Matrix4? _parseTransform(String value, [Size? viewportSize]) {
  return CSSTransform.parseTransform(value, viewportSize);
}

double _lerpDouble(double begin, double to, double t) {
  return begin * (1 - t) + to * t;
}

List<double> _lerpFloat64List(List<double> begin, List<double>? end, t) {
  List<double> r = [];
  for (int i = 0; i < begin.length; i++) {
    r.add(begin[i] * (1 - t) + end![i] * t);
  }
  return r;
}

void _updateTransform(Matrix4 begin, Matrix4 end, double t, String property, RenderStyle renderStyle) {
  Matrix4 newMatrix4;
  if (CSSTransform.isAffine(begin)) {
    List matrixA = CSSTransform.decompose2DMatrix(begin);
    List matrixB = CSSTransform.decompose2DMatrix(end);
    List lerp2D  = CSSTransform.lerp2DMatrix(matrixA, matrixB, t);
    newMatrix4 = CSSTransform.compose2DMatrix(lerp2D);
  } else {
    List beginMatrix = CSSTransform.decompose3DMatrix(begin)!;
    List endMatrix = CSSTransform.decompose3DMatrix(end)!;
    List beginQuaternion = beginMatrix[4];
    List endQuaternion = endMatrix[4];
    List<double> quaternion = CSSTransform.lerpQuaternion(beginQuaternion, endQuaternion, t);
    newMatrix4 = CSSTransform.compose3DMatrix(
      _lerpFloat64List(beginMatrix[0], endMatrix[0], t),
      _lerpFloat64List(beginMatrix[1], endMatrix[1], t),
      _lerpFloat64List(beginMatrix[2], endMatrix[2], t),
      _lerpFloat64List(beginMatrix[3], endMatrix[3], t),
      quaternion
    );
  }
  renderStyle.updateTransform(newMatrix4);
}

void _updateChildTextNodes(RenderStyle renderStyle) {
  RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
  ElementManager elementManager = renderBoxModel.elementManager!;
  int targetId = renderBoxModel.targetId;
  Element element = elementManager.getEventTargetByTargetId<Element>(targetId)!;
  for (Node? node in element.childNodes) {
    if (node is TextNode) {
      node.updateTextStyle();
    }
  }
}

const List<Function> _colorHandler = [_parseColor, _updateColor];
const List<Function> _lengthHandler = [_parseLength, _updateLength];
const List<Function> _fontWeightHandler = [_parseFontWeight, _updateFontWeight];
const List<Function> _numberHandler = [_parseNumber, _updateNumber];
const List<Function> _lineHeightHandler = [_parseLineHeight, _updateLineHeight];
const List<Function> _transformHandler = [_parseTransform, _updateTransform];

Map<String, List<Function>> CSSTransformHandlers = {
  COLOR: _colorHandler,
  BACKGROUND_COLOR: _colorHandler,
  BORDER_BOTTOM_COLOR: _colorHandler,
  BORDER_LEFT_COLOR: _colorHandler,
  BORDER_RIGHT_COLOR: _colorHandler,
  BORDER_TOP_COLOR: _colorHandler,
  BORDER_COLOR: _colorHandler,
  TEXT_DECORATION_COLOR: _colorHandler,
  OPACITY: _numberHandler,
  Z_INDEX: _numberHandler,
  FLEX_GROW: _numberHandler,
  FLEX_SHRINK: _numberHandler,
  FONT_WEIGHT: _fontWeightHandler,
  LINE_HEIGHT: _lineHeightHandler,
  TRANSFORM: _transformHandler,
  BORDER_BOTTOM_LEFT_RADIUS: _lengthHandler,
  BORDER_BOTTOM_RIGHT_RADIUS: _lengthHandler,
  BORDER_TOP_LEFT_RADIUS: _lengthHandler,
  BORDER_TOP_RIGHT_RADIUS: _lengthHandler,
  RIGHT: _lengthHandler,
  TOP: _lengthHandler,
  BOTTOM: _lengthHandler,
  LEFT: _lengthHandler,
  LETTER_SPACING: _lengthHandler,
  MARGIN_BOTTOM: _lengthHandler,
  MARGIN_LEFT: _lengthHandler,
  MARGIN_RIGHT: _lengthHandler,
  MARGIN_TOP: _lengthHandler,
  MIN_HEIGHT: _lengthHandler,
  MIN_WIDTH: _lengthHandler,
  PADDING_BOTTOM: _lengthHandler,
  PADDING_LEFT: _lengthHandler,
  PADDING_RIGHT: _lengthHandler,
  PADDING_TOP: _lengthHandler,
  // should non negative value
  BORDER_BOTTOM_WIDTH: _lengthHandler,
  BORDER_LEFT_WIDTH: _lengthHandler,
  BORDER_RIGHT_WIDTH: _lengthHandler,
  BORDER_TOP_WIDTH: _lengthHandler,
  FLEX_BASIS: _lengthHandler,
  FONT_SIZE: _lengthHandler,
  HEIGHT: _lengthHandler,
  WIDTH: _lengthHandler,
  MAX_HEIGHT: _lengthHandler,
  MAX_WIDTH: _lengthHandler,
};

double? _determinant(m) {
  return m[0][0] * m[1][1] * m[2][2] +
    m[1][0] * m[2][1] * m[0][2] +
    m[2][0] * m[0][1] * m[1][2] -
    m[0][2] * m[1][1] * m[2][0] -
    m[1][2] * m[2][1] * m[0][0] -
    m[2][2] * m[0][1] * m[1][0];
}

// from Wikipedia:
//
// [A B]^-1 = [A^-1 + A^-1B(D - CA^-1B)^-1CA^-1     -A^-1B(D - CA^-1B)^-1]
// [C D]      [-(D - CA^-1B)^-1CA^-1                (D - CA^-1B)^-1      ]
//
// Therefore
//
// [A [0]]^-1 = [A^-1       [0]]
// [C  1 ]      [ -CA^-1     1 ]
List _inverse(m) {
  var iDet = 1 / _determinant(m)!;
  var a = m[0][0], b = m[0][1], c = m[0][2];
  var d = m[1][0], e = m[1][1], f = m[1][2];
  var g = m[2][0], h = m[2][1], k = m[2][2];
  var ainv = [
    [(e * k - f * h) * iDet, (c * h - b * k) * iDet, (b * f - c * e) * iDet, 0],
    [(f * g - d * k) * iDet, (a * k - c * g) * iDet, (c * d - a * f) * iDet, 0],
    [(d * h - e * g) * iDet, (g * b - a * h) * iDet, (a * e - b * d) * iDet, 0]
  ];
  var lastRow = [];
  for (var i = 0; i < 3; i++) {
    num val = 0;
    for (var j = 0; j < 3; j++) {
      val += m[3][j] * ainv[j][i];
    }
    lastRow.add(val);
  }
  lastRow.add(1);
  ainv.add(lastRow);
  return ainv;
}

List _transposeMatrix4(m) {
  return [[m[0][0], m[1][0], m[2][0], m[3][0]],
          [m[0][1], m[1][1], m[2][1], m[3][1]],
          [m[0][2], m[1][2], m[2][2], m[3][2]],
          [m[0][3], m[1][3], m[2][3], m[3][3]]];
}

List<double> multVecMatrix(v, m) {
  List<double> result = [];
  for (int i = 0; i < 4; i++) {
    double val = 0;
    for (var j = 0; j < 4; j++) {
      val += v[j] * m[j][i];
    }
    result.add(val);
  }
  return result;
}

double _length(v) {
  return sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
}

List<double> _normalize(List<double> v) {
  var len = _length(v);
  return [v[0] / len, v[1] / len, v[2] / len];
}

List<double> _combine(v1, v2, v1s, v2s) {
  return [v1s * v1[0] + v2s * v2[0], v1s * v1[1] + v2s * v2[1],
          v1s * v1[2] + v2s * v2[2]];
}

List<double> _cross(v1, v2) {
  return [v1[1] * v2[2] - v1[2] * v2[1],
          v1[2] * v2[0] - v1[0] * v2[2],
          v1[0] * v2[1] - v1[1] * v2[0]];
}

double _dot(v1, v2) {
  double result = 0;
  for (var i = 0; i < v1._length; i++) {
    result += v1[i] * v2[i];
  }
  return result;
}

final double _1deg = 180 / pi;
final double _1rad = pi / 180;

double? _rad2deg(rad) {
  // angleInDegree = angleInRadians * (180 / Math.PI)
  return rad * _1deg;
}

double? _deg2rad(deg) {
  // angleInRadians = angleInDegrees * (Math.PI / 180)
  return deg * _1rad;
}

List<List<double>> _multiply(a, b) {
  List<List<double>> result = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 4; j++) {
      for (var k = 0; k < 4; k++) {
        result[i][j] += b[i][k] * a[k][j];
      }
    }
  }
  return result;
}

class CSSTransform {
  // https://drafts.csswg.org/css-transforms-2/#recomposing-to-a-3d-matrix
  static Matrix4 compose3DMatrix(translate, scale, skew, perspective, List<double> quaternion) {
    List<List<double>> matrix = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]];

    // apply perspective
    for (var i = 0; i < 4; i++) {
      matrix[i][3] = perspective[i];
    }

    // apply translation
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        matrix[3][i] += translate[j] * matrix[j][i];
      }
    }

    // apply rotation
    var x = quaternion[0];
    var y = quaternion[1];
    var z = quaternion[2];
    var w = quaternion[3];

    List<List<double>> rotationMatrix = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]];

    // Construct a composite rotation matrix from the quaternion values
    // rotationMatrix is a identity 4x4 matrix initially
    rotationMatrix[0][0] = 1 - 2 * (y * y + z * z);
    rotationMatrix[0][1] = 2 * (x * y - z * w);
    rotationMatrix[0][2] = 2 * (x * z + y * w);
    rotationMatrix[1][0] = 2 * (x * y + z * w);
    rotationMatrix[1][1] = 1 - 2 * (x * x + z * z);
    rotationMatrix[1][2] = 2 * (y * z - x * w);
    rotationMatrix[2][0] = 2 * (x * z - y * w);
    rotationMatrix[2][1] = 2 * (y * z + x * w);
    rotationMatrix[2][2] = 1 - 2 * (x * x + y * y);

    matrix = _multiply(matrix, rotationMatrix);

    // apply skew
    // temp is a identity 4x4 matrix initially
    List<List<double>> temp = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]];
    if (skew[2] != 0) {
      temp[2][1] = skew[2];
      matrix = _multiply(matrix, temp);
    }

    if (skew[1] != 0) {
      temp[2][1] = 0;
      temp[2][0] = skew[0];
      matrix = _multiply(matrix, temp);
    }

    if (skew[0] != 0) {
      temp[2][0] = 0;
      temp[1][0] = skew[0];
      matrix = _multiply(matrix, temp);
    }

    // apply scale
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        matrix[i][j] *= scale[i];
      }
    }

    return Matrix4.columns(
      Vector4.array(matrix[0]),
      Vector4.array(matrix[1]),
      Vector4.array(matrix[2]),
      Vector4.array(matrix[3])
    );
  }

  // https://github.com/WebKit/webkit/blob/950143da027e80924b4bb86defa8a3f21fd3fb1e/Source/WebCore/platform/graphics/transforms/TransformationMatrix.cpp#L530
  // Perform a spherical linear interpolation between the two
  // passed quaternions with 0 <= t <= 1.
  static List<double> lerpQuaternion(quaternionA, quaternionB, t) {
    var product = _dot(quaternionA, quaternionB);

    // Clamp product to -1.0 <= product <= 1.0
    product = max<double>(min<double>(product, 1.0), -1.0);

    List<double> quaternionDst = List.filled(4, 0);
    if (product.abs() == 1.0) {
      return quaternionDst = quaternionA;
    }

    var theta = acos(product);
    var w = sin(t * theta) * 1 / sqrt(1 - product * product);

    for (int i = 0; i < 4; i++) {
      quaternionA[i] *= cos(t * theta) - product * w;
      quaternionB[i] *= w;
      quaternionDst[i] = quaternionA[i] + quaternionB[i];
    }

    return quaternionDst;
  }

  // https://drafts.csswg.org/css-transforms-2/#decomposing-a-3d-matrix
  static List? decompose3DMatrix(Matrix4 matrix4) {
    List<double> m4storage = matrix4.storage;
    List<List<double>> matrix = [
      m4storage.sublist(0, 4),
      m4storage.sublist(4, 8),
      m4storage.sublist(8, 12),
      m4storage.sublist(12, 16)
    ];

    // Returns null if the matrix cannot be decomposed.
    // Normalize the matrix.
    if (matrix[3][3] == 0) {
      return null;
    }

    // perspectiveMatrix is used to solve for perspective, but it also provides
    // an easy way to test for singularity of the upper 3x3 component.
    List<List<double>?> perspectiveMatrix = List.filled(4, null);
    for (int i = 0; i < 4; i++) {
      perspectiveMatrix[i] = matrix[i].sublist(0);
    }

    for (int i = 0; i < 3; i++) {
      perspectiveMatrix[i]![3] = 0;
    }

    perspectiveMatrix[3]![3] = 1;

    if (_determinant(perspectiveMatrix) == 0) {
      return null;
    }

    // First, isolate perspective.

    // rightHandSide is the right hand side of the equation.
    List<double> rightHandSide = List.filled(4, 0);

    List<double> perspective;
    if (matrix[0][3] != 0 || matrix[1][3] != 0 || matrix[2][3] != 0) {
      rightHandSide[0] = matrix[0][3];
      rightHandSide[1] = matrix[1][3];
      rightHandSide[2] = matrix[2][3];
      rightHandSide[3] = matrix[3][3];

      // Solve the equation by inverting perspectiveMatrix and multiplying
      // rightHandSide by the inverse.
      var inversePerspectiveMatrix = _inverse(perspectiveMatrix);
      var transposedInversePerspectiveMatrix = _transposeMatrix4(inversePerspectiveMatrix);
      perspective = multVecMatrix(rightHandSide, transposedInversePerspectiveMatrix);
    } else {
      // No perspective.
      perspective = [0, 0, 0, 1];
    }

    // Next take care of translation
    List<double> translate = matrix[3].sublist(0, 3);

    // Now get scale and shear. 'row' is a 3 element array of 3 component vectors
    List<List<double>> row = [];
    row.add(matrix[0].sublist(0, 3));

    // Compute X scale factor and _normalize first row.
    List<double> scale = List.filled(3, 0);
    scale[0] = _length(row[0]);
    row[0] = _normalize(row[0]);

    // Compute XY shear factor and make 2nd row orthogonal to 1st.
    // skew factors XY,XZ,YZ represented as a 3 component vector
    List<double> skew = List.filled(3, 0);
    row.add(matrix[1].sublist(0, 3));
    skew[0] = _dot(row[0], row[1]);
    row[1] = _combine(row[1], row[0], 1.0, -skew[0]);

    // Now, compute Y scale and _normalize 2nd row.
    scale[1] = _length(row[1]);
    row[1] = _normalize(row[1]);
    skew[0] /= scale[1];

    // Compute XZ and YZ shears, orthogonalize 3rd row
    row.add(matrix[2].sublist(0, 3));
    skew[1] = _dot(row[0], row[2]);
    row[2] = _combine(row[2], row[0], 1.0, -skew[1]);
    skew[2] = _dot(row[1], row[2]);
    row[2] = _combine(row[2], row[1], 1.0, -skew[2]);

    // Next, get Z scale and _normalize 3rd row.
    scale[2] = _length(row[2]);
    row[2] = _normalize(row[2]);
    skew[1] /= scale[2];
    skew[2] /= scale[2];

    // At this point, the matrix (in rows) is orthonormal.
    // Check for a coordinate system flip.  If the _determinant
    // is -1, then negate the matrix and the scaling factors.
    var pdum3 = _cross(row[1], row[2]);
    if (_dot(row[0], pdum3) < 0) {
      for (var i = 0; i < 3; i++) {
        scale[i] *= -1;
        row[i][0] *= -1;
        row[i][1] *= -1;
        row[i][2] *= -1;
      }
    }

    // Now, get the rotations out
    List<double> quaternion = List.filled(4, 0); // a 4 component vector

    quaternion[0] = 0.5 * sqrt(max<double>(1 + row[0][0] - row[1][1] - row[2][2], 0));
    quaternion[1] = 0.5 * sqrt(max<double>(1 - row[0][0] + row[1][1] - row[2][2], 0));
    quaternion[2] = 0.5 * sqrt(max<double>(1 - row[0][0] - row[1][1] + row[2][2], 0));
    quaternion[3] = 0.5 * sqrt(max<double>(1 + row[0][0] + row[1][1] + row[2][2], 0));

    if (row[2][1] > row[1][2])
      quaternion[0] = -quaternion[0];
    if (row[0][2] > row[2][0])
      quaternion[1] = -quaternion[1];
    if (row[1][0] > row[0][1])
      quaternion[2] = -quaternion[2];

    return [translate, scale, skew, perspective, quaternion];
  }

  // https://github.com/WebKit/webkit/blob/950143da027e80924b4bb86defa8a3f21fd3fb1e/Source/WebCore/platform/graphics/transforms/TransformationMatrix.h#L328
  static bool isAffine(Matrix4 matrix4) {
    Float64List m = matrix4.storage;
    // is 2D
    return (
      m[2] == 0 &&
      m[3] == 0 &&
      m[6] == 0 &&
      m[7] == 0 &&
      m[8] == 0 &&
      m[9] == 0 &&
      m[10] == 1 &&
      m[11] == 0 &&
      m[14] == 0 &&
      m[15] == 1
    );
  }

  static Matrix4 compose2DMatrix(List decomposed) {
    // a 4x4 matrix initialized to identity matrix
    List<List<double>> matrix = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]];

    List<double> translate = decomposed[0];
    List<double> scale = decomposed[1];
    double angle = decomposed[2];
    double m11 = decomposed[3];
    double m12 = decomposed[4];
    double m21 = decomposed[5];
    double m22 = decomposed[6];

    matrix[0][0] = m11;
    matrix[0][1] = m12;
    matrix[1][0] = m21;
    matrix[1][1] = m22;

    // Translate matrix.
    matrix[3][0] = translate[0] * m11 + translate[1] * m21;
    matrix[3][1] = translate[0] * m12 + translate[1] * m22;

    // Rotate matrix.
    angle = _deg2rad(angle)!;
    double cosAngle = cos(angle);
    double sinAngle = sin(angle);

    // New temporary, identity initialized, 4x4 matrix rotateMatrix
    List<List<double>> rotateMatrix = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]];

    rotateMatrix[0][0] = cosAngle;
    rotateMatrix[0][1] = sinAngle;
    rotateMatrix[1][0] = -sinAngle;
    rotateMatrix[1][1] = cosAngle;

    matrix = _multiply(matrix, rotateMatrix);

    // Scale matrix.
    matrix[0][0] *= scale[0];
    matrix[0][1] *= scale[0];
    matrix[1][0] *= scale[1];
    matrix[1][1] *= scale[1];

    return Matrix4.columns(
      Vector4.array(matrix[0]),
      Vector4.array(matrix[1]),
      Vector4.array(matrix[2]),
      Vector4.array(matrix[3])
    );
  }


  // https://drafts.csswg.org/css-transforms-1/#interpolation-of-decomposed-2d-matrix-values
  // translationA ; a 2 component vector
  // scaleA       ; a 2 component vector
  // angleA       ; rotation
  // m11A         ; 1,1 coordinate of 2x2 matrix
  // m12A         ; 1,2 coordinate of 2x2 matrix
  // m21A         ; 2,1 coordinate of 2x2 matrix
  // m22A         ; 2,2 coordinate of 2x2 matrix
  // translationB ; a 2 component vector
  // scaleB       ; a 2 component vector
  // angleB       ; rotation
  // m11B         ; 1,1 coordinate of 2x2 matrix
  // m12B         ; 1,2 coordinate of 2x2 matrix
  // m21B         ; 2,1 coordinate of 2x2 matrix
  // m22B         ; 2,2 coordinate of 2x2 matrix
  static List lerp2DMatrix(List matrixA, List matrixB, double t) {
    // If x-axis of one is flipped, and y-axis of the other,
    // convert to an unflipped rotation.

    List<double> scaleA = matrixA[1];
    double angleA = matrixA[2];

    List<double> scaleB = matrixB[1];
    double angleB = matrixB[2];

    if ((scaleA[0] < 0 && scaleB[1] < 0) || (scaleA[1] < 0 && scaleB[0] < 0)) {
      scaleA[0] = -scaleA[0];
      scaleA[1] = -scaleA[1];
      angleA += angleA < 0 ? 180 : -180;
    }

    // Don’t rotate the long way around.
    if (angleA == 0)
      angleA = 360;
    if (angleB == 0)
      angleB = 360;

    if ((angleA - angleB).abs() > 180) {
      if (angleA > angleB)
        angleA -= 360;
      else
        angleB -= 360;
    }

    List<double> translate = _lerpFloat64List(matrixA[0], matrixB[0], t);
    List<double> scale = _lerpFloat64List(matrixA[1], matrixB[1], t);
    double angle = _lerpDouble(angleA, angleB, t);
    double m11 = _lerpDouble(matrixA[3], matrixB[3], t);
    double m12 = _lerpDouble(matrixA[4], matrixB[4], t);
    double m21 = _lerpDouble(matrixA[5], matrixB[5], t);
    double m22 = _lerpDouble(matrixA[6], matrixB[6], t);

    return [translate, scale, angle, m11, m12, m21, m22];
  }

  // https://drafts.csswg.org/css-transforms-1/#decomposing-a-2d-matrix
  static List decompose2DMatrix(Matrix4 matrix4) {

    List<double> m4storage = matrix4.storage;
    List<List<double>> matrix = [
      m4storage.sublist(0, 4),
      m4storage.sublist(4, 8),
      m4storage.sublist(8, 12),
      m4storage.sublist(12, 16)
    ];

    double row0x = matrix[0][0];
    double row0y = matrix[0][1];
    double row1x = matrix[1][0];
    double row1y = matrix[1][1];

    List<double> translate = List.filled(2, 0);
    translate[0] = matrix[3][0];
    translate[1] = matrix[3][1];

    // Compute scaling factors.
    List<double> scale = List.filled(2, 0); // [scaleX, scaleY]
    scale[0] = sqrt(row0x * row0x + row0y * row0y);
    scale[1] = sqrt(row1x * row1x + row1y * row1y);

    // If _determinant is negative, one axis was flipped.
    double _determinant = row0x * row1y - row0y * row1x;
    if (_determinant < 0) {
      // Flip axis with minimum unit vector _dot product.
      if (row0x < row1y)
        scale[0] = -scale[0];
      else
        scale[1] = -scale[1];
    }

    // Renormalize matrix to remove scale.
    if (scale[0] != 0) {
      row0x *= 1 / scale[0];
      row0y *= 1 / scale[0];
    }
    if (scale[1] != 0) {
      row1x *= 1 / scale[1];
      row1y *= 1 / scale[1];
    }

    // Compute rotation and renormalize matrix.
    double angle = atan2(row0y, row0x);

    if (angle != 0) {
      // Rotate(-angle) = [cos(angle), sin(angle), -sin(angle), cos(angle)]
      //                = [row0x, -row0y, row0y, row0x]
      // Thanks to the normalization above.
      double sn = -row0y;
      double cs = row0x;
      double m11 = row0x, m12 = row0y;
      double m21 = row1x, m22 = row1y;

      row0x = cs * m11 + sn * m21;
      row0y = cs * m12 + sn * m22;
      row1x = -sn * m11 + cs * m21;
      row1y = -sn * m12 + cs * m22;
    }

    double m11 = row0x;
    double m12 = row0y;
    double m21 = row1x;
    double m22 = row1y;

    // Convert into degrees because our rotation functions expect it.
    angle = _rad2deg(angle)!;

    return [translate, scale, angle, m11, m12, m21, m22];
  }

  static bool isValidTransformValue(String value, [Size? viewportSize]) {
    return value == NONE || parseTransform(value, viewportSize) != null;
  }

  static Matrix4 initial = Matrix4.identity();

  static Matrix4? parseTransform(String value, [Size? viewportSize]) {
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(value);

    Matrix4? matrix4;
    for (CSSFunctionalNotation method in methods) {
      Matrix4? transform = _parseTransform(method, viewportSize);
      if (transform != null) {
        if (matrix4 == null) {
          matrix4 = transform;
        } else {
          matrix4.multiply(transform);
        }
      }
    }
    return matrix4;
  }

  static const String MATRIX = 'matrix';
  static const String MATRIX_3D = 'matrix3d';
  static const String TRANSLATE = 'translate';
  static const String TRANSLATE_3D = 'translate3d';
  static const String TRANSLATE_X = 'translatex';
  static const String TRANSLATE_Y = 'translatey';
  static const String TRANSLATE_Z = 'translatez';
  static const String ROTATE = 'rotate';
  static const String ROTATE_3D = 'rotate3d';
  static const String ROTATE_X = 'rotatex';
  static const String ROTATE_Y = 'rotatey';
  static const String ROTATE_Z = 'rotatez';
  static const String SCALE = 'scale';
  static const String SCALE_3D = 'scale3d';
  static const String SCALE_X = 'scalex';
  static const String SCALE_Y = 'scaley';
  static const String SCALE_Z = 'scalez';
  static const String SKEW = 'skew';
  static const String SKEW_X = 'skewx';
  static const String SKEW_Y = 'skewy';
  static const String PERSPECTIVE = 'perspective';

  static Matrix4? _parseTransform(CSSFunctionalNotation method, [Size? viewportSize]) {
    switch (method.name) {
      case MATRIX:
        if (method.args.length == 6) {
          List<double?> args = List.filled(6, 0);
          for (int i = 0; i < 6; i++) {
            args[i] = double.tryParse(method.args[i].trim()) ?? 1.0;
          }
          return Matrix4(args[0]!, args[1]!, 0, 0, args[2]!, args[3]!, 0, 0, 0, 0, 1, 0, args[4]!, args[5]!, 0, 1);
        }
        break;
      case MATRIX_3D:
        if (method.args.length == 16) {
          List<double?> args = List.filled(16, 0);
          for (int i = 0; i < 16; i++) {
            args[i] = double.tryParse(method.args[i].trim()) ?? 1.0;
          }
          return Matrix4(args[0]!, args[1]!, args[2]!, args[3]!, args[4]!, args[5]!, args[6]!, args[7]!, args[8]!, args[9]!,
              args[10]!, args[11]!, args[12]!, args[13]!, args[14]!, args[15]!);
        }
        break;
      case TRANSLATE:
        if (method.args.length >= 1 && method.args.length <= 2) {
          double y;
          if (method.args.length == 2) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim(), viewportSize) ?? 0;
          } else {
            y = 0;
          }
          double x = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          return Matrix4.identity()..translate(x, y);
        }
        break;
      case TRANSLATE_3D:
        //  [1, 0, 0, 0,
        //   0, 1, 0, 0,
        //   0, 0, 1, 0,
        //   x, y, z, 1]
        if (method.args.length >= 1 && method.args.length <= 3) {
          double y = 0, z = 0;
          if (method.args.length == 2) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim(), viewportSize) ?? 0;
          }
          if (method.args.length == 3) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim(), viewportSize) ?? 0;
            z = CSSLength.toDisplayPortValue(method.args[2].trim(), viewportSize) ?? 0;
          }
          double x = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          return Matrix4.identity()..translate(x, y, z);
        }
        break;
      case TRANSLATE_X:
        if (method.args.length == 1) {
          double x = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          return Matrix4.identity()..translate(x);
        }
        break;
      case TRANSLATE_Y:
        if (method.args.length == 1) {
          double y = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          return Matrix4.identity()..translate(0.0, y);
        }
        break;
      case TRANSLATE_Z:
        if (method.args.length == 1) {
          double z = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          return Matrix4.identity()..translate(0.0, 0.0, z);
        }
        break;
      case ROTATE:
      case ROTATE_Z:
        if (method.args.length == 1) {
          double angle = CSSAngle.parseAngle(method.args[0].trim()) ?? 0;
          return Matrix4.rotationZ(angle);
        }
        break;
      case ROTATE_3D:
        if (method.args.length == 4) {
          double x = double.tryParse(method.args[0].trim()) ?? 0.0;
          double y = double.tryParse(method.args[1].trim()) ?? 0.0;
          double z = double.tryParse(method.args[2].trim()) ?? 0.0;
          double angle = CSSAngle.parseAngle(method.args[3].trim()) ?? 0;
          Vector3 vector3 = Vector3(x, y, z);
          return Matrix4.identity()..rotate(vector3, angle);
        }
        break;
      case ROTATE_X:
        if (method.args.length == 1) {
          double x = CSSAngle.parseAngle(method.args[0].trim()) ?? 0;
          return Matrix4.rotationX(x);
        }
        break;
      case ROTATE_Y:
        if (method.args.length == 1) {
          double y = CSSAngle.parseAngle(method.args[0].trim()) ?? 0;
          return Matrix4.rotationY(y);
        }
        break;
      case SCALE:
        if (method.args.length >= 1 && method.args.length <= 2) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = x;
          if (method.args.length == 2) {
            y = double.tryParse(method.args[1].trim()) ?? x;
          }
          return Matrix4.identity()..scale(x, y, 1);
        }
        break;
      case SCALE_3D:
        // [scaleX, 0, 0, 0,
        //   0, scaleY, 0, 0,
        //   0, 0, scaleY, 0,
        //   0, 0, 0, 1]
        if (method.args.length == 3) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = double.tryParse(method.args[1].trim()) ?? 1.0;
          double z = double.tryParse(method.args[2].trim()) ?? 1.0;
          return Matrix4.identity()..scale(x, y, z);
        }
        break;
      case SCALE_X:
      case SCALE_Y:
      case SCALE_Z:
        if (method.args.length == 1) {
          double scale = double.tryParse(method.args[0].trim()) ?? 1.0;
          double x = 1.0, y = 1.0, z = 1.0;
          if (method.name == SCALE_X) {
            x = scale;
          } else if (method.name == SCALE_Y) {
            y = scale;
          } else {
            z = scale;
          }
          return Matrix4.identity()..scale(x, y, z);
        }
        break;
      case SKEW:
        if (method.args.length == 1 || method.args.length == 2) {
          double alpha = CSSAngle.parseAngle(method.args[0].trim()) ?? 0;
          double beta = 0.0;
          if (method.args.length == 2) {
            beta = CSSAngle.parseAngle(method.args[1].trim()) ?? 0;
          }
          return Matrix4.skew(alpha, beta);
        }
        break;
      case SKEW_X:
      case SKEW_Y:
        if (method.args.length == 1) {
          double angle = CSSAngle.parseAngle(method.args[0].trim()) ?? 0;
          if (method.name == SKEW_X) {
            return Matrix4.skewX(angle);
          } else {
            return Matrix4.skewY(angle);
          }
        }
        break;
      case PERSPECTIVE:
        //  [
        //   1, 0, 0, 0,
        //   0, 1, 0, 0,
        //   0, 0, 1, perspective,
        //   0, 0, 0, 1]
        if (method.args.length == 1) {
          double p = CSSLength.toDisplayPortValue(method.args[0].trim(), viewportSize) ?? 0;
          p = (-1 / p);
          return Matrix4.identity()..storage[11] = p;
        }
        break;
    }
    return null;
  }
}

class CSSOrigin {
  Offset offset;
  Alignment alignment;

  CSSOrigin(this.offset, this.alignment);

  static CSSOrigin? parseOrigin(String origin, Size viewportSize) {
    if (origin.isNotEmpty) {
      List<String> originList = origin.trim().split(_spaceRegExp);
      String? x, y;
      if (originList.length == 1) {
        // default center
        x = originList[0];
        y = CSSPosition.CENTER;
        // flutter just support two value x y
        // FIXME when flutter support three value
      } else if (originList.length == 2 || originList.length == 3) {
        x = originList[0];
        y = originList[1];
      }
      // when origin property is not null, default is not center
      double offsetX = 0, offsetY = 0, alignX = -1, alignY = -1;
      // y just can be left right center when x is top bottom, otherwise illegal
      // switch to right place
      if ((x == CSSPosition.TOP || x == CSSPosition.BOTTOM) &&
          (y == CSSPosition.LEFT || y == CSSPosition.RIGHT || y == CSSPosition.CENTER)) {
        String? tmp = x;
        x = y;
        y = tmp;
      }

      // handle x
      if (CSSLength.isLength(x)) {
        offsetX = CSSLength.toDisplayPortValue(x, viewportSize) ?? offsetX;
      } else if (CSSPercentage.isPercentage(x)) {
        alignX = CSSPercentage.parsePercentage(x!)! * 2 - 1;
      } else if (x == CSSPosition.LEFT) {
        alignX = -1.0;
      } else if (x == CSSPosition.RIGHT) {
        alignX = 1.0;
      } else if (x == CSSPosition.CENTER) {
        alignX = 0.0;
      }

      // handle y
      if (CSSLength.isLength(y)) {
        offsetY = CSSLength.toDisplayPortValue(y, viewportSize) ?? offsetY;
      } else if (CSSPercentage.isPercentage(y)) {
        alignY = CSSPercentage.parsePercentage(y!)! * 2 - 1;
      } else if (y == CSSPosition.TOP) {
        alignY = -1.0;
      } else if (y == CSSPosition.BOTTOM) {
        alignY = 1.0;
      } else if (y == CSSPosition.CENTER) {
        alignY = 0.0;
      }
      return CSSOrigin(Offset(offsetX, offsetY), Alignment(alignX, alignY));
    }
    return null;
  }
}

mixin CSSTransformMixin on RenderStyleBase {

  Matrix4? get transform => _transform;
  Matrix4? _transform;
  set transform(Matrix4? value) {
    if (_transform == value) return;
    _transform = value;
  }

  Offset get transformOffset => _transformOffset;
  Offset _transformOffset = Offset(0, 0);
  set transformOffset(Offset value) {
    if (_transformOffset == value) return;
    _transformOffset = value;
    renderBoxModel!.markNeedsPaint();
  }

  Alignment get transformAlignment => _transformAlignment;
  Alignment _transformAlignment = Alignment.center;
  set transformAlignment(Alignment value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    renderBoxModel!.markNeedsPaint();
  }

  void updateTransform(
    Matrix4? matrix4,
    {
      bool shouldToggleRepaintBoundary = true,
      bool shouldMarkNeedsLayout = true
    }
  ) {
    // If render box model was not created yet, then exit.
    if (renderBoxModel == null) {
      return;
    }

    ElementManager elementManager = renderBoxModel!.elementManager!;
    int targetId = renderBoxModel!.targetId;
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId)!;
    element.renderBoxModel!.renderStyle.transform = matrix4;

    if (shouldToggleRepaintBoundary) {
      if (element.shouldConvertToRepaintBoundary) {
        element.convertToRepaintBoundary();
      } else {
        element.convertToNonRepaintBoundary();
      }
    }

    if (shouldMarkNeedsLayout) {
      element.renderBoxModel!.markNeedsLayout();
    }
  }

  void updateTransformOrigin(String present, [CSSOrigin? newOrigin]) {
    CSSOrigin? transformOriginValue = newOrigin ?? CSSOrigin.parseOrigin(present, viewportSize);
    if (transformOriginValue == null) return;

    Offset oldOffset = transformOffset;
    Offset offset = transformOriginValue.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      transformOffset = offset;
    }

    Alignment alignment = transformOriginValue.alignment;
    Alignment oldAlignment = transformAlignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      transformAlignment = alignment;
    }
  }
}

