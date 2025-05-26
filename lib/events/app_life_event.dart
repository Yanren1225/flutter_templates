import 'package:flutter/widgets.dart';
import 'package:flutter_templates/core/event_bus.dart';

class AppLifecycleStateEvent extends NormalEvent {
  final AppLifecycleState state;

  AppLifecycleStateEvent(this.state);
}
