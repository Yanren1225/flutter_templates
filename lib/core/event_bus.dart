import 'dart:async';

import 'package:flutter_templates/ext/type.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseEvent {}

abstract class NormalEvent extends BaseEvent {}

abstract class StickyEvent extends BaseEvent {}

class EventBus {
  EventBus._();
  static final EventBus _instance = EventBus._();
  static EventBus get instance => _instance;

  final Map<Type, Subject> _subjects = <Type, Subject>{};

  Subject<E> _getSubject<E>() {
    if (checkType<E>().isExtendOf<NormalEvent>()) {
      if (!_subjects.containsKey(E)) {
        _subjects[E] = PublishSubject<E>();
      }
      return _subjects[E] as PublishSubject<E>;
    } else {
      if (!_subjects.containsKey(E)) {
        _subjects[E] = BehaviorSubject<E>();
      }
      return _subjects[E] as BehaviorSubject<E>;
    }
  }

  StreamSubscription<E> on<E extends BaseEvent>(
    void Function(E event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subject = _getSubject<E>();

    if (subject is BehaviorSubject<E> && subject.hasValue) {
      final value = subject.value;
      if ((value as dynamic) != null) {
        onData?.call(subject.value);
      }
    }

    return subject.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  Stream<E> stream<E extends BaseEvent>() => _getSubject<E>().stream;

  void fire<E extends NormalEvent>(E event) {
    _getSubject<E>().add(event);
  }

  void fireSticky<E extends StickyEvent>(E event) {
    _getSubject<E>().add(event);
  }

  /// 获取指定类型的粘性事件
  E? getStickyEvent<E extends StickyEvent>() {
    if (!_subjects.containsKey(E)) {
      return null;
    }

    final subject = _subjects[E] as BehaviorSubject<E>;
    return subject.hasValue ? subject.value : null;
  }

  /// 移除指定类型的粘性事件
  E? removeStickyEvent<E extends StickyEvent>() {
    if (!_subjects.containsKey(E)) {
      return null;
    }

    final subject = _subjects[E] as BehaviorSubject<E>;
    final hasValue = subject.hasValue;
    final value = hasValue ? subject.value : null;

    if (hasValue) {
      subject.close();
      _subjects[E] = BehaviorSubject<E>();
    }

    return value;
  }

  /// 销毁所有事件流
  void destroy() {
    for (final Subject subject in _subjects.values) {
      subject.close();
    }
    _subjects.clear();
  }

  /// 销毁指定类型的事件流
  void destroyType<E extends BaseEvent>() {
    if (_subjects.containsKey(E)) {
      _subjects[E]!.close();
      _subjects.remove(E);
    }
  }
}
