/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height

mixin CSSSizingMixin {
  KrakenRenderConstrainedBox renderConstrainedBox;
  RenderMargin renderMargin;
  CSSEdgeInsets oldPadding;
  CSSEdgeInsets oldMargin;

//  void updateConstraints(CSSStyleDeclaration style, Map<String, CSSTransition> transitionMap) {
//    if (renderConstrainedBox != null) {
//      CSSTransition allTransition,
//          widthTransition,
//          heightTransition,
//          minWidthTransition,
//          maxWidthTransition,
//          minHeightTransition,
//          maxHeightTransition;
//      if (transitionMap != null) {
//        allTransition = transitionMap['all'];
//        widthTransition = transitionMap['width'];
//        heightTransition = transitionMap['height'];
//        minWidthTransition = transitionMap['min-width'];
//        maxWidthTransition = transitionMap['max-width'];
//        minHeightTransition = transitionMap['min-height'];
//        maxHeightTransition = transitionMap['max-height'];
//      }
//
//      if (allTransition != null ||
//          widthTransition != null ||
//          heightTransition != null ||
//          minWidthTransition != null ||
//          maxWidthTransition != null ||
//          minHeightTransition != null ||
//          maxHeightTransition != null) {
//        double diffWidth = (newConstraints.width ?? 0.0) - (oldConstraints.width ?? 0.0);
//        double diffHeight = (newConstraints.height ?? 0.0) - (oldConstraints.height ?? 0.0);
//        double diffMinWidth = (newConstraints.minWidth ?? 0.0) - (oldConstraints.minWidth ?? 0.0);
//        double diffMaxWidth = (newConstraints.maxWidth ?? 0.0) - (oldConstraints.maxWidth ?? 0.0);
//        double diffMinHeight = (newConstraints.minHeight ?? 0.0) - (oldConstraints.minHeight ?? 0.0);
//        double diffMaxHeight = (newConstraints.maxHeight ?? 0.0) - (oldConstraints.maxHeight ?? 0.0);
//
//        CSSSizedConstraints progressConstraints = CSSSizedConstraints(oldConstraints.width, oldConstraints.height,
//            oldConstraints.minWidth, oldConstraints.maxWidth, oldConstraints.minHeight, oldConstraints.maxHeight);
//
//        CSSSizedConstraints baseConstraints = CSSSizedConstraints(oldConstraints.width, oldConstraints.height,
//            oldConstraints.minWidth, oldConstraints.maxWidth, oldConstraints.minHeight, oldConstraints.maxHeight);
//
//        allTransition?.addProgressListener((progress) {
//          if (widthTransition == null) {
//            progressConstraints.width = diffWidth * progress + (baseConstraints.width ?? 0.0);
//          }
//          if (heightTransition == null) {
//            progressConstraints.height = diffHeight * progress + (baseConstraints.height ?? 0.0);
//          }
//          if (minWidthTransition == null) {
//            progressConstraints.minWidth = diffMinWidth * progress + (baseConstraints.minWidth ?? 0.0);
//          }
//          if (maxWidthTransition == null) {
//            progressConstraints.maxWidth = diffMaxWidth * progress + (baseConstraints.maxWidth ?? double.infinity);
//          }
//          if (minHeightTransition == null) {
//            progressConstraints.minHeight = diffMinHeight * progress + (baseConstraints.minHeight ?? 0.0);
//          }
//          if (maxHeightTransition == null) {
//            progressConstraints.maxHeight = diffMaxHeight * progress + (baseConstraints.maxHeight ?? double.infinity);
//          }
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        widthTransition?.addProgressListener((progress) {
//          progressConstraints.width = diffWidth * progress + (baseConstraints.width ?? 0.0);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        heightTransition?.addProgressListener((progress) {
//          progressConstraints.height = diffHeight * progress + (baseConstraints.height ?? 0.0);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        minHeightTransition?.addProgressListener((progress) {
//          progressConstraints.minHeight = diffWidth * progress + (baseConstraints.minHeight ?? 0.0);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        minWidthTransition?.addProgressListener((progress) {
//          progressConstraints.minWidth = diffWidth * progress + (baseConstraints.minWidth ?? 0.0);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        maxHeightTransition?.addProgressListener((progress) {
//          progressConstraints.maxHeight = diffWidth * progress + (baseConstraints.maxHeight ?? double.infinity);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//        maxWidthTransition?.addProgressListener((progress) {
//          progressConstraints.maxWidth = diffWidth * progress + (baseConstraints.maxWidth ?? double.infinity);
//          renderConstrainedBox.additionalConstraints = progressConstraints.toBoxConstraints();
//        });
//      } else {
//        renderConstrainedBox.additionalConstraints = newConstraints.toBoxConstraints();
//      }
//
//      // Remove inline element dimension
//      if (style[DISPLAY] == INLINE) {
//        renderConstrainedBox.additionalConstraints = BoxConstraints();
//      }
//
//      oldConstraints = newConstraints;
//    }
//  }

  void initRenderBoxSizing(RenderBoxModel renderBoxModel, CSSStyleDeclaration style) {
    updateBoxSize(renderBoxModel, style);
  }

  void updateBoxSize(RenderBoxModel renderBoxModel, CSSStyleDeclaration style) {
    double width = CSSLength.toDisplayPortValue(style[WIDTH]);
    double height = CSSLength.toDisplayPortValue(style[HEIGHT]);
    double minHeight = CSSLength.toDisplayPortValue(style[MIN_HEIGHT]);
    double maxHeight = CSSLength.toDisplayPortValue(style[MAX_HEIGHT]);
    double minWidth = CSSLength.toDisplayPortValue(style[MIN_WIDTH]);
    double maxWidth = CSSLength.toDisplayPortValue(style[MAX_WIDTH]);

    renderBoxModel.width = width;
    renderBoxModel.height = height;
    renderBoxModel.maxWidth = maxWidth;
    renderBoxModel.minWidth = minWidth;
    renderBoxModel.maxHeight = maxHeight;
    renderBoxModel.minHeight = minHeight;
  }

  RenderObject initRenderMargin(RenderObject renderObject, CSSStyleDeclaration style) {
    EdgeInsets edgeInsets = getMarginInsetsFromStyle(style);
    return renderMargin = RenderMargin(
      margin: edgeInsets,
      child: renderObject,
    );
  }

  static CSSEdgeInsets _getMarginFromStyle(CSSStyleDeclaration style) {

    double marginLeft;
    double marginTop;
    double marginRight;
    double marginBottom;

    if (style.contains(MARGIN_LEFT)) marginLeft = CSSLength.toDisplayPortValue(style[MARGIN_LEFT]);
    if (style.contains(MARGIN_TOP)) marginTop = CSSLength.toDisplayPortValue(style[MARGIN_TOP]);
    if (style.contains(MARGIN_RIGHT)) marginRight = CSSLength.toDisplayPortValue(style[MARGIN_RIGHT]);
    if (style.contains(MARGIN_BOTTOM)) marginBottom = CSSLength.toDisplayPortValue(style[MARGIN_BOTTOM]);

    return CSSEdgeInsets(marginTop ?? 0.0, marginRight ?? 0.0, marginBottom ?? 0.0, marginLeft ?? 0.0);
  }

  EdgeInsets getMarginInsetsFromStyle(CSSStyleDeclaration style) {
    oldMargin = _getMarginFromStyle(style);
    return EdgeInsets.fromLTRB(oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);
  }

  void updateRenderMargin(CSSStyleDeclaration style, [Map<String, CSSTransition> transitionMap]) {
    assert(renderMargin != null);
    CSSTransition all, margin, marginLeft, marginRight, marginBottom, marginTop;
    if (transitionMap != null) {
      all = transitionMap['all'];
      margin = transitionMap['margin'];
      marginLeft = transitionMap['margin-left'];
      marginRight = transitionMap['margin-right'];
      marginBottom = transitionMap['margin-bottom'];
      marginTop = transitionMap['margin-top'];
    }
    if (all != null ||
        margin != null ||
        marginBottom != null ||
        marginLeft != null ||
        marginRight != null ||
        marginTop != null) {
      CSSEdgeInsets newMargin = _getMarginFromStyle(style);

      double marginLeftInterval = newMargin.left - oldMargin.left;
      double marginRightInterval = newMargin.right - oldMargin.right;
      double marginTopInterval = newMargin.top - oldMargin.top;
      double marginBottomInterval = newMargin.bottom - oldMargin.bottom;

      CSSEdgeInsets progressMargin = CSSEdgeInsets(oldMargin.top, oldMargin.right, oldMargin.bottom, oldMargin.left);
      CSSEdgeInsets baseMargin = CSSEdgeInsets(oldMargin.top, oldMargin.right, oldMargin.bottom, oldMargin.left);

      all?.addProgressListener((progress) {
        if (margin == null) {
          if (marginTop == null) {
            progressMargin.top = progress * marginTopInterval + baseMargin.top;
          }
          if (marginBottom == null) {
            progressMargin.bottom = progress * marginBottomInterval + baseMargin.bottom;
          }
          if (marginLeft == null) {
            progressMargin.left = progress * marginLeftInterval + baseMargin.left;
          }
          if (marginRight == null) {
            progressMargin.right = progress * marginRightInterval + baseMargin.right;
          }
          _updateMargin(EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom));
        }
      });

      margin?.addProgressListener((progress) {
        if (marginTop == null) {
          progressMargin.top = progress * marginTopInterval + baseMargin.top;
        }
        if (marginBottom == null) {
          progressMargin.bottom = progress * marginBottomInterval + baseMargin.bottom;
        }
        if (marginLeft == null) {
          progressMargin.left = progress * marginLeftInterval + baseMargin.left;
        }
        if (marginRight == null) {
          progressMargin.right = progress * marginRightInterval + baseMargin.right;
        }
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom));
      });
      marginTop?.addProgressListener((progress) {
        progressMargin.top = progress * marginTopInterval + baseMargin.top;
        renderMargin.margin =
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom);
      });
      marginBottom?.addProgressListener((progress) {
        progressMargin.bottom = progress * marginBottomInterval + baseMargin.bottom;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom));
      });
      marginLeft?.addProgressListener((progress) {
        progressMargin.left = progress * marginLeftInterval + baseMargin.left;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom));
      });
      marginRight?.addProgressListener((progress) {
        progressMargin.right = progress * marginRightInterval + baseMargin.right;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top, progressMargin.right, progressMargin.bottom));
      });
      oldMargin = newMargin;
    } else {
      _updateMargin(getMarginInsetsFromStyle(style));
    }
  }

  void _updateMargin(EdgeInsets margin) {
    renderMargin.margin = margin;
  }

  static CSSEdgeInsets _getPaddingFromStyle(CSSStyleDeclaration style) {

    double paddingTop;
    double paddingRight;
    double paddingBottom;
    double paddingLeft;

    if (style.contains(PADDING_TOP)) paddingTop = CSSLength.toDisplayPortValue(style[PADDING_TOP]);
    if (style.contains(PADDING_RIGHT)) paddingRight = CSSLength.toDisplayPortValue(style[PADDING_RIGHT]);
    if (style.contains(PADDING_BOTTOM)) paddingBottom = CSSLength.toDisplayPortValue(style[PADDING_BOTTOM]);
    if (style.contains(PADDING_LEFT)) paddingLeft = CSSLength.toDisplayPortValue(style[PADDING_LEFT]);

    return CSSEdgeInsets(paddingTop ?? 0.0, paddingRight ?? 0.0, paddingBottom ?? 0.0, paddingLeft ?? 0.0);
  }

  EdgeInsets getPaddingInsetsFromStyle(CSSStyleDeclaration style) {
    oldPadding = _getPaddingFromStyle(style);
    return EdgeInsets.fromLTRB(oldPadding.left, oldPadding.top, oldPadding.right, oldPadding.bottom);
  }

  void updateRenderPadding(RenderBoxModel renderBoxModel, CSSStyleDeclaration style,
      [Map<String, CSSTransition> transitionMap]) {
    CSSTransition all, padding, paddingLeft, paddingRight, paddingBottom, paddingTop;
    if (transitionMap != null) {
      all = transitionMap['all'];
      padding = transitionMap['padding'];
      paddingLeft = transitionMap['padding-left'];
      paddingRight = transitionMap['padding-right'];
      paddingBottom = transitionMap['padding-bottom'];
      paddingTop = transitionMap['padding-top'];
    }
    if (all != null ||
        padding != null ||
        paddingBottom != null ||
        paddingLeft != null ||
        paddingRight != null ||
        paddingTop != null) {
      CSSEdgeInsets newPadding = _getPaddingFromStyle(style);

      double paddingLeftInterval = newPadding.left - oldPadding.left;
      double paddingRightInterval = newPadding.right - oldPadding.right;
      double paddingTopInterval = newPadding.top - oldPadding.top;
      double paddingBottomInterval = newPadding.bottom - oldPadding.bottom;

      CSSEdgeInsets progressPadding = CSSEdgeInsets(oldPadding.top, oldPadding.right, oldPadding.bottom, oldPadding.left);
      CSSEdgeInsets basePadding = CSSEdgeInsets(oldPadding.top, oldPadding.right, oldPadding.bottom, oldPadding.left);

      all?.addProgressListener((progress) {
        if (padding == null) {
          if (paddingTop == null) {
            progressPadding.top = progress * paddingTopInterval + basePadding.top;
          }
          if (paddingBottom == null) {
            progressPadding.bottom = progress * paddingBottomInterval + basePadding.bottom;
          }
          if (paddingLeft == null) {
            progressPadding.left = progress * paddingLeftInterval + basePadding.left;
          }
          if (paddingRight == null) {
            progressPadding.right = progress * paddingRightInterval + basePadding.right;
          }

          renderBoxModel.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
        }
      });
      padding?.addProgressListener((progress) {
        if (paddingTop == null) {
          progressPadding.top = progress * paddingTopInterval + basePadding.top;
        }
        if (paddingBottom == null) {
          progressPadding.bottom = progress * paddingBottomInterval + basePadding.bottom;
        }
        if (paddingLeft == null) {
          progressPadding.left = progress * paddingLeftInterval + basePadding.left;
        }
        if (paddingRight == null) {
          progressPadding.right = progress * paddingRightInterval + basePadding.right;
        }

        renderBoxModel.padding = EdgeInsets.fromLTRB(
            progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingTop?.addProgressListener((progress) {
        progressPadding.top = progress * paddingTopInterval + basePadding.top;
        renderBoxModel.padding = EdgeInsets.fromLTRB(
            progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingBottom?.addProgressListener((progress) {
        progressPadding.bottom = progress * paddingBottomInterval + basePadding.bottom;
        renderBoxModel.padding = EdgeInsets.fromLTRB(
            progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingLeft?.addProgressListener((progress) {
        progressPadding.left = progress * paddingLeftInterval + basePadding.left;
        renderBoxModel.padding = EdgeInsets.fromLTRB(
            progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingRight?.addProgressListener((progress) {
        progressPadding.right = progress * paddingRightInterval + basePadding.right;
        renderBoxModel.padding = EdgeInsets.fromLTRB(
            progressPadding.left, progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      oldPadding = newPadding;
    }

    EdgeInsets edgeInsets = getPaddingInsetsFromStyle(style);

    // Update renderPadding.
    renderBoxModel.padding = edgeInsets;
  }
}

class CSSEdgeInsets {
  double left;
  double top;
  double right;
  double bottom;

  CSSEdgeInsets(this.top, this.right, this.bottom, this.left);
}
