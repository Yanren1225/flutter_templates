import 'package:flutter/material.dart';
import 'package:flutter_templates/core/event_bus.dart';
import 'package:flutter_templates/core/service_locator.dart';
import 'package:flutter_templates/events/app_life_event.dart';
import 'package:flutter_templates/router/router.dart';
import 'package:flutter_templates/services/app_service.dart';

void main() {
  ServiceLocator.instance.register(AppService());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    EventBus.instance.fire(AppLifecycleStateEvent(state));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Templates',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
