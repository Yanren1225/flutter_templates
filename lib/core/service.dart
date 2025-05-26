import 'package:flutter/foundation.dart';
import 'package:flutter_templates/core/auto_dispose.dart';
import 'package:signals/signals_flutter.dart';

/// Service 基类
/// 用于处理全局业务逻辑和状态管理
abstract class Service with AutoDispose {
  final Map<String, Signal> _signals = {};
  bool _initialized = false;

  /// 初始化方法，在 Service 注册时调用
  @nonVirtual
  Future<void> init() async {
    if (_initialized) return;
    onInit();
    _initialized = true;
  }

  /// 子类重写此方法来执行初始化逻辑
  @protected
  void onInit() async {}

  /// 销毁方法，在 Service 被移除时调用
  @nonVirtual
  Future<void> dispose() async {
    await onDispose();
    _signals.clear();
    _initialized = false;
    clearSubscriptions();
  }

  /// 子类重写此方法来执行销毁逻辑
  @protected
  Future<void> onDispose() async {}

  /// 创建或获取一个信号
  Signal<T> signal<T>(String key, {T? initialValue}) {
    if (!_signals.containsKey(key)) {
      _signals[key] = Signal<T>(initialValue as T);
    }
    return _signals[key]! as Signal<T>;
  }

  /// 更新信号的值
  void update<T>(String key, T value) {
    if (_signals.containsKey(key)) {
      (_signals[key]! as Signal<T>).value = value;
    }
  }

  /// 获取信号的当前值
  T? getValue<T>(String key) {
    if (_signals.containsKey(key)) {
      return (_signals[key]! as Signal<T>).value;
    }
    return null;
  }
}
