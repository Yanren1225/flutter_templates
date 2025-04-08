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

  void Function() listen<T>(void Function(T? event) callback) {
    final signal = this.signal<T>();
    return effect(() => callback(signal.value));
  }

  void dispose<T>() {
    _events.remove(T);
  }

  void clear() {
    _events.clear();
  }
}
