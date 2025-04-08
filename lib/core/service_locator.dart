import 'service.dart';

class ServiceLocator {
  ServiceLocator._();
  static final _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  final Map<Type, Service> _services = {};

  /// 注册一个服务
  Future<void> register<T extends Service>(T service) async {
    if (!_services.containsKey(T)) {
      _services[T] = service;
      await service.init();
    }
  }

  /// 获取一个服务
  T get<T extends Service>() {
    if (!_services.containsKey(T)) {
      throw Exception('Service $T not registered');
    }
    return _services[T] as T;
  }

  /// 移除一个服务
  Future<void> remove<T extends Service>() async {
    if (_services.containsKey(T)) {
      await _services[T]!.dispose();
      _services.remove(T);
    }
  }

  /// 移除所有服务
  Future<void> removeAll() async {
    for (final service in _services.values) {
      await service.dispose();
    }
    _services.clear();
  }
}
