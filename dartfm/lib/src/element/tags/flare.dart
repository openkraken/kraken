import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kraken/element.dart';

const String FLARE = 'flare';
class FlareElement extends Element {
  FlareActorRenderObject flareActorRenderObject;


  FlareElement(int nodeId, Map<String, dynamic> props, List<String> events)
      : super(
          nodeId: nodeId,
          defaultDisplay: 'block',
          tagName: FLARE,
          properties: props,
          events: events,
        ) {
    flareActorRenderObject = createFlareRenderObject(props['src']);
    addChild(flareActorRenderObject);
  }

  RenderObject createFlareRenderObject(String url) {
    AssetBundle bundle = NetworkAssetBundle(Uri.parse(url));
    return FlareActorRenderObject()
      ..assetProvider = AssetFlare(bundle: bundle, name: '');
  }
}
