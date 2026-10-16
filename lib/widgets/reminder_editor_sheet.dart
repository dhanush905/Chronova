import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/chronova_data_store.dart';
import '../models/event_item.dart';
import '../models/reminder_item.dart';

/// Modal bottom sheet dialog for creating and editing reminders.
/// Follows Chronova's Material 3 styling, rounded inputs, and category selection.
class ReminderEditorSheet extends StatefulWidget {
  final ReminderItem? initialReminder;
  final ValueChanged<ReminderItem>? onSave;

  const ReminderEditorSheet({super.key, this.initialReminder, this.onSave});

  /// Helper static method to display the sheet from any screen.
  static Future<ReminderItem?> show(
    BuildContext context, {
    ReminderItem? initialReminder,
  }) {
    return showModalBottomSheet<ReminderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          ReminderEditorSheet(initialReminder: initialReminder),
    );
  }

  @override
  State<ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<ReminderEditorSheet> {
  late final TextEditingController _titleController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late EventCategory _selectedCategory;
  late bool _hasAlarm;

  String? _titleError;

  bool get _isEditing => widget.initialReminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.initialReminder;
    final storeCategories = ChronovaDataStore.instance.categories;

    _titleController = TextEditingController(text: reminder?.title ?? '');

    if (reminder != null) {
      _selectedDate = DateTime(
        reminder.dueDateTime.year,
        reminder.dueDateTime.month,
        reminder.dueDateTime.day,
      );
      _selectedTime = TimeOfDay.fromDateTime(reminder.dueDateTime);
      _selectedCategory = storeCategories.firstWhere(
        (c) => c.name.toLowerCase() == reminder.categoryName.toLowerCase(),
        orElse: () => storeCategories.isNotEmpty
            ? storeCategories.first
            : const EventCategory(
                id: 'cat-general',
                name: 'General',
                color: AppColors.primary,
              ),
      );
      _hasAlarm = reminder.hasAlarm;
    } else {
      // Default to 1 hour from now rounded to next 15 minutes
      final now = DateTime.now().add(const Duration(hours: 1));
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedTime = TimeOfDay(
        hour: now.hour,
        minute: (now.minute ~/ 15) * 15,
      );
      _selectedCategory = storeCategories.isNotEmpty
          ? storeCategories.first
          : const EventCategory(
              id: 'cat-general',
              name: 'General',
              color: AppColors.primary,
            );
      _hasAlarm = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Please enter a reminder title';
      });
      return;
    }

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final id =
        widget.initialReminder?.id ??
        'rem-${DateTime.now().millisecondsSinceEpoch}';

    final result = ReminderItem(
      id: id,
      title: title,
      dueDateTime: dueDateTime,
      categoryName: _selectedCategory.name,
      categoryColor: _selectedCategory.color,
      isDone: widget.initialReminder?.isDone ?? false,
      hasAlarm: _hasAlarm,
      snoozeCount: widget.initialReminder?.snoozeCount ?? 0,
    );

    widget.onSave?.call(result);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final categories = ChronovaDataStore.instance.categories;
    final dateFormat = DateFormat('EEE, MMM d, y');

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Reminder' : 'New Reminder',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  hintText: 'e.g. Review Q3 architectural audit',
                  errorText: _titleError,
                  prefixIcon: const Icon(
                    Icons.alarm_rounded,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (_) {
                  if (_titleError != null) {
                    setState(() {
                      _titleError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date & Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateFormat.format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Alarm Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _hasAlarm
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_outlined,
                            color: _hasAlarm
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Trigger Audio Alarm',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Sound alarm with snooze notification drawer',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: _hasAlarm,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _hasAlarm = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory.id == cat.id;
                  return ChoiceChip(
                    avatar: CircleAvatar(backgroundColor: cat.color, radius: 5),
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: cat.color.withAlpha(45),
                    backgroundColor: AppColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected ? cat.color : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? cat.color : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _save,
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Create Reminder',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
