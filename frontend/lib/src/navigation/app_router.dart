// path: lib/src/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_client.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home_screen.dart';
import '../views/map_screen.dart';
import '../views/permission_onboarding_screen.dart';
import '../views/profile_screen.dart';
import '../views/quests_list_screen.dart';
import '../views/root_tabs_screen.dart';
import '../views/search_screen.dart';
import '../views/trip_detail_screen.dart';
import 'go_router_refresh_stream.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final loggedIn = authViewModel.isAuthenticated;
    final loggingIn = state.matchedLocation == '/auth/login' || state.matchedLocation == '/auth/register';

    if (!loggedIn && !loggingIn) return '/auth/login';
    if (loggedIn && loggingIn) return '/map';
    return null;
  },
  routes: [
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
            GoRoute(path: '/quests', builder: (context, state) => const QuestListScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
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
      path: '/permissions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PermissionOnboardingScreen(),
    ),
    GoRoute(
      path: '/trip/:tripId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TripDetailScreen(tripId: state.pathParameters['tripId']!),
    ),
  ],
);
