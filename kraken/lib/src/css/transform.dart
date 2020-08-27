import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/
mixin CSSTransformMixin on Node {
  static Matrix4 _matrix4 = Matrix4.identity();

  void updateRenderTransform(RenderTransform renderElementBoundary, String value) {
    Matrix4 matrix4 = CSSTransform.parseTransform(value);
    renderElementBoundary.transform = matrix4 ?? _matrix4;
  }

  void updateRenderTransformOrigin(RenderTransform renderElementBoundary, String present) {

    CSSTransformOrigin transformOrigin = _parseTransformOrigin(present);
    if (transformOrigin == null) return;

    Offset oldOffset = renderElementBoundary.origin;
    Offset offset = transformOrigin.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      renderElementBoundary.origin = offset;
    }

    Alignment alignment = transformOrigin.alignment;
    Alignment oldAlignment = renderElementBoundary.alignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      renderElementBoundary.alignment = alignment;
    }
  }

  CSSTransformOrigin _parseTransformOrigin(String origin) {
    if (origin != null && origin.isNotEmpty) {
      List<String> originList = origin.trim().split(' ');
      String x, y;
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
        String tmp = x;
        x = y;
        y = tmp;
      }
      // handle x
      if (CSSLength.isLength(x)) {
        offsetX = CSSLength.toDisplayPortValue(x) ?? offsetX;
      } else if (CSSPercentage.isPercentage(x)) {
        alignX = CSSPercentage.parsePercentage(x) * 2 - 1;
      } else if (x == CSSPosition.LEFT) {
        alignX = -1.0;
      } else if (x == CSSPosition.RIGHT) {
        alignX = 1.0;
      } else if (x == CSSPosition.CENTER) {
        alignX = 0.0;
      }

      // handle y
      if (CSSLength.isLength(y)) {
        offsetY = CSSLength.toDisplayPortValue(y) ?? offsetY;
      } else if (CSSPercentage.isPercentage(y)) {
        alignY = CSSPercentage.parsePercentage(y) * 2 - 1;
      } else if (y == CSSPosition.TOP) {
        alignY = -1.0;
      } else if (y == CSSPosition.BOTTOM) {
        alignY = 1.0;
      } else if (y == CSSPosition.CENTER) {
        alignY = 0.0;
      }
      return CSSTransformOrigin(Offset(offsetX, offsetY), Alignment(alignX, alignY));
    }
    return null;
  }

}

