/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:quiver/collection.dart';

final _timeRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?ms|s$', caseSensitive: false);
final _0s = '0s';
final _0ms = '0ms';
final LinkedLruHashMap<String, int?> _cachedParsedTime = LinkedLruHashMap(maximumSize: 100);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#time
class CSSTime {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';

  static bool isTime(String value) {
    return (value == _0s || value == _0ms || _timeRegExp.firstMatch(value) != null);
  }

  static int? parseTime(String input) {
    if (_cachedParsedTime.containsKey(input)) {
      return _cachedParsedTime[input];
    }
    int? milliseconds;
    if (input.endsWith(MILLISECONDS)) {
      milliseconds = double.tryParse(input.split(MILLISECONDS)[0])!.toInt();
    } else if (input.endsWith(SECOND)) {
      milliseconds = (double.tryParse(input.split(SECOND)[0])! * 1000).toInt();
    }

    return _cachedParsedTime[input] = milliseconds;
  }
}
