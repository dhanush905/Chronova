import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/sample_data.dart';
import '../../models/event_item.dart';
import '../../models/reminder_item.dart';
import '../../models/note_item.dart';
import '../../models/file_item.dart';
import '../../widgets/custom_card.dart';
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
  late List<EventItem> _events;
  late List<ReminderItem> _reminders;
  late List<NoteItem> _notes;
  late List<FileItem> _files;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    _events = SampleData.getSampleEvents();
    _reminders = SampleData.getSampleReminders();
    _notes = SampleData.getSampleNotes();
    _files = SampleData.getSampleFiles();
  }

  void _toggleReminder(String reminderId) {
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        final current = _reminders[index];
        _reminders[index] = current.copyWith(isDone: !current.isDone);
      }
    });
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar / Greeting
                _buildHeader(dateFormatted),
                const SizedBox(height: 20),

                // Quick Overview Metrics
                _buildMetricsGrid(),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActionsRow(),
                const SizedBox(height: 28),

                // Today's Schedule Section
                SectionHeader(
                  title: "Today's Schedule",
                  subtitle: '${_events.length} planned activities',
                  actionLabel: 'Calendar',
                  onAction: () => widget.onNavigateToTab?.call(1),
                ),
                const SizedBox(height: 8),
                _buildTodaySchedule(),
                const SizedBox(height: 28),

                // Priority Reminders Section
                SectionHeader(
                  title: 'Priority Reminders',
                  subtitle: 'Upcoming notifications & alerts',
                  actionLabel: 'View All',
                  onAction: () => widget.onNavigateToTab?.call(1),
                ),
                const SizedBox(height: 8),
                _buildRemindersList(),
                const SizedBox(height: 28),

                // Recent Notes & Synced Files
                SectionHeader(
                  title: 'Recent Notes & Documents',
                  subtitle: 'Quick access to your captured knowledge',
                  actionLabel: 'Files Hub',
                  onAction: () => widget.onNavigateToTab?.call(2),
                ),
                const SizedBox(height: 8),
                _buildRecentNotesAndFiles(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildMetricsGrid() {
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
                count: '${_events.length}',
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryContainer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Active Reminders',
                count: '${_reminders.where((r) => !r.isDone).length}',
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.catViolet,
                iconBg: AppColors.catViolet.withAlpha(25),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Organized Notes',
                count: '${_notes.length}',
                icon: Icons.note_alt_rounded,
                iconColor: AppColors.catEmerald,
                iconBg: AppColors.catEmerald.withAlpha(25),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'Imported Files',
                count: '${_files.length}',
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
            onTap: () {
              widget.onNavigateToTab?.call(1);
            },
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
            onTap: () {
              widget.onNavigateToTab?.call(2);
            },
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

  Widget _buildTodaySchedule() {
    if (_events.isEmpty) {
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
      children: _events.take(3).map((event) {
        final timeFormat = DateFormat('h:mm a');
        final timeStr =
            '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
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
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRemindersList() {
    return Column(
      children: _reminders.map((reminder) {
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

  Widget _buildRecentNotesAndFiles() {
    return Column(
      children: [
        // Note snippet card
        if (_notes.isNotEmpty)
          CustomCard(
            onTap: () => widget.onNavigateToTab?.call(2),
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
                              _notes.first.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: _notes.first.folder,
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _notes.first.content,
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
        if (_files.isNotEmpty)
          CustomCard(
            onTap: () => widget.onNavigateToTab?.call(2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _files.first.fileType.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _files.first.fileType.icon,
                    color: _files.first.fileType.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _files.first.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_files.first.fileType.label} • ${_files.first.sizeString} • ${_files.first.linkedEventsCount} linked events',
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
