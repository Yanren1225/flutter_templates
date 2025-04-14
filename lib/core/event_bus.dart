import 'package:signals/signals.dart';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final Map<Type, Signal<dynamic>> _events = {};

  void emit<T>(T event) {
    final signal = _events[T];
    if (signal != null) {
      (signal as Signal<T?>).value = event;
    }
  }

  Signal<T?> signal<T>() {
    if (!_events.containsKey(T)) {
      _events[T] = Signal<T?>(null);
    }
    return _events[T] as Signal<T?>;
  }

  void Function() listen<T>(void Function(T event) callback) {
    final signal = this.signal<T>();
    bool isFirstRun = true;
    T? lastValue;

    return effect(() {
      final value = signal.value;
      if (value != null) {
        if (isFirstRun) {
          isFirstRun = false;
          lastValue = value;
        } else if (value != lastValue) {
          lastValue = value;
          callback(value);
        }
      }
    });
  }

  void dispose<T>() {
    _events.remove(T);
  }

  void clear() {
    _events.clear();
  }
}
