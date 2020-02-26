import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';

const String ANIMATION = "ANIMATION";

class AnimationElement extends Element {
  static final String ANIMATION_TYPE_FLARE = "flare";

  String type = ANIMATION_TYPE_FLARE;
  String objectFit = 'contain';
  RenderObject animationRenderObject;

  AnimationElement(
      int nodeId, Map<String, dynamic> properties, List<String> events)
      : super(
            nodeId: nodeId,
            properties: properties,
            events: events,
            defaultDisplay: "block",
            tagName: ANIMATION) {
    if (properties.containsKey('type')) {
      type = properties['type'];
    }

    if (style.contains('objectFit')) {
      objectFit = style['objectFit'];
    }

    if (type == ANIMATION_TYPE_FLARE) {
      animationRenderObject = _createFlareRenderObject(properties);
    }
    if (animationRenderObject != null) {
      addChild(animationRenderObject);
    }
  }

  FlareRenderObject _createFlareRenderObject(
      Map<String, dynamic> properties) {
    assert(properties.containsKey('src'));
    BoxFit boxFit;
    switch(objectFit) {
      case 'fill':
        boxFit = BoxFit.fill;
        break;
      case 'cover':
        boxFit = BoxFit.cover;
        break;
      case 'fitHeight':
        boxFit = BoxFit.fitHeight;
        break;
      case 'fitWidth':
        boxFit = BoxFit.fitWidth;
        break;
      case 'scaleDown':
        boxFit = BoxFit.scaleDown;
        break;
      case 'contain':
      default:
        boxFit = BoxFit.contain;
    }
    return FlareRenderObject(nodeId)
      ..assetProvider =
          AssetFlare(bundle: NetworkAssetBundle(Uri.parse(properties['src'])), name: '')
      ..fit = boxFit
      ..alignment = Alignment.center
      ..animationName = properties['animationName']
      ..shouldClip = false
      ..useIntrinsicSize = true;
  }
}
