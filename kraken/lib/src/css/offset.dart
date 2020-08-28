import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/element.dart';

mixin CSSOffsetMixin on Node {

  void updateRenderOffset(RenderBoxModel renderBoxModel, String property, String present) {

    if (renderBoxModel.parentData is RenderLayoutParentData) {
      RenderLayoutParentData positionParentData = renderBoxModel.parentData;

      if (property == Z_INDEX) {
        positionParentData.zIndex = int.tryParse(present) ?? 0;
      } else {
        double value = CSSLength.toDisplayPortValue(present);
        switch (property) {
          case TOP:
            positionParentData.top = value;
            break;
          case LEFT:
            positionParentData.left = value;
            break;
          case RIGHT:
            positionParentData.right = value;
            break;
          case BOTTOM:
            positionParentData.bottom = value;
            break;
          case WIDTH:
            positionParentData.width = value;
            break;
          case HEIGHT:
            positionParentData.height = value;
            break;
        }
      }

      renderBoxModel.parentData = positionParentData;
      renderBoxModel.markNeedsLayout();
    }
  }
}