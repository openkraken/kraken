import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kraken/style.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';

const String ANIMATION_PLAYER = 'ANIMATION-PLAYER';

// Ref: https://github.com/LottieFiles/lottie-player
class AnimationPlayerElement extends Element {
  static final String ANIMATION_TYPE_FLARE = 'flare';

  RenderObject _animationRenderObject;
  FlareControls _animationController;

  AnimationPlayerElement(
      int targetId, Map<String, dynamic> properties, List<String> events)
      : super(
            targetId: targetId,
            properties: properties,
            events: events,
            defaultDisplay: 'block',
            tagName: ANIMATION_PLAYER);


  String get objectFit => style['objectFit'];

  String get type {
    if (properties.containsKey('type')) return properties['type'];
    // Default type to flare
    return ANIMATION_TYPE_FLARE;
  }

  String get src {
    if (properties.containsKey('src')) return properties['src'];
    return null;
  }

  void _updateRenderObject() {
    if (src == null) return;
    bool shouldAddChild = _animationRenderObject == null;

    _animationRenderObject = _createFlareRenderObject(properties);
    if (shouldAddChild) addChild(_animationRenderObject);
  }

  void _play(List args) {
    assert(args[0] is String);
    String name = args[0];
    double mix = 1.0;
    double mixSeconds = 0.2;
    if (args.length > 1 && args[1] != null) {
      assert(args[1] is Map);
      Map options = args[1];
      if (options.containsKey('mix')) {
        mix = Length.toDouble(options['mix']);
      }
      if (options.containsKey('mixSeconds')) {
        mix = Length.toDouble(options['mixSeconds']);
      }
    }
    _animationController?.play(name, mix: mix, mixSeconds: mixSeconds);
  }

  void _updateObjectFit() {
    if (_animationRenderObject is FlareRenderObject) {
      FlareRenderObject renderBox = _animationRenderObject;
      renderBox?.fit = _getObjectFit();
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);

    _updateRenderObject();
  }

  @override
  void setStyle(String key, value) {
    super.setStyle(key, value);
    if (key == 'objectFit') {
      _updateObjectFit();
    }
  }

  @override
  method(String name, List args) {
    switch (name) {
      case 'play':
        _play(args);
        break;
      default:
        super.method(name, args);
    }
  }

  BoxFit _getObjectFit() {
    switch(objectFit) {
      case 'fill':
        return BoxFit.fill;
        break;
      case 'cover':
        return BoxFit.cover;
        break;
      case 'fit-height':
        return BoxFit.fitHeight;
        break;
      case 'fit-width':
        return BoxFit.fitWidth;
        break;
      case 'scale-down':
        return BoxFit.scaleDown;
        break;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }

  FlareRenderObject _createFlareRenderObject(
      Map<String, dynamic> properties) {
    assert(properties.containsKey('src'));

    BoxFit boxFit = _getObjectFit();
    _animationController = FlareControls();

    return FlareRenderObject(targetId)
      ..assetProvider =
          AssetFlare(
            bundle: NetworkAssetBundle(Uri.parse(src)),
            name: ''
          )
      ..fit = boxFit
      ..alignment = Alignment.center
      ..animationName = properties['name']
      ..shouldClip = false
      ..useIntrinsicSize = true
      ..controller = _animationController;
  }
}
