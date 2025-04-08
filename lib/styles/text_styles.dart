import 'package:flutter/material.dart';

class TextStyles {
  TextStyle heading1 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static final TextStyles _instance = TextStyles._();

  TextStyles._();

  factory TextStyles() => _instance;
}
