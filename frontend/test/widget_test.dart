import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:traveltrack/src/views/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('TravelTrack'), findsOneWidget);
  });
}
