import '../../models/event_item.dart';
import '../../models/note_item.dart';
import '../../models/reminder_item.dart';
import '../sample_data.dart';
import 'chronova_repository.dart';

/// In-memory repository implementation with per-user data isolation.
/// Accurately simulates PostgreSQL Row Level Security (RLS) for testing and offline development.
class InMemoryChronovaRepository implements ChronovaRepository {
  final Map<String, List<EventCategory>> _userCategories = {};
  final Map<String, List<EventItem>> _userEvents = {};
  final Map<String, List<NoteItem>> _userNotes = {};
  final Map<String, List<ReminderItem>> _userReminders = {};

  final bool _loadSample;

  InMemoryChronovaRepository({bool loadSample = false})
    : _loadSample = loadSample;

  List<EventCategory> _getCategories(String userId) {
    return _userCategories.putIfAbsent(userId, () {
      return List<EventCategory>.from(SampleData.categories);
    });
  }

  List<EventItem> _getEvents(String userId) {
    return _userEvents.putIfAbsent(userId, () {
      return _loadSample ? SampleData.getSampleEvents() : [];
    });
  }

  List<NoteItem> _getNotes(String userId) {
    return _userNotes.putIfAbsent(userId, () {
      return _loadSample ? SampleData.getSampleNotes() : [];
    });
  }

  List<ReminderItem> _getReminders(String userId) {
    return _userReminders.putIfAbsent(userId, () {
      return _loadSample ? SampleData.getSampleReminders() : [];
    });
  }

  @override
  Future<List<EventCategory>> fetchCategories(String userId) async {
    return List.from(_getCategories(userId));
  }

  @override
  Future<EventCategory> createCategory(
    String userId,
    EventCategory category,
  ) async {
    final list = _getCategories(userId);
    list.add(category);
    return category;
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    final list = _getCategories(userId);
    list.removeWhere((c) => c.id == categoryId);
  }

  @override
  Future<List<EventItem>> fetchEvents(String userId) async {
    return List.from(_getEvents(userId));
  }

  @override
  Future<EventItem> createEvent(String userId, EventItem event) async {
    final list = _getEvents(userId);
    list.add(event);
    return event;
  }

  @override
  Future<EventItem> updateEvent(String userId, EventItem event) async {
    final list = _getEvents(userId);
    final index = list.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      list[index] = event;
    } else {
      list.add(event);
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String userId, String eventId) async {
    final list = _getEvents(userId);
    list.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<NoteItem>> fetchNotes(String userId) async {
    return List.from(_getNotes(userId));
  }

  @override
  Future<NoteItem> createNote(String userId, NoteItem note) async {
    final list = _getNotes(userId);
    list.insert(0, note);
    return note;
  }

  @override
  Future<NoteItem> updateNote(String userId, NoteItem note) async {
    final list = _getNotes(userId);
    final index = list.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      list[index] = note;
    } else {
      list.insert(0, note);
    }
    return note;
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    final list = _getNotes(userId);
    list.removeWhere((n) => n.id == noteId);
  }

  @override
  Future<List<ReminderItem>> fetchReminders(String userId) async {
    return List.from(_getReminders(userId));
  }

  @override
  Future<ReminderItem> createReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    final list = _getReminders(userId);
    list.add(reminder);
    return reminder;
  }

  @override
  Future<ReminderItem> updateReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    final list = _getReminders(userId);
    final index = list.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      list[index] = reminder;
    } else {
      list.add(reminder);
    }
    return reminder;
  }

  @override
  Future<void> deleteReminder(String userId, String reminderId) async {
    final list = _getReminders(userId);
    list.removeWhere((r) => r.id == reminderId);
  }
}
