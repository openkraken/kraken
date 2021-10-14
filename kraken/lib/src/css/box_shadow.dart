import 'package:kraken/css.dart';

mixin CSSBoxShadowMixin on RenderStyleBase {
  List<CSSBoxShadow>? _boxShadow;
  set boxShadow(List<CSSBoxShadow>? value) {
    if (value == _boxShadow) return;
    _boxShadow = value;
    renderBoxModel!.markNeedsPaint();
  }
  List<CSSBoxShadow>? get boxShadow => _boxShadow;

  List<KrakenBoxShadow>? get shadows {
    if (boxShadow == null) {
      return null;
    }
    List<KrakenBoxShadow> result = [];
    for (CSSBoxShadow shadow in boxShadow!) {
      result.add(shadow.computedBoxShdow);
    }
    return result;
  }
}
