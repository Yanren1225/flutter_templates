import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

extension RouterExt on BuildContext {
  /// 获取当前路由信息
  String get currentLocation =>
      GoRouter.of(this).routerDelegate.currentConfiguration.fullPath;

  /// 获取路由参数
  Map<String, String> get pathParameters =>
      GoRouterState.of(this).pathParameters;
  Map<String, dynamic> get queryParameters =>
      GoRouterState.of(this).uri.queryParameters;
  Object? get extra => GoRouterState.of(this).extra;

  /// 导航到新页面
  Future<T?> push<T extends Object?>(
    String location, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    String finalLocation = location;
    if (pathParams != null && pathParams.isNotEmpty) {
      finalLocation = buildPath(location, params: pathParams);
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri(path: finalLocation, queryParameters: queryParams);
      finalLocation = uri.toString();
    }

    return GoRouter.of(this).push<T>(finalLocation, extra: extra);
  }

  /// 替换当前页面
  Future<T?> replace<T extends Object?>(
    String location, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    String finalLocation = location;
    if (pathParams != null && pathParams.isNotEmpty) {
      finalLocation = buildPath(location, params: pathParams);
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri(path: finalLocation, queryParameters: queryParams);
      finalLocation = uri.toString();
    }

    return GoRouter.of(this).replace<T>(finalLocation, extra: extra);
  }

  /// 导航到新页面,替换整个路由栈
  void go(
    String location, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    try {
      String finalLocation = location;
      if (pathParams != null && pathParams.isNotEmpty) {
        finalLocation = buildPath(location, params: pathParams);
      }

      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri(path: finalLocation, queryParameters: queryParams);
        finalLocation = uri.toString();
      }

      GoRouter.of(this).go(finalLocation, extra: extra);
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  bool canPop() => GoRouter.of(this).canPop();

  // 返回上一页
  void pop<T extends Object?>([T? result]) {
    if (canPop()) {
      GoRouter.of(this).pop(result);
    }
  }

  // 带参数的导航示例 (query parameters)
  void pushWithQuery(String location, Map<String, String> queryParams) {
    final uri = Uri(path: location, queryParameters: queryParams);
    push(uri.toString());
  }

  // 构建带参数的路径
  String buildPath(String path, {Map<String, String>? params}) {
    if (params == null || params.isEmpty) return path;
    final segments = path
        .split('/')
        .map((segment) {
          if (segment.startsWith(':')) {
            final key = segment.substring(1);
            return params[key] ?? segment;
          }
          return segment;
        })
        .join('/');
    return segments;
  }

  // 清除历史记录并导航
  void clearAndGo(String location) {
    go(location);
    while (canPop()) {
      pop();
    }
  }

  ///// 自定义导航方法
  void toNet() => push(RoutePaths.net);

  void toList() => push(RoutePaths.list);
}
