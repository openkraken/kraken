/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String PARAGRAPH = 'P';

class ParagraphElement extends Element {
  ParagraphElement({@required int targetId, @required ElementManager elementManager})
      : super(targetId: targetId, tagName: PARAGRAPH, elementManager: elementManager);
}
