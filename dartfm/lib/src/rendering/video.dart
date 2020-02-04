import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

class VideoRenderBox extends TextureBox {
  /// Creates a box backed by the texture identified by [textureId].
  VideoRenderBox({@required int textureId})
      : assert(textureId != null),
        super(textureId: textureId);

//  @override
//  void performLayout() {
//    size = Size(300, 300);
//  }
}
