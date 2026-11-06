// path: lib/src/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveltrack/src/views/auth/forgot_password_screen.dart';
import 'package:traveltrack/src/views/auth/reset_password_screen.dart';

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
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: Listenable.merge([
    GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    authViewModel.isPasswordRecoveryPending,
  ]),
  redirect: (context, state) {
    const resetPasswordLocation = '/auth/reset-password';
    // Le lien de réinitialisation ouvre une session : on impose la saisie du
    // nouveau mot de passe avant de donner accès au reste de l'application.
    if (authViewModel.isPasswordRecoveryPending.value) {
      return state.matchedLocation == resetPasswordLocation
          ? null
          : resetPasswordLocation;
    }

    final loggedIn = authViewModel.isAuthenticated;
    if (state.matchedLocation == resetPasswordLocation) {
      return loggedIn ? '/map' : '/auth/login';
    }

    final loggingIn = const {
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
    }.contains(state.matchedLocation);

    if (!loggedIn && !loggingIn) return '/auth/login';
    if (loggedIn && loggingIn) return '/map';
    return null;
  },
  routes: [
    // Sur le web, le retour d'OAuth ou d'un email arrive sur la racine de l'app.
    GoRoute(path: '/', redirect: (context, state) => '/home'),
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
    GoRoute(
      path: '/auth/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/reset-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // ===== MAIN APP ROUTES =====
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootTabsScreen(navigationShell: navigationShell),
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

    // ===== DETAIL ROUTES =====
    GoRoute(
      path: '/permissions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PermissionOnboardingScreen(),
    ),
    GoRoute(
      path: '/trip/:tripId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TripDetailScreen(
        tripId: state.pathParameters['tripId']!,
      ),
    ),
  ],
);
