import 'package:dio/dio.dart';
import 'package:flutter_templates/app_config.dart';
import 'package:flutter_templates/http/logger_interceptor.dart';
import 'package:flutter_templates/utils/logger.dart';
import 'package:fpdart/fpdart.dart';

import 'base_response.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete;

  String get value => name.toUpperCase();
}

class HttpClient {
  static final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )
    // ..interceptors.add(RequestInterceptor())
    ..interceptors.add(LoggerInterceptor());

  static final RawHttpClient raw = RawHttpClient._();
}

class RawHttpClient {
  RawHttpClient._();

  static Future<Response<T>> request<T>({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await HttpClient.dio.request<T>(
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

  static Future<Response<T>> get<T>(
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

  static Future<Response<T>> post<T>(
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

  static Future<Response<T>> put<T>(
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

  static Future<Response<T>> delete<T>(
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
}

class DataHttpClient {
  DataHttpClient._();

  static Future<T?> request<T>({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await RawHttpClient.request<T>(
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
}

class ResponseHttpClient {
  ResponseHttpClient._();

  static Either<String, T> basicResult<T>(BaseResponse<T> response) =>
      response.success
          ? Either.right(response.data as T)
          : Either.left(response.message);

  static Future<BaseResponse<T>> request<T>({
    required String path,
    required HttpMethod method,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await RawHttpClient.request(
      path: path,
      method: method,
      query: query,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
    return BaseResponse.fromJson(response.data, fromJson);
  }

  static Future<BaseResponse<T>> get<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    fromJson: fromJson,
    method: HttpMethod.get,
    query: query,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<BaseResponse<T>> post<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    fromJson: fromJson,
    method: HttpMethod.post,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<BaseResponse<T>> put<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    fromJson: fromJson,
    method: HttpMethod.put,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );

  static Future<BaseResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => request<T>(
    path: path,
    fromJson: fromJson,
    method: HttpMethod.delete,
    query: query,
    data: data,
    options: options,
    cancelToken: cancelToken,
  );
}
