import 'package:dio/dio.dart';
import 'package:flutter_templates/app_config.dart';
import 'package:flutter_templates/http/logger_interceptor.dart';
import 'package:flutter_templates/utils/logger.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete;

  String get value => name.toUpperCase();
}

class HttpClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(LoggerInterceptor());

  static Future<Response<T>> requestRaw<T>({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.request<T>(
        path,
        queryParameters: query,
        data: data,
        options:
            options?.copyWith(method: method.value) ??
            Options(method: method.value),
        cancelToken: cancelToken,
      );

      return response;
    } on DioException catch (e) {
      logger.e('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  static Future<T?> request<T>({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await requestRaw<T>(
      path: path,
      method: method,
      query: query,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  static Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    method: HttpMethod.get,
    query: query,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<T?> post<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    method: HttpMethod.post,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<T?> put<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    method: HttpMethod.put,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<T?> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    method: HttpMethod.delete,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<Response<T>> getRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => requestRaw<T>(
    path: path,
    method: HttpMethod.get,
    query: query,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<Response<T>> postRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => requestRaw<T>(
    path: path,
    method: HttpMethod.post,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<Response<T>> putRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => requestRaw<T>(
    path: path,
    method: HttpMethod.put,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<Response<T>> deleteRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => requestRaw<T>(
    path: path,
    method: HttpMethod.delete,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );
}
