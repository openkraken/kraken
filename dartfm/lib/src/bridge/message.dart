/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'platform.dart';

const DART = 'D';
const CPP = 'C';
const JS = 'J';

const FETCH_MESSAGE = 's';
const TIMEOUT_MESSAGE = 't';
const INTERVAL_MESSAGE = 'i';
const ScreenMetrics = 'm';

class Message {
  final String _data;

  Message(String data) : _data = data;

  sendToCpp(String kind) {
    return invokeKrakenCallback(DART + CPP + kind + _data);
  }

  static buildMessage(String key, String value) {
    return "${key}=${value};";
  }

  sendToJs() {
    return invokeKrakenCallback(DART + JS + _data);
  }
}
