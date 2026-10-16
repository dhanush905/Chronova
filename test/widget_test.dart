import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/main.dart';
import 'package:chronova/screens/main_navigation_shell.dart';
import 'package:chronova/data/chronova_data_store.dart';
import 'package:chronova/widgets/custom_card.dart';

void main() {
  setUp(() {
    ChronovaDataStore.instance.resetToSampleData();
  });

  Widget buildTestableApp() {
    return const ChronovaApp(homeOverride: MainNavigationShell());
  }

  testWidgets('Chronova navigation shell renders and switches tabs cleanly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableApp());
    await tester.pumpAndSettle();

    // 1. Verify Home Screen is active by default
    expect(find.text('Welcome to Chronova'), findsOneWidget);
    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Priority Reminders'), findsOneWidget);

    // 2. Switch to Calendar Tab
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 3. Switch to Notes & Files Tab
    await tester.tap(find.text('Notes & Files').last);
    await tester.pumpAndSettle();

    expect(find.text('Files & Import'), findsOneWidget);
    expect(find.text('Chronova Phase 1 UI Blueprint'), findsOneWidget);

    // 4. Switch to Profile Tab
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Cloud & Synchronization'), findsOneWidget);
    expect(find.text('Event Categories'), findsOneWidget);
  });

  testWidgets(
    'Events flow: create, edit, cancel edit, and delete with confirmation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp());
      await tester.pumpAndSettle();

      // Navigate to Calendar
      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();

      // 1. CREATE EVENT
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New Event'));
      await tester.pumpAndSettle();

      expect(find.text('New Calendar Event'), findsOneWidget);

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextField, 'Event Title *'),
        'Unique Test Event',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Event'));
      await tester.pumpAndSettle();

      // Verify newly created event is rendered
      expect(find.text('Unique Test Event'), findsOneWidget);

      // 2. EDIT EVENT
      await tester.tap(find.text('Unique Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);

      // Edit title
      await tester.enterText(
        find.widgetWithText(TextField, 'Event Title *'),
        'Updated Test Event',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify updated title is displayed and old title is gone
      expect(find.text('Updated Test Event'), findsOneWidget);
      expect(find.text('Unique Test Event'), findsNothing);

      // 3. CANCEL EVENT EDIT
      await tester.tap(find.text('Updated Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Event Title *'),
        'Should Not Be Saved',
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify cancellation preserved the original title
      expect(find.text('Updated Test Event'), findsOneWidget);
      expect(find.text('Should Not Be Saved'), findsNothing);

      // 4. DELETE EVENT WITH CONFIRMATION
      // Find the PopupMenuButton inside the specific card containing 'Updated Test Event'
      final eventCard = find.ancestor(
        of: find.text('Updated Test Event'),
        matching: find.byType(CustomCard),
      );
      final eventMoreButton = find.descendant(
        of: eventCard,
        matching: find.byIcon(Icons.more_vert_rounded),
      );
      await tester.tap(eventMoreButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Event'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify event is removed
      expect(find.text('Updated Test Event'), findsNothing);
    },
  );

  testWidgets(
    'Notes flow: create, edit, cancel edit, and delete with confirmation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp());
      await tester.pumpAndSettle();

      // Navigate to Notes & Files
      await tester.tap(find.text('Notes & Files').last);
      await tester.pumpAndSettle();

      // 1. CREATE NOTE
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New Note'));
      await tester.pumpAndSettle();

      expect(find.text('Create Note'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Note Title *'),
        'Brand New Test Note',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Note Content'),
        'Detailed content for test note.',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Note'));
      await tester.pumpAndSettle();

      // Verify note is rendered
      expect(find.text('Brand New Test Note'), findsOneWidget);
      expect(find.text('Detailed content for test note.'), findsOneWidget);

      // 2. EDIT NOTE
      await tester.tap(find.text('Brand New Test Note'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Note'), findsOneWidget);

      // Change title and content
      await tester.enterText(
        find.widgetWithText(TextField, 'Note Title *'),
        'Edited Test Note Title',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Note Content'),
        'Edited body content successfully updated.',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify updated values appear in the list
      expect(find.text('Edited Test Note Title'), findsOneWidget);
      expect(
        find.text('Edited body content successfully updated.'),
        findsOneWidget,
      );
      expect(find.text('Brand New Test Note'), findsNothing);

      // 3. CANCEL NOTE EDIT
      await tester.tap(find.text('Edited Test Note Title'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Note'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Note Title *'),
        'Cancelled Note Title',
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify unchanged
      expect(find.text('Edited Test Note Title'), findsOneWidget);
      expect(find.text('Cancelled Note Title'), findsNothing);

      // 4. DELETE NOTE WITH CONFIRMATION
      final noteCard = find.ancestor(
        of: find.text('Edited Test Note Title'),
        matching: find.byType(CustomCard),
      );
      final noteMoreButton = find.descendant(
        of: noteCard,
        matching: find.byIcon(Icons.more_vert_rounded),
      );
      await tester.tap(noteMoreButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Note'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify note deleted
      expect(find.text('Edited Test Note Title'), findsNothing);
    },
  );

  testWidgets(
    'Reminders flow: create with validation, edit, snooze, and delete with confirmation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp());
      await tester.pumpAndSettle();

      // 1. OPEN NEW REMINDER SHEET VIA QUICK ACTIONS
      await tester.tap(find.text('New Reminder'));
      await tester.pumpAndSettle();

      expect(find.text('New Reminder'), findsNWidgets(2));
      expect(find.text('Trigger Audio Alarm'), findsOneWidget);

      // Verify validation triggers on empty title
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Reminder'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a reminder title'), findsOneWidget);

      // Fill in title and submit
      await tester.enterText(
        find.widgetWithText(TextField, 'Reminder Title'),
        'Test Phase 3 Alarm Reminder',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Reminder'));
      await tester.pumpAndSettle();

      // Scroll down HomeScreen to view Priority Reminders
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();

      // Verify reminder appears on Home Screen
      expect(find.text('Test Phase 3 Alarm Reminder'), findsOneWidget);

      // 2. EDIT REMINDER
      await tester.tap(find.text('Test Phase 3 Alarm Reminder'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Reminder'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Reminder Title'),
        'Updated Alarm Reminder Title',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Alarm Reminder Title'), findsOneWidget);
      expect(find.text('Test Phase 3 Alarm Reminder'), findsNothing);

      // 3. SNOOZE REMINDER VIA POPUP MENU
      final reminderCard = find.ancestor(
        of: find.text('Updated Alarm Reminder Title'),
        matching: find.byType(CustomCard),
      );
      final reminderMore = find.descendant(
        of: reminderCard,
        matching: find.byIcon(Icons.more_vert_rounded),
      );
      await tester.tap(reminderMore);
      await tester.pumpAndSettle();

      expect(find.text('Snooze (10m)'), findsOneWidget);
      await tester.tap(find.text('Snooze (10m)'));
      await tester.pumpAndSettle();

      // Verify snoozed badge appears
      expect(find.text('Snoozed 1x'), findsOneWidget);

      // 4. DELETE REMINDER WITH CONFIRMATION
      await tester.tap(reminderMore);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Delete Reminder'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify reminder removed
      expect(find.text('Updated Alarm Reminder Title'), findsNothing);
    },
  );
}
