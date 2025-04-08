import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_templates/router/route_paths.dart';
import 'package:flutter_templates/views/home/home_view.dart';
import 'package:flutter_templates/views/list/list_view.dart';
import 'package:flutter_templates/views/net/net_view.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  observers: [FlutterSmartDialog.observer],
  initialLocation: RoutePaths.home,
  routes: [
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(path: RoutePaths.net, builder: (context, state) => const NetView()),
    GoRoute(
      path: RoutePaths.list,
      builder: (context, state) => const ListView(),
    ),
  ],
);
