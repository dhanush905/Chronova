import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/data/chronova_data_store.dart';
import 'package:chronova/models/event_item.dart';
import 'package:chronova/models/note_item.dart';

void main() {
  setUp(() {
    ChronovaDataStore.instance.resetToSampleData();
  });

  group('ChronovaDataStore - Event Management', () {
    test('creates an event successfully', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.events.length;

      final newEvent = EventItem(
        id: 'test-evt-1',
        title: 'Sprint Planning',
        startTime: DateTime(2026, 10, 15, 9, 0),
        endTime: DateTime(2026, 10, 15, 10, 0),
        category: store.categories.first,
      );

      await store.addEvent(newEvent);

      expect(store.events.length, initialCount + 1);
      expect(store.events.any((e) => e.id == 'test-evt-1'), isTrue);
      expect(
        store.events.firstWhere((e) => e.id == 'test-evt-1').title,
        'Sprint Planning',
      );
    });

    test('updates an existing event without duplicating it', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.events.length;
      final targetEvent = store.events.first;

      final updatedEvent = targetEvent.copyWith(
        title: 'Updated Event Title',
        location: 'New Remote Link',
      );

      final success = await store.updateEvent(updatedEvent);

      expect(success, isTrue);
      expect(store.events.length, initialCount); // No duplicate added!
      final result = store.events.firstWhere((e) => e.id == targetEvent.id);
      expect(result.title, 'Updated Event Title');
      expect(result.location, 'New Remote Link');
    });

    test('deletes the correct event by id', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.events.length;
      final targetId = store.events.first.id;

      final success = await store.deleteEvent(targetId);

      expect(success, isTrue);
      expect(store.events.length, initialCount - 1);
      expect(store.events.any((e) => e.id == targetId), isFalse);
    });
  });

  group('ChronovaDataStore - Note Management', () {
    test('creates a note successfully', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.notes.length;

      final newNote = NoteItem(
        id: 'test-note-1',
        title: 'Architecture Review',
        content: 'Review state flow and event sheets.',
        folder: 'Work',
        updatedAt: DateTime.now(),
      );

      await store.addNote(newNote);

      expect(store.notes.length, initialCount + 1);
      expect(store.notes.first.id, 'test-note-1');
      expect(store.notes.first.title, 'Architecture Review');
    });

    test('updates an existing note and preserves identity', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.notes.length;
      final targetNote = store.notes.first;

      final updatedNote = targetNote.copyWith(
        title: 'Refined Title',
        content: 'Updated body content for note.',
      );

      final success = await store.updateNote(updatedNote);

      expect(success, isTrue);
      expect(store.notes.length, initialCount); // No duplicate
      final result = store.notes.firstWhere((n) => n.id == targetNote.id);
      expect(result.title, 'Refined Title');
      expect(result.content, 'Updated body content for note.');
    });

    test('deletes the correct note by id', () async {
      final store = ChronovaDataStore.instance;
      final initialCount = store.notes.length;
      final targetId = store.notes.first.id;

      final success = await store.deleteNote(targetId);

      expect(success, isTrue);
      expect(store.notes.length, initialCount - 1);
      expect(store.notes.any((n) => n.id == targetId), isFalse);
    });
  });
}
