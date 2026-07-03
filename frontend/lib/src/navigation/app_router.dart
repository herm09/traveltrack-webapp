// path: lib/src/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home_screen.dart';
import '../views/map_screen.dart';
import '../views/profile_screen.dart';
import '../views/quests_list_screen.dart';
import '../views/root_tabs_screen.dart';
import '../views/search_screen.dart';
import '../views/trip_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/auth/login',
  routes: [
    // ===== AUTH ROUTES =====
    GoRoute(
      path: '/auth/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ===== MAIN APP ROUTES =====
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => RootTabsScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quests',
              builder: (context, state) => const QuestListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ===== DETAIL ROUTES =====
    GoRoute(
      path: '/trip/:tripId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TripDetailScreen(
        tripId: state.pathParameters['tripId']!,
      ),
    ),
  ],
);
