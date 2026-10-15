import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/core/config/supabase_config.dart';
import 'package:chronova/core/theme/app_colors.dart';
import 'package:chronova/data/chronova_data_store.dart';
import 'package:chronova/data/repositories/in_memory_chronova_repository.dart';
import 'package:chronova/models/event_item.dart';
import 'package:chronova/models/note_item.dart';
import 'package:chronova/models/reminder_item.dart';
import 'package:chronova/screens/auth/auth_screen.dart';
import 'package:chronova/screens/auth/config_guide_screen.dart';

void main() {
  group('SupabaseConfig Tests', () {
    test('reports configuration status accurately', () {
      // In automated test environments without --dart-define, isConfigured should be false
      if (!SupabaseConfig.isConfigured) {
        expect(SupabaseConfig.supabaseUrl, isEmpty);
        expect(SupabaseConfig.supabasePublishableKey, isEmpty);
      } else {
        expect(SupabaseConfig.supabaseUrl, isNotEmpty);
        expect(SupabaseConfig.supabasePublishableKey, isNotEmpty);
      }
    });
  });

  group('InMemoryChronovaRepository - User Isolation & CRUD', () {
    late InMemoryChronovaRepository repo;
    const userA = 'user-uuid-1111';
    const userB = 'user-uuid-2222';

    setUp(() {
      repo = InMemoryChronovaRepository();
    });

    test('categories are isolated per user and pre-seeded', () async {
      final catsA = await repo.fetchCategories(userA);
      final catsB = await repo.fetchCategories(userB);

      expect(catsA.length, greaterThanOrEqualTo(5));
      expect(catsB.length, greaterThanOrEqualTo(5));

      final customCat = EventCategory(
        id: 'cat-custom-a',
        name: 'Private Research',
        color: AppColors.catViolet,
      );
      await repo.createCategory(userA, customCat);

      final updatedA = await repo.fetchCategories(userA);
      final updatedB = await repo.fetchCategories(userB);

      expect(updatedA.any((c) => c.name == 'Private Research'), isTrue);
      expect(updatedB.any((c) => c.name == 'Private Research'), isFalse);
    });

    test('events CRUD and user isolation', () async {
      final eventA = EventItem(
        id: 'evt-a-1',
        title: 'User A Confidential Meeting',
        startTime: DateTime(2026, 10, 15, 10, 0),
        endTime: DateTime(2026, 10, 15, 11, 0),
        category: const EventCategory(
          id: 'cat-work',
          name: 'Work',
          color: AppColors.primary,
        ),
      );

      await repo.createEvent(userA, eventA);

      final eventsA = await repo.fetchEvents(userA);
      final eventsB = await repo.fetchEvents(userB);

      expect(
        eventsA.any((e) => e.title == 'User A Confidential Meeting'),
        isTrue,
      );
      expect(
        eventsB.any((e) => e.title == 'User A Confidential Meeting'),
        isFalse,
      );

      // Update event
      final updatedA = eventA.copyWith(title: 'User A Rescheduled Meeting');
      await repo.updateEvent(userA, updatedA);

      final refreshedA = await repo.fetchEvents(userA);
      expect(
        refreshedA.firstWhere((e) => e.id == 'evt-a-1').title,
        'User A Rescheduled Meeting',
      );

      // Delete event
      await repo.deleteEvent(userA, 'evt-a-1');
      final finalA = await repo.fetchEvents(userA);
      expect(finalA.any((e) => e.id == 'evt-a-1'), isFalse);
    });

    test('notes CRUD and user isolation', () async {
      final noteA = NoteItem(
        id: 'note-a-1',
        title: 'Secret Notes User A',
        content: 'Top secret architectural details.',
        folder: 'Work',
        updatedAt: DateTime.now(),
      );

      await repo.createNote(userA, noteA);

      final notesA = await repo.fetchNotes(userA);
      final notesB = await repo.fetchNotes(userB);

      expect(notesA.any((n) => n.id == 'note-a-1'), isTrue);
      expect(notesB.any((n) => n.id == 'note-a-1'), isFalse);

      // Update note
      final updatedNote = noteA.copyWith(content: 'Modified secret details.');
      await repo.updateNote(userA, updatedNote);

      final refreshedA = await repo.fetchNotes(userA);
      expect(
        refreshedA.firstWhere((n) => n.id == 'note-a-1').content,
        'Modified secret details.',
      );

      // Delete note
      await repo.deleteNote(userA, 'note-a-1');
      final finalA = await repo.fetchNotes(userA);
      expect(finalA.any((n) => n.id == 'note-a-1'), isFalse);
    });

    test('reminders CRUD and user isolation', () async {
      final remA = ReminderItem(
        id: 'rem-a-1',
        title: 'Tax Filing Deadline',
        dueDateTime: DateTime(2026, 10, 20, 18, 0),
        categoryName: 'Finance',
        categoryColor: AppColors.catAmber,
      );

      await repo.createReminder(userA, remA);

      final remsA = await repo.fetchReminders(userA);
      final remsB = await repo.fetchReminders(userB);

      expect(remsA.any((r) => r.id == 'rem-a-1'), isTrue);
      expect(remsB.any((r) => r.id == 'rem-a-1'), isFalse);

      // Toggle / update reminder
      final updatedRem = remA.copyWith(isDone: true);
      await repo.updateReminder(userA, updatedRem);

      final refreshedA = await repo.fetchReminders(userA);
      expect(refreshedA.firstWhere((r) => r.id == 'rem-a-1').isDone, isTrue);

      // Delete reminder
      await repo.deleteReminder(userA, 'rem-a-1');
      final finalA = await repo.fetchReminders(userA);
      expect(finalA.any((r) => r.id == 'rem-a-1'), isFalse);
    });
  });

  group('ChronovaDataStore - Repository Integration & Session Lifecycle', () {
    late InMemoryChronovaRepository testRepo;

    setUp(() {
      testRepo = InMemoryChronovaRepository();
      ChronovaDataStore.instance.setRepository(testRepo);
    });

    test(
      'initializeForUser loads user state and clearUserData resets cleanly',
      () async {
        final store = ChronovaDataStore.instance;

        const userId = 'session-user-999';

        // Pre-seed an event in the repo for this user
        await testRepo.createEvent(
          userId,
          EventItem(
            id: 'evt-session-1',
            title: 'Quarterly Review',
            startTime: DateTime(2026, 10, 18, 14, 0),
            endTime: DateTime(2026, 10, 18, 15, 0),
            category: const EventCategory(
              id: 'cat-work',
              name: 'Work',
              color: AppColors.primary,
            ),
          ),
        );

        // Initialize store for user
        await store.initializeForUser(userId);

        expect(store.currentUserId, equals(userId));
        expect(store.events.any((e) => e.id == 'evt-session-1'), isTrue);

        // Clear user session (simulating logout)
        store.clearUserData();

        expect(store.currentUserId, isNull);
        expect(store.events, isEmpty);
        expect(store.notes, isEmpty);
        expect(store.reminders, isEmpty);
      },
    );

    test(
      'CRUD operations in store sync to active repository for authenticated user',
      () async {
        final store = ChronovaDataStore.instance;
        const userId = 'sync-user-888';

        await store.initializeForUser(userId);

        // Create event via store
        final newEvt = EventItem(
          id: 'sync-evt-1',
          title: 'Database Schema Review',
          startTime: DateTime(2026, 10, 16, 11, 0),
          endTime: DateTime(2026, 10, 16, 12, 0),
          category: store.categories.first,
        );

        await store.addEvent(newEvt);

        // Verify store has event
        expect(store.events.any((e) => e.id == 'sync-evt-1'), isTrue);

        // Verify repository has event for this user
        final repoEvents = await testRepo.fetchEvents(userId);
        expect(repoEvents.any((e) => e.id == 'sync-evt-1'), isTrue);

        // Update event via store
        await store.updateEvent(
          newEvt.copyWith(title: 'Updated Database Review'),
        );
        expect(
          store.events.firstWhere((e) => e.id == 'sync-evt-1').title,
          'Updated Database Review',
        );

        final updatedRepoEvents = await testRepo.fetchEvents(userId);
        expect(
          updatedRepoEvents.firstWhere((e) => e.id == 'sync-evt-1').title,
          'Updated Database Review',
        );

        // Delete event via store
        await store.deleteEvent('sync-evt-1');
        expect(store.events.any((e) => e.id == 'sync-evt-1'), isFalse);

        final finalRepoEvents = await testRepo.fetchEvents(userId);
        expect(finalRepoEvents.any((e) => e.id == 'sync-evt-1'), isFalse);
      },
    );
  });

  group('Phase 2 Widget Tests - ConfigGuideScreen & AuthScreen', () {
    testWidgets(
      'ConfigGuideScreen renders instructions and triggers demo mode',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool demoTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            home: ConfigGuideScreen(
              onContinueInSampleMode: () {
                demoTriggered = true;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Supabase Cloud Setup'), findsOneWidget);
        expect(find.text('Configure Credentials Locally'), findsOneWidget);
        expect(find.textContaining('SUPABASE_URL'), findsWidgets);
        expect(find.textContaining('SUPABASE_PUBLISHABLE_KEY'), findsWidgets);
        expect(find.text('Continue in Local Sample Mode'), findsOneWidget);

        await tester.tap(find.text('Continue in Local Sample Mode'));
        await tester.pumpAndSettle();

        expect(demoTriggered, isTrue);
      },
    );

    testWidgets('AuthScreen validates inputs and switches modes', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
      await tester.pumpAndSettle();

      // Default: Sign In mode
      expect(
        find.text('Sign in to access your cloud workspace'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNothing);

      // Attempt submit with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Switch to Sign Up mode
      await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(
        find.text('Create your account to sync events & notes'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Create Account'),
        findsOneWidget,
      );
      expect(find.text('Confirm Password'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'invalid-email',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);

      // Enter short password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'valid@chronova.app',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );

      // Enter mismatched passwords
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password999',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
