import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traveltrack/src/navigation/router_screen_view_tracker.dart';
import 'package:traveltrack/src/services/analytics_service.dart';

class _RecordingAnalyticsService implements AnalyticsService {
  final List<String> capturedScreens = [];

  @override
  Future<void> captureScreen(String screenName) async {
    capturedScreens.add(screenName);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StatefulNavigationShell navigationShell;
  late GoRouter router;
  late _RecordingAnalyticsService analyticsService;

  Future<void> pumpRouter(WidgetTester tester) async {
    analyticsService = _RecordingAnalyticsService();
    router = GoRouter(
      initialLocation: '/quests',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) {
            navigationShell = shell;
            return shell;
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/quests',
                  builder: (context, state) => const Text('quests'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/map',
                  builder: (context, state) => const Text('map'),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/trip/:tripId',
          builder: (context, state) => const Text('trip'),
        ),
      ],
    );
    addTearDown(router.dispose);
    final tracker = RouterScreenViewTracker(
      router: router,
      analyticsService: analyticsService,
    )..start();
    addTearDown(tracker.stop);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('captures the first screen once', (tester) async {
    await pumpRouter(tester);

    expect(analyticsService.capturedScreens, ['/quests']);
  });

  testWidgets('captures every visit when switching between tabs', (
    tester,
  ) async {
    await pumpRouter(tester);

    navigationShell.goBranch(1);
    await tester.pumpAndSettle();
    navigationShell.goBranch(0);
    await tester.pumpAndSettle();
    navigationShell.goBranch(1);
    await tester.pumpAndSettle();

    expect(analyticsService.capturedScreens, [
      '/quests',
      '/map',
      '/quests',
      '/map',
    ]);
  });

  testWidgets('sends the route pattern instead of identifiers', (tester) async {
    await pumpRouter(tester);

    router.push('/trip/secret-quest-id?source=private-value');
    await tester.pumpAndSettle();

    expect(analyticsService.capturedScreens.last, '/trip/:tripId');
  });

  testWidgets('captures the previous screen after going back', (tester) async {
    await pumpRouter(tester);

    router.push('/trip/42');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(analyticsService.capturedScreens, [
      '/quests',
      '/trip/:tripId',
      '/quests',
    ]);
  });
}
