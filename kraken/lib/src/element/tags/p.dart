/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';

const String PARAGRAPH = 'P';

class ParagraphElement extends Element {
  ParagraphElement(
    int targetId
  ) : super(
        targetId: targetId,
        tagName: PARAGRAPH
      );
}
