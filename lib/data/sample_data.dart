import '../models/event_item.dart';
import '../models/reminder_item.dart';
import '../models/note_item.dart';
import '../models/file_item.dart';
import '../core/theme/app_colors.dart';

/// In-memory sample data repository for Phase 1.
/// Demonstrates customizable categories, calendar events, reminders, notes, and files.
class SampleData {
  // Customizable categories (not hardcoded fixed sets)
  static final List<EventCategory> categories = [
    const EventCategory(
      id: 'cat-1',
      name: 'Product Design',
      color: AppColors.catViolet,
    ),
    const EventCategory(
      id: 'cat-2',
      name: 'Engineering',
      color: AppColors.primary,
    ),
    const EventCategory(
      id: 'cat-3',
      name: 'Strategy & Ops',
      color: AppColors.catSky,
    ),
    const EventCategory(
      id: 'cat-4',
      name: 'Health & Wellness',
      color: AppColors.catEmerald,
    ),
    const EventCategory(
      id: 'cat-5',
      name: 'Personal',
      color: AppColors.catAmber,
    ),
  ];

  static List<EventItem> getSampleEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      EventItem(
        id: 'evt-1',
        title: 'Design System & UI Review',
        description:
            'Review updated Chronova theme tokens and card components.',
        startTime: today.add(const Duration(hours: 10, minutes: 0)),
        endTime: today.add(const Duration(hours: 11, minutes: 0)),
        category: categories[0], // Product Design
        location: 'Virtual Room A',
      ),
      EventItem(
        id: 'evt-2',
        title: 'Flutter Architecture Sync',
        description: 'Review navigation shell and multi-device state plans.',
        startTime: today.add(const Duration(hours: 13, minutes: 30)),
        endTime: today.add(const Duration(hours: 14, minutes: 30)),
        category: categories[1], // Engineering
        location: 'Conference Room 3B',
      ),
      EventItem(
        id: 'evt-3',
        title: 'Team Product Alignment',
        description: 'Q4 milestones and cross-platform release schedule.',
        startTime: today.add(const Duration(hours: 16, minutes: 0)),
        endTime: today.add(const Duration(hours: 17, minutes: 0)),
        category: categories[2], // Strategy
        location: 'Main Hall',
      ),
      EventItem(
        id: 'evt-4',
        title: 'Evening Run & Recovery',
        description: '5km outdoor run followed by stretching.',
        startTime: today.add(const Duration(days: 1, hours: 7, minutes: 30)),
        endTime: today.add(const Duration(days: 1, hours: 8, minutes: 30)),
        category: categories[3], // Health
        location: 'Riverside Park',
      ),
      EventItem(
        id: 'evt-5',
        title: 'Family Dinner & Catch-up',
        description: 'Weekend dinner reservation.',
        startTime: today.add(const Duration(days: 2, hours: 19, minutes: 0)),
        endTime: today.add(const Duration(days: 2, hours: 21, minutes: 0)),
        category: categories[4], // Personal
        location: 'Bistro 42',
      ),
    ];
  }

  static List<ReminderItem> getSampleReminders() {
    final now = DateTime.now();
    return [
      ReminderItem(
        id: 'rem-1',
        title: 'Prepare agenda for Architecture Sync',
        dueDateTime: now.add(const Duration(hours: 2)),
        categoryName: 'Engineering',
        categoryColor: AppColors.primary,
        hasAlarm: true,
      ),
      ReminderItem(
        id: 'rem-2',
        title: 'Submit weekly milestone update',
        dueDateTime: now.add(const Duration(hours: 5)),
        categoryName: 'Strategy',
        categoryColor: AppColors.catSky,
        hasAlarm: true,
      ),
      ReminderItem(
        id: 'rem-3',
        title: 'Hydration & Posture Break',
        dueDateTime: now.add(const Duration(minutes: 45)),
        categoryName: 'Health',
        categoryColor: AppColors.catEmerald,
        hasAlarm: false,
      ),
      ReminderItem(
        id: 'rem-4',
        title: 'Review exported CSV event schedule',
        dueDateTime: now.add(const Duration(days: 1, hours: 3)),
        categoryName: 'Product Design',
        categoryColor: AppColors.catViolet,
        hasAlarm: true,
      ),
    ];
  }

  static List<NoteItem> getSampleNotes() {
    final now = DateTime.now();
    return [
      NoteItem(
        id: 'note-1',
        title: 'Chronova Phase 1 UI Blueprint',
        content:
            'Light theme (#F4F7FE) with Indigo (#4F46E5) primary accent. Responsive cards, unified navigation shell, dynamic categories without hardcoding.',
        folder: 'Work',
        updatedAt: now.subtract(const Duration(hours: 3)),
        attachmentCount: 2,
        isPinned: true,
      ),
      NoteItem(
        id: 'note-2',
        title: 'Event Importer Specifications',
        content:
            'Support CSV, PDF schedule parsing, spreadsheet tables. Always show user preview dialog before importing to the calendar.',
        folder: 'Architecture',
        updatedAt: now.subtract(const Duration(days: 1)),
        attachmentCount: 1,
        isPinned: true,
      ),
      NoteItem(
        id: 'note-3',
        title: 'Notification Strategy & Sound Engine',
        content:
            'Android notification channel setup with custom alarm audio, snooze intervals (5m, 10m, 15m), and quick actions directly in drawer.',
        folder: 'Architecture',
        updatedAt: now.subtract(const Duration(days: 2)),
        attachmentCount: 0,
      ),
      NoteItem(
        id: 'note-4',
        title: 'Weekly Book Recommendations',
        content:
            'Deep Work by Cal Newport, Atomic Habits by James Clear, and The Design of Everyday Things.',
        folder: 'Personal',
        updatedAt: now.subtract(const Duration(days: 4)),
        attachmentCount: 0,
      ),
    ];
  }

  static List<FileItem> getSampleFiles() {
    final now = DateTime.now();
    return [
      FileItem(
        id: 'file-1',
        name: 'Sprint_Schedule_2026.csv',
        sizeString: '42 KB',
        fileType: FileTypeEnum.csv,
        uploadedAt: now.subtract(const Duration(hours: 6)),
        linkedEventsCount: 8,
        previewSnippet:
            'Date, Time, Event, Category\n2026-10-15, 10:00, Standup, Eng',
      ),
      FileItem(
        id: 'file-2',
        name: 'Chronova_App_Specification.pdf',
        sizeString: '2.4 MB',
        fileType: FileTypeEnum.pdf,
        uploadedAt: now.subtract(const Duration(days: 1)),
        linkedEventsCount: 3,
        previewSnippet:
            'Chronova: Cross-platform Calendar & Productivity Specification',
      ),
      FileItem(
        id: 'file-3',
        name: 'Event_Roster_Q4.xlsx',
        sizeString: '180 KB',
        fileType: FileTypeEnum.spreadsheet,
        uploadedAt: now.subtract(const Duration(days: 3)),
        linkedEventsCount: 14,
      ),
      FileItem(
        id: 'file-4',
        name: 'Dashboard_Mockup_V1.png',
        sizeString: '1.1 MB',
        fileType: FileTypeEnum.image,
        uploadedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
