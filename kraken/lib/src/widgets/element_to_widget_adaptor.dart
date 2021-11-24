import 'package:flutter/widgets.dart';

class KrakenLeafRenderObjectWidget extends RenderObjectWidget {
  final RenderObject _renderObject;

  KrakenLeafRenderObjectWidget(this._renderObject);

  @override
  RenderObjectElement createElement() {
    return KrakenLeafRenderObjectElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _renderObject;
  }
}

class KrakenLeafRenderObjectElement extends RenderObjectElement {
  KrakenLeafRenderObjectElement(RenderObjectWidget widget) : super(widget);
}
