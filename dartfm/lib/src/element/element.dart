/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:kraken/element.dart';

const String STYLE = 'style';
const String STYLE_PATH_PREFIX = '.style';

typedef Statement = bool Function(Element element);


Element createW3CElement(PayloadNode node) {
  switch (node.type) {
    case DIV:
      return DivElement(node.id, node.props, node.events);
    case SPAN:
      return SpanElement(node.id, node.props, node.events);
    case IMAGE:
      return ImgElement(node.id, node.props, node.events);
    case PARAGRAPH:
      return ParagraphElement(node.id, node.props, node.events);
    case INPUT:
      return InputElement(node.id, node.props, node.events);
    case CANVAS:
      return CanvasElement(node.id, node.props, node.events);
    case VIDEO: {
      VideoElement.setDefaultPropsStyle(node.props);
      return VideoElement(node.id, node.props, node.events);
    }
    default:
      throw FlutterError('ERROR: unexpected element type, ' + node.type);
  }
}

abstract class Element extends Node
    with
        ElementEventHandler,
        TextStyleMixin,
        BackgroundImageMixin,
        RenderDecoratedBoxMixin,
        DimensionMixin,
        FlexMixin,
        StyleOverflowMixin,
        ColorMixin,
        TransformStyleMixin,
        TransitionStyleMixin {
    Element({
      @required int nodeId,
      @required this.tagName,
      this.properties,
      this.needsReposition,
      List<String> events,
      @required this.defaultDisplay
    }) : assert(tagName != null),
        assert(defaultDisplay != null),
        super(NodeType.ELEMENT_NODE, nodeId, tagName) {
    properties = properties ?? {};
    style = Style(properties[STYLE]);
    style.set('display', style.contains('display') ? style['display'] : defaultDisplay);
    if (events != null) {
      for (String eventName in events) {
        addEvent(eventName);
      }
    }

    // mark element needs to reposition according to position property
    if (style.contains('position') &&
      (style.position == 'absolute' || style.position == 'fixed')) {
      needsReposition = true;
    }

    renderObject = renderLayoutElement = createRenderLayoutElement(style, null);
    renderObject = initRenderPadding(renderObject, style);
    if (style.backgroundAttachment == 'local' && style.backgroundImage != null) {
      renderObject = initBackgroundImage(renderObject, style);
    }
    if (style.get('display') != 'inline') {
      renderObject = initOverflowBox(renderObject, style);
    }
    renderObject = initRenderDecoratedBox(renderObject, style);

    renderObject = renderConstrainedBox = initRenderConstrainedBox(renderObject, style);
    renderObject = RenderPointerListener(
      child: renderObject,
      onPointerDown: this._handlePointDown,
      onPointerMove: this._handlePointMove,
      onPointerUp: this._handlePointUp,
      onPointerCancel: this._handlePointCancel,
    );
    renderObject = initRenderMargin(renderObject, style, this);
    renderObject = initRenderOpacity(renderObject, style);
    initTransition(style);

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

    renderObject = renderBoxModel = initTransform(renderObject, style, nodeId);
    _inited = true;
  }
  RenderConstrainedBox renderConstrainedBox;
  final String tagName;
  Map<String, dynamic> properties;
  bool needsReposition = false; // whether element needs reposition when append to tree or changing position property
  RenderObject renderObject; // Style decorated renderObject
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutElement;
  RenderBoxModel renderBoxModel;
  bool _inited = false; // True after constructor finished.

  bool shouldBlockStretch = true;

  double cropWidth = 0;

  Style _style;
  Style get style => _style;
  set style(Style newStyle) {

    newStyle.set('display', newStyle.contains('display') ? newStyle['display'] : defaultDisplay);

    // Update style;
    if (_inited) {
      ///1.update display
      String oldDisplay = style.get('display');
      String newDisplay = newStyle.get('display');
      if (newDisplay != oldDisplay) {
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
      if (renderLayoutElement is RenderFlexLayout) {
        decorateRenderFlex(renderLayoutElement, newStyle);
        // update style reference
        (renderLayoutElement as RenderFlexLayout).style = newStyle;
      }

      ///2.update overflow
      updateOverFlowBox(newStyle);

      ///3.update padding
      updateRenderPadding(newStyle, transitionMap);

      ///4.update decorated
      updateRenderDecoratedBox(newStyle, transitionMap);

      ///5.update constrained
      updateConstraints(newStyle, transitionMap);

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
        _updatePosition(newStyle);

      } else if (newPosition != 'static') {
        int newZIndex = newStyle.zIndex;
        int oldZIndex = _style.zIndex;
        // zIndex change
        if (newZIndex != oldZIndex) {
          _updateZIndex(newStyle);
        }

        // offset change
        if (newStyle.top != _style.top || newStyle.bottom != _style.bottom ||
            newStyle.left != _style.left || newStyle.right != _style.right ||
            newStyle.width != _style.width ||
            newStyle.height != _style.height) {
          _updateOffset(newStyle);
        }
      }

      ///8.update opacity
      updateRenderOpacity(
        newStyle,
        rootRenderObject: renderBoxModel,
      );

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

  final String defaultDisplay;

  void _updatePosition(Style style) {
    // from !static to static
    if (style.position == 'static') {
      // change current positioned element to non positioned, remove stack node
      RenderObject child = renderStack.firstChild;
      renderStack.remove(child);
      (renderStack.parent as RenderTransform).child = child;
      // remove positioned element from parent element stack
      Element parentElementWithStack = findParent(this, (element) => element.renderStack != null);
      parentElementWithStack.renderStack.remove(renderBoxModel);

      // find pre non positioned element
      var preNonPositionedElement = null;
      var currentElement = nodeMap[nodeId];
      var parentElement = currentElement.parentNode;
      int curIdx = parentElement.childNodes.indexOf(currentElement);
      for (int i = curIdx - 1; i > -1; i--) {
        var element = parentElement.childNodes[i];
        var style = element.properties['style'];
        if (style == null || !style.containsKey('position') ||
          (style.containsKey('position') && style['position'] == 'static')
        ) {
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
    // from static to !static
    } else {
      // change non position element to position element, add stack node
      RenderObject child = transform.child;
      transform.child = null;
      RenderStack renderNewStack = RenderPosition(
        textDirection: TextDirection.ltr,
        fit: StackFit.passthrough,
        overflow: Overflow.visible,
        children: [
          child
        ],
      );
      renderStack = transform.child = renderNewStack;

      // append element to positioned parent
      if (style.position == 'absolute' ||
        style.position == 'fixed'
      ) {
        // new node not in the tree, wait for append in appenedElement
        if (renderObject.parent == null) {
          return;
        }

        // find positioned element to attach
        Element parentElementWithStack;
        if (style.position == 'absolute') {
          parentElementWithStack = findParent(this, (element) => element.renderStack != null);
        } else {
          parentElementWithStack = ElementManager().getRootElement();
        }

        // not found positioned parent element, wait for append in appenedElement
        if (parentElementWithStack == null) {
          return;
        }

        // remove non positioned element from parent element
        (renderObject.parent as ContainerRenderObjectMixin).remove(renderObject);
        RenderStack parentStack = parentElementWithStack.renderStack;

        StackParentData stackParentData = getPositionParentDataFromStyle(style);
        renderObject.parentData = stackParentData;

        Element currentElement = nodeMap[nodeId];

        // current element's zIndex
        int curZIndex = 0;
        if (currentElement.style.contains('zIndex') &&
          currentElement.style['zIndex'] != null
        ) {
          curZIndex = currentElement.style['zIndex'];
        }
        // add current element back to parent stack by zIndex
        insertByZIndex(parentStack, renderObject, this, curZIndex);
      }
    }
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
      Transition allTransition, topTransition, leftTransition, rightTransition,
          bottomTransition, widthTransition, heightTransition;
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
      if (allTransition != null || topTransition != null ||
          leftTransition != null || rightTransition != null ||
          bottomTransition != null || widthTransition != null ||
          heightTransition != null) {
        bool hasTop = false,
            hasLeft = false,
            hasRight = false,
            hasBottom = false,
            hasWidth = false,
            hasHeight = false;
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
        if (allTransition != null &&
            (hasTop || hasBottom || hasLeft || hasRight || hasWidth ||
                hasHeight)) {
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

  Element get parent => this.parentNode;
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
    if (display == 'flex' || display == 'inline-flex') {
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

    } else if (display == 'inline' || display == 'inline-block' || display == 'block') {

      WrapAlignment alignment = WrapAlignment.start;
      switch(style['textAlign']) {
        case 'right':
          alignment = WrapAlignment.end;
          break;
        case 'center':
          alignment = WrapAlignment.center;
          break;
      }
      return RenderFlowLayout(
        alignment: alignment,
        children: children,
        style: newStyle,
        nodeId: nodeId,
      );
    } else {
      throw FlutterError('Not supported display type $display: $this');
    }
  }

  WrapAlignment getWrapAlignment(Style style) {
    String textAlign = style['textAlign'];
    switch (textAlign) {
      case 'center':
        return WrapAlignment.center;
      case 'end':
      case 'right':
        return WrapAlignment.end;
      case 'start':
      case 'left':
      default:
        return WrapAlignment.start;
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
  List findNeedsRepositionChildren(dynamic el) {
    if (el is! Element) {
      return null;
    }
    List resultEls = [];
    if (el.needsReposition == true) {
      resultEls.add(el);
    }

    List childNodes = el.childNodes;
    if (childNodes.length != 0) {
      for (int i = 0; i < childNodes.length; i++) {
        List childEls = this.findNeedsRepositionChildren(childNodes[i]);
        if (childEls != null) {
          resultEls = [...resultEls, ...childEls];
        }
      }
    }

    return resultEls;
  }

  void appendElement(Node child, {RenderObject afterRenderObject, bool isAppend = true}) {
    if (child is Element) {
      RenderObject childRenderObject = child.renderObject;
      Style childStyle = child.style;
      ContextManager().styleMap[childRenderObject] = childStyle;
      String childPosition = childStyle['position'] ?? 'static';
      bool isFlex = renderLayoutElement is RenderFlexLayout;

      if (isFlex) {
        // Add FlexItem wrap for flex child node.
        RenderPadding parent = child.renderLayoutElement.parent;
        RenderBox childRenderBox = child.renderLayoutElement as RenderBox;
        parent.child = null;
        parent.child = RenderFlexItem(
          child: childRenderBox,
          parent: renderLayoutElement,
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
          if (isFlex) {
            ///flex ignore
            return;
          }
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
        List targets = findNeedsRepositionChildren(child);
        for (int i = 0; i < targets.length; i++) {
          Element target = targets[i];
          // remove positioned element from parent
          (target.parent.renderLayoutElement as ContainerRenderObjectMixin).remove(target.renderObject);

          RenderObject stackObject = createStackObject(target);
          ///insert by z-index
          insertByZIndex(renderStack, stackObject, target, target.style.zIndex);
        }
      }

      ParentData childParentData = childRenderObject.parentData;
      if (isFlex) {
        RenderFlexLayout renderLayout = renderLayoutElement as RenderFlexLayout;
        if (renderLayout.direction == Axis.vertical &&
          renderLayout.crossAxisAlignment != CrossAxisAlignment.stretch) {
        }
        assert(childParentData is FlexParentData);
        final FlexParentData parentData = childParentData;
        FlexParentData flexParentData = FlexItem.getParentData(childStyle);
        parentData.flex = flexParentData.flex;
        parentData.fit = flexParentData.fit;
        String alignItems = style[FlexItem.ALIGN_ITEMS];
        if (alignItems != null && style[FlexItem.ALIGN_ITEMS] != 'stretch') {
          flexParentData.fit = FlexFit.tight;
        }

        child.markShouldUpdateMargin(); // Update margin for flex child.
        renderObject.markNeedsLayout();
      }
    } else if (child is TextNode) {
      RenderParagraph renderParagraph = RenderParagraph(
        createTextSpanWithStyle(child.data, style),
        textAlign: getTextAlignFromStyle(style),
        textDirection: TextDirection.ltr,
      );
      addChild(renderParagraph);
    }
  }

  void insertByZIndex(RenderStack renderStack, RenderObject renderObject, Element el, int zIndex) {
    el.needsReposition = false;
    RenderBox child = renderStack.lastChild;
    while(child != null) {
      ParentData parentData = child.parentData;
      if (parentData is ZIndexParentData) {
        if (parentData.zIndex <= zIndex) {
          renderStack.insert(renderObject, after: child);
        } else {
          final ContainerParentDataMixin childParentData = child.parentData;
          renderStack.insert(renderObject, after: childParentData.previousSibling);
        }
        return;
      } else if(zIndex >= 0) {
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

    if (style.contains('top') || style.contains('left') || style.contains('bottom') || style.contains('right')) {
      parentData
        ..top = Length(style['top']).displayPortValue
        ..left = Length(style['left']).displayPortValue
        ..bottom = Length(style['bottom']).displayPortValue
        ..right = Length(style['right']).displayPortValue;
    }
    parentData.width = Length(style['width']).displayPortValue;
    parentData.height = Length(style['height']).displayPortValue;
    parentData.zIndex = style.zIndex;
    return parentData;
  }

  // update textNode style when container style changed
  void updateTextNodeStyle(String key) {
    childNodes.forEach((node) {
      if (node is TextNode) {
        node.setProperty(key, node.data);
      }
    });
  }

  @mustCallSuper
  void setProperty(String key, value) {
    if (key.indexOf(STYLE_PATH_PREFIX) >= 0) {
      String styleKey = key.substring(1).split('.')[1];
      Style newStyle = _style.copyWith({styleKey :value});
      properties['style'] = newStyle.getOriginalStyleMap();
      style = newStyle;
      updateTextNodeStyle(styleKey);
    } else {
      properties[key] = value;
      if (key == STYLE) {
        style = _style.copyWith(value);
      }

      if (key == 'style') {
        updateTextNodeStyle(key);
      }
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);
  }

  dynamic method(String name, List<dynamic> args) {
    debugPrint('unknown method call. name: $name, args: ${args}');
  }
}

mixin ElementEventHandler on Node {
  num _touchStartTime = 0;
  num _touchEndTime = 0;

  static const int MAX_STEP_MS = 10;
  final Throttling _throttler = new Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  void _handlePointDown(PointerDownEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchstart', pointEvent);
    _touchStartTime = event.timeStamp;
    this.dispatchEvent(event);
  }

  void _handlePointMove(PointerMoveEvent pointEvent) {
    _throttler.throttle(() {
      TouchEvent event = _getTouchEvent('touchmove', pointEvent);
      this.dispatchEvent(event);
    });
  }

  void _handlePointUp(PointerUpEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchend', pointEvent);
    _touchEndTime = event.timeStamp;
    this.dispatchEvent(event);

    // <300ms to trigger click
    if (_touchStartTime > 0 &&
        _touchEndTime > 0 &&
        _touchEndTime - _touchStartTime < 300) {
      handleClick(Event('click', EventInit()));
    }
  }

  TouchEvent _getTouchEvent(String type, PointerEvent pointEvent) {
    TouchEvent event = TouchEvent(type);
    Touch touch = Touch(
      identifier: pointEvent.pointer,
      target: this,
      screenX: pointEvent.position.dx,
      screenY: pointEvent.position.dy,
      clientX: pointEvent.localPosition.dx,
      clientY: pointEvent.localPosition.dy,
      pageX: pointEvent.localPosition.dx,
      pageY: pointEvent.localPosition.dy,
      radiusX: pointEvent.radiusMajor,
      radiusY: pointEvent.radiusMinor,
      rotationAngle: pointEvent.orientation,
      force: pointEvent.pressure,
    );
    event.changedTouches.items.add(touch);
    event.targetTouches.items.add(touch);
    event.touches.items.add(touch);
    event.detail = {};
    return event;
  }

  void handleClick(Event event) {
    this.dispatchEvent(event);
  }

  void _handlePointCancel(PointerCancelEvent pointEvent) {
    Event event = Event('touchcancel', EventInit());
    event.detail = {};
    this.dispatchEvent(event);
  }

  void addEvent(String eventName) {
    if (this.eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.addEventListener(eventName, this._eventResponder);
  }

  void removeEvent(String eventName) {
    super.removeEventListener(eventName, this._eventResponder);
  }

  void _eventResponder(Event event) {
    JSMessage(json.encode([
      'event',
      [
        nodeId,
        event,
      ]
    ], toEncodable: (event) => event.toJson())).send();
  }
}
