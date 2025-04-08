import 'package:flutter/foundation.dart';

class AppConfig {
  static const bool debugMode = kDebugMode;

  static const String baseUrl = debugMode ? devBaseUrl : prodBaseUrl;

  static const String devBaseUrl = 'https://dev.example.com';

  static const String prodBaseUrl = 'https://prod.example.com';
}
