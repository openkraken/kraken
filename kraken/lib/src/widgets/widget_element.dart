/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/css.dart';
import 'package:kraken/bridge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

import 'slot.dart';

class _KrakenAdapterWidget extends StatefulWidget {
  final _KrakenAdapterWidgetPropertiesState _state;
  _KrakenAdapterWidget(this._state);
  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class _KrakenAdapterWidgetPropertiesState extends State<_KrakenAdapterWidget> {
  Map<String, dynamic> _properties;
  final WidgetElement _element;
  _KrakenAdapterWidgetPropertiesState(this._element, this._properties);

  void onAttributeChanged(Map<String, dynamic> properties) {
    setState(() {
      _properties = properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<KrakenSlot> slots = List.generate(_element.childNodes.length, (index) {
      return KrakenSlot.fromKrakenNode(_element.childNodes[index], context, (context, children, properies) {
      });
    });

    return _element.widgetBuilder(context, slots, _properties);
  }
}

class SlotElement extends dom.Element {
  SlotElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, dom.ElementManager elementManager) :
        super(targetId, nativeEventTarget, elementManager);

}

class WidgetElement extends SlotElement {
  // late Element _renderViewElement;
  // late BuildOwner _buildOwner;
  // late Widget _widget;
  // _KrakenAdapterWidgetPropertiesState? _propertiesState;

  final BuildContext context;
  final KrakenWidgetBuilder widgetBuilder;
  WidgetElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, dom.ElementManager elementManager, {
    required this.context,
    required this.widgetBuilder,
  })
      : super(
      targetId,
      nativeEventTarget,
      elementManager
  );

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    WidgetsFlutterBinding.ensureInitialized();
    // _propertiesState = _KrakenAdapterWidgetPropertiesState(this, properties);
    // _widget = _KrakenAdapterWidget(_propertiesState!);
    // _attachWidget(_widget);
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);
    // if (_propertiesState != null) {
    //   _propertiesState!.onAttributeChanged(properties);
    // }
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    // if (_propertiesState != null) {
    //   _propertiesState!.onAttributeChanged(properties);
    // }
  }

  @override
  dom.Node appendChild(dom.Node child) {
    return super.appendChild(child);
  }

  @override
  dom.Node removeChild(dom.Node child) {
    return super.removeChild(child);
  }

  void _handleBuildScheduled() {
    // Register drawFrame callback same with [WidgetsBinding.drawFrame]
    // SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
    //   _buildOwner.buildScope(_renderViewElement);
    //   // ignore: invalid_use_of_protected_member
    //   RendererBinding.instance!.drawFrame();
    //   _buildOwner.finalizeTree();
    // });
    // SchedulerBinding.instance!.ensureVisualUpdate();
  }

  void _attachWidget(Widget widget) {
    // A new buildOwner difference with flutter's buildOwner
    // _buildOwner = BuildOwner(focusManager: WidgetsBinding.instance!.buildOwner!.focusManager);
    // _buildOwner.onBuildScheduled = _handleBuildScheduled;
    // _renderViewElement = RenderObjectToWidgetAdapter<RenderBox>(
    //   child: widget,
    //   container: renderBoxModel as RenderObjectWithChildMixin<RenderBox>,
    // ).attachToRenderTree(_buildOwner);
  }
}
