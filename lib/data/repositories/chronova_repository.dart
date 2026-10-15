import '../../models/event_item.dart';
import '../../models/note_item.dart';
import '../../models/reminder_item.dart';

/// Abstract data access contract for Chronova backend persistence.
abstract class ChronovaRepository {
  // Categories
  Future<List<EventCategory>> fetchCategories(String userId);
  Future<EventCategory> createCategory(String userId, EventCategory category);
  Future<void> deleteCategory(String userId, String categoryId);

  // Events
  Future<List<EventItem>> fetchEvents(String userId);
  Future<EventItem> createEvent(String userId, EventItem event);
  Future<EventItem> updateEvent(String userId, EventItem event);
  Future<void> deleteEvent(String userId, String eventId);

  // Notes
  Future<List<NoteItem>> fetchNotes(String userId);
  Future<NoteItem> createNote(String userId, NoteItem note);
  Future<NoteItem> updateNote(String userId, NoteItem note);
  Future<void> deleteNote(String userId, String noteId);

  // Reminders
  Future<List<ReminderItem>> fetchReminders(String userId);
  Future<ReminderItem> createReminder(String userId, ReminderItem reminder);
  Future<ReminderItem> updateReminder(String userId, ReminderItem reminder);
  Future<void> deleteReminder(String userId, String reminderId);
}
