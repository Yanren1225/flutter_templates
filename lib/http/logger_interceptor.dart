import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_templates/utils/logger.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    networkLogger.log(
      Level.trace,
      "🌐 Request: [${options.method}] ${options.uri}\n"
      "Headers: ${_formatJsonData(options.headers)}\n"
      "Query Parameters: ${options.queryParameters}\n"
      "Body: ${_formatJsonData(options.data)}",
    );

    options.extra['startTime'] = startTime;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'];
    final endTime =
        startTime != null ? DateTime.now().millisecondsSinceEpoch : 0;
    final duration = endTime - startTime;

    networkLogger.log(
      Level.trace,
      "🆗 Response: [${response.statusCode}] ${response.requestOptions.uri}\n"
      "Headers: ${_formatJsonData(response.requestOptions.headers)}\n"
      "Duration: ${duration}ms\n"
      "Body: ${_formatJsonData(response.data)}",
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'];
    final endTime =
        startTime != null ? DateTime.now().millisecondsSinceEpoch : 0;
    final duration = endTime - startTime;

    networkLogger.log(
      Level.trace,
      "❌ Error: [${err.response?.statusCode}] ${err.requestOptions.uri}\n"
      "Duration: ${duration}ms\n"
      "Body: ${_formatJsonData(err.response?.data)}\n"
      "Error: ${err.message}",
    );

    handler.next(err);
  }

  final JsonEncoder _prettyJson = const JsonEncoder.withIndent('  ');

  String _formatJsonData(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is Map || data is List) {
        return _prettyJson.convert(data);
      } else if (data is String) {
        return data;
      } else {
        return data.toString();
      }
    } catch (e) {
      return "Error formatting data: $e";
    }
  }
}
