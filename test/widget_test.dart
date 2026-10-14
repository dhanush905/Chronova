import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/main.dart';

void main() {
  testWidgets('Chronova renders navigation shell and switches tabs cleanly', (
    WidgetTester tester,
  ) async {
    // Set fixed surface size to prevent layout overflows during testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ChronovaApp());
    await tester.pumpAndSettle();

    // 1. Verify Home Screen is active by default
    expect(find.text('Welcome to Chronova'), findsOneWidget);
    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Priority Reminders'), findsOneWidget);

    // 2. Verify all navigation labels exist
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Notes & Files'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // 3. Switch to Calendar Tab
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 4. Switch to Notes & Files Tab
    await tester.tap(find.text('Notes & Files').last);
    await tester.pumpAndSettle();

    expect(find.text('Files & Import'), findsOneWidget);
    expect(find.text('Chronova Phase 1 UI Blueprint'), findsOneWidget);

    // 5. Switch to Profile Tab
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Cloud & Synchronization'), findsOneWidget);
    expect(find.text('Event Categories'), findsOneWidget);
  });
}
