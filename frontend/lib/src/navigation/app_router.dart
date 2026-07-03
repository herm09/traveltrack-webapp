import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/add_quest_screen.dart';
import '../views/feed_screen.dart';
import '../views/home_screen.dart';
import '../views/map_screen.dart';
import '../views/profile_screen.dart';
import '../views/root_tabs_screen.dart';
import '../views/trip_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootTabsScreen(navigationShell: navigationShell),
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
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/add', builder: (context, state) => const AddQuestScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
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
