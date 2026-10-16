import 'dart:async';
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
import '../services/notification_service.dart';

/// Single source of truth for app state, backed by ChronovaRepository (Supabase or In-Memory).
/// Automatically notifies UI listeners on mutations and manages user session isolation.
class ChronovaDataStore extends ChangeNotifier {
  static final ChronovaDataStore _instance = ChronovaDataStore._internal();
  static ChronovaDataStore get instance => _instance;

  ChronovaRepository _repository;
  String? _currentUserId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _initializationError;

  ChronovaDataStore._internal() : _repository = InMemoryChronovaRepository() {
    _setupNotificationCallbacks();
    resetToSampleData();
  }

  void _setupNotificationCallbacks() {
    NotificationService.instance.onReminderDone = (id) {
      toggleReminder(id);
    };
    NotificationService.instance.onReminderSnoozed = (id, duration) {
      snoozeReminder(id, duration: duration);
    };
  }

  /// Active repository backing the store.
  ChronovaRepository get repository => _repository;

  /// Whether store is backed by the real Supabase cloud repository.
  bool get isUsingSupabase => _repository is SupabaseChronovaRepository;

  /// Holds any repository initialization error if Supabase setup failed.
  String? get initializationError => _initializationError;

  /// Records an initialization error explicitly (e.g. from main).
  void recordInitializationError(String error) {
    _initializationError = error;
    notifyListeners();
  }

  /// Injects a repository implementation (useful for tests or switching backends).
  void setRepository(ChronovaRepository repository) {
    _repository = repository;
  }

  /// Automatically configures repository according to Supabase availability.
  /// Does NOT silently fall back if Supabase is configured; records any error.
  void setupDefaultRepository() {
    if (SupabaseConfig.isConfigured) {
      try {
        _repository = SupabaseChronovaRepository();
        _initializationError = null;
      } catch (e) {
        _initializationError =
            'Failed to initialize Supabase client repository: $e';
        debugPrint(_initializationError);
        // Do not silently mask error as a normal in-memory fallback
      }
    } else {
      _repository = InMemoryChronovaRepository();
      _initializationError = null;
    }
  }

  /// Explicitly switches the app to Local Sample Mode (demo choice).
  void enableLocalSampleMode() {
    _repository = InMemoryChronovaRepository();
    resetToSampleData();
    unawaited(NotificationService.instance.syncReminders(_reminders));
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

    // Ensure we are using Supabase if configured
    if (SupabaseConfig.isConfigured &&
        _repository is! SupabaseChronovaRepository) {
      setupDefaultRepository();
    }

    try {
      final fetchedCategories = await _repository.fetchCategories(userId);
      final fetchedEvents = await _repository.fetchEvents(userId);
      final fetchedNotes = await _repository.fetchNotes(userId);
      final fetchedReminders = await _repository.fetchReminders(userId);

      _categories.clear();
      if (fetchedCategories.isEmpty) {
        // Provide baseline categories in memory only for UI display.
        // DO NOT automatically write sample records to the cloud database.
        _categories.addAll(SampleData.categories);
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
      unawaited(NotificationService.instance.syncReminders(_reminders));
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Completely wipes in-memory cache upon user logout so records never bleed across sessions.
  void clearUserData() {
    unawaited(NotificationService.instance.cancelAll());
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
    try {
      if (_currentUserId != null) {
        final created = await _repository.createEvent(_currentUserId!, event);
        _events.insert(0, created);
      } else {
        _events.insert(0, event);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error saving event: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateEvent(EventItem updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index == -1) return false;

    try {
      if (_currentUserId != null) {
        final updated = await _repository.updateEvent(
          _currentUserId!,
          updatedEvent,
        );
        _events[index] = updated;
      } else {
        _events[index] = updatedEvent;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating event: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteEvent(String id) async {
    final initialCount = _events.length;
    try {
      if (_currentUserId != null) {
        await _repository.deleteEvent(_currentUserId!, id);
      }
      _events.removeWhere((e) => e.id == id);
      if (_events.length != initialCount) {
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting event: $e';
      notifyListeners();
      rethrow;
    }
  }

  // --- Note Operations ---

  Future<void> addNote(NoteItem note) async {
    try {
      if (_currentUserId != null) {
        final created = await _repository.createNote(_currentUserId!, note);
        _notes.insert(0, created);
      } else {
        _notes.insert(0, note);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error saving note: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateNote(NoteItem updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index == -1) return false;

    try {
      if (_currentUserId != null) {
        final updated = await _repository.updateNote(
          _currentUserId!,
          updatedNote,
        );
        _notes[index] = updated;
      } else {
        _notes[index] = updatedNote;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating note: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteNote(String id) async {
    final initialCount = _notes.length;
    try {
      if (_currentUserId != null) {
        await _repository.deleteNote(_currentUserId!, id);
      }
      _notes.removeWhere((n) => n.id == id);
      if (_notes.length != initialCount) {
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting note: $e';
      notifyListeners();
      rethrow;
    }
  }

  // --- Category Operations ---

  Future<void> addCategory(EventCategory category) async {
    try {
      if (_currentUserId != null) {
        final created = await _repository.createCategory(
          _currentUserId!,
          category,
        );
        _categories.add(created);
      } else {
        _categories.add(category);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error creating category: $e';
      notifyListeners();
      rethrow;
    }
  }

  // --- Reminder Operations ---

  Future<void> addReminder(ReminderItem reminder) async {
    try {
      if (_currentUserId != null) {
        final created = await _repository.createReminder(
          _currentUserId!,
          reminder,
        );
        _reminders.insert(0, created);
        unawaited(NotificationService.instance.scheduleReminder(created));
      } else {
        _reminders.insert(0, reminder);
        unawaited(NotificationService.instance.scheduleReminder(reminder));
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error saving reminder: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateReminder(ReminderItem updatedReminder) async {
    final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index == -1) return false;

    try {
      if (_currentUserId != null) {
        final updated = await _repository.updateReminder(
          _currentUserId!,
          updatedReminder,
        );
        _reminders[index] = updated;
        unawaited(NotificationService.instance.scheduleReminder(updated));
      } else {
        _reminders[index] = updatedReminder;
        unawaited(
          NotificationService.instance.scheduleReminder(updatedReminder),
        );
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating reminder: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteReminder(String id) async {
    final initialCount = _reminders.length;
    try {
      if (_currentUserId != null) {
        await _repository.deleteReminder(_currentUserId!, id);
      }
      _reminders.removeWhere((r) => r.id == id);
      unawaited(NotificationService.instance.cancelReminder(id));
      if (_reminders.length != initialCount) {
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting reminder: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = _reminders[index];
      final updated = item.copyWith(isDone: !item.isDone);
      try {
        if (_currentUserId != null) {
          await _repository.updateReminder(_currentUserId!, updated);
        }
        _reminders[index] = updated;
        if (updated.isDone) {
          unawaited(NotificationService.instance.cancelReminder(id));
        } else {
          unawaited(NotificationService.instance.scheduleReminder(updated));
        }
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Error updating reminder: $e';
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> snoozeReminder(String id, {Duration? duration}) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = _reminders[index];
      final snoozed = NotificationService.instance.calculateSnoozedReminder(
        item,
        customDuration: duration,
      );
      try {
        if (_currentUserId != null) {
          await _repository.updateReminder(_currentUserId!, snoozed);
        }
        _reminders[index] = snoozed;
        unawaited(NotificationService.instance.scheduleReminder(snoozed));
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Error snoozing reminder: $e';
        notifyListeners();
        rethrow;
      }
    }
  }
}
