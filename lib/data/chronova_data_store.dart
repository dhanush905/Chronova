import 'package:flutter/foundation.dart';
import '../core/config/supabase_config.dart';
import '../models/event_item.dart';
import '../models/file_item.dart';
import '../models/note_item.dart';
import '../models/reminder_item.dart';
import 'repositories/chronova_repository.dart';
import 'repositories/in_memory_chronova_repository.dart';
import 'repositories/supabase_chronova_repository.dart';
import 'sample_data.dart';

/// Single source of truth for app state, backed by ChronovaRepository (Supabase or In-Memory).
/// Automatically notifies UI listeners on mutations and manages user session isolation.
class ChronovaDataStore extends ChangeNotifier {
  static final ChronovaDataStore _instance = ChronovaDataStore._internal();
  static ChronovaDataStore get instance => _instance;

  ChronovaRepository _repository;
  String? _currentUserId;
  bool _isLoading = false;
  String? _errorMessage;

  ChronovaDataStore._internal() : _repository = InMemoryChronovaRepository() {
    resetToSampleData();
  }

  /// Injects a repository implementation (useful for tests or switching backends).
  void setRepository(ChronovaRepository repository) {
    _repository = repository;
  }

  /// Automatically configures repository according to Supabase availability.
  void setupDefaultRepository() {
    if (SupabaseConfig.isConfigured) {
      try {
        _repository = SupabaseChronovaRepository();
      } catch (_) {
        _repository = InMemoryChronovaRepository();
      }
    } else {
      _repository = InMemoryChronovaRepository();
    }
  }

  final List<EventItem> _events = [];
  final List<EventCategory> _categories = [];
  final List<ReminderItem> _reminders = [];
  final List<NoteItem> _notes = [];
  final List<FileItem> _files = [];

  List<EventItem> get events => List.unmodifiable(_events);
  List<EventCategory> get categories => List.unmodifiable(_categories);
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);
  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<FileItem> get files => List.unmodifiable(_files);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  /// Loads the authenticated user's remote records from Supabase into the local cache.
  Future<void> initializeForUser(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCategories = await _repository.fetchCategories(userId);
      final fetchedEvents = await _repository.fetchEvents(userId);
      final fetchedNotes = await _repository.fetchNotes(userId);
      final fetchedReminders = await _repository.fetchReminders(userId);

      _categories.clear();
      if (fetchedCategories.isEmpty) {
        // Ensure baseline user categories exist in cloud
        for (final sampleCat in SampleData.categories) {
          try {
            final created = await _repository.createCategory(userId, sampleCat);
            _categories.add(created);
          } catch (_) {
            _categories.add(sampleCat);
          }
        }
      } else {
        _categories.addAll(fetchedCategories);
      }

      _events.clear();
      _events.addAll(fetchedEvents);

      _notes.clear();
      _notes.addAll(fetchedNotes);

      _reminders.clear();
      _reminders.addAll(fetchedReminders);

      _files.clear();
      _files.addAll(SampleData.getSampleFiles());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Completely wipes in-memory cache upon user logout so records never bleed across sessions.
  void clearUserData() {
    _currentUserId = null;
    _events.clear();
    _categories.clear();
    _notes.clear();
    _reminders.clear();
    _files.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets store to initial sample data (useful for test isolation and unauthenticated demo).
  void resetToSampleData() {
    _currentUserId = null;
    _categories.clear();
    _categories.addAll(SampleData.categories);
    _events.clear();
    _events.addAll(SampleData.getSampleEvents());
    _reminders.clear();
    _reminders.addAll(SampleData.getSampleReminders());
    _notes.clear();
    _notes.addAll(SampleData.getSampleNotes());
    _files.clear();
    _files.addAll(SampleData.getSampleFiles());
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // --- Event Operations ---

  Future<void> addEvent(EventItem event) async {
    if (_currentUserId != null) {
      final created = await _repository.createEvent(_currentUserId!, event);
      _events.add(created);
    } else {
      _events.add(event);
    }
    notifyListeners();
  }

  Future<bool> updateEvent(EventItem updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index == -1) return false;

    if (_currentUserId != null) {
      final updated = await _repository.updateEvent(
        _currentUserId!,
        updatedEvent,
      );
      _events[index] = updated;
    } else {
      _events[index] = updatedEvent;
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteEvent(String id) async {
    final initialCount = _events.length;
    if (_currentUserId != null) {
      await _repository.deleteEvent(_currentUserId!, id);
    }
    _events.removeWhere((e) => e.id == id);
    if (_events.length != initialCount) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Note Operations ---

  Future<void> addNote(NoteItem note) async {
    if (_currentUserId != null) {
      final created = await _repository.createNote(_currentUserId!, note);
      _notes.insert(0, created);
    } else {
      _notes.insert(0, note);
    }
    notifyListeners();
  }

  Future<bool> updateNote(NoteItem updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index == -1) return false;

    if (_currentUserId != null) {
      final updated = await _repository.updateNote(
        _currentUserId!,
        updatedNote,
      );
      _notes[index] = updated;
    } else {
      _notes[index] = updatedNote;
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteNote(String id) async {
    final initialCount = _notes.length;
    if (_currentUserId != null) {
      await _repository.deleteNote(_currentUserId!, id);
    }
    _notes.removeWhere((n) => n.id == id);
    if (_notes.length != initialCount) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Category Operations ---

  Future<void> addCategory(EventCategory category) async {
    if (_currentUserId != null) {
      final created = await _repository.createCategory(
        _currentUserId!,
        category,
      );
      _categories.add(created);
    } else {
      _categories.add(category);
    }
    notifyListeners();
  }

  // --- Reminder Operations ---

  Future<void> toggleReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = _reminders[index];
      final updated = item.copyWith(isDone: !item.isDone);
      if (_currentUserId != null) {
        await _repository.updateReminder(_currentUserId!, updated);
      }
      _reminders[index] = updated;
      notifyListeners();
    }
  }
}
