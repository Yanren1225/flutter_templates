import 'package:dio/dio.dart';
import 'package:flutter_templates/app_config.dart';
import 'package:flutter_templates/utils/logger.dart';

import 'base_response.dart';
import 'http_result.dart';
import 'logger_interceptor.dart';
import 'request_interceptor.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete;

  String get value => name.toUpperCase();
}

enum ApiType {
  defaultType('default', null),
  dev('dev', AppConfig.devBaseUrl),
  prod('prod', AppConfig.prodBaseUrl);

  final String name;
  final String? url;
  const ApiType(this.name, this.url);
}

class HttpClient {
  static Dio? _dio;
  static ApiType? _currentType;

  static Future<void> init(ApiType type) async {
    if (_currentType == type && _dio != null) return;
    _currentType = type;
    _dio =
        Dio(
            BaseOptions(
              baseUrl: type.url ?? AppConfig.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          )
          ..interceptors.add(RequestInterceptor())
          ..interceptors.add(LoggerInterceptor());
  }

  static Dio get dio {
    if (_dio == null) {
      throw Exception("HttpClient 未初始化，请先调用 HttpClient.init");
    }
    return _dio!;
  }

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
            (options?.copyWith(
                  method: method.value,
                  validateStatus: (_) => true,
                ) ??
                Options(method: method.value, validateStatus: (_) => true)),
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

extension FutureBaseResponseExt<T> on Future<BaseResponse<T>> {
  Future<HttpResult<T>> toHttpResult() {
    return then(
      ResponseHttpClient.basicResult,
    ).catchError((e, stack) => ResponseHttpClient.basicError<T>(e, stack));
  }
}

class ResponseHttpClient {
  ResponseHttpClient._();

  static HttpResult<T> basicError<T>(dynamic error, StackTrace stackTrace) =>
      HttpResult<T>.catchError(error);

  static HttpResult<T> basicResult<T>(BaseResponse<T> response) =>
      response.success
          ? HttpResult.success(response.data as T)
          : HttpResult.fail(
            HttpError(message: response.message, code: response.code),
          );

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

    final result = BaseResponse.fromJson(response.data, fromJson);

    return result;
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