class CSSTransform {
  static Matrix4 parseTransform(String value) {
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(value);

    Matrix4 matrix4;
    for (CSSFunctionalNotation method in methods) {
      Matrix4 transform = _parseTransform(method);
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

  static Matrix4 _parseTransform(CSSFunctionalNotation method) {
    Matrix4 matrix4;
    switch (method.name) {
      case 'matrix':
        if (method.args.length == 6) {
          List<double> args = List(6);
          for (int i = 0; i < 6; i++) {
            args[i] = double.tryParse(method.args[i].trim()) ?? 1.0;
          }
          matrix4 = Matrix4(args[0], args[1], 0, 0, args[2], args[3], 0, 0, 0, 0, 1, 0, args[4], args[5], 0, 1);
        }
        break;
      case 'matrix3d':
        if (method.args.length == 16) {
          List<double> args = List(16);
          for (int i = 0; i < 16; i++) {
            args[i] = double.tryParse(method.args[i].trim()) ?? 1.0;
          }
          matrix4 = Matrix4(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9],
              args[10], args[11], args[12], args[13], args[14], args[15]);
        }
        break;
      case 'translate':
        if (method.args.length >= 1 && method.args.length <= 2) {
          double y;
          if (method.args.length == 2) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim()) ?? 0;
          } else {
            y = 0;
          }
          double x = CSSLength.toDisplayPortValue(method.args[0].trim());
          matrix4 = Matrix4.identity()..translate(x, y);
        }
        break;
      case 'translate3d':
        if (method.args.length >= 1 && method.args.length <= 3) {
          double y = 0, z = 0;
          if (method.args.length == 2) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim());
          }
          if (method.args.length == 3) {
            y = CSSLength.toDisplayPortValue(method.args[1].trim());
            z = CSSLength.toDisplayPortValue(method.args[2].trim());
          }
          double x = CSSLength.toDisplayPortValue(method.args[0].trim());
          matrix4 = Matrix4.identity()..translate(x, y, z);
        }
        break;
      case 'translateX':
        if (method.args.length == 1) {
          double x = CSSLength.toDisplayPortValue(method.args[0].trim());
          matrix4 = Matrix4.identity()..translate(x);
        }
        break;
      case 'translateY':
        if (method.args.length == 1) {
          double y = CSSLength.toDisplayPortValue(method.args[0].trim());
          matrix4 = Matrix4.identity()..translate(0.0, y);
        }
        break;
      case 'translateZ':
        if (method.args.length == 1) {
          double z = CSSLength.toDisplayPortValue(method.args[0].trim());
          matrix4 = Matrix4.identity()..translate(0.0, 0.0, z);
        }
        break;
      case 'rotate':
      case 'rotateZ':
        if (method.args.length == 1) {
          double angle = CSSAngle.parseAngle(method.args[0].trim());
          matrix4 = Matrix4.rotationZ(angle);
        }
        break;
      case 'rotate3d':
        if (method.args.length == 4) {
          double x = double.tryParse(method.args[0].trim()) ?? 0.0;
          double y = double.tryParse(method.args[1].trim()) ?? 0.0;
          double z = double.tryParse(method.args[2].trim()) ?? 0.0;
          double angle = CSSAngle.parseAngle(method.args[3].trim());
          Vector3 vector3 = Vector3(x, y, z);
          matrix4 = Matrix4.identity()..rotate(vector3, angle);
        }
        break;
      case 'rotateX':
        if (method.args.length == 1) {
          double x = CSSAngle.parseAngle(method.args[0].trim());
          matrix4 = Matrix4.rotationX(x);
        }
        break;
      case 'rotateY':
        if (method.args.length == 1) {
          double y = CSSAngle.parseAngle(method.args[0].trim());
          matrix4 = Matrix4.rotationY(y);
        }
        break;
      case 'scale':
        if (method.args.length >= 1 && method.args.length <= 2) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = x;
          if (method.args.length == 2) {
            y = double.tryParse(method.args[1].trim()) ?? x;
          }
          matrix4 = Matrix4.identity()..scale(x, y, 1);
        }
        break;
      case 'scale3d':
        if (method.args.length == 3) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = double.tryParse(method.args[1].trim()) ?? 1.0;
          double z = double.tryParse(method.args[2].trim()) ?? 1.0;
          matrix4 = Matrix4.identity()..scale(x, y, z);
        }
        break;
      case 'scaleX':
      case 'scaleY':
      case 'scaleZ':
        if (method.args.length == 1) {
          double scale = double.tryParse(method.args[0].trim()) ?? 1.0;
          double x = 1.0, y = 1.0, z = 1.0;
          if (method.name == 'scaleX') {
            x = scale;
          } else if (method.name == 'scaleY') {
            y = scale;
          } else {
            z = scale;
          }
          matrix4 = Matrix4.identity()..scale(x, y, z);
        }
        break;
      case 'skew':
        if (method.args.length == 1 || method.args.length == 2) {
          double alpha = CSSAngle.parseAngle(method.args[0].trim());
          double beta = 0.0;
          if (method.args.length == 2) {
            beta = CSSAngle.parseAngle(method.args[1].trim());
          }
          matrix4 = Matrix4.skew(alpha, beta);
        }
        break;
      case 'skewX':
      case 'skewY':
        if (method.args.length == 1) {
          double angle = CSSAngle.parseAngle(method.args[0].trim());
          if (method.name == 'skewX') {
            matrix4 = Matrix4.skewX(angle);
          } else {
            matrix4 = Matrix4.skewY(angle);
          }
        }
        break;
      case 'perspective':
        if (method.args.length == 1) {
          // @TODO perspective
        }
    }
    return matrix4;
  }
}

class CSSTransformOrigin {
  Offset offset;
  Alignment alignment;

  CSSTransformOrigin(this.offset, this.alignment);
}
