/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';

const String DIV = 'DIV';

class DivElement extends Element {
  DivElement(int targetId)
      : super(
          targetId: targetId,
          tagName: DIV
        );
}
