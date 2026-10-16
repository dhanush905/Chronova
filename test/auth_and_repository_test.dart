import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/core/config/supabase_config.dart';
import 'package:chronova/core/theme/app_colors.dart';
import 'package:chronova/data/chronova_data_store.dart';
import 'package:chronova/data/repositories/chronova_repository.dart';
import 'package:chronova/data/repositories/in_memory_chronova_repository.dart';
import 'package:chronova/models/event_item.dart';
import 'package:chronova/models/note_item.dart';
import 'package:chronova/models/reminder_item.dart';
import 'package:chronova/screens/auth/auth_gate.dart';
import 'package:chronova/screens/auth/auth_screen.dart';
import 'package:chronova/screens/auth/config_guide_screen.dart';

class FailingMockRepository implements ChronovaRepository {
  final List<EventItem> existingEvents;
  final List<NoteItem> existingNotes;

  FailingMockRepository({
    this.existingEvents = const [],
    this.existingNotes = const [],
  });

  @override
  Future<List<EventCategory>> fetchCategories(String userId) async => [];

  @override
  Future<EventCategory> createCategory(
    String userId,
    EventCategory category,
  ) async {
    throw Exception('Database constraint violation (RLS)');
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {}

  @override
  Future<List<EventItem>> fetchEvents(String userId) async =>
      List.from(existingEvents);

  @override
  Future<EventItem> createEvent(String userId, EventItem event) async {
    throw Exception('PostgreSQL RLS violation: user_id mismatch');
  }

  @override
  Future<EventItem> updateEvent(String userId, EventItem event) async {
    throw Exception('PostgreSQL error: record not found or unauthorized');
  }

  @override
  Future<void> deleteEvent(String userId, String eventId) async {
    throw Exception('PostgreSQL error: delete denied by RLS');
  }

  @override
  Future<List<NoteItem>> fetchNotes(String userId) async =>
      List.from(existingNotes);

  @override
  Future<NoteItem> createNote(String userId, NoteItem note) async {
    throw Exception('Database connection timeout');
  }

  @override
  Future<NoteItem> updateNote(String userId, NoteItem note) async {
    throw Exception('Database update failed');
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    throw Exception('Database delete failed');
  }

  @override
  Future<List<ReminderItem>> fetchReminders(String userId) async => [];

  @override
  Future<ReminderItem> createReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    throw Exception('Reminder creation failed');
  }

  @override
  Future<ReminderItem> updateReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    throw Exception('Reminder update failed');
  }

  @override
  Future<void> deleteReminder(String userId, String reminderId) async {}
}

class RecordingMockRepository extends InMemoryChronovaRepository {
  int createCategoryCallCount = 0;
  final List<EventCategory> _emptyCategories = [];

  @override
  Future<List<EventCategory>> fetchCategories(String userId) async {
    return List.from(_emptyCategories);
  }

  @override
  Future<EventCategory> createCategory(
    String userId,
    EventCategory category,
  ) async {
    createCategoryCallCount++;
    _emptyCategories.add(category);
    return category;
  }
}

