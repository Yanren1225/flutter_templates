import 'auto_dispose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

abstract class BaseViewModel with AutoDispose {
  @mustCallSuper
  void init() {
    debugPrint('ViewModel initialized: $runtimeType');
  }

  @mustCallSuper
  void dispose() {
    debugPrint('ViewModel disposed: $runtimeType');
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
      try {
        ticker.dispose();
      } catch (e) {
        debugPrint('Error disposing ticker: $e');
      }
    }
    _tickers.clear();
    super.onTickerDispose();
  }
}
