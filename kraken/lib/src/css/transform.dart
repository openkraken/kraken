import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/

mixin CSSTransformMixin on Node {
  RenderTransform transform;
  Matrix4 matrix4 = Matrix4.identity();
  Map<String, CSSFunctionValue> prevMethods;

  // transform origin impl by offset and alignment
  Offset oldOffset = Offset.zero;
  Alignment oldAlignment = Alignment.center;
  int targetId;

  RenderObject initTransform(RenderObject current, CSSStyleDeclaration style, int targetId) {

    this.targetId = targetId;

    if (style.contains('transform')) {
      prevMethods = CSSFunctionValue.parseExpression(style['transform']);
      matrix4 = combineTransform(prevMethods) ?? matrix4;
      CSSTransformOrigin transformOrigin = parseOrigin(style['transformOrigin']);
      if (transformOrigin != null) {
        oldOffset = transformOrigin.offset;
        oldAlignment = transformOrigin.alignment;
      }
    }

    bool shouldRender = style['display'] != 'none';
    transform = RenderElementBoundary(
      child: current,
      transform: matrix4,
      targetId: targetId,
      style: style,
      origin: oldOffset,
      alignment: oldAlignment,
      shouldRender: shouldRender,
    );
    return transform;
  }

  void updateTransform(String transformStr,
      [Map<String, CSSTransition> transitionMap]) {
    Map<String, CSSFunctionValue> newMethods = CSSFunctionValue.parseExpression(transformStr);
    // transform transition
    if (newMethods != null) {
      if (transitionMap != null) {
        CSSTransition transition = transitionMap['transform'];
        CSSTransition all = transitionMap['all'];
        Map<String, CSSFunctionValue> baseMethods = prevMethods;
        CSSTransitionProgressListener progressListener = (progress) {
          if (progress > 0.0) {
            transform.transform = combineTransform(
                newMethods, prevMethods: baseMethods, progress: progress);
          }
        };
        if (transition != null) {
          transition.addProgressListener(progressListener);
        } else if (all != null) {
          all.addProgressListener(progressListener);
        } else {
          transform.transform = combineTransform(newMethods);
        }
      } else {
        transform.transform = combineTransform(newMethods);
      }
      prevMethods = newMethods;
    }
  }

  void updateTransformOrigin(String transformOriginStr,
      [Map<String, CSSTransition> transitionMap]) {
    Offset offset = Offset.zero;
    Alignment alignment = Alignment.center;
    CSSTransformOrigin transformOrigin = parseOrigin(transformOriginStr);
    if (transformOrigin != null) {
      offset = transformOrigin.offset;
      alignment = transformOrigin.alignment;
    }
    // transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      if (transitionMap != null) {
        CSSTransition all = transitionMap['all'];
        CSSTransition transitionOrigin = transitionMap['transform-origin'];
        Offset baseOffset = oldOffset;
        Offset diffOffset = offset - baseOffset;
        CSSTransitionProgressListener originProgressListener = (progress) {
          if (progress > 0.0) {
            transform.origin = diffOffset * progress + baseOffset;
          }
        };
        if (transitionOrigin != null) {
          transitionOrigin.addProgressListener(originProgressListener);
        } else if (all != null) {
          all.addProgressListener(originProgressListener);
        } else {
          transform.origin = offset;
        }
      } else {
        transform.origin = offset;
      }
      oldOffset = offset;
    }
    // transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      if (transitionMap != null) {
        CSSTransition all = transitionMap['all'];
        CSSTransition transitionOrigin = transitionMap['transform-origin'];
        Alignment baseAlign = oldAlignment;
        Alignment diffAlign = alignment - baseAlign;
        CSSTransitionProgressListener originProgressListener = (progress) {
          if (progress > 0.0) {
            transform.alignment = diffAlign * progress + baseAlign;
          }
        };
        if (transitionOrigin != null) {
          transitionOrigin.addProgressListener(originProgressListener);
        } else if (all != null) {
          all.addProgressListener(originProgressListener);
        } else {
          transform.alignment = alignment;
        }
      } else {
        transform.alignment = alignment;
      }
      oldAlignment = alignment;
    }
  }

  CSSTransformOrigin parseOrigin(String origin) {
    if (origin != null && origin.isNotEmpty) {
      List<String> originList = origin.trim().split(' ');
      String x, y;
      if (originList.length == 1) {
        // default center
        x = originList[0];
        y = CENTER;
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
      if ((x == TOP || x == BOTTOM) &&
          (y == LEFT || y == RIGHT || y == CENTER)) {
        String tmp = x;
        x = y;
        y = tmp;
      }
      // handle x
      if (CSSLength.isLength(x)) {
        offsetX = CSSLength.toDisplayPortValue(x);
      } else if (CSSPercentage.isPercentage(x)) {
        alignX = CSSPercentage(x).toDouble() * 2 - 1;
      } else if (x == LEFT) {
        alignX = -1.0;
      } else if (x == RIGHT) {
        alignX = 1.0;
      } else if (x == CENTER) {
        alignX = 0.0;
      }

      // handle y
      if (CSSLength.isLength(y)) {
        offsetY = CSSLength.toDisplayPortValue(y);
      } else if (CSSPercentage.isPercentage(y)) {
        alignY = CSSPercentage(y).toDouble() * 2 - 1;
      } else if (y == TOP) {
        alignY = -1.0;
      } else if (y == BOTTOM) {
        alignY = 1.0;
      } else if (y == CENTER) {
        alignY = 0.0;
      }
      return CSSTransformOrigin(Offset(offsetX, offsetY), Alignment(alignX, alignY));
    }
    return null;
  }

  Matrix4 combineTransform(Map<String, CSSFunctionValue> methods,
      {double progress = 1.0, Map<String, CSSFunctionValue> prevMethods}) {
    Matrix4 matrix4;
    for (CSSFunctionValue method in methods?.values) {
      Matrix4 cur = getTransform(
          method, progress: progress, prevMethods: prevMethods);
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

  Matrix4 getTransform(CSSFunctionValue method,
      {double progress = 1.0, Map<String, CSSFunctionValue> prevMethods}) {
    Matrix4 matrix4;
    bool needDiff = progress != null;
    CSSFunctionValue oldMethod = prevMethods != null ? prevMethods[method.name] : null;
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
              y = CSSLength.toDisplayPortValue(method.args[1].trim());
            } else {
              y = 0;
            }
            double x = CSSLength.toDisplayPortValue(method.args[0].trim());
            if (needDiff) {
              double oldX = 0.0, oldY = 0.0;
              if (oldMethod != null && oldMethod.args.length >= 1 &&
                  oldMethod.args.length <= 2) {
                oldX = CSSLength.toDisplayPortValue(oldMethod.args[0].trim());
                if (oldMethod.args.length == 2) {
                  oldY = CSSLength.toDisplayPortValue(oldMethod.args[1].trim());
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
              y = CSSLength.toDisplayPortValue(method.args[1].trim());
            }
            if (method.args.length == 3) {
              y = CSSLength.toDisplayPortValue(method.args[1].trim());
              z = CSSLength.toDisplayPortValue(method.args[2].trim());
            }
            double x = CSSLength.toDisplayPortValue(method.args[0].trim());
            if (needDiff) {
              double oldX = 0.0, oldY = 0.0, oldZ = 0.0;
              if (oldMethod != null && oldMethod.args.length >= 1 &&
                  oldMethod.args.length <= 3) {
                oldX = CSSLength.toDisplayPortValue(oldMethod.args[0].trim());
                if (oldMethod.args.length == 2) {
                  oldY = CSSLength.toDisplayPortValue(oldMethod.args[1].trim());
                }
                if (oldMethod.args.length == 3) {
                  oldY = CSSLength.toDisplayPortValue(oldMethod.args[1].trim());
                  oldZ = CSSLength.toDisplayPortValue(oldMethod.args[2].trim());
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
          double x = CSSLength.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldX = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldX = CSSLength.toDisplayPortValue(oldMethod.args[0].trim());
            }
            x = _getProgressValue(x, oldX, progress);
          }
          matrix4 = Matrix4.identity()
            ..translate(x);
        }
        break;
      case 'translateY':
        if (method.args.length == 1) {
          double y = CSSLength.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldY = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldY = CSSLength.toDisplayPortValue(oldMethod.args[0].trim());
            }
            y = _getProgressValue(y, oldY, progress);
          }
          matrix4 = Matrix4.identity()
            ..translate(0.0, y);
        }
        break;
      case 'translateZ':
        if (method.args.length == 1) {
          double z = CSSLength.toDisplayPortValue(method.args[0].trim());
          if (needDiff) {
            double oldZ = 0.0;
            if(oldMethod != null && oldMethod.args.length == 1) {
              oldZ = CSSLength.toDisplayPortValue(oldMethod.args[0].trim());
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
          double angle = CSSAngle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldAngle = 0.0;
            if(oldMethod != null && oldMethod.args.length == 1) {
              oldAngle = CSSAngle(oldMethod.args[0].trim()).angleValue;
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
          double angle = CSSAngle(method.args[3].trim()).angleValue;
          if (needDiff) {
            double oldX = 0.0, oldY = 0.0, oldZ = 0.0, oldAngle = 0.0;
            if(oldMethod != null && oldMethod.args.length == 4) {
              oldX = double.tryParse(oldMethod.args[0].trim()) ?? 0.0;
              oldY = double.tryParse(oldMethod.args[1].trim()) ?? 0.0;
              oldZ = double.tryParse(oldMethod.args[2].trim()) ?? 0.0;
              oldAngle = CSSAngle(oldMethod.args[3].trim()).angleValue;
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
          double x = CSSAngle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldX = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldX = CSSAngle(oldMethod.args[0].trim()).angleValue;
            }
            x = _getProgressValue(x, oldX, progress);
          }
          matrix4 = Matrix4.rotationX(x);
        }
        break;
      case 'rotateY':
        if (method.args.length == 1) {
          double y = CSSAngle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldY = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldY = CSSAngle(oldMethod.args[0].trim()).angleValue;
            }
            y = _getProgressValue(y, oldY, progress);
          }
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
          if (needDiff) {
            double oldX = 1.0;
            double oldY = 1.0;
            if (oldMethod != null && oldMethod.args.length >= 1 && oldMethod.args.length <= 2) {
              oldX = double.tryParse(oldMethod.args[0].trim()) ?? 1.0;
              if (oldMethod.args.length == 2) {
                oldY = double.tryParse(oldMethod.args[1].trim()) ?? oldX;
              } else {
                oldY = oldX;
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
          double alpha = CSSAngle(method.args[0].trim()).angleValue;
          double beta = 0.0;
          if (method.args.length == 2) {
            beta = CSSAngle(method.args[1].trim()).angleValue;
          }
          if (needDiff) {
            double oldAlpha = 0.0;
            double oldBeta = 0.0;
            if (oldMethod != null && (oldMethod.args.length == 1 || oldMethod.args.length == 2)) {
              oldAlpha = CSSAngle(oldMethod.args[0].trim()).angleValue;
              if (oldMethod.args.length == 2) {
                oldBeta = CSSAngle(oldMethod.args[1].trim()).angleValue;
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
          double angle = CSSAngle(method.args[0].trim()).angleValue;
          if (needDiff) {
            double oldAngle = 0.0;
            if (oldMethod != null && oldMethod.args.length == 1) {
              oldAngle = CSSAngle(oldMethod.args[0].trim()).angleValue;
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
          // @TODO perspective
        }
    }
    return matrix4;
  }

  double _getProgressValue(double newValue, double oldValue, double progress) {
    return oldValue + (newValue - oldValue) * progress;
  }
}

class CSSTransformOrigin {
  Offset offset;
  Alignment alignment;

  CSSTransformOrigin(this.offset, this.alignment);
}