void main() {
  group('SupabaseConfig Tests', () {
    tearDown(() {
      SupabaseConfig.resetOverride();
    });

    test('detects missing URL and missing key', () {
      SupabaseConfig.setOverride(url: '', publishableKey: '');
      expect(SupabaseConfig.isUrlPresent, isFalse);
      expect(SupabaseConfig.isUrlValid, isFalse);
      expect(SupabaseConfig.isKeyPresent, isFalse);
      expect(SupabaseConfig.isKeyValid, isFalse);
      expect(SupabaseConfig.isConfigured, isFalse);
      expect(SupabaseConfig.statusDescription, contains('Missing credentials'));
      expect(
        SupabaseConfig.diagnosticSummary,
        contains('SUPABASE_URL (not found)'),
      );
      expect(
        SupabaseConfig.diagnosticSummary,
        contains('SUPABASE_PUBLISHABLE_KEY (not found)'),
      );
      expect(SupabaseConfig.urlHost, equals('Not configured'));
    });

    test(
      'reproduces setup failure when SUPABASE_URL is invalid or missing host',
      () {
        SupabaseConfig.setOverride(
          url: 'invalid-url-without-scheme',
          publishableKey: 'sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu',
        );
        expect(SupabaseConfig.isUrlPresent, isTrue);
        expect(SupabaseConfig.isUrlValid, isFalse);
        expect(SupabaseConfig.isKeyPresent, isTrue);
        expect(SupabaseConfig.isKeyValid, isTrue);
        expect(SupabaseConfig.isConfigured, isFalse);
        expect(
          SupabaseConfig.diagnosticSummary,
          contains('must be https://<host>'),
        );
      },
    );

    test(
      'sanitizes quotes, escaped quotes, accidental KEY= prefix, and trailing slashes',
      () {
        SupabaseConfig.setOverride(
          url: r'\"https://atkczrenrlfpssrbdzpi.supabase.co/\"',
          publishableKey: '"sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu"',
        );
        expect(
          SupabaseConfig.supabaseUrl,
          equals('https://atkczrenrlfpssrbdzpi.supabase.co'),
        );
        expect(SupabaseConfig.isUrlPresent, isTrue);
        expect(SupabaseConfig.isUrlValid, isTrue);
        expect(
          SupabaseConfig.urlHost,
          equals('atkczrenrlfpssrbdzpi.supabase.co'),
        );
        expect(
          SupabaseConfig.supabasePublishableKey,
          equals('sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu'),
        );
        expect(SupabaseConfig.keyType, equals('Publishable Key'));
        expect(SupabaseConfig.keyLength, equals(46));
        expect(SupabaseConfig.isKeyValid, isTrue);
        expect(SupabaseConfig.isConfigured, isTrue);
        expect(
          SupabaseConfig.diagnosticSummary,
          contains('Connected to host "atkczrenrlfpssrbdzpi.supabase.co"'),
        );
      },
    );

    test('normalizes URL without scheme to https://', () {
      SupabaseConfig.setOverride(
        url: 'atkczrenrlfpssrbdzpi.supabase.co',
        publishableKey: 'sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu',
      );
      expect(
        SupabaseConfig.supabaseUrl,
        equals('https://atkczrenrlfpssrbdzpi.supabase.co'),
      );
      expect(SupabaseConfig.urlScheme, equals('https'));
      expect(
        SupabaseConfig.urlHost,
        equals('atkczrenrlfpssrbdzpi.supabase.co'),
      );
      expect(SupabaseConfig.isUrlValid, isTrue);
      expect(SupabaseConfig.isConfigured, isTrue);
    });

    test('reproduces setup failure when SUPABASE_URL has no host', () {
      SupabaseConfig.setOverride(
        url: 'https://',
        publishableKey: 'sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu',
      );
      expect(SupabaseConfig.isUrlPresent, isTrue);
      expect(SupabaseConfig.hasHost, isFalse);
      expect(SupabaseConfig.isUrlValid, isFalse);
      expect(SupabaseConfig.isConfigured, isFalse);
      expect(
        SupabaseConfig.diagnosticSummary,
        contains('must be https://<host>'),
      );
    });

    test('strips accidental SUPABASE_URL= from argument value', () {
      SupabaseConfig.setOverride(
        url: 'SUPABASE_URL=https://atkczrenrlfpssrbdzpi.supabase.co',
        publishableKey:
            'SUPABASE_PUBLISHABLE_KEY=sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu',
      );
      expect(
        SupabaseConfig.supabaseUrl,
        equals('https://atkczrenrlfpssrbdzpi.supabase.co'),
      );
      expect(
        SupabaseConfig.supabasePublishableKey,
        equals('sb_publishable_Y_ld1p-oD7IuG9ciHeF3cg_gSbmwyXu'),
      );
      expect(SupabaseConfig.isConfigured, isTrue);
    });

    test('detects short or invalid publishable key', () {
      SupabaseConfig.setOverride(
        url: 'https://atkczrenrlfpssrbdzpi.supabase.co',
        publishableKey: 'short',
      );
      expect(SupabaseConfig.isUrlValid, isTrue);
      expect(SupabaseConfig.isKeyValid, isFalse);
      expect(SupabaseConfig.isConfigured, isFalse);
      expect(SupabaseConfig.diagnosticSummary, contains('too short'));
    });

    test('validates UUID helper on models', () {
      const validUuid = '123e4567-e89b-12d3-a456-426614174000';
      const nonUuid = 'evt-1760541234567';

      expect(EventCategory.isValidUuid(validUuid), isTrue);
      expect(EventCategory.isValidUuid(nonUuid), isFalse);
      expect(NoteItem.isValidUuid(validUuid), isTrue);
      expect(NoteItem.isValidUuid(nonUuid), isFalse);
      expect(ReminderItem.isValidUuid(validUuid), isTrue);
      expect(ReminderItem.isValidUuid('rem-12345'), isFalse);
    });

    test(
      'EventItem.toJson omits non-UUID ids for PostgreSQL gen_random_uuid()',
      () {
        final sampleEvent = EventItem(
          id: 'evt-1760541234567',
          title: 'Draft Event',
          startTime: DateTime(2026, 10, 15, 10, 0),
          endTime: DateTime(2026, 10, 15, 11, 0),
          category: const EventCategory(
            id: 'cat-1',
            name: 'Work',
            color: AppColors.primary,
          ),
        );

        final jsonMap = sampleEvent.toJson(userId: 'user-123');

        // 'id' should be omitted so database gen_random_uuid() generates the UUID
        expect(jsonMap.containsKey('id'), isFalse);
        expect(jsonMap['user_id'], equals('user-123'));
        expect(jsonMap['title'], equals('Draft Event'));
        // 'category_id' should also be omitted since 'cat-1' is not a valid UUID
        expect(jsonMap.containsKey('category_id'), isFalse);
      },
    );

    test('EventItem.toJson preserves valid UUID ids', () {
      const realUuid = '123e4567-e89b-12d3-a456-426614174000';
      const catUuid = '987fcdeb-51a2-43d7-9012-3456789abcde';

      final sampleEvent = EventItem(
        id: realUuid,
        title: 'Saved Event',
        startTime: DateTime(2026, 10, 15, 10, 0),
        endTime: DateTime(2026, 10, 15, 11, 0),
        category: const EventCategory(
          id: catUuid,
          name: 'Work',
          color: AppColors.primary,
        ),
      );

      final jsonMap = sampleEvent.toJson(userId: 'user-123');

      expect(jsonMap['id'], equals(realUuid));
      expect(jsonMap['category_id'], equals(catUuid));
      expect(jsonMap['user_id'], equals('user-123'));
    });

    test('NoteItem.toJson omits non-UUID ids and preserves valid UUIDs', () {
      final newNote = NoteItem(
        id: 'note-1760541234567',
        title: 'New Idea',
        content: 'Idea text',
        folder: 'Ideas',
        updatedAt: DateTime.now(),
      );

      final jsonMap = newNote.toJson(userId: 'user-999');
      expect(jsonMap.containsKey('id'), isFalse);
      expect(jsonMap['user_id'], equals('user-999'));

      const realNoteUuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final existingNote = newNote.copyWith(id: realNoteUuid);
      final existingMap = existingNote.toJson(userId: 'user-999');
      expect(existingMap['id'], equals(realNoteUuid));
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

  group('ChronovaDataStore - Repository Selection & Error Propagation', () {
    late InMemoryChronovaRepository testRepo;

    setUp(() {
      testRepo = InMemoryChronovaRepository();
      ChronovaDataStore.instance.setRepository(testRepo);
    });

    test('enableLocalSampleMode switches store cleanly to mock repository', () {
      final store = ChronovaDataStore.instance;
      store.enableLocalSampleMode();

      expect(store.isUsingSupabase, isFalse);
      expect(store.events.isNotEmpty, isTrue);
      expect(store.currentUserId, isNull);
    });

    test(
      'initializeForUser does not auto-insert sample categories into cloud database',
      () async {
        final store = ChronovaDataStore.instance;
        final recordingRepo = RecordingMockRepository();
        store.setRepository(recordingRepo);
        const newUserId = 'clean-user-empty-db';

        // Empty repository
        await store.initializeForUser(newUserId);

        // Verify that the repository still has zero remote categories written
        expect(recordingRepo.createCategoryCallCount, equals(0));
        final remoteCats = await recordingRepo.fetchCategories(newUserId);
        expect(remoteCats.isEmpty, isTrue);

        // But in-memory store provides baseline categories for local display
        expect(store.categories.isNotEmpty, isTrue);
      },
    );

    test(
      'visible error handling: propagates exceptions when repository fails',
      () async {
        final store = ChronovaDataStore.instance;

        final sampleEvent = EventItem(
          id: 'test-evt-fail',
          title: 'Will Fail',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          category: const EventCategory(
            id: 'c1',
            name: 'Work',
            color: Colors.blue,
          ),
        );

        final sampleNote = NoteItem(
          id: 'test-note-fail',
          title: 'Will Fail',
          content: '',
          folder: 'Work',
          updatedAt: DateTime.now(),
        );

        store.setRepository(
          FailingMockRepository(
            existingEvents: [sampleEvent],
            existingNotes: [sampleNote],
          ),
        );
        await store.initializeForUser('failing-user');

        // addEvent should throw and record error
        expect(
          () async => await store.addEvent(sampleEvent),
          throwsA(isA<Exception>()),
        );

        // updateEvent should throw and record error
        expect(
          () async => await store.updateEvent(sampleEvent),
          throwsA(isA<Exception>()),
        );

        // deleteEvent should throw and record error
        expect(
          () async => await store.deleteEvent('test-evt-fail'),
          throwsA(isA<Exception>()),
        );

        // addNote should throw and record error
        expect(
          () async => await store.addNote(sampleNote),
          throwsA(isA<Exception>()),
        );

        // updateNote should throw and record error
        expect(
          () async => await store.updateNote(sampleNote),
          throwsA(isA<Exception>()),
        );

        // deleteNote should throw and record error
        expect(
          () async => await store.deleteNote('test-note-fail'),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('Phase 2 Widget Tests - ConfigGuideScreen & AuthScreen', () {
    testWidgets(
      'ConfigGuideScreen renders instructions, diagnostics, and triggers demo mode',
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
        expect(find.text('Launch Diagnostics:'), findsOneWidget);
        expect(find.text('SUPABASE_URL Presence:'), findsOneWidget);
        expect(find.text('SUPABASE_URL Validity:'), findsOneWidget);
        expect(find.text('Publishable Key Presence:'), findsOneWidget);
        expect(find.textContaining('SUPABASE_URL'), findsWidgets);
        expect(find.textContaining('SUPABASE_PUBLISHABLE_KEY'), findsWidgets);
        expect(find.text('Continue in Local Sample Mode'), findsOneWidget);

        await tester.tap(find.text('Continue in Local Sample Mode'));
        await tester.pumpAndSettle();

        expect(demoTriggered, isTrue);
      },
    );

    testWidgets(
      'AuthGate renders ConfigGuideScreen with diagnostics when credentials are missing or invalid',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          SupabaseConfig.resetOverride();
        });

        SupabaseConfig.setOverride(
          url: 'https://',
          publishableKey: 'sb_publishable_test_key_sample',
        );

        await tester.pumpWidget(const MaterialApp(home: AuthGate()));
        await tester.pumpAndSettle();

        expect(find.text('Supabase Cloud Setup'), findsOneWidget);
        expect(find.text('SUPABASE_URL Presence:'), findsOneWidget);
        expect(
          find.text('Invalid format (needs https:// & host)'),
          findsOneWidget,
        );
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
