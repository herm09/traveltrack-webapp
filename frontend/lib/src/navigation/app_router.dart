import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/home_screen.dart';
import '../views/map_screen.dart';
import '../views/root_tabs_screen.dart';
import '../views/trip_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => RootTabsScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/trip/:tripId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TripDetailScreen(tripId: state.pathParameters['tripId']!),
    ),
  ],
);
