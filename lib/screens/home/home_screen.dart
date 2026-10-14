import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/chronova_data_store.dart';
import '../../models/event_item.dart';
import '../../models/reminder_item.dart';
import '../../models/note_item.dart';
import '../../models/file_item.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/event_editor_sheet.dart';
import '../../widgets/note_editor_sheet.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Chronova Home Dashboard screen.
class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _toggleReminder(String reminderId) {
    ChronovaDataStore.instance.toggleReminder(reminderId);
  }

  Future<void> _addNewEvent() async {
    final newEvent = await EventEditorSheet.show(context);
    if (newEvent != null && mounted) {
      ChronovaDataStore.instance.addEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event scheduled successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _editEvent(EventItem event) async {
    final updatedEvent = await EventEditorSheet.show(
      context,
      initialEvent: event,
    );
    if (updatedEvent != null && mounted) {
      ChronovaDataStore.instance.updateEvent(updatedEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _confirmDeleteEvent(EventItem event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Event',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ChronovaDataStore.instance.deleteEvent(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addNewNote() async {
    final newNote = await NoteEditorSheet.show(context);
    if (newNote != null && mounted) {
      ChronovaDataStore.instance.addNote(newNote);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note created successfully')),
      );
    }
  }

  Future<void> _editNote(NoteItem note) async {
    final updatedNote = await NoteEditorSheet.show(context, initialNote: note);
    if (updatedNote != null && mounted) {
      ChronovaDataStore.instance.updateNote(updatedNote);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
    }
  }

  void _showQuickActionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatted = DateFormat('EEEE, MMMM d, y').format(now);

    return ListenableBuilder(
      listenable: ChronovaDataStore.instance,
      builder: (context, _) {
        final store = ChronovaDataStore.instance;
        final events = store.events;
        final reminders = store.reminders;
        final notes = store.notes;
        final files = store.files;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar / Greeting
                    _buildHeader(dateFormatted),
                    const SizedBox(height: 20),

                    // Quick Overview Metrics
                    _buildMetricsGrid(
                      eventsCount: events.length,
                      activeRemindersCount: reminders
                          .where((r) => !r.isDone)
                          .length,
                      notesCount: notes.length,
                      filesCount: files.length,
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActionsRow(),
                    const SizedBox(height: 28),

                    // Today's Schedule Section
                    SectionHeader(
                      title: "Today's Schedule",
                      subtitle: '${events.length} planned activities',
                      actionLabel: 'Calendar',
                      onAction: () => widget.onNavigateToTab?.call(1),
                    ),
                    const SizedBox(height: 8),
                    _buildTodaySchedule(events),
                    const SizedBox(height: 28),

                    // Priority Reminders Section
                    SectionHeader(
                      title: 'Priority Reminders',
                      subtitle: 'Upcoming notifications & alerts',
                      actionLabel: 'View All',
                      onAction: () => widget.onNavigateToTab?.call(1),
                    ),
                    const SizedBox(height: 8),
                    _buildRemindersList(reminders),
                    const SizedBox(height: 28),

                    // Recent Notes & Synced Files
                    SectionHeader(
                      title: 'Recent Notes & Documents',
                      subtitle: 'Quick access to your captured knowledge',
                      actionLabel: 'Files Hub',
                      onAction: () => widget.onNavigateToTab?.call(2),
                    ),
                    const SizedBox(height: 8),
                    _buildRecentNotesAndFiles(notes, files),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String dateString) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateString.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome to Chronova',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All reminder notifications are active.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid({
    required int eventsCount,
    required int activeRemindersCount,
    required int notesCount,
    required int filesCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Upcoming Events',
                count: '$eventsCount',
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryContainer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Active Reminders',
                count: '$activeRemindersCount',
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.catViolet,
                iconBg: AppColors.catViolet.withAlpha(25),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Organized Notes',
                count: '$notesCount',
                icon: Icons.note_alt_rounded,
                iconColor: AppColors.catEmerald,
                iconBg: AppColors.catEmerald.withAlpha(25),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Imported Files',
                count: '$filesCount',
                icon: Icons.folder_shared_rounded,
                iconColor: AppColors.catSky,
                iconBg: AppColors.catSky.withAlpha(25),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionButton(
            label: 'Add Event',
            icon: Icons.add_rounded,
            isPrimary: true,
            onTap: _addNewEvent,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            label: 'New Reminder',
            icon: Icons.alarm_add_rounded,
            onTap: () {
              _showQuickActionDialog(
                'New Reminder',
                'Create a reminder with custom alarm sound and snooze time.',
              );
            },
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            label: 'New Note',
            icon: Icons.edit_note_rounded,
            onTap: _addNewNote,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            label: 'Import Document',
            icon: Icons.file_upload_outlined,
            onTap: () {
              widget.onNavigateToTab?.call(2);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.primary.withAlpha(50)
                  : Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(List<EventItem> events) {
    if (events.isEmpty) {
      return const CustomCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No events scheduled for today.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Column(
      children: events.take(3).map((event) {
        final timeFormat = DateFormat('h:mm a');
        final timeStr =
            '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _editEvent(event),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category color accent bar
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: event.category.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: event.category.name,
                            color: event.category.color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (event.location.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                event.location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _editEvent(event);
                    } else if (val == 'delete') {
                      _confirmDeleteEvent(event);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRemindersList(List<ReminderItem> reminders) {
    return Column(
      children: reminders.map((reminder) {
        final timeFormat = DateFormat('h:mm a, MMM d');
        final formattedDue = timeFormat.format(reminder.dueDateTime);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Checkbox for completion
                InkWell(
                  onTap: () => _toggleReminder(reminder.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: reminder.isDone
                          ? AppColors.success
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: reminder.isDone
                            ? AppColors.success
                            : AppColors.textTertiary,
                        width: 1.8,
                      ),
                    ),
                    child: reminder.isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: reminder.isDone
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          decoration: reminder.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (reminder.hasAlarm) ...[
                            const Icon(
                              Icons.alarm_on_rounded,
                              size: 13,
                              color: AppColors.catViolet,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            formattedDue,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: reminder.categoryName,
                            color: reminder.categoryColor,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentNotesAndFiles(List<NoteItem> notes, List<FileItem> files) {
    return Column(
      children: [
        // Note snippet card
        if (notes.isNotEmpty)
          CustomCard(
            onTap: () => _editNote(notes.first),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notes.first.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: notes.first.folder,
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notes.first.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        // File snippet card
        if (files.isNotEmpty)
          CustomCard(
            onTap: () => widget.onNavigateToTab?.call(2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: files.first.fileType.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    files.first.fileType.icon,
                    color: files.first.fileType.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        files.first.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${files.first.fileType.label} • ${files.first.sizeString} • ${files.first.linkedEventsCount} linked events',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
