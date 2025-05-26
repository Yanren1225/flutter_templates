import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';

class ColorGen implements Builder {
  final String input;
  final String output;

  ColorGen(BuilderOptions options)
    : input =
          options.config['color_file'] as String? ?? 'lib/color/colors.json',
      output =
          options.config['output_file'] as String? ??
          'lib/color/color_extensions.g.dart';

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith('colors.json')) {
      return Future.value();
    }

    final inputId = buildStep.inputId;
    final outputId = AssetId(buildStep.inputId.package, output);
    final jsonString = await buildStep.readAsString(inputId);
    final Map<String, dynamic> colors = json.decode(jsonString);

    final buffer = StringBuffer();
    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: type=lint, camel_case_types')
      ..writeln()
      ..writeln('import "package:flutter/material.dart";')
      ..writeln();

    // 收集所有类信息
    final classInfos = <ClassInfo>[];
    _collectClassInfo(classInfos, colors['light'], 'CustomColors', null);

    final colorKeys = <String>[];
    final colorValues = <String>[];
    final colorMapEntries = <String, String>{};

    // 生成所有类定义（顶层，final字段+const构造）
    for (final classInfo in classInfos) {
      _writeFinalClass(
        buffer,
        classInfo,
        '',
        colorKeys,
        colorValues,
        colorMapEntries,
      );
      buffer.writeln();
    }

    // 生成 const 实例 LightColors（light）
    if (colors['light'] != null) {
      buffer.writeln('const LightColors = CustomColors(');
      _writeConstInstance(buffer, classInfos.first, colors['light'], 1);
      buffer.writeln(');\n');
    }

    // 生成 const 实例 DarkColors（dark）
    if (colors['dark'] != null) {
      buffer.writeln('const DarkColors = CustomColors(');
      _writeConstInstance(buffer, classInfos.first, colors['dark'], 1);
      buffer.writeln(');\n');
    }

    // 生成 LightColorsConsts 静态常量类
    if (colors['light'] != null) {
      final lightColorMapEntries = <String, String>{};
      _collectColorMapEntries(
        classInfos.first,
        colors['light'],
        '',
        lightColorMapEntries,
      );
      buffer.writeln('class LightColorsConsts {');
      for (final entry in lightColorMapEntries.entries) {
        final camelField = _toCamelField(entry.key);
        buffer.writeln('  static const Color $camelField = ${entry.value};');
      }
      buffer.writeln('}');
    }

    // 生成 DarkColorsConsts 静态常量类
    if (colors['dark'] != null) {
      final darkColorMapEntries = <String, String>{};
      _collectColorMapEntries(
        classInfos.first,
        colors['dark'],
        '',
        darkColorMapEntries,
      );
      buffer.writeln('class DarkColorsConsts {');
      for (final entry in darkColorMapEntries.entries) {
        final camelField = _toCamelField(entry.key);
        buffer.writeln('  static const Color $camelField = ${entry.value};');
      }
      buffer.writeln('}');
    }

    // 生成静态 List 和 Map
    buffer.writeln('class CustomColorsList {');
    buffer.writeln('  static const List<Color> all = [');
    for (final v in colorValues) {
      buffer.writeln('    $v,');
    }
    buffer.writeln('  ];');
    buffer.writeln('  static const Map<String, Color> map = {');
    for (final entry in colorMapEntries.entries) {
      buffer.writeln('    \'${entry.key}\': ${entry.value},');
    }
    buffer.writeln('  };');
    buffer.writeln('}');

    // 生成 ThemeData 扩展和便捷方法，自动切换
    buffer.writeln('extension CustomTheme on ThemeData {');
    if (colors['light'] != null && colors['dark'] != null) {
      buffer.writeln(
        '  CustomColors get appColors => brightness == Brightness.dark ? DarkColors : LightColors;',
      );
    } else if (colors['dark'] != null) {
      buffer.writeln('  CustomColors get appColors => DarkColors;');
    } else if (colors['light'] != null) {
      buffer.writeln('  CustomColors get appColors => LightColors;');
    } else {
      buffer.writeln(
        '  CustomColors get appColors => throw Exception("No theme colors defined");',
      );
    }
    buffer.writeln('}');
    buffer.writeln();
    await buildStep.writeAsString(outputId, buffer.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    input: [output],
  };
}

