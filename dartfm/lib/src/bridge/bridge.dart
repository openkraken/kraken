/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'from_native.dart';
import 'to_native.dart';

void initBridge() {
  initJSEngine();
  registerDartMethodsToCpp();
}
