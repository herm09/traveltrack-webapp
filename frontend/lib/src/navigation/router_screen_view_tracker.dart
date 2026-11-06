import 'package:go_router/go_router.dart';
import 'package:traveltrack/src/services/analytics_service.dart';

/// Signale chaque changement d'écran à l'analytics.
///
/// `PosthogObserver` ne convient pas ici : chaque onglet du
/// `StatefulShellRoute` garde son propre navigateur, donc revenir sur un onglet
/// ne déclenche aucun événement de navigation. On suit plutôt le routeur.
///
/// Le nom envoyé est le motif de la route (`/trip/:tripId`) : il ne contient ni
/// identifiant, ni paramètre d'URL.
class RouterScreenViewTracker {
  RouterScreenViewTracker({
    required this._router,
    required this._analyticsService,
  });

  final GoRouter _router;
  final AnalyticsService _analyticsService;
  String? _lastScreenName;

  void start() {
    _router.routerDelegate.addListener(_onRouteChanged);
  }

  void stop() {
    _router.routerDelegate.removeListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    // `state` décrit l'écran au sommet de la pile, y compris après un `push`.
    final screenName = _router.state.fullPath;
    if (screenName == null ||
        screenName.isEmpty ||
        screenName == _lastScreenName) {
      return;
    }
    _lastScreenName = screenName;
    _analyticsService.captureScreen(screenName);
  }
}
