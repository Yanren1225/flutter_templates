import 'package:dio/dio.dart';

class RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    final token = null;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
