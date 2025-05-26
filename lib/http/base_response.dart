class BaseResponse<T> {
  final int code;
  final String message;
  final bool success;
  final T? data;

  BaseResponse({
    required this.code,
    required this.message,
    required this.success,
    required this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    if (json['success'] == false || json['data'] == null) {
      return BaseResponse<T>(
        code: json['code'] as int,
        message: json['message'] as String,
        success: json['success'] as bool,
        data: null,
      );
    } else {
      return BaseResponse<T>(
        code: json['code'] as int,
        message: json['message'] as String,
        success: json['success'] as bool,
        data: fromJsonT(json['data']),
      );
    }
  }

  Map<String, dynamic> toJson(dynamic Function(T?) toJsonT) {
    return {
      'code': code,
      'message': message,
      'success': success,
      'data': data != null ? toJsonT(data) : null,
    };
  }

  @override
  String toString() {
    return 'BaseResponse(statusCode: $code, statusMessage: $message, success: $success, data: $data)';
  }
}
