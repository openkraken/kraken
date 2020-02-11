import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin TransformStyleMixin {
  RenderTransform transform;
  Matrix4 matrix4 = Matrix4.identity();

  RenderObject initTransform(RenderObject current, Style style, int nodeId) {
    if (style?.transform != null) {
      List<Method> methods = Method.parseMethod(style.transform);
      matrix4 = combineTransform(methods) ?? matrix4;
    }
    Offset offset = parseOrigin(style?.transformOrigin);
    transform = RenderBoxModel(
        child: current,
        transform: matrix4,
        origin: offset,
        nodeId: nodeId,
        style: style);
    return transform;
  }

  void updateTransform(Style style, [Map<String, Transition> transitionMap]) {
    Offset offset = parseOrigin(style?.transformOrigin);
    transform.origin = offset;
    Matrix4 newMatrix4;
    if (style?.transform != null) {
      List<Method> methods = Method.parseMethod(style.transform);
      newMatrix4 = combineTransform(methods);
    }
    if (newMatrix4 != null) {
      if (transitionMap != null) {
        Transition transition = transitionMap["transform"];
        Transition all = transitionMap["all"];
        Matrix4 oldMatrix4 = matrix4.clone();
        ProgressListener progressListener = (progress) {
          transform.transform =
              (newMatrix4 - oldMatrix4) * progress + oldMatrix4;
        };
        if (transition != null) {
          transition.addProgressListener(progressListener);
        } else if (all != null) {
          all.addProgressListener(progressListener);
        } else {
          transform.transform = newMatrix4;
        }
      } else {
        transform.transform = newMatrix4;
      }
      matrix4 = newMatrix4;
    }
    (transform as RenderBoxModel).style = style;
  }

  Offset parseOrigin(String origin) {
    Offset offset;
    if (origin != null && origin.isNotEmpty) {
      List<String> originList = origin.split(" ");
      //FIXME need support percentage and value
      //FIXME just support two value
      if (originList.length == 2) {
        offset = Offset(Length.toDisplayPortValue(originList[0]),
            Length.toDisplayPortValue(originList[1]));
      }
    }
    return offset;
  }

  Matrix4 combineTransform(List<Method> methods) {
    Matrix4 matrix4;
    for (Method method in methods) {
      Matrix4 cur = getTransform(method);
      if (cur != null) {
        if (matrix4 == null) {
          matrix4 = cur;
        } else {
          matrix4.multiply(cur);
        }
      }
    }
    return matrix4;
  }

  Matrix4 getTransform(Method method) {
    Matrix4 matrix4;
    switch (method.name.trim()) {
      case 'matrix':
        if (method.args.length == 6) {
          try {
            matrix4 = Matrix4(
                double.parse(method.args[0].trim()),
                double.parse(method.args[1].trim()),
                0,
                0,
                double.parse(method.args[2].trim()),
                double.parse(method.args[3].trim()),
                0,
                0,
                0,
                0,
                1,
                0,
                double.parse(method.args[4].trim()),
                double.parse(method.args[5].trim()),
                0,
                1);
          } catch (exception) {}
        }
        break;
      case 'matrix3d':
        if (method.args.length == 16) {
          try {
            matrix4 = Matrix4(
                double.parse(method.args[0].trim()),
                double.parse(method.args[1].trim()),
                double.parse(method.args[2].trim()),
                double.parse(method.args[3].trim()),
                double.parse(method.args[4].trim()),
                double.parse(method.args[5].trim()),
                double.parse(method.args[6].trim()),
                double.parse(method.args[7].trim()),
                double.parse(method.args[8].trim()),
                double.parse(method.args[9].trim()),
                double.parse(method.args[10].trim()),
                double.parse(method.args[11].trim()),
                double.parse(method.args[12].trim()),
                double.parse(method.args[13].trim()),
                double.parse(method.args[14].trim()),
                double.parse(method.args[15].trim()));
          } catch (exception) {}
        }
        break;
      case 'translate':
        if (method.args.length >= 1 && method.args.length <= 2) {
          try {
            double y = 0;
            if (method.args.length == 2) {
              y = Length.toDisplayPortValue(method.args[1].trim());
            }
            matrix4 = Matrix4.identity()
              ..translate(Length.toDisplayPortValue(method.args[0].trim()), y);
          } catch (exception) {}
        }
        break;
      case 'translate3d':
        if (method.args.length >= 1 && method.args.length <= 3) {
          try {
            double y = 0, z = 0;
            if (method.args.length == 2) {
              y = Length.toDisplayPortValue(method.args[1].trim());
            }
            if (method.args.length == 3) {
              y = Length.toDisplayPortValue(method.args[1].trim());
              z = Length.toDisplayPortValue(method.args[2].trim());
            }
            matrix4 = Matrix4.identity()
              ..translate(
                  Length.toDisplayPortValue(method.args[0].trim()), y, z);
          } catch (exception) {}
        }
        break;
      case 'translateX':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..translate(Length.toDisplayPortValue(method.args[0].trim()));
          } catch (exception) {}
        }
        break;
      case 'translateY':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..translate(
                  0.0, Length.toDisplayPortValue(method.args[0].trim()));
          } catch (exception) {
            print(exception);
          }
        }
        break;
      case 'translateZ':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..translate(
                  0.0, 0, Length.toDisplayPortValue(method.args[0].trim()));
          } catch (exception) {}
        }
        break;
      case 'rotate':
      case 'rotateZ':
        if (method.args.length == 1) {
          try {
            matrix4 =
                Matrix4.rotationZ(Angle(method.args[0].trim()).angleValue);
          } catch (exception) {}
        }
        break;
      case 'rotate3d':
        if (method.args.length == 4) {
          try {
            double x = double.parse(method.args[0].trim());
            double y = double.parse(method.args[1].trim());
            double z = double.parse(method.args[2].trim());
            Vector3 vector3 = Vector3(x, y, z);
            matrix4 = Matrix4.identity()
              ..rotate(vector3, Angle(method.args[3].trim()).angleValue);
          } catch (exception) {}
        }
        break;
      case 'rotateX':
        if (method.args.length == 1) {
          try {
            matrix4 =
                Matrix4.rotationX(Angle(method.args[0].trim()).angleValue);
          } catch (exception) {}
        }
        break;
      case 'rotateY':
        if (method.args.length == 1) {
          try {
            matrix4 =
                Matrix4.rotationY(Angle(method.args[0].trim()).angleValue);
          } catch (exception) {}
        }
        break;
      case 'scale':
        if (method.args.length >= 1 && method.args.length <= 2) {
          try {
            double y = 1;
            if (method.args.length == 2) {
              y = double.parse(method.args[1].trim());
            }
            matrix4 = Matrix4.identity()
              ..scale(double.parse(method.args[0].trim()), y, 1);
          } catch (exception) {}
        }
        break;
      case 'scale3d':
        if (method.args.length == 3) {
          try {
            matrix4 = Matrix4.identity()
              ..scale(
                  double.parse(method.args[0].trim()),
                  double.parse(method.args[1].trim()),
                  double.parse(method.args[2].trim()));
          } catch (exception) {}
        }
        break;
      case 'scaleX':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..scale(double.parse(method.args[0].trim()), 1, 1);
          } catch (exception) {}
        }
        break;
      case 'scaleY':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..scale(1.0, double.parse(method.args[0].trim()), 1);
          } catch (exception) {}
        }
        break;
      case 'scaleZ':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.identity()
              ..scale(1.0, 1, double.parse(method.args[0].trim()));
          } catch (exception) {}
        }
        break;
      case 'skew':
        try {
          if (method.args.length >= 1) {
            double alpha = double.parse(method.args[0].trim());
            if (method.args.length == 2) {
              double beta = double.parse(method.args[1].trim());
              matrix4 = Matrix4.skew(alpha, beta);
            } else if (method.args.length == 1) {
              matrix4 = Matrix4.skewX(alpha);
            }
          }
        } catch (exception) {}
        break;
      case 'skewX':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.skewX(double.parse(method.args[0].trim()));
          } catch (exception) {}
        }
        break;
      case 'skewY':
        if (method.args.length == 1) {
          try {
            matrix4 = Matrix4.skewY(double.parse(method.args[0].trim()));
          } catch (exception) {}
        }
        break;
      case 'perspective':
        if (method.args.length == 1) {
          //TODO perspective
        }
    }
    return matrix4;
  }
}
