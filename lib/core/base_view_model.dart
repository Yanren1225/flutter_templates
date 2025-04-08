import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_templates/core/auto_unsub.dart';

abstract class BaseViewModel extends ChangeNotifier with AutoUnsub {
  @mustCallSuper
  void init() {}

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    clearSubscriptions();
    onTickerDispose();
  }

  void onTickerDispose() {}
}

mixin ViewModelTicker on BaseViewModel implements TickerProvider {
  final Set<Ticker> _tickers = <Ticker>{};

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick, debugLabel: 'created by $runtimeType');
    _tickers.add(ticker);
    return ticker;
  }

  @override
  void onTickerDispose() {
    for (final ticker in _tickers) {
      ticker.dispose();
    }
    _tickers.clear();
    super.onTickerDispose();
  }
}