class ClassInfo {
  final String name;
  final Map<String, dynamic> map;
  final List<String> path;

  ClassInfo(this.name, this.map, this.path);
}

void _collectClassInfo(
  List<ClassInfo> result,
  Map<String, dynamic> map,
  String className,
  List<String>? parentPath,
) {
  final path = parentPath == null ? [className] : [...parentPath, className];
  result.add(ClassInfo(className, map, path));

  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final nestedClassName = '${className}_${_capitalize(key)}';
      _collectClassInfo(result, value, nestedClassName, path);
    }
  });
}

void _writeFinalClass(
  StringBuffer buffer,
  ClassInfo info,
  String parentKey,
  List<String> colorKeys,
  List<String> colorValues,
  Map<String, String> colorMapEntries,
) {
  buffer.writeln('class ${info.name} {');
  info.map.forEach((key, value) {
    final fullKey = parentKey.isEmpty ? key : '$parentKey.$key';
    if (value is Map<String, dynamic>) {
      final nestedClassName = '${info.name}_${_capitalize(key)}';
      buffer.writeln('  final $nestedClassName $key;');
    } else {
      final colorValue = _parseColorLiteral(value);
      buffer.writeln('  final Color $key;');
      colorKeys.add(fullKey);
      colorValues.add(colorValue);
      colorMapEntries[fullKey] = colorValue;
    }
  });
  // 构造函数
  buffer.writeln();
  buffer.writeln('  const ${info.name}({');
  info.map.forEach((key, value) {
    buffer.writeln('    required this.$key,');
  });
  buffer.writeln('  });');
  buffer.writeln('}');
}

void _writeConstInstance(
  StringBuffer buffer,
  ClassInfo info,
  Map<String, dynamic> map,
  int indent,
) {
  final indentStr = '  ' * indent;
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final nestedClassName = '${info.name}_${_capitalize(key)}';
      buffer.writeln('$indentStr$key: $nestedClassName(');
      _writeConstInstance(
        buffer,
        ClassInfo(nestedClassName, value, []),
        value,
        indent + 1,
      );
      buffer.writeln('$indentStr),');
    } else {
      final colorValue = _parseColorLiteral(value);
      buffer.writeln('$indentStr$key: $colorValue,');
    }
  });
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _parseColorLiteral(String hex) {
  if (hex.startsWith('#')) {
    if (hex.length == 9) {
      return 'Color(0x${hex.substring(1)})';
    } else if (hex.length == 7) {
      return 'Color(0xFF${hex.substring(1)})';
    }
  }
  throw FormatException('Invalid color format: $hex');
}

// Builder 工厂
Builder colorGenBuilder(BuilderOptions options) => ColorGen(options);

// 新增递归收集 dark 主题所有颜色的辅助方法
void _collectColorMapEntries(
  ClassInfo info,
  Map<String, dynamic> map,
  String parentKey,
  Map<String, String> colorMapEntries,
) {
  map.forEach((key, value) {
    final fullKey = parentKey.isEmpty ? key : '$parentKey.$key';
    if (value is Map<String, dynamic>) {
      final nestedClassName = '${info.name}_${_capitalize(key)}';
      _collectColorMapEntries(
        ClassInfo(nestedClassName, value, []),
        value,
        fullKey,
        colorMapEntries,
      );
    } else {
      final colorValue = _parseColorLiteral(value);
      colorMapEntries[fullKey] = colorValue;
    }
  });
}

// 新增统一命名方法
String _toCamelField(String key) {
  final parts = key.split('.');
  final fieldName = parts
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join('');
  return fieldName[0].toLowerCase() + fieldName.substring(1);
}
