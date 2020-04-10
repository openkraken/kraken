import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:kraken/style.dart';
import 'package:kraken/rendering.dart';

mixin TransformStyleMixin {
  RenderTransform transform;
  Matrix4 matrix4 = Matrix4.identity();
  Map<String, Method> oldMethods;
  Offset oldOrigin;

  RenderObject initTransform(RenderObject current, StyleDeclaration style, int nodeId, bool shouldRender) {
    if (style.contains('transform')) {
      oldMethods = Method.parseMethod(style['transform']);
      matrix4 = combineTransform(oldMethods) ?? matrix4;
    }
    oldOrigin = parseOrigin(style['transformOrigin']);
    transform = RenderElementBoundary(
        child: current,
        transform: matrix4,
        nodeId: nodeId,
        style: style,
        origin: oldOrigin,
        shouldRender: shouldRender,
    );
    return transform;
  }

  void updateTransform(StyleDeclaration style,
      [Map<String, Transition> transitionMap]) {
    Offset offset = parseOrigin(style['transformOrigin']);
    transform.origin = offset;
    Map<String, Method> newMethods;
    if (style.contains('transform')) {
      newMethods = Method.parseMethod(style['transform']);
    }
    if (newMethods != null) {
      if (transitionMap != null) {
        Transition transition = transitionMap['transform'];
        Transition all = transitionMap['all'];
        Map<String, Method> baseMethods = oldMethods;
        ProgressListener progressListener = (progress) {
          if (progress > 0.0) {
            transform.transform = combineTransform(
                newMethods, oldMethods: baseMethods, progress: progress);
          }
        };
        if (transition != null) {
          transition.setProgressListener(progressListener);
        } else if (all != null) {
          all.addProgressListener(progressListener);
        } else {
          transform.transform = combineTransform(newMethods);
        }
      } else {
        transform.transform = combineTransform(newMethods);
      }
      oldMethods = newMethods;
    }
  }

  Offset parseOrigin(String origin) {
    Offset offset;
    if (origin != null && origin.isNotEmpty) {
      List<String> originList = origin.split(' ');
      //FIXME need support percentage and value
      //FIXME just support two value
      if (originList.length == 2) {
        offset = Offset(Length.toDisplayPortValue(originList[0]),
            Length.toDisplayPortValue(originList[1]));
      }
    }
    return offset;
  }

  Matrix4 combineTransform(Map<String, Method> methods,
      {double progress = 1.0, Map<String, Method> oldMethods}) {
    Matrix4 matrix4;
    for (Method method in methods?.values) {
      Matrix4 cur = getTransform(
          method, progress: progress, oldMethods: oldMethods);
      if (cur != null) {
        if (matrix4 == null) {
          matrix4 = cur;
        } else {
          matrix4.multiply(cur);
        }
      }
    }
    // default return identity
    return matrix4 ?? this.matrix4;
  }

  Matrix4 getTransform(Method method,
      {double progress = 1.0, Map<String, Method> oldMethods}) {
    Matrix4 matrix4;
    bool needDiff = progress != null;
    Method oldMethod = oldMethods != null ? oldMethods[method.name] : null;
    switch (method.name) {
      case 'matrix':
        if (method.args.length == 6) {
            List<double> args = List(6);
            bool hasOldValue = oldMethod != null && oldMethod.args.length == 6;
            for (int i = 0; i < 6; i++) {
              args[i] = needDiff ? _getProgressValue(
                  double.tryParse(method.args[i].trim()) ?? 1.0, hasOldValue
                  ? double.tryParse(oldMethod.args[i].trim()) ?? 1.0
                  : 1.0, progress) : double.tryParse(method.args[i].trim()) ??
                  1.0;
            }
            matrix4 = Matrix4(
                args[0],
                args[1],
                0,
                0,
                args[2],
                args[3],
                0,
                0,
                0,
                0,
                1,
                0,
                args[4],
                args[5],
                0,
                1);
        }
        break;
      case 'matrix3d':
        if (method.args.length == 16) {
            List<double> args = List(16);;
            bool hasOldValue = oldMethod != null && oldMethod.args.length == 16;
            for (int i = 0; i < 16; i++) {
              args[i] = needDiff ? _getProgressValue(
                  double.tryParse(method.args[i].trim()) ?? 1.0, hasOldValue
                  ? double.tryParse(oldMethod.args[i].trim()) ?? 1.0
                  : 1.0, progress) : double.tryParse(method.args[i].trim()) ??
                  1.0;
            }
            matrix4 = Matrix4(
                args[0],
                args[1],
                args[2],
                args[3],
                args[4],
                args[5],
                args[6],
                args[7],
                args[8],
                args[9],
                args[10],
                args[11],
                args[12],
                args[13],
                args[14],
                args[15]);
        }
        break;
      case 'translate':
        if (method.args.length >= 1 && method.args.length <= 2) {
            double y;
            if (method.args.length == 2) {
              y = Length.toDisplayPortValue(method.args[1].trim());
            } else {
              y = 0;
            }
            double x = Length.toDisplayPortValue(method.args[0].trim());
            if (needDiff) {
              double oldX = 0.0, oldY = 0.0;
              if (oldMethod != null && oldMethod.args.length >= 1 &&
                  oldMethod.args.length <= 2) {
                oldX = Length.toDisplayPortValue(oldMethod.args[0].trim());
                if (oldMethod.args.length == 2) {
                  oldY = Length.toDisplayPortValue(oldMethod.args[1].trim());
                }
              }
              x = _getProgressValue(x, oldX, progress);
              y = _getProgressValue(y, oldY, progress);
            }
            matrix4 = Matrix4.identity()
              ..translate(x, y);
        }
        break;
      case 'translate3d':
        if (method.args.length >= 1 && method.args.length <= 3) {
            double y = 0, z = 0;
            if (method.args.length == 2) {
              y = Length.toDisplayPortValue(method.args[1].trim());
            }
            if (method.args.length == 3) {
              y = Length.toDisplayPortValue(method.args[1].trim());
              z = Length.toDisplayPortValue(method.args[2].trim());
            }
            double x = Length.toDisplayPortValue(method.args[0].trim());
            if (needDiff) {
              double oldX = 0.0, oldY = 0.0, oldZ = 0.0;
              if (oldMethod != null && oldMethod.args.length >= 1 &&
                  oldMethod.args.length <= 3) {
                oldX = Length.toDisplayPortValue(oldMethod.args[0].trim());
                if (oldMethod.args.length == 2) {
                  oldY = Length.toDisplayPortValue(oldMethod.args[1].trim());
                }
                if (oldMethod.args.length == 3) {
                  oldY = Length.toDisplayPortValue(oldMethod.args[1].trim());
                  oldZ = Length.toDisplayPortValue(oldMethod.args[2].trim());
                }
              }
              x = _getProgressValue(x, oldX, progress);
              y = _getProgressValue(y, oldY, progress);
              z = _getProgressValue(z, oldZ, progress);
            }
            matrix4 = Matrix4.identity()
              ..translate(x, y, z);
        }
        break;
      case 'translateX':
        if (method.args.length == 1) {
          double x = Length.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldX = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldX = Length.toDisplayPortValue(oldMethod.args[0].trim());
            }
            x = _getProgressValue(x, oldX, progress);
          }
          matrix4 = Matrix4.identity()
            ..translate(x);
        }
        break;
      case 'translateY':
        if (method.args.length == 1) {
          double y = Length.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldY = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldY = Length.toDisplayPortValue(oldMethod.args[0].trim());
            }
            y = _getProgressValue(y, oldY, progress);
          }
          matrix4 = Matrix4.identity()
            ..translate(0.0, y);
        }
        break;
      case 'translateZ':
        if (method.args.length == 1) {
          double z = Length.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldZ = 0.0;
            if(oldMethod != null && oldMethod.args.length == 1) {
              oldZ = Length.toDisplayPortValue(oldMethod.args[0].trim());
            }
            z = _getProgressValue(z, oldZ, progress);
          }
          matrix4 = Matrix4.identity()
            ..translate(0.0, 0.0, z);
        }
        break;
      case 'rotate':
      case 'rotateZ':
        if (method.args.length == 1) {
          double angle = Angle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldAngle = 0.0;
            if(oldMethod != null && oldMethod.args.length == 1) {
              oldAngle = Angle(oldMethod.args[0].trim()).angleValue;
            }
            angle = _getProgressValue(angle, oldAngle, progress);
          }
          matrix4 = Matrix4.rotationZ(angle);
        }
        break;
      case 'rotate3d':
        if (method.args.length == 4) {
          double x = double.tryParse(method.args[0].trim()) ?? 0.0;
          double y = double.tryParse(method.args[1].trim()) ?? 0.0;
          double z = double.tryParse(method.args[2].trim()) ?? 0.0;
          double angle = Angle(method.args[3].trim()).angleValue;
          if (needDiff) {
            double oldX = 0.0, oldY = 0.0, oldZ = 0.0, oldAngle = 0.0;
            if(oldMethod != null && oldMethod.args.length == 4) {
              oldX = double.tryParse(oldMethod.args[0].trim()) ?? 0.0;
              oldY = double.tryParse(oldMethod.args[1].trim()) ?? 0.0;
              oldZ = double.tryParse(oldMethod.args[2].trim()) ?? 0.0;
              oldAngle = Angle(oldMethod.args[3].trim()).angleValue;
            }
            x = _getProgressValue(x, oldX, progress);
            y = _getProgressValue(y, oldY, progress);
            z = _getProgressValue(z, oldZ, progress);
            angle = _getProgressValue(angle, oldAngle, progress);
          }
          Vector3 vector3 = Vector3(x, y, z);
          matrix4 = Matrix4.identity()
            ..rotate(vector3, angle);
        }
        break;
      case 'rotateX':
        if (method.args.length == 1) {
          double x = Angle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldX = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldX = Angle(oldMethod.args[0].trim()).angleValue;
            }
            x = _getProgressValue(x, oldX, progress);
          }
          matrix4 = Matrix4.rotationX(x);
        }
        break;
      case 'rotateY':
        if (method.args.length == 1) {
          double y = Angle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldY = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldY = Angle(oldMethod.args[0].trim()).angleValue;
            }
            y = _getProgressValue(y, oldY, progress);
          }
          matrix4 = Matrix4.rotationY(y);
        }
        break;
      case 'scale':
        if (method.args.length >= 1 && method.args.length <= 2) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = 1;
          if (method.args.length == 2) {
            y = double.tryParse(method.args[1].trim()) ?? 1.0;
          }
          if (needDiff) {
            double oldX = 1.0;
            double oldY = 1.0;
            if (oldMethod != null && oldMethod.args.length >= 1 && oldMethod.args.length <= 2) {
              oldX = double.tryParse(oldMethod.args[0].trim()) ?? 1.0;
              if (oldMethod.args.length == 2) {
                oldY = double.tryParse(oldMethod.args[1].trim()) ?? 1.0;
              }
            }
            x = _getProgressValue(x, oldX, progress);
            y = _getProgressValue(y, oldY, progress);
          }
          matrix4 = Matrix4.identity()
            ..scale(x, y, 1);
        }
        break;
      case 'scale3d':
        if (method.args.length == 3) {
          double x = double.tryParse(method.args[0].trim()) ?? 1.0;
          double y = double.tryParse(method.args[1].trim()) ?? 1.0;
          double z = double.tryParse(method.args[2].trim()) ?? 1.0;
          if (needDiff) {
            double oldX = 1.0;
            double oldY = 1.0;
            double oldZ = 1.0;
            if (oldMethod != null && oldMethod.args.length == 3) {
              oldX = double.tryParse(oldMethod.args[0].trim()) ?? 1.0;
              oldY = double.tryParse(oldMethod.args[1].trim()) ?? 1.0;
              oldZ = double.tryParse(oldMethod.args[2].trim()) ?? 1.0;
            }
            x = _getProgressValue(x, oldX, progress);
            y = _getProgressValue(y, oldY, progress);
            z = _getProgressValue(z, oldZ, progress);
          }
          matrix4 = Matrix4.identity()
            ..scale(x, y, z);
        }
        break;
      case 'scaleX':
      case 'scaleY':
      case 'scaleZ':
        if (method.args.length == 1) {
          double scale = double.tryParse(method.args[0].trim()) ?? 1.0;
          if (needDiff) {
            double oldScale = 1.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldScale = double.tryParse(oldMethod.args[0].trim()) ?? 1.0;
            }
            scale = _getProgressValue(scale, oldScale, progress);
          }
          double x = 1.0, y = 1.0, z = 1.0;
          if (method.name == 'scaleX') {
            x = scale;
          } else if (method.name == 'scaleY') {
            y = scale;
          } else {
            z = scale;
          }
          matrix4 = Matrix4.identity()
            ..scale(x, y, z);
        }
        break;
      case 'skew':
        if (method.args.length == 1 || method.args.length == 2) {
          double alpha = Angle(method.args[0].trim()).angleValue;
          double beta = 0.0;
          if (method.args.length == 2) {
            beta = Angle(method.args[1].trim()).angleValue;
          }
          if (needDiff) {
            double oldAlpha = 0.0;
            double oldBeta = 0.0;
            if (oldMethod != null && (oldMethod.args.length == 1 || oldMethod.args.length == 2)) {
              oldAlpha = Angle(oldMethod.args[0].trim()).angleValue;
              if (oldMethod.args.length == 2) {
                oldBeta = Angle(oldMethod.args[1].trim()).angleValue;
              }
            }
            alpha = _getProgressValue(alpha, oldAlpha, progress);
            beta = _getProgressValue(beta, oldBeta, progress);
          }
          matrix4 = Matrix4.skew(alpha, beta);
        }
        break;
      case 'skewX':
      case 'skewY':
        if (method.args.length == 1) {
          double angle = Angle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldAngle = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldAngle = Angle(oldMethod.args[0].trim()).angleValue;
            }
            angle = _getProgressValue(angle, oldAngle, progress);
          }
          if (method.name == 'skewX') {
            matrix4 = Matrix4.skewX(angle);
          } else {
            matrix4 = Matrix4.skewY(angle);
          }
        }
        break;
      case 'perspective':
        if (method.args.length == 1) {
          //TODO perspective
        }
    }
    return matrix4;
  }

  double _getProgressValue(double newValue, double oldValue, double progress) {
    return oldValue + (newValue - oldValue) * progress;
  }
}
