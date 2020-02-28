/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:meta/meta.dart';

import 'event_handler.dart';

const String STYLE_PATH_PREFIX = '.style';

typedef Statement = bool Function(Element element);

abstract class Element extends Node
    with
        EventHandlerMixin,
        TextStyleMixin,
        BackgroundImageMixin,
        RenderDecoratedBoxMixin,
        DimensionMixin,
        FlexMixin,
        StyleOverflowMixin,
        ColorMixin,
        TransformStyleMixin,
        TransitionStyleMixin {
  RenderConstrainedBox renderConstrainedBox;
  RenderObject stickyPlaceholder;
  RenderObject renderObject; // Style decorated renderObject
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutElement;
  RenderBoxModel renderBoxModel;
  Map<String, dynamic> properties;
  RenderIntersectionObserver renderIntersectionObserver;

  bool needsReposition = false; // whether element needs reposition when append to tree or changing position property
  bool _inited = false; // True after constructor finished.
  bool shouldBlockStretch = true;
  double cropWidth = 0;
  double cropHeight = 0;
  double cropBorderWidth = 0;
  double cropBorderHeight = 0;
  double offsetTop = null; // offset to the top of viewport
  bool stickyFixed = false;

  final String tagName;
  final String defaultDisplay;

  Element(
      {@required int nodeId,
      @required this.tagName,
      this.properties,
      this.needsReposition,
      List<String> events,
      @required this.defaultDisplay})
      : assert(tagName != null),
        assert(defaultDisplay != null),
        super(NodeType.ELEMENT_NODE, nodeId, tagName) {
    properties = properties ?? {};

    /// Element style render

    style = Style(properties[STYLE]);
    style.set('display', style.contains('display') ? style['display'] : defaultDisplay);

    // mark element needs to reposition according to position property
    if (style.contains('position') && (style.position == 'absolute' || style.position == 'fixed')) {
      needsReposition = true;
    }

    renderObject = renderLayoutElement = createRenderLayoutElement(style, null);
    // padding
    renderObject = initRenderPadding(renderObject, style);
    // background image
    if (style.backgroundAttachment == 'local' && style.backgroundImage != null) {
      renderObject = initBackgroundImage(renderObject, style, nodeId);
    }
    // display
    if (style.get('display') != 'inline') {
      renderObject = initOverflowBox(renderObject, style, _scrollListener);
    }
    // constrained box
    renderObject = renderConstrainedBox = initRenderConstrainedBox(renderObject, style);
    // position
    if (style.position != 'static') {
      renderObject = renderStack = RenderPosition(
        textDirection: TextDirection.ltr,
        fit: StackFit.passthrough,
        overflow: Overflow.visible,
        children: [
          renderObject,
        ],
      );
    }
    // border
    renderObject = initRenderDecoratedBox(renderObject, style, this);

    // Pointer event listener
    renderObject = RenderPointerListener(
      child: renderObject,
      onPointerDown: this.handlePointDown,
      onPointerMove: this.handlePointMove,
      onPointerUp: this.handlePointUp,
      onPointerCancel: this.handlePointCancel,
      behavior: HitTestBehavior.translucent,
    );

    // Intersection observer
    renderObject = renderIntersectionObserver = RenderIntersectionObserver(child: renderObject);
    // opacity
    renderObject = initRenderOpacity(renderObject, style);

    // margin
    renderObject = initRenderMargin(renderObject, style, this);
    // transition
    initTransition(style);

    // transform
    renderObject = renderBoxModel = initTransform(renderObject, style, nodeId);

    /// Element event listener
    if (events != null) {
      for (String eventName in events) {
        addEvent(eventName);
      }
    }

    _inited = true;
  }

  Element get parent => this.parentNode;

  Style _style;
  Style get style => _style;
  set style(Style newStyle) {
    newStyle.set('display', newStyle.contains('display') ? newStyle['display'] : defaultDisplay);

    // Update style;
    if (_inited) {
      ///1.update display
      String oldDisplay = style.get('display');
      String newDisplay = newStyle.get('display');
      bool hasFlexChange = isFlexStyleChanged(newStyle);
      if (newDisplay != oldDisplay || hasFlexChange) {
        ContainerRenderObjectMixin oldRenderElement = renderLayoutElement;
        List<RenderBox> children = [];
        RenderObjectVisitor visitor = (child) {
          children.add(child);
        };
        oldRenderElement
          ..visitChildren(visitor)
          ..removeAll();
        RenderPadding parent = renderLayoutElement.parent;
        parent.child = null;
        renderLayoutElement = createRenderLayoutElement(newStyle, children);
        parent.child = renderLayoutElement as RenderBox;
        // update style reference
        renderBoxModel.style = newStyle;
      }

      // update flex related properties
      if (newDisplay == 'flex' || newDisplay == 'inline-flex') {
        decorateRenderFlex(renderLayoutElement, newStyle);
      }
      // update style reference
      if (renderLayoutElement is RenderFlowLayout) {
        (renderLayoutElement as RenderFlowLayout).style = newStyle;
      } else {
        (renderLayoutElement as RenderFlexLayout).style = newStyle;
      }

      ///2.update overflow
      updateOverFlowBox(newStyle, _scrollListener);

      ///3.update padding
      updateRenderPadding(newStyle, transitionMap);

      ///4.update constrained
      updateConstraints(newStyle, transitionMap);

      ///5.update decorated
      updateRenderDecoratedBox(newStyle, this, transitionMap);

      ///6.update margin
      updateRenderMargin(newStyle, this, transitionMap);

      ///7.update position
      String newPosition = newStyle['position'] ?? 'static';
      String oldPosition = _style['position'] ?? 'static';
      bool positionChanged = false;
      if (newPosition != oldPosition) {
        positionChanged = true;
      }

      // position change
      if (positionChanged) {
        needsReposition = true;
        updatePosition(newStyle);
      } else if (newPosition != 'static') {
        int newZIndex = newStyle.zIndex;
        int oldZIndex = _style.zIndex;
        // zIndex change
        if (newZIndex != oldZIndex) {
          _updateZIndex(newStyle);
        }

        // offset change
        if (newStyle.top != _style.top ||
            newStyle.bottom != _style.bottom ||
            newStyle.left != _style.left ||
            newStyle.right != _style.right ||
            newStyle.width != _style.width ||
            newStyle.height != _style.height) {
          _updateOffset(newStyle);
        }
      }

      ///8.update opacity and visiblity
      updateRenderOpacity(
        style,
        newStyle,
        rootRenderObject: renderMargin,
        childRenderObject: renderDecoratedBox,
      );

      ///9.update transform
      updateTransform(newStyle, transitionMap);

      if (transitionMap != null) {
        for (Transition transition in transitionMap.values) {
          transition?.apply();
        }
      }
    }

    _style = newStyle;
  }

  markShouldUpdateMargin() {
    updateRenderMargin(style, this);
  }

  bool isFlexStyleChanged(Style newStyle) {
    String display = newStyle.get('display');
    List flexStyles = [
      'flexDirection',
      'flexWrap',
      'alignItems',
      'justifyContent',
      'alignContent',
    ];
    bool hasChanged = false;
    if (display == 'flex' || display == 'inline-flex') {
      flexStyles.forEach((key) {
        if (style.get(key) != newStyle.get(key)) {
          hasChanged = true;
        }
      });
    }
    return hasChanged;
  }

  void _scrollListener(double scrollTop) {
    if (this != ElementManager().getRootElement()) {
      return;
    }

    List stickyEls = findStickyChildren(this);

    for (int i = 0; i < stickyEls.length; i++) {
      Element el = stickyEls[i];
      Style elStyle = el.style;
      bool isFixed;

      if (el.offsetTop == null) {
        double offsetTop = double.parse(el.getOffsetY());
        // save element original offset to viewport
        el.offsetTop = offsetTop;
      }

      if (elStyle.get('top') != null) {
        double top = baseGetDisplayPortedLength(elStyle.get('top'));
        isFixed = el.offsetTop - scrollTop <= top;
      } else if (elStyle.get('bottom') != null) {
        double bottom = baseGetDisplayPortedLength(elStyle.get('bottom'));
        double viewPortHeight = renderMargin?.size?.height;
        double elViewPortTop = el.offsetTop - scrollTop;
        isFixed = viewPortHeight - elViewPortTop <= bottom;
      }

      if (isFixed) {
        // change to fixed behavior
        if (!el.stickyFixed) {
          el.stickyFixed = true;
          el.updatePosition(elStyle.copyWith({'position': 'fixed'}));
        }
      } else {
        // change to relative behavior
        if (el.stickyFixed) {
          el.stickyFixed = false;
          el.updatePosition(elStyle.copyWith({'position': 'sticky'}));
        }
      }
    }
  }

  List findStickyChildren(dynamic el) {
    if (el is! Element) {
      return null;
    }
    List resultEls = [];

    List childNodes = el.childNodes;
    if (childNodes.length != 0) {
      for (int i = 0; i < childNodes.length; i++) {
        dynamic childEl = childNodes[i];
        if (childEl is Element) {
          Style childStyle = childEl.style;
          if (childStyle.position == 'sticky' && (childStyle.top != null || childStyle.bottom != null)) {
            resultEls.add(childEl);
          }

          List childEls = findStickyChildren(childEl);
          if (childEls != null) {
            resultEls = [...resultEls, ...childEls];
          }
        }
      }
    }

    return resultEls;
  }

  void updatePosition(Style newStyle) {
    // remove stack node when change to non positioned
    if (newStyle.position == 'static') {
      RenderObject child = renderStack.firstChild;
      renderStack.remove(child);
      (renderStack.parent as RenderDecoratedBox).child = child;
      renderStack = null;
    } else {
      // add stack node when change to positioned
      if (renderStack == null) {
        RenderObject child = renderDecoratedBox.child;
        renderDecoratedBox.child = null;
        RenderStack renderNewStack = RenderPosition(
          textDirection: TextDirection.ltr,
          fit: StackFit.passthrough,
          overflow: Overflow.visible,
          children: [child],
        );

        renderStack = renderDecoratedBox.child = renderNewStack;
      }
    }

    // move element back to document flow
    if (newStyle.position == 'static' ||
        newStyle.position == 'relative' ||
        (newStyle.position == 'sticky' && !stickyFixed)) {
      // move element back to document flow
      if (style.position == 'absolute' || style.position == 'fixed' || style.position == 'sticky') {
        // remove positioned element from parent element stack
        Element parentElementWithStack = findParent(this, (element) => element.renderStack != null);
        parentElementWithStack.renderStack.remove(renderBoxModel);

        // remove sticky placeholder
        if (style.position == 'sticky') {
          removeStickyPlaceholder();
        }
        // find pre non positioned element
        var preNonPositionedElement = null;
        var currentElement = nodeMap[nodeId];
        var parentElement = currentElement.parentNode;
        int curIdx = parentElement.childNodes.indexOf(currentElement);
        for (int i = curIdx - 1; i > -1; i--) {
          var element = parentElement.childNodes[i];
          var style = element.properties['style'];
          if (style == null ||
              !style.containsKey('position') ||
              (style.containsKey('position') && style['position'] == 'static')) {
            preNonPositionedElement = element;
            break;
          }
        }
        // find pre non positioned renderObject
        RenderBoxModel preNonPositionedObject = null;
        if (preNonPositionedElement != null) {
          RenderObjectVisitor visitor = (child) {
            if (child is RenderBoxModel && preNonPositionedElement.nodeId == child.nodeId) {
              preNonPositionedObject = child;
            }
          };
          parentElement.renderLayoutElement.visitChildren(visitor);
        }
        // insert non positioned renderObject to parent element in the order of original element tree
        parentElement.renderLayoutElement.insert(renderBoxModel, after: preNonPositionedObject);

        needsReposition = false;
      }
    } else {
      // move element out of document flow

      // append element to positioned parent
      _rePositionElement(this);
    }

    // loop positioned children to reposition
    List targets = findPositionedChildren(this, false);
    for (int i = 0; i < targets.length; i++) {
      Element target = targets[i];
      _rePositionElement(target);
    }
  }

  void removeStickyPlaceholder() {
    (stickyPlaceholder.parent as ContainerRenderObjectMixin).remove(stickyPlaceholder);
  }

  void insertStickyPlaceholder() {
    Style pStyle = Style({
      'width': renderMargin.size.width.toString() + 'px',
      'height': renderMargin.size.height.toString() + 'px',
    });
    stickyPlaceholder = initRenderConstrainedBox(stickyPlaceholder, pStyle);
    stickyPlaceholder = initRenderDecoratedBox(stickyPlaceholder, pStyle, this);
    (renderObject.parent as ContainerRenderObjectMixin).insert(stickyPlaceholder, after: renderObject);
  }

  // reposition element with position absolute/fixed
  void _rePositionElement(Element el) {
    RenderObject renderObject = el.renderObject;
    Style style = el.style;
    int nodeId = el.nodeId;

    // new node not in the tree, wait for append in appenedElement
    if (renderObject.parent == null) {
      return;
    }

    // find positioned element to attach
    Element parentElementWithStack;
    if (style.position == 'absolute') {
      parentElementWithStack = findParent(el, (element) => element.renderStack != null);
    } else {
      parentElementWithStack = ElementManager().getRootElement();
    }
    // not found positioned parent element, wait for append in appenedElement
    if (parentElementWithStack == null) {
      return;
    }

    // add placeholder for sticky element before moved
    if (style.position == 'sticky') {
      insertStickyPlaceholder();
    }

    // remove non positioned element from parent element
    (renderObject.parent as ContainerRenderObjectMixin).remove(renderObject);
    RenderStack parentStack = parentElementWithStack.renderStack;

    StackParentData stackParentData = getPositionParentDataFromStyle(style);
    renderObject.parentData = stackParentData;

    Element currentElement = nodeMap[nodeId];

    // current element's zIndex
    int curZIndex = 0;
    if (currentElement.style.contains('zIndex') && currentElement.style['zIndex'] != null) {
      curZIndex = currentElement.style['zIndex'];
    }
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, renderObject, el, curZIndex);
  }

  void _updateZIndex(Style style) {
    Element parentElementWithStack = findParent(this, (element) => element.renderStack != null);
    RenderStack parentStack = parentElementWithStack.renderStack;

    // remove current element from parent stack
    parentStack.remove(renderObject);

    StackParentData stackParentData = getPositionParentDataFromStyle(style);
    renderObject.parentData = stackParentData;

    // current element's zIndex
    int curZIndex = 0;
    if (style['zIndex'] != null) {
      curZIndex = style['zIndex'];
    }
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, renderObject, this, curZIndex);
  }

  void _updateOffset(Style style) {
    ZIndexParentData zIndexParentData;
    AbstractNode renderParent = renderObject.parent;
    if (renderParent is RenderPosition && renderObject.parentData is ZIndexParentData) {
      zIndexParentData = renderObject.parentData;
      Transition allTransition,
          topTransition,
          leftTransition,
          rightTransition,
          bottomTransition,
          widthTransition,
          heightTransition;
      double topDiff, leftDiff, rightDiff, bottomDiff, widthDiff, heightDiff;
      double topBase, leftBase, rightBase, bottomBase, widthBase, heightBase;
      ZIndexParentData progressParentData = zIndexParentData;

      if (transitionMap != null) {
        allTransition = transitionMap["all"];
        if (style.top != _style.top) {
          topTransition = transitionMap["top"];
          topDiff = style.top ?? 0 - _style.top ?? 0;
          topBase = _style.top ?? 0;
        }
        if (style.left != _style.left) {
          leftTransition = transitionMap["left"];
          leftDiff = style.left ?? 0 - _style.left ?? 0;
          leftBase = _style.left ?? 0;
        }
        if (style.right != _style.right) {
          rightTransition = transitionMap["right"];
          rightDiff = style.right ?? 0 - _style.left ?? 0;
          rightBase = _style.right ?? 0;
        }
        if (style.bottom != _style.bottom) {
          bottomTransition = transitionMap["bottom"];
          bottomDiff = style.bottom ?? 0 - _style.bottom ?? 0;
          bottomBase = _style.bottom ?? 0;
        }
        if (style.width != _style.width) {
          widthTransition = transitionMap["width"];
          widthDiff = style.width ?? 0 - _style.width ?? 0;
          widthBase = _style.bottom ?? 0;
        }
        if (style.height != _style.height) {
          heightTransition = transitionMap["height"];
          heightDiff = style.height ?? 0 - _style.height ?? 0;
          heightBase = _style.height ?? 0;
        }
      }
      if (allTransition != null ||
          topTransition != null ||
          leftTransition != null ||
          rightTransition != null ||
          bottomTransition != null ||
          widthTransition != null ||
          heightTransition != null) {
        bool hasTop = false, hasLeft = false, hasRight = false, hasBottom = false, hasWidth = false, hasHeight = false;
        if (topDiff != null) {
          if (topTransition == null) {
            hasTop = true;
          } else {
            topTransition.addProgressListener((percent) {
              progressParentData.top = topBase + topDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (leftDiff != null) {
          if (leftTransition == null) {
            hasLeft = true;
          } else {
            leftTransition.addProgressListener((percent) {
              progressParentData.left = leftBase + leftDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (rightDiff != null) {
          if (rightTransition == null) {
            hasRight = true;
          } else {
            rightTransition.addProgressListener((percent) {
              progressParentData.right = rightBase + rightDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (bottomDiff != null) {
          if (bottomTransition == null) {
            hasBottom = true;
          } else {
            bottomTransition.addProgressListener((percent) {
              progressParentData.bottom = bottomBase + bottomDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (widthDiff != null) {
          if (widthTransition == null) {
            hasWidth = true;
          } else {
            widthTransition.addProgressListener((percent) {
              progressParentData.width = widthBase + widthDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (heightDiff != null) {
          if (heightTransition == null) {
            hasHeight = true;
          } else {
            heightTransition.addProgressListener((percent) {
              progressParentData.height = heightBase + heightDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (allTransition != null && (hasTop || hasBottom || hasLeft || hasRight || hasWidth || hasHeight)) {
          allTransition.addProgressListener((percent) {
            if (hasTop) {
              progressParentData.top = topBase + topDiff * percent;
            }
            if (hasLeft) {
              progressParentData.left = leftBase + leftDiff * percent;
            }
            if (hasRight) {
              progressParentData.right = rightBase + rightDiff * percent;
            }
            if (hasBottom) {
              progressParentData.bottom = bottomBase + bottomDiff * percent;
            }
            if (hasWidth) {
              progressParentData.width = widthBase + widthDiff * percent;
            }
            if (hasHeight) {
              progressParentData.height = heightBase + heightDiff * percent;
            }
            renderObject.parentData = progressParentData;
            renderParent.markNeedsLayout();
          });
        }
      } else {
        zIndexParentData.zIndex = style.zIndex;
        zIndexParentData.top = style.top;
        zIndexParentData.left = style.left;
        zIndexParentData.right = style.right;
        zIndexParentData.bottom = style.bottom;
        zIndexParentData.width = style.width;
        zIndexParentData.height = style.height;
        renderObject.parentData = zIndexParentData;
        renderParent.markNeedsLayout();
      }
    }
  }

  Element getElementById(Element parentElement, int nodeId) {
    Element result = null;
    List childNodes = parentElement.childNodes;

    for (int i = 0; i < childNodes.length; i++) {
      Element element = childNodes[i];
      if (element.nodeId == nodeId) {
        result = element;
        break;
      }
    }
    return result;
  }

  List<Element> get children {
    List<Element> _children = [];
    for (var child in this.childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  void addChild(RenderObject child) {
    assert(renderLayoutElement != null);
    renderLayoutElement.add(child);
  }

  ContainerRenderObjectMixin createRenderLayoutElement(Style newStyle, List<RenderBox> children) {
    String display = newStyle.get('display');
    String flexWrap = newStyle.get('flexWrap');
    bool isFlexWrap = (display == 'flex' || display == 'inline-flex') && flexWrap == 'wrap';
    if ((display == 'flex' || display == 'inline-flex') && flexWrap != 'wrap') {
      ContainerRenderObjectMixin flexLayout = RenderFlexLayout(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
        style: newStyle,
        nodeId: nodeId,
      );
      decorateRenderFlex(flexLayout, newStyle);
      return flexLayout;
    } else if (display == 'none' ||
        display == 'inline' ||
        display == 'inline-block' ||
        display == 'block' ||
        isFlexWrap) {
      MainAxisAlignment alignment = MainAxisAlignment.start;
      switch (newStyle['textAlign']) {
        case 'right':
          alignment = MainAxisAlignment.end;
          break;
        case 'center':
          alignment = MainAxisAlignment.center;
          break;
      }
      MainAxisAlignment runAlignment = MainAxisAlignment.start;
      switch (newStyle['alignContent']) {
        case 'end':
          runAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          runAlignment = MainAxisAlignment.center;
          break;
        case 'space-around':
          runAlignment = MainAxisAlignment.spaceAround;
          break;
        case 'space-between':
          runAlignment = MainAxisAlignment.spaceBetween;
          break;
        case 'space-evenly':
          runAlignment = MainAxisAlignment.spaceEvenly;
          break;
      }
      ContainerRenderObjectMixin flowLayout = RenderFlowLayout(
        mainAxisAlignment: alignment,
        runAlignment: runAlignment,
        children: children,
        style: newStyle,
        nodeId: nodeId,
      );

      if (isFlexWrap) {
        decorateRenderFlex(flowLayout, newStyle);
      }
      return flowLayout;
    } else {
      throw FlutterError('Not supported display type $display: $this');
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    super.appendChild(child);
    appendElement(child);
    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    removeElement(child);
    super.removeChild(child);
    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    int referenceIndex = childNodes.indexOf(referenceNode);

    // Node.insertBefore will change element tree structure,
    // so get the referenceIndex before calling it.
    Node node = super.insertBefore(child, referenceNode);
    if (referenceIndex != -1) {
      Node after;
      RenderObject afterRenderObject;
      if (referenceIndex == 0) {
        after = null;
      } else {
        do {
          after = childNodes[--referenceIndex];
        } while (after is! Element && referenceIndex > 0);
        if (after is Element) {
          afterRenderObject = after?.renderObject;
        }
      }
      appendElement(child, afterRenderObject: afterRenderObject, isAppend: false);
    }
    return node;
  }

  // Loop element's children to find elements need to reposition
  List findPositionedChildren(dynamic el, bool needsReposition) {
    if (el is! Element) {
      return null;
    }
    List resultEls = [];

    List childNodes = el.childNodes;
    if (childNodes.length != 0) {
      for (int i = 0; i < childNodes.length; i++) {
        dynamic childEl = childNodes[i];
        if (childEl is Element) {
          if (childEl.style.contains('position') &&
              (childEl.style.position == 'absolute' || childEl.style.position == 'fixed')) {
            if (needsReposition) {
              if (childEl.needsReposition == true) {
                resultEls.add(childEl);
              }
            } else {
              resultEls.add(childEl);
            }
          }

          List childEls = this.findPositionedChildren(childEl, needsReposition);
          if (childEls != null) {
            resultEls = [...resultEls, ...childEls];
          }
        }
      }
    }

    return resultEls;
  }

  void removeElement(Node child) {
    List<RenderObject> children = [];
    RenderObjectVisitor visitor = (child) {
      children.add(child);
    };
    renderLayoutElement..visitChildren(visitor);

    int childIdx;
    children.forEach((childNode) {
      int childId;
      if (childNode is RenderTextNode) {
        childId = childNode.nodeId;
      } else if (childNode is RenderBoxModel) {
        childId = childNode.nodeId;
      }
      if (childId == child.nodeId) {
        childIdx = children.indexOf(childNode);
      }
    });
    renderLayoutElement.remove(children[childIdx]);
  }

  void appendElement(Node child, {RenderObject afterRenderObject, bool isAppend = true}) {
    if (child is Element) {
      RenderObject childRenderObject = child.renderObject;
      Style childStyle = child.style;
      String childPosition = childStyle['position'] ?? 'static';
      // bool isFlex = renderLayoutElement is RenderFlexLayout;

      String display = style.get('display');
      bool isFlex = display == 'flex' || display == 'inline-flex';

      if (isFlex) {
        // Add FlexItem wrap for flex child node.
        RenderPadding parent = child.renderLayoutElement.parent;
        RenderBox childRenderBox = child.renderLayoutElement as RenderBox;
        parent.child = null;
        parent.child = RenderFlexItem(
          child: childRenderBox,
        );
      } else {
        Style childStyle = Style(child.properties[STYLE]);
        String childDisplay = childStyle.contains('display') ? childStyle['display'] : defaultDisplay;
        // Remove inline element dimension in flow layout
        if (childDisplay == 'inline') {
          RenderConstrainedBox renderConstrainedBox = child.renderConstrainedBox;
          renderConstrainedBox.additionalConstraints = BoxConstraints();
        }
      }

      RenderObject createStackObject(child) {
        RenderObject childRenderObject = child.renderObject;
        Style childStyle = child.style;
        ZIndexParentData stackParentData = getPositionParentDataFromStyle(childStyle);
        RenderObject stackObject = childRenderObject;

        childRenderObject = RenderPadding(padding: EdgeInsets.zero);
        if (!isFlex) {
          stackParentData.hookRenderObject = childRenderObject;
        }
        stackObject.parentData = stackParentData;
        return stackObject;
      }

      if (childPosition == 'absolute') {
        Element parentStackedElement = findParent(child, (element) => element.renderStack != null);
        if (parentStackedElement != null) {
          RenderObject stackObject = createStackObject(child);
          insertByZIndex(parentStackedElement.renderStack, stackObject, child, childStyle.zIndex);
          return;
        }
      } else if (childPosition == 'fixed') {
        final RenderPosition rootRenderStack = ElementManager().getRootElement().renderStack;
        if (rootRenderStack != null) {
          RenderObject stackObject = createStackObject(child);
          insertByZIndex(rootRenderStack, stackObject, child, childStyle.zIndex);
          return;
        }
        if (isFlex) {
          ///flex ignore
          return;
        }
      }

      if (isAppend) {
        addChild(childRenderObject);
      } else {
        renderLayoutElement.insert(childRenderObject, after: afterRenderObject);
      }

      // append positioned children not appended to renderStack yet to element's renderStack
      if (renderStack != null) {
        List targets = findPositionedChildren(child, true);
        for (int i = 0; i < targets.length; i++) {
          Element target = targets[i];
          // remove positioned element from parent
          target.parent.renderLayoutElement.remove(target.renderObject);

          RenderObject stackObject = createStackObject(target);

          ///insert by z-index
          insertByZIndex(renderStack, stackObject, target, target.style.zIndex);
        }
      }

      ParentData childParentData = childRenderObject.parentData;
      if (isFlex) {
        assert(childParentData is KrakenFlexParentData);
        final KrakenFlexParentData parentData = childParentData;
        KrakenFlexParentData flexParentData = FlexItem.getParentData(childStyle);
        parentData.flexGrow = flexParentData.flexGrow;
        parentData.flexShrink = flexParentData.flexShrink;
        parentData.flexBasis = flexParentData.flexBasis;
        parentData.fit = flexParentData.fit;
        String alignItems = style[FlexItem.ALIGN_ITEMS];
        if (alignItems != null && style[FlexItem.ALIGN_ITEMS] != 'stretch') {
          flexParentData.fit = FlexFit.tight;
        }

        child.markShouldUpdateMargin(); // Update margin for flex child.
        renderObject.markNeedsLayout();
      }
    } else if (child is TextNode) {
      RenderTextNode newTextNode = RenderTextNode(
        nodeId: child.nodeId,
        text: child.data,
        style: style,
      );
      addChild(newTextNode);
    }
  }

  void insertByZIndex(RenderStack renderStack, RenderObject renderObject, Element el, int zIndex) {
    el.needsReposition = false;
    RenderBox child = renderStack.lastChild;
    while (child != null) {
      ParentData parentData = child.parentData;
      if (parentData is ZIndexParentData) {
        if (parentData.zIndex <= zIndex) {
          renderStack.insert(renderObject, after: child);
        } else {
          final ContainerParentDataMixin childParentData = child.parentData;
          renderStack.insert(renderObject, after: childParentData.previousSibling);
        }
        return;
      } else if (zIndex >= 0) {
        renderStack.insert(renderObject, after: child);
        return;
      }
      final ContainerParentDataMixin childParentData = child.parentData;
      child = childParentData.previousSibling;
    }
    renderStack.insert(renderObject, after: null);
  }

  static Element findParent(Element element, Statement statement) {
    Element _el = element.parent;
    while (_el != null && !statement(_el)) {
      _el = _el.parent;
    }

    return _el;
  }

  static ZIndexParentData getPositionParentDataFromStyle(Style style) {
    ZIndexParentData parentData = ZIndexParentData();

    if (style.contains('top')) {
      parentData..top = Length.toDisplayPortValue(style['top']);
    }
    if (style.contains('left')) {
      parentData..left = Length.toDisplayPortValue(style['left']);
    }
    if (style.contains('bottom')) {
      parentData..bottom = Length.toDisplayPortValue(style['bottom']);
    }
    if (style.contains('right')) {
      parentData..right = Length.toDisplayPortValue(style['right']);
    }
    parentData.width = Length.toDisplayPortValue(style['width']);
    parentData.height = Length.toDisplayPortValue(style['height']);
    parentData.zIndex = style.zIndex;
    return parentData;
  }

  // update textNode style when container style changed
  void updateTextNodeStyle(String key) {
    childNodes.forEach((node) {
      if (node is TextNode) {
        node.setProperty('style', style);
      }
    });
  }

  @mustCallSuper
  void setProperty(String key, dynamic value) {
    if (key.indexOf(STYLE_PATH_PREFIX) >= 0) {
      String styleKey = key.substring(1).split('.')[1];
      Style newStyle = _style.copyWith({styleKey: value});
      properties['style'] = newStyle.getOriginalStyleMap();
      style = newStyle;
      updateTextNodeStyle(styleKey);
    } else {
      properties[key] = value;
      if (key == STYLE) {
        if (value is String) {
          // if value is raw style string, should convert it into map
          value = jsonEncode(value);
        }

        style = _style.copyWith(value);
      }

      if (key == STYLE) {
        updateTextNodeStyle(key);
      }
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);
  }

  dynamic method(String name, List<dynamic> args) {
    switch (name) {
      case 'offsetTop':
        return getOffsetY();
      case 'offsetLeft':
        return getOffsetX();
      case 'offsetWidth':
        return renderMargin?.size?.width ?? '0';
      case 'offsetHeight':
        return renderMargin?.size?.height ?? '0';
      case 'clientWidth':
        return renderPadding?.size?.width ?? '0';
      case 'clientHeight':
        return renderPadding?.size?.height ?? '0';
      case 'clientLeft':
        return renderPadding.localToGlobal(Offset.zero, ancestor: renderMargin).dx;
      case 'clientTop':
        return renderPadding.localToGlobal(Offset.zero, ancestor: renderMargin).dy;
      case 'scrollTop':
        return getScrollTop();
      case 'scrollLeft':
        return getScrollLeft();
      case 'scrollHeight':
        return getScrollHeight();
      case 'scrollWidth':
        return getScrollWidth();
      case 'getBoundingClientRect':
        return getBoundingClientRect();
      default:
        debugPrint('unknown method call. name: $name, args: ${args}');
    }
  }

  Map getBoundingClientRect() {
    Offset offset = getOffset(renderBorderMargin);
    Size size = renderBorderMargin.size;
    Map rect = {};
    rect['x'] = offset.dx;
    rect['y'] = offset.dy;
    rect['width'] = size.width;
    rect['height'] = size.height;
    rect['top'] = offset.dy;
    rect['left'] = offset.dx;
    rect['right'] = offset.dx + size.width;
    rect['bottom'] = offset.dy + size.height;
    return rect;
  }

  String getOffsetX() {
    double offset = 0;
    if (renderObject is RenderBox) {
      Offset relative = getOffset(renderObject as RenderBox);
      offset +=  relative.dx;
    }
    return offset.toString();
  }

  String getOffsetY() {
    double offset = 0;
    if (renderObject is RenderBox) {
      Offset relative = getOffset(renderObject as RenderBox);
      offset +=  relative.dy;
    }
    return offset.toString();
  }

  Offset getOffset(RenderBox renderBox) {
    Element element = findParent(this, (element) => element.renderStack != null);
    if (element == null) {
      element = ElementManager().getRootElement();
    }
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderObject);
  }

  void addEvent(String eventName) {
    if (this.eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.addEventListener(eventName, this._eventResponder);

    if (_isIntersectionObserverEvent(eventName)) {
      renderIntersectionObserver.onIntersectionChange = handleIntersectionChange;
    }
  }

  void removeEvent(String eventName) {
    if (!this.eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.removeEventListener(eventName, this._eventResponder);

    if (_isIntersectionObserverEvent(eventName)) {
      if (!_hasIntersectionObserverEvent(this.eventHandlers)) {
        renderIntersectionObserver.onIntersectionChange = null;
      }
    }
  }

  void _eventResponder(Event event) {
    String json = jsonEncode([nodeId, event]);
    emitUIEvent(json);
  }
}

bool _isIntersectionObserverEvent(String eventName) {
  return eventName == 'appear' || eventName == 'disappear' || eventName == 'intersectionchange';
}

bool _hasIntersectionObserverEvent(eventHandlers) {
  return eventHandlers.containsKey('appear') ||
      eventHandlers.containsKey('disappear') ||
      eventHandlers.containsKey('intersectionchange');
}
