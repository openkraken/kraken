/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/src/element/context.dart';
import 'package:kraken/src/bridge/message.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:kraken/element.dart';

const String STYLE = 'style';

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
  Element(
      {@required int nodeId,
      @required this.tagName,
      this.properties,
      List<String> events,
      @required this.defaultDisplay})
      : assert(tagName != null),
        assert(defaultDisplay != null),
        super(NodeType.ELEMENT_NODE, nodeId, tagName) {
    properties = properties ?? {};
    style = Style(properties[STYLE]);
    if (events != null) {
      for (String eventName in events) {
        addEvent(eventName);
      }
    }

    renderObject = renderLayoutElement = createRenderLayoutElement(null);
    if (renderLayoutElement is RenderFlexLayout) {
      decorateRenderFlex(renderLayoutElement, style);
    }
    renderObject = initRenderPadding(renderObject, style);
    if (style.backgroundAttachment == 'local' && style.backgroundImage != null) {
      renderObject = initBackgroundImage(renderObject, style);
    }
    renderObject = initOverflowBox(renderObject, style);
    renderObject = initRenderDecoratedBox(renderObject, style);

    renderObject = initRenderConstrainedBox(renderObject, style);
    renderObject = initRenderMargin(renderObject, style);
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

    renderObject = initTransform(renderObject, style);

    Map<String, dynamic> elementStyle = {};
    if (properties['style'] != null) {
      elementStyle = properties['style'];
    }
    elementStyle.putIfAbsent('display', () => display);

    // Init default events.
    renderObject = renderBoxModel = RenderBoxModel(
      child: renderObject,
      onPointerDown: this._handlePointDown,
      onPointerMove: this._handlePointMove,
      onPointerUp: this._handlePointUp,
      onPointerCancel: this._handlePointCancel,
      style: elementStyle,
    );
    _inited = true;
  }

  final String tagName;
  Map<String, dynamic> properties;
  RenderObject renderObject; // Style decorated renderObject
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutElement;
  RenderBoxModel renderBoxModel;
  bool _inited = false; // True after constructor finished.

  bool shouldBlockStretch = true;

  Style _style;
  Style get style => _style;
  set style(Style newStyle) {
    // Update style;
    if (_inited) {
      ///1.update display
      String oldDisplay =
          style.contains('display') ? style['display'] : defaultDisplay;
      String newDisplay =
          newStyle.contains('display') ? newStyle['display'] : defaultDisplay;
      if (newDisplay != oldDisplay) {
        ContainerRenderObjectMixin oldRenderElement = renderLayoutElement;
        List<RenderBox> children = [];
        RenderObjectVisitor visitor = (child) {
          children.add(child);
        };
        oldRenderElement
          ..visitChildren(visitor)
          ..removeAll();
        renderLayoutElement = createRenderLayoutElement(children);
        if (renderLayoutElement is RenderFlexLayout) {
          decorateRenderFlex(renderLayoutElement, style);
          RenderFlexLayout renderLayout = renderLayoutElement as RenderFlexLayout;
          if (renderLayout.direction == Axis.vertical &&
            renderLayout.crossAxisAlignment != CrossAxisAlignment.stretch) {
          }
        }
      }

      ///2.update overflow
      updateOverFlowBox(newStyle);

      ///3.update padding
      updateRenderPadding(newStyle, transitionMap);

      ///4.update decorated
      updateRenderDecoratedBox(newStyle, transitionMap);

      ///5.update constrained
      String newPosition = newStyle['position'] ?? 'static';
      String oldPosition = _style['position'] ?? 'static';
      bool positionChanged = false;
      if (newPosition != oldPosition) {
        positionChanged = true;
      }

      updateConstraints(newStyle, transitionMap);

      ///6.update margin
      updateRenderMargin(newStyle, transitionMap);

      ///7.update position
      if (positionChanged) {
        _updatePosition(newStyle);
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
    updateRenderMargin(style);
  }

  final String defaultDisplay;
  String get display {
    return style.contains('display') ? style['display'] : defaultDisplay;
  }

  void _updatePosition(Style style) {
    ///from !static to static
    ///need remove renderStack and attach the element to the doc tree
    if (style.position == 'static') {
      List<RenderBox> children = [];
      RenderObject childRenderObject;
      RenderObjectVisitor visitor = (child) {
        if (childRenderObject == null) {
          ///skip the first child, because it's not for position
          childRenderObject = child;
        } else {
          children.add(child);
        }
      };
      renderStack
        ..visitChildren(visitor)
        ..removeAll();

      ///add children to pre renderStack
      Element parentStackElement =
          findParent(this, (element) => element.renderStack != null);
      parentStackElement.renderStack.addAll(children);

      //FIXME: when RenderBoxModel change
      AbstractNode abstractNode = renderStack.parent;
      assert(abstractNode is RenderBoxModel);
      (abstractNode as RenderBoxModel).child = childRenderObject;

      ///attach the element to the doc tree
      Element parentStaticElement = findParent(this, (element) {
        bool state = element.renderStack == null;
        return state;
      });
      if (parentStaticElement != null) {
        AbstractNode parent = renderObject.parent;
        if (parent is ContainerRenderObjectMixin) {
          ///attach the element to the parent stack
          parent.remove(renderObject);

          ///find the pre child
          int curIndex = childNodes.indexOf(this);
          Node before =
              ++curIndex > childNodes.length ? null : childNodes[curIndex];
          parentStackElement.insertBefore(this, before);
        }
      }
    }

    ///from static to !static
    ///need add renderStack and attach the element to the parent stack
    else {
      //FIXME: when RenderBoxModel change
      AbstractNode stackParent = renderObject;
      assert(stackParent is RenderBoxModel);
      if (stackParent is RenderBoxModel) {
        stackParent.child = null;
        renderStack = RenderPosition(
          textDirection: TextDirection.ltr,
          fit: StackFit.passthrough,
          overflow: Overflow.visible,
          children: [
            //FIXME: when RenderBoxModel change
            renderBoxModel.child,
          ],
        );
      }

      assert(renderObject.parent is ContainerRenderObjectMixin);
      AbstractNode parent = renderObject.parent;
      if (parent is ContainerRenderObjectMixin) {
        ///attach the element to the parent stack
        parent.remove(renderObject);
        Element renderStackElement =
            findParent(this.parent, (element) => element.renderStack != null);
        StackParentData stackParentData = getAbsoluteParentDataFromStyle(style);
        renderObject.parentData = stackParentData;
        //FIXME:z-index should change after
        renderStackElement.renderStack.insert(renderObject);
      }
    }
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

  ContainerRenderObjectMixin createRenderLayoutElement(List<RenderBox> children) {
    if (display == 'flex' || display == 'inline-flex') {
      return RenderFlexLayout(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else if (display == 'inline' || display == 'block') {
      Map<String, dynamic> elementStyle = {};
      if (properties['style'] != null) {
        elementStyle = properties['style'];
      }
      elementStyle.putIfAbsent('display', () => display);

      return RenderFlowLayout(
        children: children,
        style: elementStyle,
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
    Node node = super.insertBefore(child, referenceNode);
    int referenceIndex = childNodes.indexOf(referenceNode);
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
      }

      if (childPosition == 'absolute') {
        Element parentStackedElement =
        findParent(this, (element) => element.renderStack != null);
        if (parentStackedElement != null) {
          ZIndexParentData stackParentData =
          getAbsoluteParentDataFromStyle(childStyle);
          RenderObject stackObject = childRenderObject;

          childRenderObject = RenderPadding(padding: EdgeInsets.zero);
          if (!isFlex) {
            stackParentData.hookRenderObject = childRenderObject;
          }
          stackObject.parentData = stackParentData;
          ///insert by z-index
          SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
            insertByZIndex(parentStackedElement.renderStack, stackObject, childStyle.zIndex);
          });
          if (isFlex) {
            ///flex ignore
            return;
          }
        }
      } else if (childPosition == 'fixed') {
        ZIndexParentData stackParentData =
        getAbsoluteParentDataFromStyle(childStyle);
        RenderObject stackObject = childRenderObject;

        childRenderObject = RenderPadding(padding: EdgeInsets.zero);
        if (!isFlex) {
          stackParentData.hookRenderObject = childRenderObject;
        }
        stackObject.parentData = stackParentData;
        final RenderPosition renderPosition = ElementManager().getRootElement().renderStack;
        SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
          insertByZIndex(renderPosition, stackObject, childStyle.zIndex);
        });
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

  void insertByZIndex(RenderStack renderStack, RenderObject renderObject, int zIndex) {
    RenderBox child = renderStack.lastChild;
    while(child != null) {
      ParentData parentData = child.parentData;
      if (parentData is ZIndexParentData) {
        if (parentData.zIndex <= zIndex){
          renderStack.insert(renderObject, after: child);
          return;
        }
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
    Element _el = element;

    while (_el != null && !statement(_el)) {
      _el = _el.parent;
    }

    return _el;
  }

  static ZIndexParentData getAbsoluteParentDataFromStyle(Style style) {
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

  @mustCallSuper
  void setProperty(String key, value) {
    properties[key] = value;
    if (key == STYLE) {
      style = _style.copyWith(value);
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

  void _handlePointDown(PointerDownEvent pointEvent) {
    Event event = Event('touchstart', EventInit());
    _touchStartTime = event.timeStamp;
    event.detail = {};
    this.dispatchEvent(event);
  }

  void _handlePointMove(PointerMoveEvent pointEvent) {
    Event event = Event('touchmove', EventInit());
    event.detail = {};
    this.dispatchEvent(event);
  }

  void _handlePointUp(PointerUpEvent pointEvent) {
    Event event = Event('touchend', EventInit());
    _touchEndTime = event.timeStamp;
    event.detail = {};
    this.dispatchEvent(event);

    // <300ms to trigger click
    if (_touchStartTime > 0 &&
        _touchEndTime > 0 &&
        _touchEndTime - _touchStartTime < 300) {
      handleClick(Event('click', EventInit()));
    }
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
    ], toEncodable: (event) => event.toJson())).sendToJs();
  }
}
