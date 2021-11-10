/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/widgets.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/rendering.dart';

typedef KrakenWidgetBuilder = Widget Function(BuildContext context, List<KrakenSlot> children, Map<String, dynamic> properies);

class KrakenSlotElement extends RenderObjectElement {
  KrakenSlotElement(KrakenSlot widget) : super(widget);

  @override
  // TODO: implement debugDoingBuild
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void visitChildren(ElementVisitor visitor) {

  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {

  }

  @override
  void performRebuild() {
    // TODO: implement performRebuild
  }
}

class KrakenSlot extends RenderObjectWidget {
  final String tagName;
  final BuildContext context;
  final KrakenWidgetBuilder builder;

  KrakenSlot(this.tagName, this.context, this.builder);

  @override
  RenderObjectElement createElement() {
    return KrakenSlotElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlowLayout(renderStyle: RenderStyle());
  }
}



