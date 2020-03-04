/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/scheduler.dart';

mixin CustomTickerProviderStateMixin implements TickerProvider {
  Set<Ticker> _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= <_CustomTicker>{};
    final _CustomTicker result =
        _CustomTicker(onTick, this, debugLabel: 'created by $this');
    _tickers.add(result);
    return result;
  }

  void _removeTicker(_CustomTicker ticker) {
    assert(_tickers != null);
    assert(_tickers.contains(ticker));
    _tickers.remove(ticker);
  }
}

// This class should really be called _DisposingTicker or some such, but this
// class name leaks into stack traces and error messages and that name would be
// confusing. Instead we use the less precise but more anodyne "_WidgetTicker",
// which attracts less attention.
class _CustomTicker extends Ticker {
  _CustomTicker(TickerCallback onTick, this._creator, {String debugLabel})
      : super(onTick, debugLabel: debugLabel);

  final CustomTickerProviderStateMixin _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}
