import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_item.dart';
import '../../models/note_item.dart';
import '../../models/reminder_item.dart';
import 'chronova_repository.dart';

/// PostgreSQL & Supabase data access layer for Chronova.
class SupabaseChronovaRepository implements ChronovaRepository {
  final SupabaseClient client;

  SupabaseChronovaRepository({SupabaseClient? client})
    : client = client ?? Supabase.instance.client;

  // --- Categories ---

  @override
  Future<List<EventCategory>> fetchCategories(String userId) async {
    final response = await client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((item) => EventCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventCategory> createCategory(
    String userId,
    EventCategory category,
  ) async {
    final response = await client
        .from('categories')
        .insert(category.toJson(userId: userId))
        .select()
        .single();

    return EventCategory.fromJson(response);
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await client
        .from('categories')
        .delete()
        .eq('id', categoryId)
        .eq('user_id', userId);
  }

  // --- Events ---

  @override
  Future<List<EventItem>> fetchEvents(String userId) async {
    final response = await client
        .from('events')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: true);

    return (response as List<dynamic>)
        .map((item) => EventItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventItem> createEvent(String userId, EventItem event) async {
    final response = await client
        .from('events')
        .insert(event.toJson(userId: userId))
        .select()
        .single();

    return EventItem.fromJson(response);
  }

  @override
  Future<EventItem> updateEvent(String userId, EventItem event) async {
    final response = await client
        .from('events')
        .update(event.toJson(userId: userId))
        .eq('id', event.id)
        .eq('user_id', userId)
        .select()
        .single();

    return EventItem.fromJson(response);
  }

  @override
  Future<void> deleteEvent(String userId, String eventId) async {
    await client
        .from('events')
        .delete()
        .eq('id', eventId)
        .eq('user_id', userId);
  }

  // --- Notes ---

  @override
  Future<List<NoteItem>> fetchNotes(String userId) async {
    final response = await client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NoteItem> createNote(String userId, NoteItem note) async {
    final response = await client
        .from('notes')
        .insert(note.toJson(userId: userId))
        .select()
        .single();

    return NoteItem.fromJson(response);
  }

  @override
  Future<NoteItem> updateNote(String userId, NoteItem note) async {
    final response = await client
        .from('notes')
        .update(note.toJson(userId: userId))
        .eq('id', note.id)
        .eq('user_id', userId)
        .select()
        .single();

    return NoteItem.fromJson(response);
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    await client.from('notes').delete().eq('id', noteId).eq('user_id', userId);
  }

  // --- Reminders ---

  @override
  Future<List<ReminderItem>> fetchReminders(String userId) async {
    final response = await client
        .from('reminders')
        .select()
        .eq('user_id', userId)
        .order('due_date_time', ascending: true);

    return (response as List<dynamic>)
        .map((item) => ReminderItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReminderItem> createReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    final response = await client
        .from('reminders')
        .insert(reminder.toJson(userId: userId))
        .select()
        .single();

    return ReminderItem.fromJson(response);
  }

  @override
  Future<ReminderItem> updateReminder(
    String userId,
    ReminderItem reminder,
  ) async {
    final response = await client
        .from('reminders')
        .update(reminder.toJson(userId: userId))
        .eq('id', reminder.id)
        .eq('user_id', userId)
        .select()
        .single();

    return ReminderItem.fromJson(response);
  }

  @override
  Future<void> deleteReminder(String userId, String reminderId) async {
    await client
        .from('reminders')
        .delete()
        .eq('id', reminderId)
        .eq('user_id', userId);
  }
}
