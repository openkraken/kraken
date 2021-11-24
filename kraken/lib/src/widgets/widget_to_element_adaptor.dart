/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/css.dart';
import 'package:kraken/bridge.dart';

import 'element_to_widget_adaptor.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

class KrakenRenderObjectToWidgetAdapter<T extends RenderObject> extends RenderObjectWidget {
  /// Creates a bridge from a [RenderObject] to an [Element] tree.
  ///
  /// Used by [WidgetsBinding] to attach the root widget to the [RenderView].
  KrakenRenderObjectToWidgetAdapter({
    this.child,
    required this.container,
    this.debugShortDescription,
  }) : super(key: GlobalObjectKey(container));

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderObjectWithChildMixin<T> container;

  /// A short description of this widget used by debugging aids.
  final String? debugShortDescription;

  @override
  KrakenRenderObjectToWidgetElement<T> createElement() => KrakenRenderObjectToWidgetElement<T>(this);

  @override
  RenderObjectWithChildMixin<T> createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) { }

  /// Inflate this widget and actually set the resulting [RenderObject] as the
  /// child of [container].
  KrakenRenderObjectToWidgetElement<T> attachToRenderTree(BuildOwner owner, RenderObjectElement rootElement) {
    KrakenRenderObjectToWidgetElement<T>? element;
    owner.lockState(() {
      element = createElement();
      assert(element != null);
    });
    owner.buildScope(element!, () {
      // TODO: needs to set parent KrakenRenderObjectToWidgetElement after appendChild on widgetElement supported.
      element!.mount(rootElement, null);
    });
    return element!;
  }

  @override
  String toStringShort() => debugShortDescription ?? super.toStringShort();
}

class KrakenRenderObjectToWidgetElement<T extends RenderObject> extends RenderObjectElement {
  /// Creates an element that is hosted by a [RenderObject].
  ///
  /// The [RenderObject] created by this element is not automatically set as a
  /// child of the hosting [RenderObject]. To actually attach this element to
  /// the render tree, call [RenderObjectToWidgetAdapter.attachToRenderTree].
  KrakenRenderObjectToWidgetElement(KrakenRenderObjectToWidgetAdapter<T> widget) : super(widget);

  @override
  KrakenRenderObjectToWidgetAdapter get widget => super.widget as KrakenRenderObjectToWidgetAdapter<T>;

  Element? _child;

  static const Object _rootChildSlot = Object();

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null)
      visitor(_child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _rebuild();
    assert(_child != null);
  }

  @override
  void update(RenderObjectToWidgetAdapter<T> newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _rebuild();
  }

  // When we are assigned a new widget, we store it here
  // until we are ready to update to it.
  Widget? _newWidget;

  @override
  void performRebuild() {
    if (_newWidget != null) {
      // _newWidget can be null if, for instance, we were rebuilt
      // due to a reassemble.
      final Widget newWidget = _newWidget!;
      _newWidget = null;
      update(newWidget as RenderObjectToWidgetAdapter<T>);
    }
    super.performRebuild();
    assert(_newWidget == null);
  }

  void _rebuild() {
    try {
      _child = updateChild(_child, widget.child, _rootChildSlot);
    } catch (exception, stack) {
      final FlutterErrorDetails details = FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'widgets library',
        context: ErrorDescription('attaching to the render tree'),
      );
      FlutterError.reportError(details);
      final Widget error = ErrorWidget.builder(details);
      _child = updateChild(null, error, _rootChildSlot);
    }
  }

  @override
  RenderObjectWithChildMixin<T> get renderObject => super.renderObject as RenderObjectWithChildMixin<T>;

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    assert(slot == _rootChildSlot);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child as T;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    assert(renderObject.child == child);
    renderObject.child = null;
  }
}

abstract class WidgetElement extends dom.Element {
  late Widget _widget;
  _KrakenAdapterWidgetState? _state;
  WidgetElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, dom.ElementManager elementManager)
      : super(
      targetId,
      nativeEventTarget,
      elementManager,
      isIntrinsicBox: true,
      defaultStyle: _defaultStyle
  );

  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children);

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();

    WidgetsFlutterBinding.ensureInitialized();

    _state = _KrakenAdapterWidgetState(this, properties, children);
    _widget = _KrakenAdapterWidget(_state!);
    _attachWidget(_widget);
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    if (_state != null) {
      _state!.onAttributeChanged(properties);
    }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    if (_state != null) {
      _state!.onAttributeChanged(properties);
    }
  }

  @override
  dom.Node appendChild(dom.Node child) {
    super.appendChild(child);

    if (_state != null) {
      _state!.onChildrenChanged(childNodes);
    }

    return child;
  }

  @override
  dom.Node removeChild(dom.Node child) {
    super.removeChild(child);

    if (_state != null) {
      _state!.onChildrenChanged(children);
    }

    return child;
  }

  void _attachWidget(Widget widget) {
    RenderObjectElement rootWidgetElement = elementManager.controller.rootKrakenElement;
    KrakenRenderObjectToWidgetAdapter adaptor = KrakenRenderObjectToWidgetAdapter(
      child: widget,
      container: renderBoxModel as RenderObjectWithChildMixin<RenderBox>
    );
    adaptor.attachToRenderTree(rootWidgetElement.owner!, rootWidgetElement);
  }
}

class _KrakenAdapterWidget extends StatefulWidget {
  final _KrakenAdapterWidgetState _state;
  _KrakenAdapterWidget(this._state);
  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}


class _KrakenAdapterWidgetState extends State<_KrakenAdapterWidget> {
  Map<String, dynamic> _properties;
  final WidgetElement _element;
  List<dom.Node> _childNodes;

  _KrakenAdapterWidgetState(this._element, this._properties, this._childNodes);

  void onAttributeChanged(Map<String, dynamic> properties) {
    setState(() {
      _properties = properties;
    });
  }

  void onChildrenChanged(List<dom.Node> childNodes) {
    setState(() {
      _childNodes = childNodes;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    _childNodes.forEach((dom.Node node) {
      if (node is dom.Element) {
        node.createRenderer();
        RenderObject? object = node.renderer;
        list.add(KrakenLeafRenderObjectWidget(object!));
      } else if (node is dom.TextNode) {
        node.createRenderer();
        RenderObject? object = node.renderer;
        list.add(KrakenLeafRenderObjectWidget(object!));
      }

      // element.createRenderer();

    });

    return _element.build(context, _properties, list);
  }
}
