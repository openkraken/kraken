/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'message.dart';

class KrakenTimer {
  int timerId = 1;
  Map<int, Timer> timerMap = {};

  KrakenTimer();

  int setTimeout(int callbackId, int timeout) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer(timeoutDurationMS, () {
      Message("$callbackId").sendToCpp(TIMEOUT_MESSAGE);
      timerMap.remove(id);
    });
    return id;
  }

  void clearTimeout(int timerId) {
    timerMap[timerId].cancel();
    timerMap.remove(timerId);
  }

  int setInterval(int callbackId, int timeout) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer.periodic(timeoutDurationMS, (Timer timer) {
      Message("$callbackId").sendToCpp(INTERVAL_MESSAGE);
    });
    return id;
  }
}
