import 'package:logger/logger.dart';

final logger = Logger();

final networkLogger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 0),
);
