import 'package:flutter/foundation.dart';
import '../models/event_item.dart';
import '../models/reminder_item.dart';
import '../models/note_item.dart';
import '../models/file_item.dart';
import 'sample_data.dart';

/// Single source of truth for in-memory session state in Phase 1.
/// Manages reactive updates across Home, Calendar, Notes & Files, and Profile screens.
class ChronovaDataStore extends ChangeNotifier {
  static final ChronovaDataStore _instance = ChronovaDataStore._internal();
  static ChronovaDataStore get instance => _instance;

  ChronovaDataStore._internal() {
    resetToSampleData();
  }

  late List<EventItem> _events;
  late List<EventCategory> _categories;
  late List<ReminderItem> _reminders;
  late List<NoteItem> _notes;
  late List<FileItem> _files;

  List<EventItem> get events => List.unmodifiable(_events);
  List<EventCategory> get categories => List.unmodifiable(_categories);
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);
  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<FileItem> get files => List.unmodifiable(_files);

  /// Resets store to initial sample data (useful for test isolation and fresh runs).
  void resetToSampleData() {
    _categories = List.from(SampleData.categories);
    _events = SampleData.getSampleEvents();
    _reminders = SampleData.getSampleReminders();
    _notes = SampleData.getSampleNotes();
    _files = SampleData.getSampleFiles();
    notifyListeners();
  }

  // --- Event Operations ---

  /// Adds a new calendar event.
  void addEvent(EventItem event) {
    _events.add(event);
    notifyListeners();
  }

  /// Updates an existing event matching the event ID. Returns true if updated.
  bool updateEvent(EventItem updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Deletes an existing event by ID. Returns true if an event was deleted.
  bool deleteEvent(String id) {
    final initialCount = _events.length;
    _events.removeWhere((e) => e.id == id);
    if (_events.length != initialCount) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Note Operations ---

  /// Adds a new note to the top of the collection.
  void addNote(NoteItem note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  /// Updates an existing note matching the note ID. Returns true if updated.
  bool updateNote(NoteItem updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Deletes an existing note by ID. Returns true if a note was deleted.
  bool deleteNote(String id) {
    final initialCount = _notes.length;
    _notes.removeWhere((n) => n.id == id);
    if (_notes.length != initialCount) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Category Operations ---

  /// Adds a new user-defined custom category.
  void addCategory(EventCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  // --- Reminder Operations ---

  /// Toggles reminder completed status.
  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = _reminders[index];
      _reminders[index] = item.copyWith(isDone: !item.isDone);
      notifyListeners();
    }
  }
}
